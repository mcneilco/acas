#!/usr/bin/python
# compare_single_csv.py
# Script for comparing differences between a pair of Live Report exports from LiveDesign
# By Brian Fielder

import csv
import csvdiff
from os import listdir, system
import subprocess
import json
import pprint
import argparse
import collections
import re

def compare(x,y):
	return collections.Counter(x) == collections.Counter(y)

def clean_units(value):
	return value.replace(' N/A','').replace(' ID','').replace(' uM','')

def clean_diff(diffObject):
	for changed in diffObject['changed']:
		for fieldkey in changed['fields']:
			from_value = changed['fields'][fieldkey]['from']
			to_value = changed['fields'][fieldkey]['to']
			
			from_value = clean_units(from_value)
			to_value = clean_units(to_value)
			
			if '\n' in from_value and '\n' in to_value:
				from_list = from_value.split('\n')
				to_list = to_value.split('\n')
				
				from_list = map(lambda x: clean_units(x), from_list)
				to_list = map(lambda x: clean_units(x), to_list)
				if compare(from_list, to_list):
					changed['fields'][fieldkey] = {}
			if 'onschrodinger.com' in from_value and 'onschrodinger.com' in to_value:
				if re.sub('[a-zA-Z\-]+\.onschrodinger\.com','hostname', from_value) == re.sub('[a-zA-Z\-]+\.onschrodinger\.com','hostname', to_value):
					changed['fields'][fieldkey] = {}
			if from_value == to_value:
				changed['fields'][fieldkey] = {}
	return diffObject

def main(): 
	parser = argparse.ArgumentParser()
	parser.add_argument('-b', '--before', type=str, help="Filepath to live report dump from before upgrade")
	parser.add_argument('-a', '--after', type=str, help="Filepath with live report dump from after upgrade")
	parser.add_argument('-k', '--key', type=str, help="Field to use as primary key. Defaults to Compound Structure. \"Entity ID\" is another good alternative")
	args = parser.parse_args()
	before_export_filename = args.before
	after_export_filename = args.after
	if args.key:
		primary_key = args.key
	else: primary_key = "Compound Structure"
	
	diffResult = {}
	diff = csvdiff.diff_files(before_export_filename, after_export_filename, [primary_key])
	key = ''
	if len(diff)>0:
		diffObject = clean_diff(diff)
# 				print json.dumps(diffObject)
		for changed in diffObject['changed']:
			for fieldkey in changed['fields']:
				if fieldkey not in ['Lot Scientist', 'Lot Date Registered', 'Lot Properties (Lot Registration Link)', 'All IDs'] and changed['fields'][fieldkey] != {}:
					lr_key = "Changes in Live Report "+str(key)
					if lr_key not in diffResult: diffResult[lr_key]={}
					if 'changed' not in diffResult[lr_key]: diffResult[lr_key]['changed']={}
					if changed['key'][0] not in diffResult[lr_key]['changed']: diffResult[lr_key]['changed'][changed['key'][0]] = {}
					diffResult[lr_key]['changed'][changed['key'][0]][fieldkey] = changed['fields'][fieldkey]
		for row in diffObject['added']:
			lr_key = "Changes in Live Report "+str(key)
			row_key = row['Compound Structure']
			if lr_key not in diffResult: diffResult[lr_key]={}
			if 'added' not in diffResult[lr_key]: diffResult[lr_key]['added']={}
			diffResult[lr_key]['added'][row_key] = row
		for row in diffObject['removed']:
			lr_key = "Changes in Live Report "+str(key)
			row_key = row['Compound Structure']
			if lr_key not in diffResult: diffResult[lr_key]={}
			if 'removed' not in diffResult[lr_key]: diffResult[lr_key]['removed']={}
			diffResult[lr_key]['removed'][row_key] = row
	print(json.dumps(diffResult, sort_keys=True, indent=4))

if __name__ == '__main__':
    main()

