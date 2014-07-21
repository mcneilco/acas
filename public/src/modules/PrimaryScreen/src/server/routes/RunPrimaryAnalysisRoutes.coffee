exports.setupAPIRoutes = (app) ->
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/instrumentReaderCodes', exports.getInstrumentReaderCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/signalDirectionCodes', exports.getSignalDirectionCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy1Codes', exports.getAggregateBy1Codes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy2Codes', exports.getAggregateBy2Codes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/transformationCodes', exports.getTransformationCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/normalizationCodes', exports.getNormalizationCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/readNameCodes', exports.getreadNameCodes


exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/primaryAnalysis/runPrimaryAnalysis', loginRoutes.ensureAuthenticated, exports.runPrimaryAnalysis
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/instrumentReaderCodes', loginRoutes.ensureAuthenticated, exports.getInstrumentReaderCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/signalDirectionCodes', loginRoutes.ensureAuthenticated, exports.getSignalDirectionCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy1Codes', loginRoutes.ensureAuthenticated, exports.getAggregateBy1Codes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy2Codes', loginRoutes.ensureAuthenticated, exports.getAggregateBy2Codes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/transformationCodes', loginRoutes.ensureAuthenticated, exports.getTransformationCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/normalizationCodes', loginRoutes.ensureAuthenticated, exports.getNormalizationCodes
	app.get '/api/primaryAnalysis/runPrimaryAnalysis/readNameCodes', loginRoutes.ensureAuthenticated, exports.getreadNameCodes


exports.runPrimaryAnalysis = (request, response)  ->
	request.connection.setTimeout 1800000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
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

exports.getInstrumentReaderCodes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.instrumentReaderCodes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.instrumentReaderCodes

exports.getSignalDirectionCodes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.signalDirectionCodes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.signalDirectionCodes

exports.getAggregateBy1Codes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.aggregateBy1Codes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.aggregateBy1Codes

exports.getAggregateBy2Codes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.aggregateBy2Codes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.aggregateBy2Codes

exports.getTransformationCodes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.transformationCodes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.transformationCodes

exports.getNormalizationCodes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.normalizationCodes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.normalizationCodes

exports.getreadNameCodes = (req, resp) ->
	if global.specRunnerTestmode
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.readNameCodes
	else
		primaryScreenTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js'
		resp.json primaryScreenTestJSON.readNameCodes

# TODO: make a real implementation

