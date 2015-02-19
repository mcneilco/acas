exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.post '/api/validateName/:lsKind', exports.validateName

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.post '/api/validateName/:lsKind', loginRoutes.ensureAuthenticated, exports.validateName

exports.thingByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postThingParent = (req, resp) ->
	console.log "post thing parent"
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind
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
				console.log 'got ajax error trying to save lsThing'
				console.log error
				console.log json
				console.log response
#				if response.body[0].message is "not unique lsThing name"
#					console.log "ending resp"
#					resp.end JSON.stringify response.body[0].message
#
		)

exports.postThingBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingTestJSON.thingBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/?parentIdOrCodeName="+req.params.parentCode
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
				console.log 'got ajax error trying to save lsThing'
				console.log error
				console.log json
				console.log response
#				if response.body[0].message is "not unique lsThing name"
#					console.log "ending resp"
#					resp.end JSON.stringify response.body[0].message
#
		)

exports.putThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/"+req.params.code
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
				console.log 'got ajax error trying to update lsThing'
				console.log error
				console.log response
		)

exports.batchesByParentCodeName = (req, resp) ->
	console.log "get batches by parent codeName"
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingServiceTestJSON.batchList
	else
		if req.params.parentCode is "undefined"
			resp.end JSON.stringify []
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/"+req.params.lsKind+"/getbatches/"+req.params.parentCode
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.validateName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify true
	else
		console.log "validate name"
		console.log req
		console.log JSON.stringify req.body.requestName
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/validatename?lsKind="+req.params.lsKind
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.requestName
			json: true
		, (error, response, json) =>
			console.log error
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save thing parent'
				console.log error
				console.log json
				console.log response
		)
