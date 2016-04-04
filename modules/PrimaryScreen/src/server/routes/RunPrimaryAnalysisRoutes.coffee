exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/primaryAnalysis/runPrimaryAnalysis', loginRoutes.ensureAuthenticated, exports.runPrimaryAnalysis

exports.runPrimaryAnalysis = (request, response)  ->
	request.connection.setTimeout 180000000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	console.log request.body

	response.writeHead(200, {'Content-Type': 'application/json'});

	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/PrimaryScreen/PrimaryAnalysisStub.R",
			"runPrimaryAnalysis",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/PrimaryScreen/PrimaryAnalysis.R",
			"runPrimaryAnalysis",
			(rReturn) ->
				response.end rReturn
		)

