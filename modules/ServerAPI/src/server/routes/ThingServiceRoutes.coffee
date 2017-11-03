exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', exports.thingsByTypeKind
	app.get '/api/things/getMultipleKinds/:lsType/:lsKindsList', exports.thingsByTypeAndKinds
	app.get '/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', exports.thingByCodeName
	app.post '/api/getThingCodeByLabel/:thingType/:thingKind', exports.getThingCodeByLabel
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.post '/api/validateName', exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', exports.getAssemblies
	app.get '/api/genericSearch/things/:searchTerm', exports.genericThingSearch
	app.get '/api/getThingThingItxsByFirstThing/:firstThingId', exports.getThingThingItxsByFirstThing
	app.get '/api/getThingThingItxsBySecondThing/:secondThingId', exports.getThingThingItxsBySecondThing
	app.get '/api/getThingThingItxsByFirstThing/:lsType/:lsKind/:firstThingId', exports.getThingThingItxsByFirstThingAndItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/:lsType/:lsKind/:secondThingId', exports.getThingThingItxsBySecondThingAndItxTypeKind
	app.get '/api/getThingThingItxsByFirstThing/exclude/:lsType/:lsKind/:firstThingId', exports.getThingThingItxsByFirstThingAndExcludeItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/exclude/:lsType/:lsKind/:secondThingId', exports.getThingThingItxsBySecondThingAndExcludeItxTypeKind
	app.get '/api/getThingCodeTablesByLabelText/:lsType/:lsKind/:labelText', exports.getThingsByTypeAndKindAndLabelTypeAndLabelText
	app.post '/api/things/:lsType/:lsKind/codeNames/jsonArray', exports.getThingsByCodeNames
	app.get '/api/thingKinds', exports.getThingKinds
	app.post '/api/bulkPostThings', exports.bulkPostThings
	app.put '/api/bulkPutThings', exports.bulkPutThings


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind
	app.get '/api/things/getMultipleKinds/:lsType/:lsKindsList', loginRoutes.ensureAuthenticated, exports.thingsByTypeAndKinds
	app.get '/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.post '/api/getThingCodeByLabel/:thingType/:thingKind', loginRoutes.ensureAuthenticated, exports.getThingCodeByLabel
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.post '/api/validateName', loginRoutes.ensureAuthenticated, exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', loginRoutes.ensureAuthenticated, exports.getAssemblies
	app.get '/api/genericSearch/things/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericThingSearch
	app.get '/api/getThingThingItxsByFirstThing/:firstThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsByFirstThing
	app.get '/api/getThingThingItxsBySecondThing/:secondThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsBySecondThing
	app.get '/api/getThingThingItxsByFirstThing/:lsType/:lsKind/:firstThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsByFirstThingAndItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/:lsType/:lsKind/:secondThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsBySecondThingAndItxTypeKind
	app.get '/api/getThingThingItxsByFirstThing/exclude/:lsType/:lsKind/:firstThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsByFirstThingAndExcludeItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/exclude/:lsType/:lsKind/:secondThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsBySecondThingAndExcludeItxTypeKind
	app.get '/api/getThingCodeTablesByLabelText/:lsType/:lsKind/:labelText', loginRoutes.ensureAuthenticated, exports.getThingsByTypeAndKindAndLabelTypeAndLabelText
	app.post '/api/things/:lsType/:lsKind/codeNames/jsonArray', loginRoutes.ensureAuthenticated, exports.getThingsByCodeNames
	app.get '/api/thingKinds', loginRoutes.ensureAuthenticated, exports.getThingKinds
	app.post '/api/bulkPostThings', loginRoutes.ensureAuthenticated, exports.bulkPostThings
	app.put '/api/bulkPutThings', loginRoutes.ensureAuthenticated, exports.bulkPutThings

request = require 'request'

exports.thingsByTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingServiceTestJSON.batchList
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind
		stubFlag = "with=stub"
		codeTableFlag = "with=codetable"
		if req.query.stub
			baseurl += "?#{stubFlag}"
		else if req.query.codetable
			baseurl += "?#{codeTableFlag}"
			if req.query.labelType?
				baseurl += "&labelType=#{req.query.labelType}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
_ = require 'underscore'

exports.getThingsByTypeAndKindAndLabelTypeAndLabelText = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingServiceTestJSON.batchList
	else
		exports.getThingsByTypeAndKindAndLabelTypeAndLabelTextInternal req.params.lsType, req.params.lsKind, req.query.labelType, req.params.labelText, null, (codeTables) ->
			resp.json codeTables

exports.getThingsByTypeAndKindAndLabelTypeAndLabelTextInternal = (thingType, thingKind, labelType, labelText, format, callback) ->
	searchJSON =
		lsType: thingType
		lsKind: thingKind
		labels: []
	searchJSON.labels.push
		labelType: if labelType? then labelType else null
		labelText: labelText
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+'lsthings/genericInteractionSearch'
	console.log baseurl
	request = require 'request'
	if format?
		params =
			with: format
	else
		params =
			with: 'codeTable'
	if labelType?
		params.labelType = labelType
	request(
		method: 'POST'
		url: baseurl
		qs: params
		body: searchJSON
		json: true
	, (error, response, json) =>
		console.log response.statusCode
		if !error && response.statusCode == 200
			callback json.results
	)

getThingByTypeAndKind = (lsType, lsKind, stub, callback) =>
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+lsType+"/"+lsKind
	console.log "in getThingByTypeAndKind"
	if stub
		baseurl += "?with=stub"
		console.log "baseurl for getting multiple"
		console.log baseurl
	request = require 'request'
	request(
		method: 'GET'
		url: baseurl
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log "get json"
			console.log json
			callback json

		else
			console.log error
			callback "error getting things with type: "+ lsType + " and kind: " + lsKind
	)

exports.thingsByTypeAndKinds = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingServiceTestJSON.batchList
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		kinds = req.params.lsKindsList.split(";") #lsKindsList = semi-colon delimited list
		index = 0
		fetchedThings = []
		if index >= kinds.length
			resp.json JSON.stringify fetchedThings
		else
			getThingByTypeAndKind req.params.lsType, kinds[0], false, (response) =>
				if response.indexOf("error") > -1
					resp.end JSON.stringify response
				else
					fetchedThings = response
					getThingByTypeAndKind req.params.lsType, kinds[1], true, (response2) =>
						if response2.indexOf("error") > -1
							resp.end JSON.stringify response2
						else
							console.log fetchedThings
							console.log "response2"
							console.log response2
							resp.json fetchedThings.concat response2...

exports.thingByCodeName = (req, resp) ->
	getThing req, req.params.code, (thing) ->
		if typeof thing is 'string'
			resp.statusCode = 500
			resp.end thing
		else
			resp.json thing


#	if req.query.testMode or global.specRunnerTestmode
#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
#		resp.json thingTestJSON.thingParent
#	else
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/"+req.params.code
#		if req.query.nestedstub
#			nestedstub = "with=nestedstub"
#			baseurl += "?#{nestedstub}"
#		else if req.query.nestedfull
#			nestedfull = "with=nestedfull"
#			baseurl += "?#{nestedfull}"
#		else if req.query.prettyjson
#			prettyjson = "with=prettyjson"
#			baseurl += "?#{prettyjson}"
#		else if req.query.stub
#			stub = "with=stub"
#			baseurl += "?#{stub}"
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)

getThing = (req, codeName, callback) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		callback thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/"+ encodeURIComponent codeName
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
				callback json
			else
				console.log 'got ajax error trying to get lsThing after get'
				console.log error
				console.log json
				console.log response
				callback "getting lsThing by codeName failed"
		)



updateThing = (thing, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
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
			if !error && response.statusCode == 200 and json.codeName?
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
	if thingToSave.transactionOptions?
		transactionOptions = thingToSave.transactionOptions
		delete thingToSave.transactionOptions
	else
		transactionOptions = {
			comments: "new experiment"
		}
	transactionOptions.recordedBy = req.session.passport.user.username
	transactionOptions.status = "PENDING"
	transactionOptions.type = "NEW"
	serverUtilityFunctions.createLSTransaction2 thingToSave.recordedDate, transactionOptions, (transaction) ->
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
					transaction.status = 'COMPLETED'
					serverUtilityFunctions.updateLSTransaction transaction, (transaction) ->
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
					transaction.status = 'COMPLETED'
					serverUtilityFunctions.updateLSTransaction transaction, (transaction) ->
						console.log transaction
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
					req.query.nestedfull=true
					getThing req, json.codeName, (thing) ->
						checkFilesAndUpdate thing
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
	if thingToSave.transactionOptions?
		thingToSave.transactionOptions.recordedBy = req.session.passport.user.username
	completeThingUpdate = ->
		if thingToSave.transactionOptions?
			transactionOptions = thingToSave.transactionOptions
			delete thingToSave.transactionOptions
		else
			transactionOptions = {
				comments: "updated experiment"
			}
		transactionOptions.status = "COMPLETED"
		transactionOptions.type = "CHANGE"
		serverUtilityFunctions.createLSTransaction2 thingToSave.recordedDate, transactionOptions, (transaction) ->
			thingToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thingToSave
			updateThing thingToSave, req.query.testMode, (updatedThing) ->
				req.query.nestedfull = true
				getThing req, updatedThing.codeName, (thing) ->
					resp.json thing

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
			if !error && response.statusCode == 202
				resp.json json
			else if response.statusCode == 409
				console.log "not unique name"
				console.log json
				resp.statusCode = 409
				resp.json json
			else
				console.log 'got ajax error trying to save validate thing name'
				console.log error
				console.log json
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

exports.getThingCodeByLabel = (req, resp) ->
	exports.getThingCodesFromNamesOrCodes req.body, (results) =>
		if typeof response is "string" and results.indexOf("error") > -1
			resp.statusCode = 500
			resp.end results
		else 
			resp.json results
	
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
				callback "error trying to lookup lsThing name"
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

exports.getThingThingItxsByFirstThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/byfirstthing?firstthing="+req.params.firstThingId
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsBySecondThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/bysecondthing?secondthing="+req.params.secondThingId
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsByFirstThingAndItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/byfirstthing/#{req.params.lsType}/#{req.params.lsKind}?firstthing=#{req.params.firstThingId}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsBySecondThingAndItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/bysecondthing/#{req.params.lsType}/#{req.params.lsKind}?secondthing=#{req.params.secondThingId}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsByFirstThingAndExcludeItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/byfirstthing/exclude/#{req.params.lsType}/#{req.params.lsKind}?firstthing=#{req.params.firstThingId}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsBySecondThingAndExcludeItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/bysecondthing/exclude/#{req.params.lsType}/#{req.params.lsKind}?secondthing=#{req.params.secondThingId}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingsByCodeNames = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		config = require '../conf/compiled/conf.js'
		request = require 'request'
		options =
			method: 'POST'
			url: config.all.client.service.persistence.fullpath+"/lsthings/#{req.params.lsType}/#{req.params.lsKind}/codeNames/jsonArray"
			qs: req.query
			headers:
				'content-type': 'application/json'
			body: req.body
			json: true
		request options, (error, response, body) ->
			if error
				throw new Error(error)
			resp.json body
			return

exports.getThingKinds = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"thingkinds"
	serverUtilityFunctions.getFromACASServerInternal baseurl, (statusCode, kinds) ->
		codeTables = []
		_.each kinds, (kind) ->
			codeTable =
				id: kind.id
				code: kind.kindName
				name: kind.kindName
			codeTables.push codeTable
		resp.json codeTables

exports.bulkPostThings = (req, resp) ->
	exports.bulkPostThingsInternal req.body, (response) =>
		resp.json response

exports.bulkPostThingsInternal = (thingArray, callback) ->
	console.log "bulkPostThings"
	console.log JSON.stringify thingArray
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"lsthings/jsonArray"
	request(
		method: 'POST'
		url: baseurl
		body: thingArray
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 201
			callback json
		else
			console.log "got error bulk posting things"
			callback JSON.stringify "bulk post things saveFailed: " + JSON.stringify error
	)

exports.bulkPutThings = (req, resp) ->
	exports.bulkPutThingsInternal req.body, (response) =>
		resp.json response

exports.bulkPutThingsInternal = (thingArray, callback) ->
	console.log "bulkPutThings"
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"lsthings/jsonArray"
	console.log "bulkPutThingsInternal"
	console.log baseurl
	console.log thingArray
	request(
		method: 'PUT'
		url: baseurl
		body: thingArray
		json: true
	, (error, response, json) =>
		console.log "bulkPutThingsInternal"
		console.log response.statusCode
		if !error && response.statusCode == 200
			callback json
		else
			console.log "got error bulk updating things"
			console.log error
			callback JSON.stringify "bulk update things saveFailed: " + JSON.stringify error
	)		