exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', exports.thingsByTypeKind
	app.get '/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.post '/api/validateName', exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', exports.getAssemblies
	app.get '/api/genericSearch/things/:searchTerm', exports.genericThingSearch

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind
	app.get '/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.post '/api/validateName', loginRoutes.ensureAuthenticated, exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', loginRoutes.ensureAuthenticated, exports.getAssemblies
	app.get '/api/genericSearch/things/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericThingSearch


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
		else if req.query.prettyjson
			prettyjson = "with=prettyjson"
			baseurl += "?#{prettyjson}"
		else if req.query.stub
			stub = "with=stub"
			baseurl += "?#{stub}"
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				if response? and response.statusCode == 404 and json?[0]? and json[0].errorLevel is "error" and json[0].message.indexOf("not found")>-1
					resp.end JSON.stringify json
				else
					resp.end "Error getting thing by codeName"
		)



updateThing = (thing, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serverUtilityFunctions.createLSTransaction thing.recordedDate, "updated experiment", (transaction) ->
		thing = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thing
		if testMode or global.specRunnerTestmode
			callback thing
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+thing.lsType+"/"+thing.lsKind+"/"+thing.codeName+ "?with=nestedfull"
			request = require 'request'
			request(
				method: 'PUT'
				url: baseurl
				body: thing
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 200 and json.id?
					callback json
				else
					console.log 'got ajax error trying to update lsThing'
					console.log error
					console.log response
					callback "update lsThing failed"
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
			else
				baseurl += "?with=nestedfull"
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
					resp.end JSON.stringify "update lsThing failed"
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
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.data
			json: true
		, (error, response, json) =>
			console.log "validate response"
			console.log response.statusCode
			console.log response.json
			if !error && response.statusCode == 202
				resp.json json
			else if response.statusCode == 409
				console.log "not unique name - 409"
				console.log error
				console.log response
				console.log json
				resp.json json
			else
				console.log 'got ajax error trying to validate thing name'
				console.log error
				console.log json
				console.log response
				resp.json "validate name failed"
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
				console.log json
				console.log response
				callback json
		)

exports.genericThingSearch = (req, resp) ->
	console.log "generic thing search"
	console.log req.query.testMode
	console.log global.specRunnerTestmode
	if req.query.testMode is true or global.specRunnerTestmode is true
		resp.end JSON.stringify "Stubs mode not implemented yet"
	else
		config = require '../conf/compiled/conf.js'
		console.log "search req"
		console.log req
		if req.query.lsType?
			typeFilter = "lsType=" + req.query.lsType
		if req.query.lsKind?
			kindFilter = "lsKind=" + req.query.lsKind
		searchTerm = "q=" + req.params.searchTerm

		searchParams = ""
		if typeFilter?
			searchParams += typeFilter + "&"
		if kindFilter?
			searchParams += kindFilter + "&"
		searchParams += searchTerm

		baseurl = config.all.client.service.persistence.fullpath+"lsthings/search?"+searchParams
		#		baseurl = config.all.client.service.persistence.fullpath+"lsthings/search?lsType=batch&q="+req.params.searchTerm
		console.log "generic thing search baseurl"
		console.log baseurl
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getProjectCodesFromNamesOrCodes = (codeRequest, callback) ->
	#TODO: real implementation
	console.log "got to getProjectCodesFromNamesOrCodes"
	results = []
	for req in codeRequest.requests
		res = requestName: req.requestName
		if req.requestName.indexOf("ambiguous") > -1
			res.projectCode = ""
		else if req.requestName.indexOf("name") > -1
			res.projectCode = "GENE1111"
		else if req.requestName.indexOf("1111") > -1
			res.projectCode = "GENE1111"
		else
			res.projectCode = ""
		results.push res
	response =
		thingType: codeRequest.thingType
		thingKind: codeRequest.thingKind
		results: results

	callback response
