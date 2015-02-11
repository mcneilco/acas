exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/proteinParents/codename/:code', exports.proteinParentByCodeName
	app.get '/api/proteinParents/:code', exports.proteinParentByCodeName
	app.post '/api/proteinParents', exports.postProteinParent
	app.put '/api/proteinParents/:id', exports.putProteinParent
	app.get '/api/proteinBatches/codename/:code', exports.proteinBatchesByCodeName
	app.post '/api/proteinBatches/:parentCode', exports.postProteinBatch
	app.put '/api/proteinBatches/:id', exports.putProteinBatch

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/proteinParents/codename/:code', loginRoutes.ensureAuthenticated, exports.proteinParentByCodeName
	app.get '/api/proteinParents/:code', loginRoutes.ensureAuthenticated, exports.proteinParentByCodeName
	app.post '/api/proteinParents', loginRoutes.ensureAuthenticated, exports.postProteinParent
	app.put '/api/proteinParents/:id', loginRoutes.ensureAuthenticated, exports.putProteinParent
	app.get '/api/proteinBatches/codename/:code', loginRoutes.ensureAuthenticated, exports.proteinBatchesByCodeName
	app.post '/api/proteinBatches/:parentCode', loginRoutes.ensureAuthenticated, exports.postProteinBatch
	app.put '/api/proteinBatches/:id', loginRoutes.ensureAuthenticated, exports.putProteinBatch

exports.proteinParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/protein/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postProteinParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/protein"
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
				console.log 'got ajax error trying to save protein parent'
				console.log error
				console.log json
				console.log response
		)

exports.putProteinParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/protein/"+req.params.code
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
				console.log 'got ajax error trying to update protein parent'
				console.log error
				console.log response
		)

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProteinServiceTestJSON.js'
		resp.end JSON.stringify proteinServiceTestJSON.batchList
	else
		if req.params.parentCode is "undefined"
			resp.end JSON.stringify []
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/"+req.params.kind+"/getbatches/"+req.params.parentCode
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.proteinBatchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinBatch
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/protein/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postProteinBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/protein/?parentIdOrCodeName="+req.params.parentCode
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
				console.log 'got ajax error trying to save new protein batch'
				console.log error
				console.log json
				console.log response
		)

exports.putProteinBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/protein/"+req.params.code
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
