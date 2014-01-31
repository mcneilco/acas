### To install this Module
1) Add these lines to app.coffee:
# RunPrimaryAnalysisRoutes routes
runPrimaryAnalysisRoutes = require './routes/RunPrimaryAnalysisRoutes.js'
app.post '/api/primaryAnalysis/runPrimaryAnalysis', runPrimaryAnalysisRoutes.runPrimaryAnalysis

2) Add to index.coffee
 under applicationScripts:
  	#Primary Screen module
	'javascripts/src/PrimaryScreenExperiment.js'

  under specScripts
#Primary Screen module
'javascripts/spec/RunPrimaryScreenAnalysisServiceSpec.js'
'javascripts/spec/PrimaryScreenExperimentSpec.js'

3) in layout.jade
  // for PrimaryScreen module
 include ../public/src/modules/PrimaryScreen/src/client/PrimaryScreenExperiment.html
  // for serverAPI module
  include ../public/src/modules/serverAPI/src/client/Experiment.html

###
exports.setupRoutes = (app) ->
	#	app.get '/primaryScreenExperiment/*', exports.primaryScreenExperimentIndex
	#	app.get '/primaryScreenExperiment', exports.primaryScreenExperimentIndex
	app.post '/api/primaryAnalysis/runPrimaryAnalysis', exports.runPrimaryAnalysis


#exports.primaryScreenExperimentIndex = (request, response) ->
#	scriptsToLoad = requiredScripts.concat applicationScripts
#	global.specRunnerTestmode = true
#
#	return response.render 'PrimaryScreenExperiment',
#	                       title: 'Primary Screen Experiment'
#	                       scripts: scriptsToLoad
#	                       appParams:
#		                       exampleParam: null


exports.runPrimaryAnalysis = (request, response)  ->
	request.connection.setTimeout 1800000
	serverUtilityFunctions = require '../../../../02_serverAPI/src/server/routes/ServerUtilityFunctions.js'
	console.log request.body

	response.writeHead(200, {'Content-Type': 'application/json'});

	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/PrimaryScreen/src/server/PrimaryAnalysisStub.R",
			"runPrimaryAnalysis",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R",
			"runPrimaryAnalysis",
			(rReturn) ->
				response.end rReturn
		)

