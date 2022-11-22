"""
Interface for fetching data for ACAS API
"""
import re
from ldclient.client import LDClient
from ldclient.api.requester import SUPPORTED_SERVER_VERSION
from ldclient.base import version_str_as_tuple

import argparse
import json
import os, sys
import locale
from functools import cmp_to_key

def get_parser():
    """
    @return:
        A command-line parser with switches and defaults defined.
    @rtype:
        argparse.ArgumentParser

    """
    # Get an argsparse parser, and populate it
    script_usage = "python {} [-t] (optional: none curerntly) [Test(s) to run]".format(os.path.basename(sys.argv[0]))
    script_desc = "Run lambda_function tests"
    parser = argparse.ArgumentParser(
        usage=script_usage,
        description=script_desc
    )
    parser.add_argument(
        '--ldserver',
        '-l',
        help='Live Design Server',
        dest='ld_server',
        required=True
    )
    parser.add_argument(
        '--user',
        '-u',
        help='LD client user',
        dest='username',
        required=True
    )
    parser.add_argument(
        '--password',
        '-p',
        help='LD client password',
        dest='password',
        required=True
    )
    parser.add_argument(
        '--method',
        '-m',
        help='Method to call',
        dest='method',
        required=True
    )
    parser.add_argument(
        '--args',
        '-a',
        nargs='*',
        help='arguments to the method',
        dest='args',
        required=False
    )
    return parser

def list_groups(client, test):
    print(test)
    return client.list_groups()

def auth_check(endpoint, username, password):
    auth_return = {'authorized': True, 'error': None}
    try:
        sessionClient = LDClient(host=endpoint, username=username, password=password, compatibility_mode=version_str_as_tuple(SUPPORTED_SERVER_VERSION))

    except Exception as e:
        auth_return['authorized'] = False
        auth_return['error'] = e.message    
    return auth_return

def ld_group_to_acas_role(group):
    # u'LDAP_Auto_ROLE_SEURAT-USERS'
    # u'Project_ProjectX_Administrator'
    split = group["name"].split('_')
    ls_type = split[0]
    ls_kind = split[1]
    role_name = "_".join(split[2:len(split)])
    acas_role = {
        "id": group["id"], 
        "roleEntry": {
            'id': group["id"],
            'lsType': ls_type,
            'lsKind': ls_kind,
            'lsTypeAndKind': ls_type + "_" + ls_kind,
            'roleDescription': "Original group fetched from Live Design: "+ group["name"],
            'roleName': role_name,
            'version': 0
        }
    }
    return acas_role

def ld_user_to_acas_user_code_table(ld_user):
    acas_user = {
        "code":ld_user["username"],
        "id":ld_user["id"],
        "ignored":False,
        "name":ld_user["username"]
    }
    return acas_user

def get_acas_only_acl_group_permissions(groups, projects):
    # Gets permissions for groups that are formatted like "ACAS_ONLY_ACL_GROUP_ProjectX"
    # These groups are used to grant project access to users to ACAS but not to Live Design
    acas_acl_group_permissions = []
    GROUP_NAME_REGEX = "ACAS_ONLY_ACL_GROUP_(.*)"
    for g in groups:
        acas_only_acl_group_match = re.match(GROUP_NAME_REGEX, g["name"])
        if acas_only_acl_group_match is not None:
            project_name = acas_only_acl_group_match.group(1)
            # Get the matching project id from the project name
            project_id = None
            for p in projects:
                if p.name == project_name:
                    project_id = p.id
                    break
            if project_id is not None:
                acas_acl_group_permissions.append({
                    "project_id": project_id,
                    "group_id": g["id"]
                })
    return acas_acl_group_permissions

def get_users(client, ls_type = None, ls_kind = None, role_name = None, use_acas_only_acl_groups = True):
    # ld_users = client.list_users()
    ld_users = client.client.get("/users?include_permissions=false", '')
    if ls_type == None and ls_kind == None and role_name == None:
        acas_users = list(map(ld_user_to_acas_user_code_table, ld_users))
    else:
        groups = client.list_groups()
        permissions = client.list_permissions()
        memberships = client.list_memberships()
        projects = client.projects()
    
        if bool(use_acas_only_acl_groups) == True:
            permissions.extend(get_acas_only_acl_group_permissions(groups, projects))

        user_projects = {}
        for p in permissions:
            for g in groups:
                if p["group_id"] == g["id"]:
                    for proj in projects:
                        if p["project_id"] == proj.id:
                            if proj.name in user_projects:
                                user_projects[proj.name]["granting_groups"].append(g["name"])
                            else:
                                user_projects[proj.name] = {"id":proj.id, "granting_groups": [g["name"]], "ld_users": []}
                            for m in memberships:
                                if m["group_id"] == g["id"]:
                                    for u in ld_users:
                                        if u["id"] == m["user_id"]:
                                            user_projects[proj.name]["ld_users"].append(u)
        if ls_kind in user_projects:
            acas_users = list(map(ld_user_to_acas_user_code_table, user_projects[ls_kind]["ld_users"])) 
        else:
            acas_users = []
    return acas_users

def ld_user_to_acas_user(ld_user, roles):
    acas_user = {
        'id': ld_user["id"],
        'username': ld_user["username"],
        'email': ld_user["username"],
        'firstName': ld_user["username"],
        'lastName': ld_user["username"],
        'roles': roles
    }
    return acas_user

def get_users_roles(client, users):
    usersDict = {}
    for u in users:
        usersDict[u["id"]] = u
    groups = client.list_groups()
    roles = list(map(ld_group_to_acas_role, groups))
    roleDict = {}
    for r in roles:
        roleDict[r["id"]] = r
    memberships = client.list_memberships()
    for m in memberships:
        usersDict[m["user_id"]].append(roleDict[m["group_id"]])
    users = []
    for user in usersDict.items():
        users.append(user)
    return users

def get_user(client, username, use_acas_only_acl_groups = True):
    user = client.get_user(username)
    permissions = client.list_permissions()
    memberships = client.list_memberships()
    projects = client.projects()
    groups = client.list_groups()

    if bool(use_acas_only_acl_groups) == True:
        permissions.extend(get_acas_only_acl_group_permissions(groups, projects))

    user_memberships = [m for m in memberships if m['user_id'] == user['id']]
    user_groups = [next(g for g in groups if g["id"]==m["group_id"]) for m in user_memberships]
    user_projects = {}
    for p in permissions:
        for g in user_groups:
            if p["group_id"] == g["id"]:
                for proj in projects:
                    if p["project_id"] == proj.id:
                        if proj.name in user_projects:
                            user_projects[proj.name]["granting_groups"].append(g["name"])
                        else:
                            user_projects[proj.name] = {"id":proj.id, "granting_groups": [g["name"]]}
    roles = []
    for proj, data in user_projects.items():
        roles.append({
            "id": data["id"], 
            "roleEntry": {
                'id': data["id"],
                'lsType': 'Project',
                'lsKind': proj,
                'lsTypeAndKind':  "Project_" + proj,
                'roleDescription': "Permission to Project granted by Live Design group(s): "+', '.join("'{0}'".format(g) for g in data["granting_groups"]),
                'roleName': "User",
                'version': 0
            }
        })
    acas_user = ld_user_to_acas_user(user, roles)
    return acas_user

def get_projects(client):
    ld_projects = client.projects()      

    projects = list(map(ld_project_to_acas, ld_projects))

    # Sort by name
    locale.setlocale(locale.LC_ALL, '')
    projects = sorted(projects, key=lambda x: locale.strxfrm(x['name']))
    return projects

def ld_project_to_acas(ld_project):
    acas_project = {
        'id': ld_project.id,
        'code': ld_project.name,
        'alias': ld_project.name,
        'active': True if ld_project.active == "Y" else False,
        'ignored': False if ld_project.active == "Y" else True,
        'isRestricted': ld_project.restricted,
        'name': ld_project.name
    }
    return acas_project

def main():
    parser = get_parser()
    args = parser.parse_args()
    endpoint = "{0}/api".format(args.ld_server)
    if args.method != "auth_check":
        client = LDClient(host=endpoint, username=args.username, password=args.password, compatibility_mode=version_str_as_tuple(SUPPORTED_SERVER_VERSION))
        method = eval(args.method)
        result = method(client, *args.args)
    else:
        result = auth_check(endpoint, *args.args)

    print(json.dumps(result))

if __name__ == "__main__":
    main()
