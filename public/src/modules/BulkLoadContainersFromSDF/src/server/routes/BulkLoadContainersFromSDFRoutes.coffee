### To install this Module
1) Add these lines to app.coffee:
# BulkLoadContainersFromSDF routes
bulkLoadContainersFromSDFRoutes = require './routes/BulkLoadContainersFromSDFRoutes.js'
app.post '/api/bulkLoadContainersFromSDF', bulkLoadContainersFromSDFRoutes.bulkLoadContainersFromSDF

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Containers From SDF", mainControllerClassName: "BulkLoadContainersFromSDFController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
# For BulkLoadContainersFromSDF module
'javascripts/src/BulkLoadContainersFromSDF.js'

###

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

