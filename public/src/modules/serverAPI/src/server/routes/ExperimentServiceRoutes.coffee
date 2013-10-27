### To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
experimentRoutes = require './routes/ExperimentServiceRoutes.js'
app.get '/api/experiments/codename/:code', experimentRoutes.experimentByCodename
app.get '/api/experiments/:id', experimentRoutes.experimentById
app.post '/api/experiments', experimentRoutes.postExperiment
app.put '/api/experiments', experimentRoutes.putExperiment


###

exports.experimentByCodename = (request, response) ->
	console.log request.params.code
	console.log request.query.testMode

	if request.query.testMode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		response.end JSON.stringify experimentServiceTestJSON.stubSavedExperiment

exports.experimentById = (req, resp) ->
	console.log req.params.id
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistance.fullpath+"/experiments/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postExperiment = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistance.fullpath+"/experiments"
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
		baseurl = config.all.client.service.persistance.fullpath+"/experiments"
		request = require 'request'
		request(
			method: 'PUT'
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




