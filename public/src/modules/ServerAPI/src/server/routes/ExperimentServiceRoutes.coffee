### To install this Module
1) Add these lines to app.coffee:
	experimentRoutes = require './public/src/modules/02_serverAPI/src/server/routes/ExperimentServiceRoutes.js'
	experimentRoutes.setupRoutes(app)


###
exports.setupRoutes = (app) ->
	app.get '/api/experiments/codename/:code', exports.experimentByCodename
	app.get '/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', exports.experimentById
	app.post '/api/experiments', exports.postExperiment
	app.put '/api/experiments/:id', exports.putExperiment

exports.experimentByCodename = (request, response) ->
	console.log request.params.code
	console.log request.query.testMode

	if request.query.testMode or global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+request.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, response)

exports.experimentsByProtocolCodename = (request, response) ->
	console.log request.params.code
	console.log request.query.testMode

	if request.query.testMode or global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/protocolCodename/"+request.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, response)

exports.experimentById = (req, resp) ->
	console.log req.params.id
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postExperiment = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments"
		request = require 'request'
		request(
				method: 'POST'
				url: baseurl
				body: req.body
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 201
					console.log JSON.stringify json
					resp.end JSON.stringify json
				else
					console.log 'got ajax error trying to save new experiment'
					console.log error
					console.log json
					console.log response
		)

exports.putExperiment = (req, resp) ->
	#console.log JSON.stringify req.body
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		putId = req.body.id
		baseurl = config.all.client.service.persistence.fullpath+"experiments/"+putId
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error && response.statusCode == 200
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log response
		)




