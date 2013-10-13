csUtilities = require "./public/src/conf/CustomerSpecificServerFunctions.js"

#  global.deployMode may be overwritten in prepareConfigFile
global.deployMode = "Dev"

csUtilities.prepareConfigFile ->
	csUtilities.logUsage("Configuration file generated", "deployMode: "+deployMode, "")
	prepareRooConfig()

prepareRooConfig = ->
	config = require './public/src/conf/configurationNode.js'
	fs = require('fs')

	configOut = ""
	for attr, value of config.serverConfigurationParams.configuration
		configOut += attr+"="+value+"\n"
	fs.writeFile "./public/src/conf/acas_roo.properties", configOut

