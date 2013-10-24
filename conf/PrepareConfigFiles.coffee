csUtilities = require "../public/src/conf/CustomerSpecificServerFunctions.js"

properties = require "properties"

options =
	path: true
	namespaces: true
	sections: true
	variables: true
	include: true

configDir = "./"

properties.parse configDir+"config.properties", options, (error, env) ->
	console.log error
	console.log env

#  global.deployMode may be overwritten in prepareConfigFile
global.deployMode = "Dev"

#csUtilities.fillConfigTemplateFile ->
#	#csUtilities.logUsage("Configuration file generated", "deployMode: "+deployMode, "")
#	console.log "completed template substitutions"

prepareRooConfig = ->
	config = require '../public/src/conf/configurationNode.js'
	fs = require('fs')

	configOut = ""
	for attr, value of config.serverConfigurationParams.configuration
		configOut += attr+"="+value+"\n"
	fs.writeFile "../public/src/conf/acas_roo.properties", configOut


