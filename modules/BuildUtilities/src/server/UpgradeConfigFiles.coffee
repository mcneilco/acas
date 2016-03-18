properties = require "properties-parser"

exports.upgradeConfigFiles = (examplePropertiesPath, customPropertiesPath, outPath) ->
	exampleConfigEditor = properties.createEditor examplePropertiesPath
	userConfigEditor = properties.createEditor customPropertiesPath

	exampleProperties = properties.parse(exampleConfigEditor.toString())
	userConfigProperties = properties.parse(userConfigEditor.toString())
	for name, userValue of userConfigProperties
		exampleConfig = exampleConfigEditor.get name
		if exampleConfig == userValue
			userConfigEditor.unset name

	userConfigEditor.save(outPath)
	console.log "#{outPath} written"


if require.main == module
	printUsageAndExit = () ->
		console.log "Usage:\n
													node UpgradeConfigFile.js config.properties.example config.properties config.properties.diff\n
													coffee UpgradeConfigFile.coffee config.properties.example config.properties config.properties.diff\n
													e.g. coffee UpgradeConfigFiles.coffee ../config.properties.example ../config.properties config.properties.diff\n"
		process.exit()

	examplePropertiesPath = process.argv[2]
	customPropertiesPath = process.argv[3]
	outPath = process.argv[4]

	if ! examplePropertiesPath? | ! customPropertiesPath? | ! outPath?
		printUsageAndExit()

	exports.upgradeConfigFiles exampleConfig, userConfig
