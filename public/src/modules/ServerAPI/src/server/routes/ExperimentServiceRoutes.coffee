

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename
	app.get '/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById
	app.post '/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment
	app.put '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment
	app.get '/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch
	app.get '/api/experiments/edit/:experimentCodeName', loginRoutes.ensureAuthenticated, exports.editExperimentLookupAndRedirect

exports.experimentByCodename = (request, response) ->
	console.log request.params.code
	console.log request.query.testMode

	if request.query.testMode or global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+request.params.code
		if request.query.fullObject
			baseurl += "?#{fullObjectFlag}"
			serverUtilityFunctions.getSingleObjectFromACASServer(baseurl, response)
		else
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

exports.genericExperimentSearch = (req, res) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		res.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		json = {message: "genericExperimentSearch not implemented yet"}
		res.end JSON.stringify json

exports.editExperimentLookupAndRedirect = (req, res) ->
	if global.specRunnerTestmode
		json = {message: "got to edit experiment redirect"}
		res.end JSON.stringify json
	else
		json = {message: "genericExperimentSearch not implemented yet"}
		res.end JSON.stringify json
