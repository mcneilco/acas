exports.setupRoutes = (app) ->
	app.post '/api/dnsKDAnalysis/runDNSKDPrimaryAnalysis', exports.runDNSKDPrimaryAnalysis

exports.runDNSKDPrimaryAnalysis = (request, response)  ->
	request.connection.setTimeout 1800000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	console.log request.body

	response.writeHead(200, {'Content-Type': 'application/json'});

	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/DNSKD/src/server/RunDNSKDPrimaryAnalysisStub.R",
			"runDNSKDPrimaryAnalysisStub",
		(rReturn) ->
			response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/DNSKD/src/server/RunDNSKDPrimaryAnalysisStub.R",
			"runDNSKDPrimaryAnalysisStub",
		(rReturn) ->
			response.end rReturn
		)

