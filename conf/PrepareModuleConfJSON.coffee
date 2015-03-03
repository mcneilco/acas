fs = require 'fs'
glob = require 'glob'

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
for fileName in allModuleConfJSONFiles
	data = require fileName
	for typeOrKind in typeKinds
		if data.typeKindList[typeOrKind]?
			for value in data.typeKindList[typeOrKind]
				config = require '../conf/compiled/conf.js'
				baseurl = config.all.client.service.persistence.fullpath+"setup/"+typeOrKind
				request = require 'request'
				if value.kindName? and value.typeName?
					console.log "trying to save typeName: " + value.typeName + " and kindName: " + value.kindName
				else if value.typeName?
					console.log "trying to save typeName: " + value.typeName
				else
					console.log "trying to save " + typeOrKind
				request(
					method: 'POST'
					url: baseurl
					body: JSON.stringify [value]
					json: true
					headers:
						"Content-Type": 'application/json'
				, (error, response, json) =>
					unless !error && response.statusCode == 201
						console.log 'got ajax error trying to setup type/kind'
						console.log error
						console.log json

				)

#				$.ajax
#					type: 'POST'
#					url: "/api/setup/"+typeOrKind
#					data:
#						JSON.stringify value
#	#					JSON.stringify(codeEntry:(selectedModel))
#					contentType: 'application/json'
#					dataType: 'json'
#					success: (response) =>
#						console.log "successful post"
#					error: (err) =>
#						alert 'could not add option to code table'
#						@serviceReturn = null

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


