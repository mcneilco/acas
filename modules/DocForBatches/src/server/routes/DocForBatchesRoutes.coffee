### To install this Module
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Annotate Batches with File", mainControllerClassName: "DocForBatchesController"}

###
exports.setupRoutes = (app, loginRoutes) ->
	# app.get '/docForBatches/*', loginRoutes.ensureAuthenticated, exports.docForBatchesIndex
	# app.get '/docForBatches', loginRoutes.ensureAuthenticated, exports.docForBatchesIndex
	app.get '/api/docForBatches/:id', loginRoutes.ensureAuthenticated, exports.getDocForBatches
	app.post '/api/docForBatches', loginRoutes.ensureAuthenticated, exports.saveDocForBatches


fixturesData = require '../public/javascripts/spec/DocForBatches/testFixtures/testJSON.js'

#exports.docForBatchesIndex = (request, response) ->
#	scriptsToLoad = requiredScripts.concat applicationScripts
#	global.specRunnerTestmode = false
#	return response.render 'docForBatchesIndex',
#		title: 'Document Annotation'
#		scripts: scriptsToLoad
#		appParams:
#			loginUserName: 'jmcneil'
#			testMode: false
#			liveServiceTest: true

exports.getDocForBatches = (request, response) ->
	#console.log request.params.id
	#TODO validate that id is an int and convert it
	if request.params.id is "1"
		response.end JSON.stringify fixturesData.docForBatches
	else
		response.end JSON.stringify fixturesData.docForBatchesWithURl



exports.saveDocForBatches = (request, response)  ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});

	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/DocForBatches/DocForBatches_Stub.R",
			"saveDocForBatches",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"src/r/DocForBatches/DocForBatches.R",
			"saveDocForBatches",
			(rReturn) ->
				response.end rReturn
		)
