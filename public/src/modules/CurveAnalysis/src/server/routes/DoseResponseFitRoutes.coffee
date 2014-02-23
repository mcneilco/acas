
exports.setupRoutes = (app) ->
	app.post '/api/doseResponseCurveFit', exports.fitDoseResponse

exports.fitDoseResponse = (request, response)  ->
	request.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/CurveAnalysis/src/server/DoseResponseCurveFitStub.R",
			"fitDoseResponse",
		(rReturn) ->
			response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/CurveAnalysis/src/server/DoseResponseCurveFit.R",
			"fitDoseResponse",
		(rReturn) ->
			response.end rReturn
		)




