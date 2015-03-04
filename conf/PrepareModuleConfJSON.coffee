fs = require 'fs'
glob = require 'glob'

allModuleConfJSFiles = glob.sync "../public/javascripts/conf/*.js"
for fileName in allModuleConfJSFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = fileName.replace "conf", "conf/confJSON/moduleJSON"
	newFileName = newFileName.replace ".js", ".json"
	fs.writeFileSync newFileName, jsonfilestring

typeKinds = [
	"codetables"
	"containertypes"
	"containerkinds"
	"ddicttypes"
	"ddictkinds"
	"experimenttypes"
	"experimentkinds"
	"interactiontypes"
	"interactionkinds"
	"labeltypes"
	"labelkinds"
	"labelsequences"
	"operatortypes"
	"operatorkinds"
	"protocoltypes"
	"protocolkinds"
	"statetypes"
	"statekinds"
	"thingtypes"
	"thingkinds"
	"unittypes"
	"unitkinds"
	"valuetypes"
	"valuekinds"
]
allModuleConfJSONFiles = glob.sync "../public/javascripts/conf/confJSON/moduleJSON/*.json"
allModulesTypesAndKinds = {}

for fileName in allModuleConfJSONFiles
	moduleData = require fileName
	for typeOrKind in typeKinds
		if moduleData.typeKindList[typeOrKind]?
			value = moduleData.typeKindList[typeOrKind]
			if allModulesTypesAndKinds[typeOrKind]?
				compiledTypesAndKinds = allModulesTypesAndKinds[typeOrKind]
				compiledTypesAndKinds.push value...
			else
				allModulesTypesAndKinds[typeOrKind] = value
jsonfilestring = JSON.stringify allModulesTypesAndKinds
compiledModuleConfsFileName = "../public/javascripts/conf/confJSON/CompiledModuleConfJSONs.json"
fs.writeFileSync compiledModuleConfsFileName, jsonfilestring

async = require 'async'
request = require 'request'
data = require '../public/javascripts/conf/confJSON/CompiledModuleConfJSONs.json'
config = require '../conf/compiled/conf.js'

async.forEachSeries typeKinds, ((typeOrKind, callback) ->
	baseurl = config.all.client.service.persistence.fullpath+"setup/"+typeOrKind
	if data[typeOrKind]?
		console.log "trying to save " + typeOrKind
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify data[typeOrKind]
			json: true
			headers:
				"Content-Type": 'application/json'
			, (error, response, json) =>
				if !error && response.statusCode == 201
					console.log "successfully added " + typeOrKind
				else
					console.log 'got ajax error trying to setup type/kind ' + typeOrKind
					console.log error
					console.log json
				callback()
		)
	else
		console.log "no "+typeOrKind+" to save"
		callback()
), (err) ->
	console.log "done adding types and kinds"
