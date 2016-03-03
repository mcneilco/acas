### To install this Module
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Experiment Browser", mainControllerClassName: "ExperimentBrowserController"}


###

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experimentsForProtocol/:protocolCode', loginRoutes.ensureAuthenticated, exports.experimentsForProtocol

exports.experimentsForProtocol = (req, resp) ->
	fixturesData = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
	config = require '../conf/compiled/conf.js'


	baseurl = config.all.client.service.persistence.fullpath+"experiments/protocol/#{req.params.protocolCode}"
	console.log "baseurl"
	console.log baseurl

	request = require 'request'
	request(
		method: 'GET'
		url: baseurl
		body: req.body
		json: true
	, (error, response, json) =>
		#if !error && response.statusCode == 201
		if !error
			console.log JSON.stringify json
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to save new experiment'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

	#response.send fixturesData.listOfExperiments


