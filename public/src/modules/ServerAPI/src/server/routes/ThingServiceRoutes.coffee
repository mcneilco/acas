exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', exports.thingsByTypeKind
	app.get '/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.post '/api/validateName/:lsKind', exports.validateName

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind
	app.get '/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.post '/api/validateName/:lsKind', loginRoutes.ensureAuthenticated, exports.validateName


exports.thingsByTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingServiceTestJSON.batchList
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind
		stubFlag = "with=stub"
		if req.query.stub
			baseurl += "?#{stubFlag}"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'


exports.thingByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/"+req.params.code
		if req.query.nestedstub
			nestedstub = "with=nestedstub"
			baseurl += "?#{nestedstub}"
		else if req.query.nestedfull
			nestedfull = "with=nestedfull"
			baseurl += "?#{nestedfull}"
		else
		serverUtilityFunctions.getFromACASServer(baseurl, resp)


updateThing = (thing, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback thing
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+thing.lsType+"/"+thing.lsKind+"/"+thing.code
		console.log baseurl
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: thing
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log 'got ajax error trying to update lsThing'
				console.log error
				console.log response
		)


postThing = (isBatch, req, resp) ->
	console.log "post thing parent"
	#	if req.query.testMode or global.specRunnerTestmode
	#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
	#		if isBatch
	#			thingToSave = JSON.parse(JSON.stringify(thingTestJSON.thingBatch))
	#		else
	#			thingToSave = JSON.parse(JSON.stringify(thingTestJSON.thingParent))
	#	else
	thingToSave = req.body
	if req.query.testMode or global.specRunnerTestmode
		unless thingToSave.codeName?
			if isBatch
				thingToSave.codeName = "PT00002"
			else
				thingToSave.codeName = "PT00002-1"
	else

	checkFilesAndUpdate = (thing) ->
		fileVals = serverUtilityFunctions.getFileValesFromThing thing, false
		filesToSave = fileVals.length

		completeThingUpdate = (thingToUpdate)->
			updateThing thingToUpdate, req.query.testMode, (updatedThing) ->
				resp.json updatedThing

		fileSaveCompleted = (passed) ->
			if !passed
				resp.statusCode = 500
				return resp.end "file move failed"
			if --filesToSave == 0 then completeThingUpdate(thing)

		if filesToSave > 0
			prefix = serverUtilityFunctions.getPrefixFromThingCode thing.codeName
			for fv in fileVals
				console.log "updating file"
				csUtilities.relocateEntityFile fv, prefix, thing.codeName, fileSaveCompleted
		else
			resp.json thing

	if req.query.testMode or global.specRunnerTestmode
		checkFilesAndUpdate thingToSave
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind
		if isBatch
			baseurl += "/?parentIdOrCodeName="+req.params.parentCode
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: thingToSave
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				checkFilesAndUpdate json
			else
				console.log 'got ajax error trying to save lsThing'
				console.log error
				console.log json
				console.log response
		)

exports.postThingParent = (req, resp) ->
	postThing false, req, resp

exports.postThingBatch = (req, resp) ->
	postThing true, req, resp

exports.putThing = (req, resp) ->
#	if req.query.testMode or global.specRunnerTestmode
#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
#		thingToSave = JSON.parse(JSON.stringify(thingTestJSON.thingParent))
#	else
	thingToSave = req.body
	fileVals = serverUtilityFunctions.getFileValesFromThing thingToSave, true
	filesToSave = fileVals.length

	completeThingUpdate = ->
		updateThing thingToSave, req.query.testMode, (updatedThing) ->
			resp.json updatedThing

	fileSaveCompleted = (passed) ->
		if !passed
			resp.statusCode = 500
			return resp.end "file move failed"
		if --filesToSave == 0 then completeThingUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromThingCode req.body.codeName
		for fv in fileVals
			console.log fv
			console.log prefix
			console.log req.body.codeName
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, req.body.codeName, fileSaveCompleted
	else
		completeThingUpdate()


exports.batchesByParentCodeName = (req, resp) ->
	console.log "get batches by parent codeName"
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingServiceTestJSON.batchList
	else
		if req.params.parentCode is "undefined"
			resp.json []
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/"+req.params.lsKind+"/getbatches/"+req.params.parentCode
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.validateName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json true
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
				resp.json json
			else
				console.log 'got ajax error trying to save thing parent'
				console.log error
				console.log json
				console.log response
		)


