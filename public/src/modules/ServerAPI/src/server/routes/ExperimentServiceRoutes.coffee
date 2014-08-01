exports.setupAPIRoutes = (app) ->
	app.get '/api/experiments/codename/:code', exports.experimentByCodename
	app.get '/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', exports.experimentById
	app.post '/api/experiments', exports.postExperiment
	app.put '/api/experiments/:id', exports.putExperiment
	app.get '/api/experimentStatusCodes', exports.getExperimentStatusCodes


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename
	app.get '/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById
	app.post '/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment
	app.put '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment
<<<<<<< HEAD
	app.get '/api/experimentStatusCodes', loginRoutes.ensureAuthenticated, exports.getExperimentStatusCodes
=======
	app.get '/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch
	app.get '/api/experiments/edit/:experimentCodeName', loginRoutes.ensureAuthenticated, exports.editExperimentLookupAndRedirect
	app.delete '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.deleteExperiment
>>>>>>> development

exports.experimentByCodename = (request, response) ->
	console.log request.params.code
	console.log request.query.testMode
	if (request.query.testMode is true) or (global.specRunnerTestmode is true)
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+request.params.code
		fullObjectFlag = "with=fullobject"
		if request.query.fullObject
			baseurl += "?#{fullObjectFlag}"
			serverUtilityFunctions.getFromACASServer(baseurl, response)
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

exports.getExperimentStatusCodes = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.json experimentServiceTestJSON.experimentStatusCodes
	else
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.json experimentServiceTestJSON.experimentStatusCodes

#TODO: make a real implementation

exports.genericExperimentSearch = (req, res) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		if req.params.searchTerm == "no-match"
			emptyResponse = []
			res.end JSON.stringify emptyResponse
		else
			res.end JSON.stringify [experimentServiceTestJSON.fullExperimentFromServer]
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

exports.deleteExperiment = (req, res) ->
	# route to handle deleting experiments
	#curl -i -X DELETE -H Accept:application/json -H Content-Type:application/json  http://host4.labsynch.com:8080/acas/experiments/406773
	config = require '../conf/compiled/conf.js'
	experimentId = req.params.id
	baseurl = config.all.client.service.persistence.fullpath+"experiments/"+experimentId
	console.log "baseurl"
	console.log baseurl
	request = require 'request'

	request(
		method: 'DELETE'
		url: baseurl
		json: true
	, (error, response, json) =>
		console.log response.statusCode
		if !error && response.statusCode == 200
			console.log JSON.stringify json
			res.end JSON.stringify json
		else
			console.log 'got ajax error trying to save new experiment'
			console.log error
			console.log response
	)
