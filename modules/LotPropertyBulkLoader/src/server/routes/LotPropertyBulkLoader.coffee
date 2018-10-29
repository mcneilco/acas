### To install this Module

Add this line to modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
		isHeader: false
		menuName: "Substance Loader"
		mainControllerClassName: "SubstanceLoaderController"
###

exports.setupAPIRoutes = (app, loginRoutes) ->
	app.post '/api/lotPropertyBulkLoader/fileProcessor', exports.lotPropertyBulkLoader

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/lotPropertyBulkLoader/fileProcessor', loginRoutes.ensureAuthenticated, exports.lotPropertyBulkLoader

config = require '../conf/compiled/conf.js'
serverUtilityFunctions = require "./ServerUtilityFunctions"

exports.lotPropertyBulkLoader = (request, response)  ->
	request.connection.setTimeout 86400000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	serverUtilityFunctions.runRFunction(
		request,
		"src/r/LotPropertyBulkLoader/LotPropertyBulkLoader.R",
		"requestHandler",
		(rReturn) ->
			response.end rReturn
	)

