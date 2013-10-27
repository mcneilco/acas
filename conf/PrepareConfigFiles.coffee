csUtilities = require "../public/src/conf/CustomerSpecificServerFunctions.js"
properties = require "properties"
_ = require "underscore"
underscoreDeepExtend = require "underscoreDeepExtend"
_.mixin({deepExtend: underscoreDeepExtend(_)})
fs = require 'fs'
flat = require 'flat'

global.deployMode = "Dev"
sysEnv = process.env
global.deployMode = "Dev"


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

	properties.parse configDir+"config.properties", options, (error, conf) ->
		if error?
			console.log "Problem parsing config.properties: "+error
		else
			properties.parse configDir+"config_advanced.properties", options, (error, confAdv) ->
				if errors?
					console.log "Problem parsing config_advanced.properties: "+error
				else
					allConf = _.deepExtend confAdv, conf
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
		configOut += attr+"="+value+"\n"
	fs.writeFile "./compiled/conf.properties", configOut


