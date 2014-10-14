fs = require 'fs'
glob = require 'glob'
_ = require "underscore"


allFiles = glob.sync "../public/javascripts/spec/testFixtures/*.js"
for fileName in allFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = fileName.replace "testFixtures","TestJSON"
	newFileName = newFileName.replace ".js", ".json"
	fs.writeFileSync newFileName, jsonfilestring

allCodeTableFiles = glob.sync "../public/javascripts/spec/testFixtures/*CodeTableTestJSON.js"
allCodeTables = []
allCodeTableTypesAndKinds = []
currentTypeAndKind = {}

for fileName in allCodeTableFiles
	codeTableFile = require fileName
	for codeTable in codeTableFile['dataDictValues']
		type = codeTable['type']
		kind = codeTable['kind']
		currentTypeAndKind['type'] = type
		currentTypeAndKind['kind'] = kind
		if _.findWhere(allCodeTableTypesAndKinds, currentTypeAndKind) is undefined
			allCodeTableTypesAndKinds.push [{type:codeTable['type'], kind:codeTable['kind']}]...
			allCodeTables.push codeTable
		else
			console.log "Error: code table for type: " + type + "and kind: " + kind + " already stored"
			process.exit -1

jsonallcodetablesstring = JSON.stringify allCodeTables
allCodeTablesFileName = "../public/javascripts/spec/testFixtures/CodeTableJSON.js"
jsonallcodetablesstring = "exports.codes = " + jsonallcodetablesstring
fs.writeFileSync allCodeTablesFileName, jsonallcodetablesstring


