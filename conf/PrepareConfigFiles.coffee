csUtilities = require "../public/src/conf/CustomerSpecificServerFunctions.js"
properties = require "properties"
_ = require "underscore"
underscoreDeepExtend = require "underscoreDeepExtend"
_.mixin({deepExtend: underscoreDeepExtend(_)})
fs = require 'fs'
flat = require 'flat'

global.deployMode= "Dev" # This may be overridden in getConfServiceVars()

sysEnv = process.env

csUtilities.getConfServiceVars sysEnv, (confVars) ->

	substitutions =
		env: sysEnv
		conf: confVars

	options =
		path: true
		namespaces: true
		sections: true
		variables: true
		include: true
		vars: substitutions

	configDir = "./"

	configSuffix=process.argv[2]
	if typeof configSuffix == "undefined"
		configFile = "config.properties"
		configFileAdvanced = "config_advanced.properties"
	else
		configFile = "config-"+configSuffix+".properties"
		configFileAdvanced = "config_advanced-"+configSuffix+".properties"

	console.log "Using "+configFile
	console.log "Using "+configFileAdvanced
	properties.parse configDir+configFile, options, (error, conf) ->
		if error?
			console.log "Problem parsing config.properties: "+error
		else
			properties.parse configDir+configFileAdvanced, options, (error, confAdv) ->
				if errors?
					console.log "Problem parsing config_advanced.properties: "+error
				else
					allConf = _.deepExtend confAdv, conf
					if allConf.client.deployMode == "Prod"
						allConf.server.enableSpecRunner = false
					else
						allConf.server.enableSpecRunner = true
					writeJSONFormat allConf
					writeClientJSONFormat allConf
					writePropertiesFormat allConf


writeJSONFormat = (conf) ->
	fs.writeFile "./compiled/conf.js", "exports.all="+JSON.stringify(conf)+";"

writeClientJSONFormat = (conf) ->
	fs.writeFile "../public/src/conf/conf.js", "window.conf="+JSON.stringify(conf.client)+";"

writePropertiesFormat = (conf) ->
	fs = require('fs')

	flatConf = flat.flatten conf
	configOut = ""
	for attr, value of flatConf
		if value != null
			configOut += attr+"="+value+"\n"
		else
			configOut += attr+"=\n"
	fs.writeFile "./compiled/conf.properties", configOut


