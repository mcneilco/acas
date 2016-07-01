fs = require 'fs'
glob = require 'glob'
path = require 'path'
_ = require "underscore"
ACAS_HOME="#{__dirname}/../../.."

mkdirSync = (path) ->
	try
		fs.mkdirSync path
	catch e
		if e.code != 'EEXIST'
			throw e
	return
mkdirSync "#{ACAS_HOME}/public/javascripts/spec/TestJSON"
allFiles = glob.sync "#{ACAS_HOME}/public/javascripts/spec/**/testFixtures/*.js"
for fileName in allFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = "#{ACAS_HOME}/public/javascripts/spec/TestJSON/#{path.basename(fileName)}"
	newFileName = newFileName.replace ".js", ".json"
	fs.writeFileSync newFileName, jsonfilestring

allCodeTableFiles = glob.sync "#{ACAS_HOME}/public/javascripts/spec/**/testFixtures/*CodeTableTestJSON.js"
allCodeTables = []
allCodeTableTypesAndKinds = []
currentTypeAndKind = {}

for fileName in allCodeTableFiles
	codeTableFile = require fileName
	for codeTable in codeTableFile['codetableValues']
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
allCodeTablesFileName = "#{ACAS_HOME}/public/javascripts/spec/CodeTableJSON.js"
jsonallcodetablesstring = "exports.codes = " + jsonallcodetablesstring
fs.writeFileSync allCodeTablesFileName, jsonallcodetablesstring


