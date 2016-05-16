exports.setupAPIRoutes = (app) ->
#	app.post '/api/experiments/parentExperiment', exports.postParentExperiment

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experiments/parentExperiment/:id', loginRoutes.ensureAuthenticated, exports.getParentExperimentById
	app.get '/api/experiments/parentExperiment/codename/:codename', loginRoutes.ensureAuthenticated, exports.getParentExperimentByCodeName
#	app.post '/api/experiments/parentExperiment', loginRoutes.ensureAuthenticated, exports.postParentExperiment

exports.getParentExperimentById = (req, resp) ->
	if global.specRunnerTestmode
		parentExperiment = require '../public/javascripts/spec/ParentExperiment/testFixtures/ParentExperimentServiceTestJSON.js'
		resp.end JSON.stringify parentExperiment['savedParentExperiment']
	else
		config = require '../conf/compiled/conf.js'
		url = config.all.client.service.persistence.fullpath+"experiments/"+req.params.id
		request = require 'request'
		# Note: http://192.168.99.100:8080/acas/api/v1/itxexperimentexperiments?find=ByFirstExperiment&firstExperiment=1
		request
			url: url
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				experiment = json
				# TODO: fill in childExperiments, should return expt obj with states included
				resp.json experiment
			else
				console.error 'got ajax error with ' + url
				console.error error
				console.error json
				console.error response
				resp.status(500).send "got ajax error"

exports.getParentExperimentByCodeName = (req, resp) ->
	if global.specRunnerTestmode
		parentExperiment = require '../public/javascripts/spec/ParentExperiment/testFixtures/ParentExperimentServiceTestJSON.js'
		resp.end JSON.stringify parentExperiment['savedParentExperiment']
	else
		parentExperiment = require '../public/javascripts/spec/ParentExperiment/testFixtures/ParentExperimentServiceTestJSON.js'
		experimentServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/ExperimentServiceTestJSON.js'

		if req.query.childExperiments?
			if req.query.childExperiments is "fullObject"
				parentExperimentWithChildExperiments = parentExperiment['savedParentExperiment']
				parentExperimentWithChildExperiments.childExperiments = [experimentServiceTestJSON.fullSavedExperiment, experimentServiceTestJSON.fullDeletedExperiment]
				resp.end JSON.stringify parentExperimentWithChildExperiments
			else
				resp.end JSON.stringify parentExperiment['savedParentExperiment']
		else
			resp.end JSON.stringify parentExperiment['savedParentExperiment']
#		getExperimentByCodename req.params.codename, (err, prot) ->
#			if err
#				resp.statusCode = 500
#				resp.end err
#			else
#				resp.json prot
# TODO: fill in childExperiments
# TODO: add option to return childExperiments in full object (with states) format or with just min info for ParentExperiment View

#getExperimentByIdOrCodename =