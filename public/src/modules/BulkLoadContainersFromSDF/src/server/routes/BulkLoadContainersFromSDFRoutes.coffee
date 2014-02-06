### To install this Module
1) add to app.coffee
  # BulkLoadContainersFromSDF routes
	bulkLoadContainersFromSDFRoutes = require './public/src/modules/BulkLoadContainersFromSDF/src/server/routes/BulkLoadContainersFromSDFRoutes.js'
	bulkLoadContainersFromSDFRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Containers From SDF", mainControllerClassName: "BulkLoadContainersFromSDFController"}

###

exports.setupRoutes = (app) ->
	app.post '/api/bulkLoadContainersFromSDF', exports.bulkLoadContainersFromSDF


exports.bulkLoadContainersFromSDF = (request, response)  ->
	request.connection.setTimeout 6000000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDFStub.R",
			"bulkLoadContainersFromSDF",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDF.R",
			"bulkLoadContainersFromSDF",
		(rReturn) ->
			response.end rReturn
		)

