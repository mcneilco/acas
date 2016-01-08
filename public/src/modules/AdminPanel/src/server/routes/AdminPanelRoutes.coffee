### To install this Module
1) Add these lines to app.coffee:
	# GenericDataParser routes
	genericDataParserRoutes = require './public/src/modules/GenericDataParser/src/server/routes/GenericDataParserRoutes.js'
	genericDataParserRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load From Generic Format", mainControllerClassName: "GenericDataParserController"}

###
exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/adminPanel', loginRoutes.ensureAuthenticated, exports.parseAdminPanel
	
exports.parseAdminPanel = (request, response)  ->
	request.connection.setTimeout 6000000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/EchoPlateFile/src/server/AdminPanelStub.R",
			"parseAdminPanel",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/EchoPlateFile/src/server/adminPanel.R",
			"external.parseCreateFiles",
			(rReturn) ->
				response.end rReturn
		)
