exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:id', loginRoutes.ensureAuthenticated, exports.thingById
	app.get '/api/things/codeName/:code', loginRoutes.ensureAuthenticated, exports.thingByCodename
	app.post '/api/things', loginRoutes.ensureAuthenticated, exports.postThing
	app.put '/api/things/:id', loginRoutes.ensureAuthenticated, exports.putThing
	app.delete '/api/things/:id', loginRoutes.ensureAuthenticated, exports.deleteThing
	app.get '/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors #TODO: in 1.4 implemented in BaseEntityServiceRoutes
	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName

exports.thingByCodename = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingTestJSON.js'
#		resp.end JSON.stringify thingTestJSON.siRNA
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/cationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "get thing by codename not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		baseurl = config.all.client.service.persistence.fullpath+"thing/codename/"+req.params.code
#		fullObjectFlag = "with=fullobject"
#		if req.query.fullObject
#			baseurl += "?#{fullObjectFlag}"
#			serverUtilityFunctions.getFromACASServer(baseurl, resp)
#		else
#			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.thingById = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingTestJSON.js'
		resp.end JSON.stringify thingTestJSON.siRNA
	else
		resp.end JSON.stringify {error: "get thing by id not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"thing/"+req.params.id
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.postThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingTestJSON.js'
#		resp.end JSON.stringify thingTestJSON.siRNA
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "post thing not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"thing"
#		request = require 'request'
#		request(
#			method: 'POST'
#			url: baseurl
#			body: req.body
#			json: true
#		, (error, response, json) =>
#			if !error && response.statusCode == 201
#				console.log JSON.stringify json
#				resp.end JSON.stringify json
#			else
#				console.log 'got ajax error trying to save new thing'
#				console.log error
#				console.log json
#				console.log response
#		)

exports.putThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingTestJSON.js'
#		resp.end JSON.stringify thingTestJSON.siRNA
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "put thing not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		putId = req.body.id
#		console.log "putID"
#		console.log putId
#		baseurl = config.all.client.service.persistence.fullpath+"things/"+putId
#		request = require 'request'
#		request(
#			method: 'PUT'
#			url: baseurl
#			body: req.body
#			json: true
#		, (error, response, json) =>
#			console.log response.statusCode
#			if !error && response.statusCode == 200
#				console.log JSON.stringify json
#				resp.end JSON.stringify json
#			else
#				console.log 'got ajax error trying to save new experiment'
#				console.log error
#				console.log response
#		)
#

exports.deleteThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		resp.end JSON.stringify {message: "deleted thing"}
	else
		resp.end JSON.stringify {error: "delete thing not implemented yet"}
#
#		# route to handle deleting experiments
#		#curl -i -X DELETE -H Accept:application/json -H Content-Type:application/json  http://host4.labsynch.com:8080/acas/experiments/406773
#		config = require '../conf/compiled/conf.js'
#		experimentId = req.params.id
#		baseurl = config.all.client.service.persistence.fullpath+"experiments/"+experimentId
#		console.log "baseurl"
#		console.log baseurl
#		request = require 'request'
#
#		request(
#			method: 'DELETE'
#			url: baseurl
#			json: true
#		, (error, response, json) =>
#			console.log response.statusCode
#			if !error && response.statusCode == 200
#				console.log JSON.stringify json
#				res.end JSON.stringify json
#			else
#				console.log 'got ajax error trying to save new experiment'
#				console.log error
#				console.log response
#		)


exports.getAuthors = (req, resp) ->
	console.log "getting authors"
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingServiceTestJSON.authorsList
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"authors/codeTable"
		console.log baseurl
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockServiceTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify cationicBlockServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)
