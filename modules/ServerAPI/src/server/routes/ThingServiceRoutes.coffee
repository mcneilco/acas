exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', exports.thingsByTypeKind
	app.get '/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.post '/api/validateName/:componentOrAssembly', exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', exports.getAssemblies

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind
	app.get '/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.post '/api/validateName/:componentOrAssembly', loginRoutes.ensureAuthenticated, exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', loginRoutes.ensureAuthenticated, exports.getAssemblies


exports.thingsByTypeKind = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	if req.query.format? and req.query.format=="codetable" #ie has '?format=codetable' appended to end of api route
		if req.query.testMode or global.specRunnerTestmode
			resp.end JSON.stringify "stubsMode for getting things in codetable format not implemented yet"
		else
	#		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/codetable?lsType=#{req.params.lsType}&lsKind=#{req.params.lsKind}"
			stubFlag = "with=stub"
			if req.query.stub
				baseurl += "?#{stubFlag}"
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

	else
		if req.query.testMode or global.specRunnerTestmode
			thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
			resp.end JSON.stringify thingServiceTestJSON.batchList
		else
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind
			stubFlag = "with=stub"
			if req.query.stub
				baseurl += "?#{stubFlag}"
			serverUtilityFunctions.getFromACASServer(baseurl, resp)
serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'


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
		else if req.query.prettyjson
			prettyjson = "with=prettyjson"
			baseurl += "?#{prettyjson}"
		else if req.query.stub
			stub = "with=stub"
			baseurl += "?#{stub}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)


updateThing = (thing, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serverUtilityFunctions.createLSTransaction thing.recordedDate, "updated experiment", (transaction) ->
		thing = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thing
		if testMode or global.specRunnerTestmode
			callback thing
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+thing.lsType+"/"+thing.lsKind+"/"+thing.code
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
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	thingToSave = req.body
	serverUtilityFunctions.createLSTransaction thingToSave.recordedDate, "new experiment", (transaction) ->
		thingToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thingToSave
		if req.query.testMode or global.specRunnerTestmode
			unless thingToSave.codeName?
				if isBatch
					thingToSave.codeName = "PT00002"
				else
					thingToSave.codeName = "PT00002-1"

		checkFilesAndUpdate = (thing) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity thing, false
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
				prefix = serverUtilityFunctions.getPrefixFromEntityCode thing.codeName
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
	fileVals = serverUtilityFunctions.getFileValuesFromEntity thingToSave, true
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
		prefix = serverUtilityFunctions.getPrefixFromEntityCode req.body.codeName
		for fv in fileVals
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
			if req.query.nestedstub
				nestedstub = "with=nestedstub"
				baseurl += "?#{nestedstub}"
			else if req.query.nestedfull
				nestedfull = "with=nestedfull"
				baseurl += "?#{nestedfull}"
			else if req.query.prettyjson
				prettyjson = "with=prettyjson"
				baseurl += "?#{prettyjson}"
			else if req.query.stub
				stub = "with=stub"
				baseurl += "?#{stub}"
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.validateName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json true
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/validate"
		if req.params.componentOrAssembly is "component"
			baseurl += "?uniqueName=true"
		else #is assembly
			baseurl += "?uniqueName=true&uniqueInteractions=true&orderMatters=true&forwardAndReverseAreSame=true"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.modelToSave
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 202
				resp.json json
			else if response.statusCode == 409
				resp.json "not unique name"
			else
				console.log 'got ajax error trying to save thing parent'
				console.log error
				console.log jsonthing
				console.log response
		)

exports.getAssemblies = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		resp.json []
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/getcomposites/"+req.params.componentCode
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingCodesFromNamesOrCodes = (codeRequest, callback) ->
	console.log "got to getThingCodesFormNamesOrCodes"
	if global.specRunnerTestmode
		results = []
		for req in codeRequest.requests
			res = requestName: req.requestName
			if req.requestName.indexOf("ambiguous") > -1
				res.referenceName = ""
				res.preferredName = ""
			else if req.requestName.indexOf("name") > -1
				res.referenceName = "GENE1111"
				res.preferredName = "1111"
			else if req.requestName.indexOf("1111") > -1
				res.referenceName = "GENE1111"
				res.preferredName = "1111"
			else
				res.referenceName = req.requestName
				res.preferredName = req.requestName
			results.push res
		response =
			thingType: codeRequest.thingType
			thingKind: codeRequest.thingKind
			results: results

		callback response
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/getCodeNameFromNameRequest?"
		url = baseurl+"thingType=#{codeRequest.thingType}&thingKind=#{codeRequest.thingKind}"
		postBody = requests: codeRequest.requests
		console.log postBody
		console.log url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			console.log json
			if !error and !json.error
				callback
					thingType: codeRequest.thingType
					thingKind: codeRequest.thingKind
					results: json.results
			else
				console.log 'got ajax error trying to lookup lsThing name'
				console.log error
				console.log jsonthing
				console.log response
				callback json
		)
