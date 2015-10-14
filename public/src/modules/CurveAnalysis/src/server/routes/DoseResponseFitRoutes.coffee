
exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/doseResponseCurveFit', loginRoutes.ensureAuthenticated, exports.fitDoseResponse

exports.fitDoseResponse = (request, response)  ->
	request.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/DoseResponseCurveFitStub.R",
			"fitDoseResponse",
		(rReturn) ->
			response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/DoseResponseCurveFit.R",
			"fitDoseResponse",
		(rReturn) ->
			response.end rReturn
		)




