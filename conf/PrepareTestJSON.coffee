fs = require 'fs'
glob = require 'glob'

allFiles = glob.sync "../public/javascripts/spec/testFixtures/*.js"
for fileName in allFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = fileName.replace "testFixtures","TestJSON"
	newFileName = newFileName.replace ".js", ".json"
	fs.writeFileSync newFileName, jsonfilestring

allCodeTableFiles = glob.sync "../public/javascripts/spec/testFixtures/*CodeTableTestJSON.js"
allCodeTables = []
allCodeTableKeys = []
for fileName in allCodeTableFiles
	codeTablesFile = require fileName
	for codeTable in codeTablesFile['dataDictValues']
		if (Object.keys(codeTable)[0] in allCodeTableKeys)
			console.log "Error: code table for " + Object.keys(codeTable)[0] + " already stored"
			process.exit -1
		else
			allCodeTables.push codeTable
			Array::push.apply allCodeTableKeys, Object.keys(codeTable)

jsonallcodetablesstring = JSON.stringify allCodeTables
allCodeTablesFileName = "../public/javascripts/spec/testFixtures/CodeTableJSON.js"
jsonallcodetablesstring = "exports.codes = " + jsonallcodetablesstring
fs.writeFileSync allCodeTablesFileName, jsonallcodetablesstring


