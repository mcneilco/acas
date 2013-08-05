### To install this Module
1) Add these lines to app.coffee:
# GenericDataParser routes
genericDataParserRoutes = require './routes/GenericDataParserRoutes.js'
app.post '/api/genericDataParser', genericDataParserRoutes.parseGenericData

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load From Generic Format", mainControllerClassName: "GenericDataParserController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
	# For Generic Data Parser module
	'/javascripts/src/GenericDataParser.js'

###

exports.parseGenericData = (request, response)  ->
	request.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/GenericDataParser/src/server/GenericDataParserStub.R",
			"parseGenericData",
			(rReturn) ->
				response.end rReturn
		)
	else
		logDnsUsage "Generic data parser service about to call R", "dryRunMode="+request.body.dryRunMode, request.body.user
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/GenericDataParser/src/server/generic_data_parser.R",
			"parseGenericData",
			(rReturn) ->
				response.end rReturn
				logDnsUsage "Generic data parser service returned", "dryRunMode="+request.body.dryRunMode, request.body.user
		)




