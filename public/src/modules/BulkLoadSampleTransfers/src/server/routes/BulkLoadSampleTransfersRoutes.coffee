### To install this Module
1) Add these lines to app.coffee:
# BulkLoadSampleTransfers routes
bulkLoadSampleTransfersRoutes = require './routes/BulkLoadSampleTransfersRoutes.js'
app.post '/api/bulkLoadSampleTransfers', bulkLoadSampleTransfersRoutes.bulkLoadSampleTransfers

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Sample Transfer Log", mainControllerClassName: "BulkLoadSampleTransfersController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
# For BulkLoadSampleTransfers module
'javascripts/src/BulkLoadSampleTransfers.js'

###


exports.bulkLoadSampleTransfers = (request, response)  ->
	request.connection.setTimeout 6000000
#	console.log "bulkload called"
#	setTimeout =>
#		console.log "timeout over"
#		response.end "sending response now"
#	,
#		125000

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

