#!/usr/bin/env python

"""
ld_entitlements.py -- Bulk update of LiveDesign groups and entitlements
Copyright (C) 2013 Schrodinger, Inc. All rights reserved.

Syntax:
    ld_entitlements.py config.json import_file.json
"""

import datetime
import json
import optparse
import os
import pprint
import requests
import sys

API = '/api/'


def parse_options(argv):
    parser = optparse.OptionParser(usage="%prog [--dry-run] <config.json> <import.json>")

    parser.add_option(
        '-n', '--dry-run',
        action='store_true',
        dest='dry_run',
        default=False,
        help='Print a list of actions to execute but do not actually run them')

    opts, args = parser.parse_args(argv)

    if len(args) < 2:
        parser.error("Provide an action and a params.json file.")

    return opts, args


def identity(x):
    """ A coercion function that does no coercing. """
    return x


def accumulate_mapping(data, key_key, value_key, key_coerce=identity, value_coerce=identity):
    """
    Turns a relation like this:
    [{key_key: '1', value_key: '2'}]
    Into this:
    {'1': '2'}
    If the same key_key value is mentioned twice, only the last value is taken.
    """
    return dict([(key_coerce(item[key_key]), value_coerce(item[value_key]))
                for item in data])


def accumulate_m2m_mapping(obj, container_key, item_key, container_coerce=identity, item_coerce=identity):
    """
    Turns a relation like this:
    [{container_key: 'X', item_key: 1}, {container_key: 'X', item_key: 2}]
    Into this:
    {'X': [1,2]}
    """
    ret = {}
    for item in obj:
        container_id = container_coerce(item[container_key])
        item_id = item_coerce(item[item_key])
        if container_id in ret:
            ret[container_id].append(item_id)
        else:
            ret[container_id] = [item_id]
    return ret


def permission_object_map(data, perm_key, user_key, id_key, perm_coerce=identity, user_coerce=identity, id_coerce=int):
    """
    Turns a relation like this:
    [{id_key: '1', perm_key: '2', user_key: '3'}]
    Into this:
    {('2','3'): '1'}
    If the same (perm_key, user_key) tuple appear twice, only the last instance
    will be taken.
    """
    return dict([((int(item[perm_key]), int(item[user_key])), int(item[id_key])) for item in data])


def reverse_mapping(m):
    """
    Reverse a mapping (ignoring duplicate keys)
    """
    return dict((v, k) for k, v in m.iteritems())


def retrieve_raw_model(config, session):
    """
    Retrieves a snapshot of the LiveDesign authorization model.
    """
    get_targets = {
        'users': 'users',
        'projects': 'projects',
        'groups': 'groups',
        'groups/membership': 'memberships',
        'permissions': 'permissions',
    }

    ret = {}
    for endpoint, dest in get_targets.iteritems():
        url = config['ld_url'] + API + endpoint
        response = session.get(url)
        response.raise_for_status()
        ret[dest] = json.loads(response.content)

    return ret


def crunch_model(raw_model):
    users = accumulate_mapping(raw_model['users'], 'id', 'username', int)
    projects = accumulate_mapping(raw_model['projects'], 'id', 'alternate_id', int)

    # Assert that no two groups are named the same way
    # The data model does not enforce this but we do.
    all_names = [group['name'] for group in raw_model['groups']]
    assert len(all_names) == len(set(all_names))
    groups = accumulate_mapping(raw_model['groups'], 'id', 'name', int)


    memberships = accumulate_m2m_mapping(raw_model['memberships'], 'group_id', 'user_id', int, int)
    membership_ids = permission_object_map(raw_model['memberships'], 'group_id', 'user_id', 'id', int, int, int)

    permissions = accumulate_m2m_mapping(raw_model['permissions'], 'project_id', 'group_id', int, int)
    permission_ids = permission_object_map(raw_model['permissions'], 'project_id', 'group_id', 'id', int, int, int)

    crunched_model = {
        'users': users,
        'groups': groups,
        'projects': projects,
        'memberships': memberships,
        'membership_ids': membership_ids,
        'permissions': permissions,
        'permission_ids': permission_ids,
    }

    return crunched_model


def resolve_project_selector(model, model_projects_by_name, import_project):
    if 'id' in import_project:
        if import_project['id'] not in model['projects']:
            raise ValueError('Project with ID %d not in model' % import_project['id'])
        return [int(import_project['id'])]
    elif 'alias' in import_project:
        predicate = None
        pattern = import_project['alias']
        if pattern[0] == '*':
            assert len(pattern) > 1
            pattern = pattern[1:]
            predicate = str.endswith
        elif pattern[-1] == '*':
            assert len(pattern) > 1
            pattern = pattern[:-1]
            predicate = str.startswith

        if predicate:
            ret = []
            # pattern has a beginning or end wildcard
            for pid, name in model['projects'].iteritems():
                if predicate(name, pattern):
                    ret.append(pid)
            if len(ret) > 0:
                return ret
            raise ValueError('Unresolved project selector: %s' % pattern)
        else:
            return model_projects_by_name[pattern]


def compute_changes(model, import_data):
    users_by_name = reverse_mapping(model['users'])
    groups_by_name = reverse_mapping(model['groups'])

    # Have to treat this specially since multiple projects might have same name
    projects_by_name = {}
    for id, name in model['projects'].iteritems():
        projects_by_name[name] = projects_by_name.get(name, [])
        projects_by_name[name].append(id)

    # First pass for creating new groups and members
    users_to_create = set()  # set of strings (usernames)
    groups_to_create = {}    # dict of strings (group names -> [members])
    memberships_to_create = set()         # set of (gid, uid) tuples
    memberships_to_create_by_name = set() # set of (gid, username) tuples
    memberships_to_remove = set()         # set of (gid, uid) tuples

    # Used in second pass for creating new group entitlements
    permissions_to_create = set()          # set of (pid, gid) tuples
    permissions_to_create_by_name = set()  # set of (pid, group name) tuples
    permissions_to_remove = set()          # set of (pid, gid) tuples

    for group, members in import_data['groups'].iteritems():
        # Check if the group already exists in the model.
        if group not in groups_by_name:
            assert group not in groups_to_create

            # We add the member names to groups_to_create, as we don't yet have
            # user IDs for the users that don't yet exist. The users are created
            # first, so by the time we process groups_to_create, we'll update
            # the in memory user model with the new user IDs.
            users_to_create.update([user for user in members if user not in users_by_name])
            groups_to_create[group] = members
            continue

        model_members = set()
        import_members = set()

        gid = groups_by_name[group]
        # Some groups may exist but not have any members.
        if gid in model['memberships']:
            model_members = set(model['memberships'][gid])

        # Look at the new list of members and figure out what to add.
        for username in members:
            uid = users_by_name.get(username)
            if uid:
                import_members.add(uid)
            else:
                users_to_create.add(username)
                memberships_to_create_by_name.add((gid, username))

        to_add = import_members - model_members
        to_remove = model_members - import_members

        # Locate the membership object IDs for each membership we need to remove
        memberships_to_remove.update([(gid, uid) for uid in to_remove])
        memberships_to_create.update([(gid, uid) for uid in to_add])

    # Now process permissions on projects
    selected_projects = set()
    for project in import_data['projects']:
        # Validate import data
        if 'groups' not in project:
            raise ValueError('Missing "groups" member in JSON')
        if ('alias' not in project and 'id' not in project) or \
           ('alias' in project and 'id' in project):
            raise ValueError('Identify a project by one of "id" or "alias"')

        pids = resolve_project_selector(model, projects_by_name, project)
        for pid in pids:
            model_groups = set()
            import_groups = set()

            if pid in selected_projects:
                raise RuntimeError('The same project ID is selected twice: %d' % pid)
            selected_projects.add(pid)

            # Again, a project may exist but may not be entitled to anyone
            # as of yet.
            if pid in model['permissions']:
                model_groups.update(model['permissions'][pid])

            for group in project['groups']:
                if group not in groups_by_name:
                    if group not in groups_to_create:
                        raise ValueError('Group does not exist in model and is not to be created: %s' % group)
                    permissions_to_create_by_name.add((pid, group))
                else:
                    import_groups.add(groups_by_name[group])

            to_add = import_groups - model_groups
            to_remove = model_groups - import_groups

            permissions_to_remove.update([(pid, gid) for gid in to_remove])
            permissions_to_create.update([(pid, gid) for gid in to_add])

    ret = {
        'create_users': users_to_create,
        'create_groups': groups_to_create,
        'create_memberships': memberships_to_create,
        'create_memberships_named': memberships_to_create_by_name,
        'remove_memberships': memberships_to_remove,
        'create_permissions': permissions_to_create,
        'create_permissions_named': permissions_to_create_by_name,
        'remove_permissions': permissions_to_remove,
    }

    return ret


def apply_changes(config, session, model, changes):
    session.headers.update({'Content-Type': 'application/json'})
    url = config['ld_url'] + API + 'users'
    for user in changes['create_users']:
        data = { 'username': user }
        response = session.post(url, data=json.dumps(data))
        response.raise_for_status()
        # Get the UID and insert it into the in-memory model so it can be used
        # for entitlements.
        obj = json.loads(response.content)
        model['users'][obj['id']] = user

    # All users we'll need for this run are present, do the reverse mapping.
    users_by_name = reverse_mapping(model['users'])
    projects_by_name = reverse_mapping(model['projects'])

    url = config['ld_url'] + API + 'groups'
    for group, members in changes['create_groups'].iteritems():
        data = { 'name': group }
        response = session.post(url, data=json.dumps(data))
        response.raise_for_status()
        # Get the GID and insert it into the in-memory model so it can be used
        # for entitlements.
        obj = json.loads(response.content)
        model['groups'][obj['id']] = group
        for member in members:
            changes['create_memberships_named'].add((obj['id'], member))

    # All groups we'll need for this run are present, do the reverse mapping.
    groups_by_name = reverse_mapping(model['groups'])

    # Now converge named memberships with the normal ones.
    for gid, username in changes['create_memberships_named']:
        changes['create_memberships'].add((gid, users_by_name[username]))

    # Now process new memberships.
    url = config['ld_url'] + API + 'groups/membership'
    for gid, uid in changes['create_memberships']:
        data = { 'group_id': gid, 'user_id': uid }
        response = session.post(url, data=json.dumps(data))
        response.raise_for_status()

    # Now delete memberships.
    for item in changes['remove_memberships']:
        gid, uid = item
        data = { 'id': model['membership_ids'][item], 'group_id': gid, 'user_id': uid }
        response = session.delete(url, data=json.dumps(data))
        response.raise_for_status()

    # Now converge named permissions with the normal ones.
    for pid, group in changes['create_permissions_named']:
        changes['create_permissions'].add((pid, groups_by_name[group]))

    # Now process new permissions.
    url = config['ld_url'] + API + 'permissions'
    for pid, gid in changes['create_permissions']:
        data = { 'group_id': gid, 'project_id': pid }
        response = session.post(url, data=json.dumps(data))
        response.raise_for_status()

    # Now delete permissions.
    for item in changes['remove_permissions']:
        pid, gid = item
        data = { 'id': model['permission_ids'][item], 'group_id': gid, 'project_id': pid }
        response = session.delete(url, data=json.dumps(data))
        response.raise_for_status()


def main(argv):
    opts, args = parse_options(argv[1:])
    config_json, import_json = args

    # Load import data
    import_data = json.loads(import_json)

    if set(import_data.keys()) != set(['groups', 'projects']):
        raise RuntimeError('Missing import file entries, see README.md')
    
    config = json.loads(config_json)

    if set(config.keys()) != set(['ld_url', 'ld_username', 'ld_password']):
        raise RuntimeError('Missing config entries, see README.md')

    session = requests.Session()
    session.verify = False
    session.headers.update({'Accept': 'application/json'})
    session.auth = requests.auth.HTTPBasicAuth(config['ld_username'],
                                               config['ld_password'])

    raw_model = retrieve_raw_model(config, session)
    model = crunch_model(raw_model)

    print 'Current user model:'
    pprint.pprint(model)
    print

    changes = compute_changes(model, import_data)
    print 'Changes to make:'
    pprint.pprint(changes)

    if opts.dry_run:
        print '\nExiting, as this is a dry run.'
        return 0

    # Check to see if the current run is a no-op.
    has_changes = False
    for obj in changes.values():
        if len(obj) > 0:
            has_changes = True
            break

    if not has_changes:
        print '\nExiting, as no changes need to be made.'
        return 0

    # Back the current model, import data and proposed changes (for forensics)
    now = datetime.datetime.now()
    backup_root = os.path.expanduser('~/.livedesign/entitlement_backups')
    prefix = now.strftime('%Y%m%d_%H%M%S_')

    if not os.path.exists(backup_root):
        os.makedirs(backup_root)

    def serialize_sets(obj):
        if isinstance(obj, set):
            return list(obj)
        raise TypeError('%s is not JSON serializable' % obj)

    filename = prefix + 'model.json'
    with open(os.path.join(backup_root, filename), 'w') as fp:
        json.dump(raw_model, fp)

    filename = prefix + 'changes.json'
    with open(os.path.join(backup_root, filename), 'w') as fp:
        json.dump(changes, fp, default=serialize_sets)

    filename = prefix + 'import.json'
    with open(os.path.join(backup_root, filename), 'w') as fp:
        json.dump(import_data, fp)

    apply_changes(config, session, model, changes)
    print '\nAll changes applied successfully'

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))