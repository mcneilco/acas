fs = require 'fs'
glob = require 'glob'
_ = require "underscore"

console.log "here"

allModuleConfJSFiles = glob.sync "../public/javascripts/conf/*.js"
for fileName in allModuleConfJSFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = fileName.replace "conf", "conf/confJSON"
	newFileName = newFileName.replace ".js", ".json"
	fs.writeFileSync newFileName, jsonfilestring

typeKinds = [
	"codetables"
	"containerkinds"
	"containertypes"
	"ddictkinds"
	"ddicttypes"
	"experimentkinds"
	"experimenttypes"
	"interactionkinds"
	"interactiontypes"
	"labelkinds"
	"labelsequences"
	"labeltypes"
	"operatorkinds"
	"operatortypes"
	"protocolkinds"
	"protocoltypes"
	"statekinds"
	"statetypes"
	"thingkinds"
	"thingtypes"
	"unitkinds"
	"unittypes"
	"valuekinds"
	"valuetypes"
]
allModuleConfJSONFiles = glob.sync "../public/javascripts/conf/confJSON/*.json"
#for fileName in allModuleConfJSONFiles
#	data = require fileName
##	console.log typeKinds
#	console.log typeKinds[6]
#	test = typeKinds[6]
#	console.log data[test]
#	for typeOrKind in typeKinds
#		for value in data[typeOrKind]
#			$.ajax
#				type: 'POST'
#				url: "/api/setup"+typeOrKind
#				data:
#					JSON.stringify value
##					JSON.stringify(codeEntry:(selectedModel))
#				contentType: 'application/json'
#				dataType: 'json'
#				success: (response) =>
#					console.log "successful post"
#				error: (err) =>
#					alert 'could not add option to code table'
#					@serviceReturn = null

#allCodeTables = []
#allCodeTableTypesAndKinds = []
#currentTypeAndKind = {}
#
#for fileName in allCodeTableFiles
#	codeTableFile = require fileName
#	for codeTable in codeTableFile['codetableValues']
#		type = codeTable['type']
#		kind = codeTable['kind']
#		currentTypeAndKind['type'] = type
#		currentTypeAndKind['kind'] = kind
#		if _.findWhere(allCodeTableTypesAndKinds, currentTypeAndKind) is undefined
#			allCodeTableTypesAndKinds.push [{type:codeTable['type'], kind:codeTable['kind']}]...
#			allCodeTables.push codeTable
#		else
#			console.log "Error: code table for type: " + type + "and kind: " + kind + " already stored"
#			process.exit -1
#
#jsonallcodetablesstring = JSON.stringify allCodeTables
#allCodeTablesFileName = "../public/javascripts/spec/testFixtures/CodeTableJSON.js"
#jsonallcodetablesstring = "exports.codes = " + jsonallcodetablesstring
#fs.writeFileSync allCodeTablesFileName, jsonallcodetablesstring


