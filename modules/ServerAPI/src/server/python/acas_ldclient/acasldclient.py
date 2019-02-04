"""
Interface for fetching data for ACAS API
"""
from ldclient.client import LDClient
import argparse
import json
import os, sys

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
    print test
    return client.list_groups()

def auth_check(client, username, password):
    auth_return = client.auth_check(username = username, password = password)
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

def get_users(client, ls_type = None, ls_kind = None, role_name = None):
    ld_users = client.list_users()
    if ls_type == None and ls_kind == None and role_name == None:
        acas_users = map(ld_user_to_acas_user_code_table, ld_users)
    else:
        groups = client.list_groups()
        roles = map(ld_group_to_acas_role, groups)
        role = [r for r in roles if r["roleEntry"]["lsType"] == ls_type and r["roleEntry"]["lsKind"] == ls_kind and r["roleEntry"]["roleName"] == role_name]
        if len(role) == 0:
            return []
        users = []
        memberships = client.list_memberships()
        userDict = {}
        for u in ld_users:
            userDict[u["id"]] = u
        for m in memberships:
            if m["group_id"] == role[0]["id"]:
                users.append(userDict[m["user_id"]])
        acas_users = map(ld_user_to_acas_user_code_table, users) 
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
    roles = map(ld_group_to_acas_role, groups)
    roleDict = {}
    for r in roles:
        roleDict[r["id"]] = r
    memberships = client.list_memberships()
    for m in memberships:
        usersDict[m["user_id"]].append(roleDict[m["group_id"]])
    users = []
    for user in usersDict.iteritems():
        users.append(user)
    return users

def get_user(client, username):
    user = client.get_user(username)
    permissions = client.list_permissions()
    memberships = client.list_memberships()
    groups = client.list_groups()
    user_memberships = [m for m in memberships if m['user_id'] == user['id']]
    user_groups = [next(g for g in groups if g["id"]==m["group_id"]) for m in user_memberships]
    roles = map(ld_group_to_acas_role, user_groups)
    acas_user = ld_user_to_acas_user(user, roles)
    # user = {"id":1,"username":"bob","email":"bob@mcneilco.com","firstName":"Ham","lastName":"Cheese","roles":[{"id":2,"roleEntry":{"id":1,"lsKind":"ACAS","lsType":"System","lsTypeAndKind":"System_ACAS","roleDescription":"ROLE_ACAS-USERS autocreated by ACAS","roleName":"ROLE_ACAS-USERS","version":0},"version":0},{"id":1,"roleEntry":{"id":2,"lsKind":"ACAS","lsType":"System","lsTypeAndKind":"System_ACAS","roleDescription":"ROLE_ACAS-ADMINS autocreated by ACAS","roleName":"ROLE_ACAS-ADMINS","version":0},"version":0},{"id":4,"roleEntry":{"id":4,"lsKind":"CmpdReg","lsType":"System","lsTypeAndKind":"System_CmpdReg","roleDescription":"ROLE_CMPDREG-ADMINS autocreated by ACAS","roleName":"ROLE_CMPDREG-ADMINS","version":0},"version":0},{"id":3,"roleEntry":{"id":5,"lsKind":"ACAS","lsType":"System","lsTypeAndKind":"System_ACAS","roleDescription":"ROLE_ACAS-CROSS-PROJECT-LOADER autocreated by ACAS","roleName":"ROLE_ACAS-CROSS-PROJECT-LOADER","version":0},"version":0},{"id":5,"roleEntry":{"id":3,"lsKind":"CmpdReg","lsType":"System","lsTypeAndKind":"System_CmpdReg","roleDescription":"ROLE_CMPDREG-USERS autocreated by ACAS","roleName":"ROLE_CMPDREG-USERS","version":0},"version":0},{"id":6,"roleEntry":{"id":6,"lsKind":"PROJ-00000001","lsType":"Project","lsTypeAndKind":"Project_PROJ-00000001","roleDescription":"User autocreated by ACAS","roleName":"User","version":0},"version":0}]}

    return acas_user

def get_projects(client):
    ld_projects = client.projects()
    projects = map(ld_project_to_acas, ld_projects)
    return projects

def ld_project_to_acas(ld_project):
    acas_project = {
        'id': ld_project.id,
        'code': ld_project.alternate_id,
        'alias': ld_project.name,
        'active': True if ld_project.active == "Y" else False,
        'isRestricted': ld_project.restricted,
        'name': ld_project.name
    }
    return acas_project

def main():
    parser = get_parser()
    args = parser.parse_args()
    endpoint = "{0}/api".format(args.ld_server)
    client = LDClient(host=endpoint, username=args.username, password=args.password)
    method = eval(args.method)

    result = method(client, *args.args)
    print json.dumps(result)

if __name__ == "__main__":
    main()
