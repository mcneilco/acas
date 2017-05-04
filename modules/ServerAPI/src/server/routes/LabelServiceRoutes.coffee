exports.setupAPIRoutes = (app) ->
	app.post '/api/getNextLabelSequence', exports.getNextLabelSequence

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/getNextLabelSequence', loginRoutes.ensureAuthenticated, exports.getNextLabelSequence

exports.getNextLabelSequence = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		labelServiceTestJSON = require '../public/javascripts/spec/testFixtures/LabelServiceTestJSON.js'
		resp.json labelServiceTestJSON.nextLabelSequenceResponse
	else
		exports.getNextLabelSequenceInternal req.body, (callback) ->
			resp.json callback

exports.getNextLabelSequenceInternal = (labelSequence, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"labelsequences/getLabels"
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: labelSequence
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback json
		else
			console.log 'got ajax error trying to get next label sequence'
			console.log error
			console.log json
			console.log response
			callback "getNextLabelSequenceFailed"
	)
