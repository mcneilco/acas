#!/usr/bin/python
"""
Create a Live Report in LiveDesign with data from provided ACAS experiment.

By:
Brian Frost

"""

import argparse
import json
import re
import time
import sys
try:
    import http.client as http_client
except ImportError:
    # Python 2
    import http.client as http_client
http_client.HTTPConnection.debuglevel = 0

import ldclient
from ldclient.client import LDClient, LiveReport

try:
    import requests
    from requests.packages.urllib3.exceptions import (InsecurePlatformWarning,
                                                      InsecureRequestWarning,
                                                      SNIMissingWarning)
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    requests.packages.urllib3.disable_warnings(InsecurePlatformWarning)
    requests.packages.urllib3.disable_warnings(SNIMissingWarning)
except ImportError:
    #ignore error, allow warnings
    print('ignoring ImportError')

### Generic helper functions
def eprint(*args, **kwargs):
    """Print to stderr"""
    print(*args, file=sys.stderr, **kwargs)

def str2bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

### LD-specific helpers
def find_column_ids(
        ld_client,
        assay_name,
        project_id,
        column_names=None,
        exclude_column_names=False
        ):
    """
    Returns addable column IDs for the given column names
    :param ld_client: LD Client
    :param assay_name: Name of the assay under which the columns are.
    :param project_id: ID of the project
    :param column_names: Names of columns. Optional, if not specified
                         then all columns under folder are returned.
                         See `exclude_column_names` for more behavior.
    :param exclude_column_names: If True, exclude columns provided in `column_names`.
                         If False, filter to ONLY include columns provided in `column_names.
                         Defaults to False.
    :return: list of column IDs corresponding to each name
    """
    column_pattern = None
    if column_names is None and assay_name:
        assay_name_escaped = re.escape(assay_name)
        column_pattern = re.compile(rf"^{assay_name_escaped}\s\(.+\)$")

    col_ids = []
    resp_tree = ld_client.get_folder_tree_data(project_id, assay_name)
    if type(resp_tree) is list:
        resp_tree = [
            item for item in resp_tree if item['name'] == 'Experimental Assays'
        ]
        if resp_tree:
            resp_tree = resp_tree[0]
    if resp_tree and column_names:
        if not exclude_column_names:
            # Filter to only include `column_names`:
            for column_name in column_names:
                assays = []
                find_assay(resp_tree, assays, assay_name=column_name)
                for assay in assays:
                    col_id = extract_endpoints(assay, [])
                    col_ids.append(col_id[0])
        else:
            # Filter to exclude `column_names`
            columns_dict = extract_endpoints_dict(resp_tree, {})
            for col_name, col_id_list in columns_dict.items():
                if col_name not in column_names:
                    col_ids.extend(col_id_list)
    elif resp_tree:
        # Find all columns within this assay name
        assays = []
        if column_pattern:
            find_assay(resp_tree, assays, assay_pattern=column_pattern)
        else:
            find_assay(resp_tree, assays, assay_name=assay_name)
        for assay in assays:
            col_ids.extend(extract_endpoints(assay, []))
    return col_ids


def find_assay(assay_tree, assays, assay_pattern=None, assay_name=None):
    """Recursive function to find an assay dict in a sub-tree of the assay tree.
    :param assay_tree: The assay sub-tree
    :param assays: The current list of assay dicts
    :param assay_pattern (Optional): A regex pattern to match the column name(s)
    :param assay_name (Optional): The full column name to match exactly
    """
    if 'name' in assay_tree:
        if assay_pattern and assay_pattern.fullmatch(assay_tree['name']):
            assays.append(assay_tree)
        elif assay_name and assay_name == assay_tree['name']:
            assays.append(assay_tree)

    for sub_tree in assay_tree['children']:
        item = find_assay(
            sub_tree,
            assays,
            assay_pattern=assay_pattern,
            assay_name=assay_name)
        if item is not None:
            assays.append(item)


def extract_endpoints(assay, endpoints):
    """Recursive function to extract a list of column IDs from a sub-tree of the assay tree.
    :param assay: The assay sub-tree
    :param endpoints: The current list of column IDs
    :return: The list of column IDs
    """
    if 'addable_column_ids' in assay and len(assay['addable_column_ids']) > 0:
        endpoints.extend(assay['addable_column_ids'])
    for sub_assay in assay['children']:
        extract_endpoints(sub_assay, endpoints)
    return endpoints


def extract_endpoints_dict(node, endpoints_dict):
    """Recursive function to extract a dictionary of column names to column IDs from a sub-tree of the assay tree.
    :param node: The assay sub-tree
    :param endpoints_dict: The current dictionary of column names to column IDs
    :return: The dictionary of column names to column IDs
    """
    if node['column_folder_node_type'] == 'LEAF':
        endpoints_dict[node['name']] = node['addable_column_ids']
    for child_node in node['children']:
        extract_endpoints_dict(child_node, endpoints_dict)
    return endpoints_dict

def wait_and_add_columns(ld_client,
                         live_report_id,
                         project_id,
                         assay_name,
                         column_names=None,
                         max_retries=10,
                         delay_sec=5):
    """
    Attempt to find and add columns with specified names into a LR.
    If the columns don't exist, poll for `retries` times with `delay_sec` delay between tries
    until either success or timeout.
    :param ld_client: LD client
    :param live_report_id: ID of LiveReport to add columns to
    :param column_ids: Assay name of columns: if column is 'Foo (bar)' then assay_name = 'Foo'
    :param column_names: Full column names of format 'Foo (bar)'
    :param max_retries: Maximum of retries, defaults to 10
    :param delay_sec: Seconds of delay been tries, defaults to 5
    """
    success = False
    for attempt in range(max_retries):
        try:
            col_ids = find_column_ids(
                ld_client, assay_name, project_id=project_id, column_names=column_names)
            expected = len(column_names)
            found = len(col_ids)
            if found < expected:
                raise ValueError(
                    f'Some columns under {assay_name} not found. Found {found} of {expected}.')
            ld_client.add_columns(live_report_id, col_ids)
            success = True
            break
        except (KeyError, ValueError) as e:
            eprint(f'Failed to add columns, retrying {max_retries - attempt - 1} more times.')
            time.sleep(delay_sec)
    return success

### Main functions

def get_assay_names_to_full_col_names(assays_to_add):
    """Convert the incoming `assays_to_add` to a dictionary of assay names to list of full column names.
    :param assays_to_add: A list of assay name & result type objects from ACAS
    :return: A dictionary of assay names to list full column names
    """
    assay_names_to_full_col_names = {}
    for assay in assays_to_add:
        assay_name = assay['protocolName']
        result_type = assay['resultType']
        if assay_name not in assay_names_to_full_col_names:
            assay_names_to_full_col_names[assay_name] = []
        col_name = f'{assay_name} ({result_type})'
        assay_names_to_full_col_names[assay_name].append(col_name)
    return assay_names_to_full_col_names

def get_column_ids_legacy(ld_client, assays_to_add):
    assays = ld_client.assays()
    assay_hash = {}
    # Build a dict of { (assay_name, result_type): column_id }
    for assay in assays:
        for assay_type in assay.types:
            assay_hash[(assay.name, assay_type.name)] = assay_type.addable_column_id
    # Look up incoming assay names and result types and grab the column_ids
    assay_column_ids = []
    for assay_to_add in assays_to_add:
        key = (assay_to_add['protocolName'], assay_to_add['resultType'])
        assay_column_ids.append(assay_hash[key])
    return assay_column_ids

def get_or_create_folder(ld_client, project_id, folder_name):
    """
    Get or create a folder with the given name
    :param ld_client: LD Client
    :param project_id: ID of the project
    :param folder_name: Name of the folder
    :return: ID of the folder
    """
    # Find the folder by name and project_id
    current_folders =  ld_client.list_folders([project_id])
    for folder in current_folders:
        if int(folder.project_id) == int(project_id) and folder.name == folder_name:
            return folder.id
    # Otherwise create the folder
    eprint('Autogenerated ACAS Reports folder does not exist in this project. Creating it')
    folder = ld_client.create_folder('Autogenerated ACAS Reports', project_id)
    return folder.id    

def make_acas_live_report(api, compound_ids, assays_to_add, experiment_code, logged_in_user, database, project_id, ldClientVersion, readonly):
    # Get or create the folder the LR will go in
    folder_id = get_or_create_folder(api, project_id, 'Autogenerated ACAS Reports')
    # Create the LR
    lr = LiveReport(experiment_code, "Contains the data just loaded", project_id=project_id)

    lr = api.create_live_report(lr)
    #change LR owner to logged in user
    lr.owner = logged_in_user
    #put the LR in the Autogenerated ACAS Reports folder
    lr.tags = [folder_id]
    #Make the LR read-only
    if readonly:
        lr.update_policy = LiveReport.NEVER
    #Update LR
    api.update_live_report(lr.id, lr)
    
    
    lr_id = int(lr.id)
    eprint("Live Report ID is:" + str(lr_id))
    #get the list of assay addable columns
    if ldClientVersion >= 7.6:
        # convert `assays_to_add` into a list of full column names
        assay_names_to_column_names = get_assay_names_to_full_col_names(assays_to_add)
        for assay_name, column_names in assay_names_to_column_names.items():
            # get columns and add them, including a retry period
            wait_and_add_columns(api, lr_id, project_id, assay_name, column_names=column_names)
    else:
        addable_column_ids = get_column_ids_legacy(api, assays_to_add)
        # Add the columns to the LR
        api.add_columns(lr_id, addable_column_ids)
    
    # Hide the rationale column
    rationale_column_descriptor = api.column_descriptors(lr_id,'Rationale')[0]
    rationale_column_descriptor.hidden = True
    api.update_column_descriptor(lr_id,rationale_column_descriptor)
   
    # Compound search by id
    if isinstance(compound_ids, str):
        search_string = compound_ids
    else:
        search_string = "\n".join(compound_ids)
    found_cmpd_ids = api.compound_search_by_id(search_string, database_names=[database], project_id = project_id)
    # Now add the rows for the compound ids for which we want data
    #compound_ids = ["V51411","V51412","V51413","V51414"]
    api.add_rows(lr_id, found_cmpd_ids)
    
    return lr_id

def get_ldclient(ld_base_url, username, password):
    """
    Returns an LDClient object.
    :param endpoint: LD endpoint
    :param username: LD username
    :param password: LD password
    :return: LDClient object
    """
    apiEndpoint = ld_base_url + "/api"
    return LDClient(apiEndpoint, username, password)

def get_ldclient_version():
    """
    Returns the LDClient version. Used for backward compatibility
    """
    try:
        ld_client_version=float(ldclient.client.SUPPORTED_SERVER_VERSION)
    except:
        try:
            ld_client_version=float(ldclient.api.requester.SUPPORTED_SERVER_VERSION)
        except:
            ld_client_version=float(7.3)
    return ld_client_version

def get_ld_project_id(ld_client, project_name):
    """
    Returns the LD project id for the given project name.
    :param ld_client: LDClient object
    :param project_name: LD project name
    :return: LD project id as an int
    """
    try:
        matching_projects = [p for p in ld_client.projects() if p.name == project_name]
        projectId = int(matching_projects[0].id.encode('ascii'))
        eprint("Project " + project_name + " found with id: " + str(projectId))
    except:
        projectId = 0
    if type(projectId) is not int:
        projectId = 0
    return projectId

def get_args():
    parser = argparse.ArgumentParser(description='Parse input parameters')
    parser.add_argument('-i', '--input', type=json.loads)
    parser.add_argument('-e', '--endpoint', type=str)
    parser.add_argument('-c', '--client_url', type=str)
    parser.add_argument('-u', '--username', type=str)
    parser.add_argument('-p', '--password', type=str)
    parser.add_argument('-d', '--database', type=str)
    parser.add_argument('-r', '--readonly', type=str2bool)
    return parser.parse_args()

def main():
    args = get_args()
    args = vars(args)
    ld_base_url = args['endpoint']
    ld_client_url = args['client_url']

    # Need to make sure the ld client url is set and if not then fall back to the base url
    if ld_client_url is None or ld_client_url == "" or ld_client_url == "null":
        eprint("LD Client URL is not provided. Using fallback to base url: " + ld_base_url)
        ld_client_url = ld_base_url
    else:
        eprint("Using LD Client URL: " + ld_client_url)

    username = args['username']
    password = args['password']
    database = 'ACAS'

    compound_ids=args['input']['compounds']
    assays_to_add=args['input']['assays']
    experiment_code=args['input']['experimentCode']
    try:
        project=args['input']['project']
    except:
        project="Global"
    try:
        logged_in_user=args['input']['username']
    except:
        logged_in_user=username
    # Get LDClient and check version
    ld_client = get_ldclient(ld_base_url, username, password)
    ld_client_version = get_ldclient_version()
    eprint("LDClient version is:"+str(ld_client_version))
    project_id = get_ld_project_id(ld_client, project)
    status_code = 200
    result = ''
    try:
        lr_id = make_acas_live_report(ld_client, compound_ids, assays_to_add, experiment_code, logged_in_user, database, project_id, ld_client_version, args["readonly"])
        liveReportSuffix = "/#/projects/"+str(project_id)+"/livereports/";
        result = ld_client_url + liveReportSuffix + str(lr_id)
    except requests.exceptions.HTTPError as e:
        status_code = e.response.status_code
        try:
            # Attempt to parse the response body
            result = e.response.json()[0]['message']
        except:
            result = e.response.content
    # Print results to stdout
    print("STATUS_CODE: {}".format(status_code))
    print("RESULT: " + result)

if __name__ == '__main__':
    main()

    
 
