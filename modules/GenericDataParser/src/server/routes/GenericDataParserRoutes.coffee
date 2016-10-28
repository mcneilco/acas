### To install this Module
1) Add these lines to app.coffee:
	# GenericDataParser routes
	genericDataParserRoutes = require './public/src/modules/GenericDataParser/src/server/routes/GenericDataParserRoutes.js'
	genericDataParserRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load From Generic Format", mainControllerClassName: "GenericDataParserController"}

###
exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/genericDataParser', loginRoutes.ensureAuthenticated, exports.parseGenericData


exports.parseGenericData = (request, response)  ->
	request.connection.setTimeout 6000000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/GenericDataParser/GenericDataParserStub.R",
			"parseGenericData",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/GenericDataParser/generic_data_parser.R",
			"parseGenericData",
			(rReturn) ->
				response.end rReturn
		)




