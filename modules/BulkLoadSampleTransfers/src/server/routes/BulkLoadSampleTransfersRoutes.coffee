###
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Sample Transfer Log", mainControllerClassName: "BulkLoadSampleTransfersController"}

###
exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/bulkLoadSampleTransfers', loginRoutes.ensureAuthenticated, exports.bulkLoadSampleTransfers

exports.bulkLoadSampleTransfers = (request, response)  ->
	request.connection.setTimeout 6000000

	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});

	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/BulkLoadSampleTransfers/src/server/BulkLoadSampleTransfersStub.R",
			"bulkLoadSampleTransfers",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/BulkLoadSampleTransfers/src/server/BulkLoadSampleTransfers.R",
			"bulkLoadSampleTransfers",
			(rReturn) ->
				response.end rReturn
		)

