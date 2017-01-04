import argparse

from ldclient.client import LDClient as Api
from ldclient.client import LiveReport


def main():
    #if len(sys.argv) is not 4:
    #    raise Exception("Must call with endpoint, username, and password" +\
    #                    " i.e.: python example.py http://<server>:9087 <user> <pass>")
    #endpoint = sys.argv[1]
    #username = sys.argv[2]
    #password = sys.argv[3]
    parser = argparse.ArgumentParser(description='Parse input parameters')
    parser.add_argument('-i', '--id', type=int)
    parser.add_argument('-e', '--endpoint', type=str)
    parser.add_argument('-u', '--username', type=str)
    parser.add_argument('-p', '--password', type=str)
    parser.add_argument('-d', '--database', type=str)
    args = parser.parse_args()
    args = vars(args)
    live_report_id = args['id']
    endpoint = args['endpoint']
    username = args['username']
    password = args['password']
    database = args['database']
        
    apiSuffix = "/api"
    apiEndpoint = endpoint + apiSuffix;
    api = Api(apiEndpoint, username, password)
   #  try:
#     	projectId = api.get_project_id_by_name(project)
#     except:
#     	projectId = 0
    csv_dump = api.export_live_report(live_report_id, 'csv')
    print csv_dump

if __name__ == '__main__':
    main()