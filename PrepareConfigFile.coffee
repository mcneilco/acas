csUtilities = require "./public/src/conf/CustomerSpecificServerFunctions.js"

#  global.deployMode may be overwritten in prepareConfigFile
global.deployMode = "Dev"

csUtilities.prepareConfigFile ->
	csUtilities.logUsage("Configuration file generated", "deployMode: "+deployMode, "")

