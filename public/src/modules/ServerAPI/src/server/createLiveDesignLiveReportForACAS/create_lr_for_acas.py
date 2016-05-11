#!/usr/bin/python
"""
Demonstrate creating a LiveReport

Running the examples requires the Python Requests module to be installed. See
http://docs.python-requests.org/en/latest/user/install/ for installation instructions.

"""

import json
import sys
import argparse


try:
    import http.client as http_client
except ImportError:
    # Python 2
    import httplib as http_client
http_client.HTTPConnection.debuglevel = 0

import ldclient
from ldclient.client import LDClient as Api
from ldclient.client import LiveReport
from ldclient.models import ViewSelection

def make_acas_live_report(api, compound_ids, assays_to_add, database, projectId, ldClientVersion):

   
    lr = LiveReport("Live Report of ACAS Registered data", 
                    "Contains the data just loaded",
                    "BY_CACHEBUILDER",
                    False,
                    False,
                    view_selection=ViewSelection("=", "Assay Display"),
                    project_id = projectId)

    lr = api.create_live_report(lr)

    #instead of creating, you can request an existing LR
    #lr = api.live_report(1648)
    
    lr_id = int(lr.id)
    print "Live Report ID is:" + str(lr_id)
    #get the list of assay addable columns
    if ldClientVersion >= 7.6:
        assay_column_ids = []
        for assay_to_add in assays_to_add:
            assay_tree=api.get_folder_tree_data(projectId, assay_to_add['protocolName'])
            if type(assay_tree) is list:
                assay_tree=assay_tree[0]
            while assay_tree['name'] != assay_to_add['protocolName']:
    	        assay_tree=assay_tree['children'][0]
            for assay in assay_tree['children']:
                assay_column_ids.extend(assay['addable_column_ids'])
    else:
        assays = api.assays()
        assay_hash = {}
        for assay in assays:
            if assay.name not in assay_hash:
                assay_hash[assay.name] = {}
            for assay_type in assay.types:
                assay_hash[assay.name][assay_type.name] = assay_type.addable_column_id
        assay_column_ids = []
        for assay_to_add in assays_to_add:
    	    assay_column_ids.append(assay_hash[assay_to_add['protocolName']][assay_to_add['resultType']])
    #assay_column_id1 = assay_hash["Peroxisome proliferator-activated receptor delta"]["EC50"]
    #assay_column_id2 = assay_hash["DRC TEST ASSAY"]["IC50%"]


    # This is the API call to cause addition of the assay columns by their ids
    # need to modify code above to take the list of assay names and types as input
    # and generte an array of matchign ids and pass those in here
    api.add_columns(lr_id,assay_column_ids)
    
    #add an external property
    #addable_column_id is found in /api/extprop/versions?project_ids=0%2C1%2C476759
    
    #hide the rationale column
    #rationale_column_descriptor = api.column_descriptors(lr_id,'Rationale')[0]
    #rationale_column_descriptor.hidden = True
    #api.update_column_descriptor(lr_id,rationale_column_descriptor)
   
    #compound search by id
    search_results = []
    if isinstance(compound_ids, (str,unicode)):
    	search_results.extend(api.compound_search_by_id(compound_ids, database_names=[database], project_id = projectId))
    else:
    	search_string = ""
    	for compound_id in compound_ids:
    		search_string += compound_id +"\n"
    	search_results.extend(api.compound_search_by_id(search_string, database_names=[database], project_id = projectId))
    # Now add the rows for the compound ids for which we want data
    #compound_ids = ["V51411","V51412","V51413","V51414"]
    api.add_rows(lr_id, search_results)
    
    return lr_id
    

def main():
    #if len(sys.argv) is not 4:
    #    raise Exception("Must call with endpoint, username, and password" +\
    #                    " i.e.: python example.py http://<server>:9087 <user> <pass>")
    #endpoint = sys.argv[1]
    #username = sys.argv[2]
    #password = sys.argv[3]
    parser = argparse.ArgumentParser(description='Parse input parameters')
    parser.add_argument('-i', '--input', type=json.loads)
    parser.add_argument('-e', '--endpoint', type=str)
    parser.add_argument('-u', '--username', type=str)
    parser.add_argument('-p', '--password', type=str)
    parser.add_argument('-d', '--database', type=str)
    args = parser.parse_args()
    args = vars(args)
    endpoint = args['endpoint']
    username = args['username']
    password = args['password']
    database = args['database']
    
    compound_ids=args['input']['compounds']
    assays_to_add=args['input']['assays']
    try:
		project=args['input']['project']
    except:
		project="Global"
    
    apiSuffix = "/api"
    apiEndpoint = endpoint + apiSuffix;
    api = Api(apiEndpoint, username, password)
#    api.reload_db_constants()
    try:
        ld_client_version=float(ldclient.client.SUPPORTED_SERVER_VERSION)
    except:
        ld_client_version=float(7.3)
    print "LDClient version is:"+str(ld_client_version)
    try:
    	projectId = api.get_project_id_by_name(project)
    except:
    	projectId = 0
    if type(projectId) is not int:
		projectId = 0
    lr_id = make_acas_live_report(api, compound_ids, assays_to_add, database, projectId, ld_client_version)
    
    liveReportSuffix = "/#/projects/"+str(projectId)+"/livereports/";
    print endpoint + liveReportSuffix + str(lr_id)
    #return endpoint + liveReportSuffix + str(lr_id)

if __name__ == '__main__':
    main()

    
 
