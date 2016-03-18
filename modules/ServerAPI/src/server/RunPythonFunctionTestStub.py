#!/usr/bin/python
"""
Example python script that accepts JSON input and returns standardized JSON output
Example to run:
python runPythonTest.py -i '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv", "dryRun":true,"user":"jmcneil"}'
"""

import json
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description='Parse input parameters')
    parser.add_argument('-i', '--input', type=json.loads)
    args = parser.parse_args()
    args = vars(args)
    
    request=args['input']
    response = {"results":request, "hasError":False,"hasWarning":False,"errorMessages":[]}
    
    print json.dumps(response)

if __name__ == '__main__':
    main()
