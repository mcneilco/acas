### To install this Module
1) Add these lines to app.coffee:
	# DocForBatches routes
	docForBatchesRoutes = require './public/src/modules/DocForBatches/src/server/routes/DocForBatchesRoutes.js'
	docForBatchesRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Annotate Batches with File", mainControllerClassName: "DocForBatchesController"}

###
exports.setupRoutes = (app) ->
	app.get '/docForBatches/*', exports.docForBatchesIndex
	app.get '/docForBatches', exports.docForBatchesIndex
	app.get '/api/docForBatches/:id', exports.getDocForBatches
	app.post '/api/docForBatches', exports.saveDocForBatches


fixturesData = require '../public/src/modules/DocForBatches/spec/testFixtures/testJSON.js'

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
			"public/src/modules/DocForBatches/src/server/DocForBatches_Stub.R",
			"saveDocForBatches",
			(rReturn) ->
				response.end rReturn
		)
	else
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/DocForBatches/src/server/DocForBatches.R",
			"saveDocForBatches",
			(rReturn) ->
				response.end rReturn
		)

