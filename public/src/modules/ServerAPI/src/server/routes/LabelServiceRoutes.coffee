exports.setupAPIRoutes = (app) ->
	app.post '/api/getNextLabelSequence', exports.getNextLabelSequence

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/getNextLabelSequence', loginRoutes.ensureAuthenticated, exports.getNextLabelSequence

exports.getNextLabelSequence = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		labelServiceTestJSON = require '../public/javascripts/spec/testFixtures/LabelServiceTestJSON.js'
		resp.json labelServiceTestJSON.nextLabelSequenceResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences/getNextLabelSequences"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get next label sequence'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "getNextLabelSequenceFailed"
		)
