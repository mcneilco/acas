exports.setupAPIRoutes = (app) ->
	app.get '/api/experiments/codename/:code', exports.experimentByCodename
	app.get '/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', exports.experimentById
	app.post '/api/experiments', exports.postExperiment
	app.put '/api/experiments/:id', exports.putExperiment


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename
	app.get '/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById
	app.post '/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment
	app.put '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment
	app.get '/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch
	app.get '/api/experiments/edit/:experimentCodeName', loginRoutes.ensureAuthenticated, exports.editExperimentLookupAndRedirect
	app.delete '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.deleteExperiment
	app.get '/api/experiments/resultViewerURL/:code', loginRoutes.ensureAuthenticated, exports.resultViewerURLByExperimentCodename

exports.experimentByCodename = (req, resp) ->
	console.log req.params.code
	console.log req.query.testMode
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
#		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
		expt = JSON.parse(JSON.stringify (experimentServiceTestJSON.fullExperimentFromServer))

		if req.params.code.indexOf("screening") > -1
			expt.lsKind = "flipr screening assay"

		else
			expt.lsKind = "default"

		resp.json expt

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

exports.resultViewerURLByExperimentCodename = (request, resp) ->
	console.log __dirname
	_ = require '../public/src/lib/underscore.js'
	if (request.query.testMode is true) or (global.specRunnerTestmode is true)
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.resultViewerURLByExperimentCodeName
	else
		config = require '../conf/compiled/conf.js'
		if config.all.client.service.result && config.all.client.service.result.viewer && config.all.client.service.result.viewer.experimentPrefix? && config.all.client.service.result.viewer.protocolPrefix? && config.all.client.service.result.viewer.experimentNameColumn?
			resultViewerURL = [resultViewerURL: ""]
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+request.params.code
			request = require 'request'
			request(
				method: 'GET'
				url: baseurl
				json: true
			, (error, response, experiment) =>
				if !error && response.statusCode == 200
					if experiment.length == 0
						resp.statusCode = 404
						resp.json resultViewerURL
					else
						baseurl = config.all.client.service.persistence.fullpath+"protocols/"+experiment[0].protocol.id
						request = require 'request'
						request(
							method: 'GET'
							url: baseurl
							json: true
						, (error, response, protocol) =>
							if response.statusCode == 404
								resp.statusCode = 404
								resp.json resultViewerURL
							else
								if !error && response.statusCode == 200
									preferredExperimentLabel = _.filter experiment[0].lsLabels, (lab) ->
										lab.preferred && lab.ignored==false
									preferredExperimentLabelText = preferredExperimentLabel[0].labelText
									if config.all.client.service.result.viewer.experimentNameColumn == "EXPERIMENT_NAME"
										experimentName = experiment[0].codeName + "::" + preferredExperimentLabelText
									else
										experimentName = preferredExperimentLabelText
									preferredProtocolLabel = _.filter protocol.lsLabels, (lab) ->
										lab.preferred && lab.ignored==false
									preferredProtocolLabelText = preferredProtocolLabel[0].labelText
									resp.json
										resultViewerURL: config.all.client.service.result.viewer.protocolPrefix + encodeURIComponent(preferredProtocolLabelText) + config.all.client.service.result.viewer.experimentPrefix + encodeURIComponent(experimentName)
								else
									console.log 'got ajax error trying to save new experiment'
									console.log error
									console.log json
									console.log response
						)
				else
					console.log 'got ajax error trying to save new experiment'
					console.log error
					console.log json
					console.log response
			)
		else
			resp.statusCode = 500
			resp.end "configuration client.service.result.viewer.protocolPrefix and experimentPrefix and experimentNameColumn must exist"