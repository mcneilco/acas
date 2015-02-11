exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/spacerParents/codename/:code', exports.spacerParentByCodeName
	app.get '/api/spacerParents/:code', exports.spacerParentByCodeName
	app.post '/api/spacerParents', exports.postSpacerParent
	app.put '/api/spacerParents/:id', exports.putSpacerParent
	app.get '/api/spacerBatches/codename/:code', exports.spacerBatchesByCodeName
	app.post '/api/spacerBatches/:parentCode', exports.postSpacerBatch
	app.put '/api/spacerBatches/:id', exports.putSpacerBatch

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/spacerParents/codename/:code', loginRoutes.ensureAuthenticated, exports.spacerParentByCodeName
	app.get '/api/spacerParents/:code', loginRoutes.ensureAuthenticated, exports.spacerParentByCodeName
	app.post '/api/spacerParents', loginRoutes.ensureAuthenticated, exports.postSpacerParent
	app.put '/api/spacerParents/:id', loginRoutes.ensureAuthenticated, exports.putSpacerParent
	app.get '/api/spacerBatches/codename/:code', loginRoutes.ensureAuthenticated, exports.spacerBatchesByCodeName
	app.post '/api/spacerBatches/:parentCode', loginRoutes.ensureAuthenticated, exports.postSpacerBatch
	app.put '/api/spacerBatches/:id', loginRoutes.ensureAuthenticated, exports.putSpacerBatch

exports.spacerParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/spacer/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postSpacerParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/spacer"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save spacer parent'
				console.log error
				console.log json
				console.log response
		)

exports.putSpacerParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/spacer/"+req.params.code
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to update spacer parent'
				console.log error
				console.log response
		)

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerServiceTestJSON = require '../public/javascripts/spec/testFixtures/SpacerServiceTestJSON.js'
		resp.end JSON.stringify spacerServiceTestJSON.batchList
	else
		if req.params.parentCode is "undefined"
			resp.end JSON.stringify []
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/"+req.params.kind+"/getbatches/"+req.params.parentCode
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.spacerBatchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerBatch
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/spacer/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postSpacerBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/spacer/?parentIdOrCodeName="+req.params.parentCode
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new spacer batch'
				console.log error
				console.log json
				console.log response
		)

exports.putSpacerBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/spacer/"+req.params.code
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log response
		)
