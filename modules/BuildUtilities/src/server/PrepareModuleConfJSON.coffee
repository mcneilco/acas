fs = require 'fs'
glob = require 'glob'
_ = require "underscore"
path = require "path"
ACAS_HOME="../../.."

mkdirSync = (path) ->
	try
		fs.mkdirSync path
	catch e
		if e.code != 'EEXIST'
			throw e
	return

mkdirSync "#{ACAS_HOME}/public/javascripts/conf/confJSON"
mkdirSync "#{ACAS_HOME}/public/javascripts/conf/confJSON/moduleJSON"

allModuleConfJSFiles = glob.sync "#{ACAS_HOME}/public/javascripts/conf/**/*.js"
for fileName in allModuleConfJSFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = fileName.replace "conf", "conf/confJSON/moduleJSON"
	mkdirSync path.dirname(newFileName)
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
	"roletypes"
	"rolekinds"
	"lsroles"
]

#name/pattern of confJSON file(s) to compile and store in CompiledModuleConfJSONs.json and to save the contents into the database
selectedConfJSONFiles = process.argv[2]
if selectedConfJSONFiles?
	confJSONFilesToCompile = glob.sync process.argv[2]
	if confJSONFilesToCompile.length is 0
		console.log "This file does not exist"
		console.log "Check the file path. The file should be in /public/javascripts/conf/confJSON/moduleJSON"
		process.exit -1
else
	confJSONFilesToCompile = glob.sync "#{ACAS_HOME}/public/javascripts/conf/confJSON/moduleJSON/**/*ConfJSON.json"

allModulesTypesAndKinds = {}

for fileName in confJSONFilesToCompile
	moduleData = require fileName
	for typeOrKind in typeKinds
		if moduleData.typeKindList[typeOrKind]?
			values = moduleData.typeKindList[typeOrKind]
			if allModulesTypesAndKinds[typeOrKind]?
				compiledTypesAndKinds = allModulesTypesAndKinds[typeOrKind]
				for value in values
					if _.findWhere(compiledTypesAndKinds, value) is undefined
						compiledTypesAndKinds.push value
				delete allModulesTypesAndKinds[typeOrKind]
				allModulesTypesAndKinds[typeOrKind] = compiledTypesAndKinds
			else
				allModulesTypesAndKinds[typeOrKind] = values
jsonfilestring = JSON.stringify allModulesTypesAndKinds
compiledModuleConfsFileName = "#{ACAS_HOME}/public/javascripts/conf/confJSON/CompiledModuleConfJSONs.json"
fs.writeFileSync compiledModuleConfsFileName, jsonfilestring

async = require 'async'
request = require 'request'
data = require "#{ACAS_HOME}/public/javascripts/conf/confJSON/CompiledModuleConfJSONs.json"
config = require "#{ACAS_HOME}/conf/compiled/conf.js"

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
