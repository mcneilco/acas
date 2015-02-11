_ = require "underscore"

exports.setupAPIRoutes = (app) ->
	app.get '/api/codetables/:type/:kind', exports.getCodeTableValues

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/codetables/:type/:kind', loginRoutes.ensureAuthenticated, exports.getCodeTableValues

exports.getCodeTableValues = (req, resp) ->
	if global.specRunnerTestmode
		codeTableServiceTestJSON = require '../public/javascripts/spec/testFixtures/CodeTableJSON.js'
		correctCodeTable = _.findWhere(codeTableServiceTestJSON.codes, {type:req.params.type, kind:req.params.kind})
		resp.end JSON.stringify correctCodeTable['codes']

	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"ddictvalues/all/"+req.params.type+"/"+req.params.kind+"/codetable"
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get protocol labels'
				console.log error
				console.log json
				console.log response
		)

