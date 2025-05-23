exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', exports.thingsByTypeKind
	app.get '/api/things/getMultipleKinds/:lsType/:lsKindsList', exports.thingsByTypeAndKinds
	app.get '/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:labelType/:labelKind/:labelText', exports.getThingsByTypeKindAndLabelTypeKindText
	app.put '/api/things/:lsType/:lsKind/:labelType/:labelKind/:labelText', exports.putThing
	app.post '/api/getThingCodeByLabel/:thingType?/:thingKind?', exports.getThingCodeByLabel
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.post '/api/validateName', exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', exports.getAssemblies
	app.get '/api/genericSearch/things/:searchTerm', exports.genericThingSearch
	app.post '/api/advancedSearch/things/:lsType/:lsKind', exports.advancedThingSearch
	app.get '/api/getThingThingItxsByFirstThing/:firstThingId', exports.getThingThingItxsByFirstThing
	app.get '/api/getThingThingItxsBySecondThing/:secondThingId', exports.getThingThingItxsBySecondThing
	app.get '/api/getThingThingItxsByFirstThing/:lsType/:lsKind/:firstThingId', exports.getThingThingItxsByFirstThingAndItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/:lsType/:lsKind/:secondThingId', exports.getThingThingItxsBySecondThingAndItxTypeKind
	app.get '/api/getThingThingItxsByFirstThing/exclude/:lsType/:lsKind/:firstThingId', exports.getThingThingItxsByFirstThingAndExcludeItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/exclude/:lsType/:lsKind/:secondThingId', exports.getThingThingItxsBySecondThingAndExcludeItxTypeKind
	app.get '/api/getThingCodeTablesByLabelText/:lsType/:lsKind/:labelText', exports.getThingsByTypeKindAndLabelTypeKindTextQuery
	app.post '/api/things/:lsType/:lsKind/codeNames/jsonArray', exports.getThingsByCodeNames
	app.get '/api/thingKinds', exports.getThingKinds
	app.post '/api/things/jsonArray', exports.postThings
	app.post '/api/bulkPostThings', exports.bulkPostThings
	app.put '/api/bulkPutThings', exports.bulkPutThings
	app.post '/api/bulkPostThingsSaveFile', exports.bulkPostThingsSaveFile
	app.put '/api/bulkPutThingsSaveFile', exports.bulkPutThingsSaveFile
	app.delete '/api/things/:lsType/:lsKind/:idOrCodeName', exports.deleteThing
	app.get '/api/thingvalues/getThingValueById/:id', exports.getThingValueById
	app.get '/api/thingvalues/downloadThingBlobValueByID/:id', exports.downloadThingBlobValueByID


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind
	app.get '/api/things/getMultipleKinds/:lsType/:lsKindsList', loginRoutes.ensureAuthenticated, exports.thingsByTypeAndKinds
	app.get '/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName
	app.get '/api/things/:lsType/:lsKind/:labelType/:labelKind/:labelText', exports.getThingsByTypeKindAndLabelTypeKindText
	app.put '/api/things/:lsType/:lsKind/:labelType/:labelKind/:labelText', exports.putThing
	app.post '/api/getThingCodeByLabel/:thingType?/:thingKind?', loginRoutes.ensureAuthenticated, exports.getThingCodeByLabel
	app.post '/api/things/:lsType/:lsKind', exports.postThingParent
	app.post '/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch
	app.put '/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing
	app.get '/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.post '/api/validateName', loginRoutes.ensureAuthenticated, exports.validateName
	app.get '/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', loginRoutes.ensureAuthenticated, exports.getAssemblies
	app.get '/api/genericSearch/things/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericThingSearch
	app.post '/api/advancedSearch/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.advancedThingSearch
	app.get '/api/getThingThingItxsByFirstThing/:firstThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsByFirstThing
	app.get '/api/getThingThingItxsBySecondThing/:secondThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsBySecondThing
	app.get '/api/getThingThingItxsByFirstThing/:lsType/:lsKind/:firstThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsByFirstThingAndItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/:lsType/:lsKind/:secondThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsBySecondThingAndItxTypeKind
	app.get '/api/getThingThingItxsByFirstThing/exclude/:lsType/:lsKind/:firstThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsByFirstThingAndExcludeItxTypeKind
	app.get '/api/getThingThingItxsBySecondThing/exclude/:lsType/:lsKind/:secondThingId', loginRoutes.ensureAuthenticated, exports.getThingThingItxsBySecondThingAndExcludeItxTypeKind
	app.get '/api/getThingCodeTablesByLabelText/:lsType/:lsKind/:labelText', loginRoutes.ensureAuthenticated, exports.getThingsByTypeKindAndLabelTypeKindTextQuery
	app.post '/api/things/:lsType/:lsKind/codeNames/jsonArray', loginRoutes.ensureAuthenticated, exports.getThingsByCodeNames
	app.get '/api/thingKinds', loginRoutes.ensureAuthenticated, exports.getThingKinds
	app.get '/api/transaction/:id', loginRoutes.ensureAuthenticated, exports.getTransaction
	app.post '/api/things/jsonArray', loginRoutes.ensureAuthenticated, exports.postThings
	app.post '/api/bulkPostThings', loginRoutes.ensureAuthenticated, exports.bulkPostThings
	app.put '/api/bulkPutThings', loginRoutes.ensureAuthenticated, exports.bulkPutThings
	app.post '/api/bulkPostThingsSaveFile', loginRoutes.ensureAuthenticated, exports.bulkPostThingsSaveFile
	app.put '/api/bulkPutThingsSaveFile', loginRoutes.ensureAuthenticated, exports.bulkPutThingsSaveFile
	app.delete '/api/things/:lsType/:lsKind/:idOrCodeName', loginRoutes.ensureAuthenticated, exports.deleteThing
	app.get '/api/thingvalues/getThingValueById/:id', loginRoutes.ensureAuthenticated, exports.getThingValueById
	app.get '/api/thingvalues/downloadThingBlobValueByID/:id', loginRoutes.ensureAuthenticated, exports.downloadThingBlobValueByID


request = require 'request'
config = require '../conf/compiled/conf.js'

exports.getThingValueById = (req, resp) ->
	exports.getlsValuesByIdInternal req.params.id, req.query, (statusCode, value) ->
		resp.statusCode = statusCode
		resp.json value
		
exports.getlsValuesByIdInternal = (id, params, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"lsthingvalues/"+id
	if params? && params.format?
		baseurl += "?format=#{params.format}"
	serverUtilityFunctions.getFromACASServerInternal baseurl, (statusCode, value) ->
		callback(statusCode, value)

exports.downloadThingBlobValueByID = (req, resp) ->
	mime = require('mime');
	fs = require('fs');
	exports.getlsValuesInternal req.params.id, {format: "withblobvalue"}, (statusCode, value) ->
		mimetype = mime.lookup(value.comments);
		resp.setHeader('Content-disposition', 'attachment; filename=' + value.comments);
		resp.setHeader('Content-type', mimetype);
		buffer = new Buffer.from(Uint8Array.from(value.blobValue))
		stream = exports.bufferToStream(buffer)
		stream.on 'data', (chunk) ->
			resp.send(chunk);
		stream.on 'data', (chunk) ->
			resp.status(200).send();

exports.bufferToStream = (buffer) ->
	Duplex = require('stream').Duplex
	stream = new Duplex
	stream.push buffer
	stream.push null
	stream

exports.getlsValuesInternal = (id, params, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"lsthingvalues/"+id
	if params? && params.format?
		baseurl += "?format=#{params.format}"
	serverUtilityFunctions.getFromACASServerInternal baseurl, (statusCode, value) ->
		callback(statusCode, value)

exports.thingsByTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.end JSON.stringify thingServiceTestJSON.batchList
	else
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

exports.getThingsByTypeKindAndLabelTypeKindTextQuery = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingServiceTestJSON.batchList
	else
		searchParams = {
			lsType: req.params.lsType,
			lsKind: req.params.lsKind,
			labels: [
				labelType: req.query.labelType,
				labelKind: req.query.labelKind,
				labelText: req.params.labelText
			]
		}
		opts = {
			returnOne: req.query.returnOne
			format: req.query.with
		}
		exports.getThingsByTypeKindAndLabelTypeKindTextInternal searchParams, opts, (codeTables) ->
			resp.json codeTables

exports.getThingsByTypeKindAndLabelTypeKindText = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingServiceTestJSON.batchList
	else
		searchParams = {
			lsType: req.params.lsType,
			lsKind: req.params.lsKind,
			labels: [
				labelType: req.params.labelType,
				labelKind: req.params.labelKind,
				labelText: req.params.labelText
			]
		}
		opts = {
			returnOne: req.query.returnOne
			format: req.query.with
		}
		exports.getThingsByTypeKindAndLabelTypeKindTextInternal searchParams, opts, (codeTables) ->
			resp.json codeTables

exports.getThingsByTypeAndKindAndLabelTypeAndLabelTextInternal = (thingType, thingKind, labelType, labelText, format, callback) ->
	searchParams = {
		lsType: thingType,
		lsKind: thingKind,
		labels: [
			labelType: labelType,
			labelKind: labelKind,
			labelText: labelText
		]
	}
	opts = {
		returnOne: false
		format: format
	}
	exports.getThingsByTypeKindAndLabelTypeKindTextInternal search, opts, (codeTables) ->
		callback codeTables
		
exports.getThingsByTypeKindAndLabelTypeKindTextInternal = (searchParams, opts, callback) ->
	baseurl = config.all.client.service.persistence.fullpath+'lsthings/genericInteractionSearch'
	console.log baseurl
	request = require 'request'
	if opts.format?
		params =
			with: opts.format
	else
		params =
			with: 'codeTable'
	request(
		method: 'POST'
		url: baseurl
		qs: params
		body: searchParams
		json: true
	, (error, response, json) =>
		console.log response.statusCode
		if !error && response.statusCode == 200
			if opts.returnOne? && opts.returnOne && json.results.length > 0
				callback json.results[0]
			else
				callback json.results
	)

getThingByTypeAndKind = (lsType, lsKind, stub, callback) =>
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

exports.getThingInternal = (lsType, lsKind, format, testMode, codeName, callback) ->
	if testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		callback thingTestJSON.thingParent
	else
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+lsType+"/"+lsKind+"/"+ encodeURIComponent codeName
		if format?
			baseurl += "?with=#{format}"
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


getThing = (req, codeName, callback) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		callback thingTestJSON.thingParent
	else
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


exports.bulkPostThingsSaveFile = (req, resp) ->

	# First save all the ls things that come in
	exports.bulkPostThingsInternal req.body, (response) =>

		# Local function checkFilesAndUpdate
		checkFilesAndUpdate = (thing, callback) ->

			# Check if there are any files to save
			fileVals = serverUtilityFunctions.getFileValuesFromEntity thing, false
			filesToSave = fileVals.length

			# Function called after final file is saved
			completeThingUpdate = (thingToUpdate)->
				updateThing thingToUpdate, false, (updatedThing) ->
					callback updatedThing, 200

			# Function to call after a file is saved
			fileSaveCompleted = (passed) ->
				if !passed
					callback "file move failed", 500
				# Decrement one from the filesToSave and if this is the final file that was saved call 
				# completeThingUpdate
				if --filesToSave == 0 then completeThingUpdate(thing)

			# If there are any files to save, call the customer specific server function which should handle
			# saving the file to the correct location and update the thing file value with the correct path
			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode thing.codeName
				for fv in fileVals

					# Send just the file value "fv" to the relocateEntityFile function
					# relocate entity file is responsible for moving the file and updating the 
					# file value of thing in memory and later completeThingUpdate will handle persisting
					# the change to the db.
					csUtilities.relocateEntityFile fv, prefix, thing.codeName, fileSaveCompleted
			else
				callback thing, 200

		# If we failed to bulk save the things then just respond
		if response.indexOf("saveFailed") > -1
			resp.json response
		else
			# Loop through the saved ls things and call the checkFilesAndUpdate function
			# which should handle doing the correct thing with the files.
			lengthThingsToCheck = response.length
			i = 0
			resps = []
			for t in response
				checkFilesAndUpdate t, (response, statusCode) ->
					resps.push response
					i++
					if i == lengthThingsToCheck
						resp.json resps

postThing = (isBatch, req, resp) ->
	console.log "post thing parent"
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	if config.all.client.solr?.updateSolrForThings?
		updateSolr = config.all.client.solr.updateSolrForThings
	else
		updateSolr = false
	console.log "updateSolr: " + updateSolr
	thingToSave = req.body
	if thingToSave.transactionOptions?
		transactionOptions = thingToSave.transactionOptions
		delete thingToSave.transactionOptions
	else
		transactionOptions = {
			comments: "new experiment"
		}
	transactionOptions.recordedBy = if req.session?.passport?.user?.username? then req.session.passport.user.username else "acas"
	transactionOptions.status = "PENDING"
	transactionOptions.type = "NEW"
	serverUtilityFunctions.createLSTransaction2 thingToSave.recordedDate, transactionOptions, (transaction) =>
		thingToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thingToSave
		if req.query.testMode or global.specRunnerTestmode
			unless thingToSave.codeName?
				if isBatch
					thingToSave.codeName = "PT00002"
				else
					thingToSave.codeName = "PT00002-1"

		checkFilesAndUpdate = (thing) =>
			fileVals = serverUtilityFunctions.getFileValuesFromEntity thing, false
			filesToSave = fileVals.length

			completeThingUpdate = (thingToUpdate)=>
				updateThing thingToUpdate, req.query.testMode, (updatedThing) =>
					transaction.status = 'COMPLETED'
					serverUtilityFunctions.updateLSTransaction transaction, (transaction) =>
						if updatedThing is "update lsThing failed"
							resp.json updatedThing
						else if updateSolr
							csUtilities.updateSolrIndex (updateMessage) =>
								resp.json updatedThing
						else
							resp.json updatedThing

			fileSaveCompleted = (passed) =>
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
					serverUtilityFunctions.updateLSTransaction transaction, (transaction) =>
						console.log transaction
						if thing.codeName? and updateSolr
							csUtilities.updateSolrIndex (updateMessage) =>
								resp.json thing
						else
							resp.json thing

		if req.query.testMode or global.specRunnerTestmode
			checkFilesAndUpdate thingToSave
		else
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
					getThing req, json.codeName, (thing) =>
						checkFilesAndUpdate thing
				else
					console.log 'got ajax error trying to save lsThing'
					console.log error
					console.log json
					console.log response
					resp.statusCode = 500
					resp.end "got ajax error trying to save lsThing"
			)

exports.postThingParent = (req, resp) ->
	postThing false, req, resp

exports.postThingBatch = (req, resp) ->
	postThing true, req, resp

exports.bulkPutThingsSaveFile = (req, resp) ->

	# First save all the ls things that come in
	exports.bulkPutThingsInternal req.body, (response) =>

		# Local function checkFilesAndUpdate
		checkFilesAndUpdate = (thing, callback) ->

			# Check if there are any files to save
			fileVals = serverUtilityFunctions.getFileValuesFromEntity thing, false
			filesToSave = fileVals.length
			console.log("got #{filesToSave} file values to check for updates")

			# Function called after final file is saved
			completeThingUpdate = (thingToUpdate)->
				updateThing thingToUpdate, false, (updatedThing) ->
					callback updatedThing, 200

			# Function to call after a file is saved
			fileSaveCompleted = (passed) ->
				if !passed
					callback "file move failed", 500
				# Decrement one from the filesToSave and if this is the final file that was saved call 
				# completeThingUpdate
				if --filesToSave == 0 then completeThingUpdate(thing)

			# If there are any files to save, call the customer specific server function which should handle
			# saving the file to the correct location and update the thing file value with the correct path
			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode thing.codeName
				for fv in fileVals

					# Only update new files
					if !fv.id?
						console.log("file value was updated #{JSON.stringify(fv)}")
						# Send just the file value "fv" to the relocateEntityFile function
						# relocate entity file is responsible for moving the file and updating the 
						# file value of thing in memory and later completeThingUpdate will handle persisting
						# the change to the db.
						csUtilities.relocateEntityFile fv, prefix, thing.codeName, fileSaveCompleted
					else
						fileSaveCompleted(true)
			else
				callback thing, 200

		# If we failed to bulk save the things then just respond
		if response.indexOf("saveFailed") > -1
			resp.json response
		else
			# Loop through the saved ls things and call the checkFilesAndUpdate function
			# which should handle doing the correct thing with the files.
			lengthThingsToCheck = response.length
			i = 0
			resps = []
			for t in response
				console.log("running check on files for thing #{JSON.stringify(t)}")
				checkFilesAndUpdate t, (response, statusCode) ->
					console.log("got response from check files #{statusCode} #{JSON.stringify(response)}")
					resps.push response
					i++
					if i == lengthThingsToCheck
						resp.json resps

exports.putThingInternal = (thing, lsType, lsKind, testMode, callback) ->
	thingToSave = thing
	fileVals = serverUtilityFunctions.getFileValuesFromEntity thingToSave, true
	filesToSave = fileVals.length

	if thingToSave.transactionOptions?
		thingToSave.transactionOptions.recordedBy = recordedBy
	completeThingUpdate = ->
		if thingToSave.transactionOptions?
			transactionOptions = thingToSave.transactionOptions
			delete thingToSave.transactionOptions
		else
			transactionOptions = {
				comments: "updated thing"
			}
		transactionOptions.status = "COMPLETED"
		transactionOptions.type = "CHANGE"
		serverUtilityFunctions.createLSTransaction2 thingToSave.recordedDate, transactionOptions, (transaction) ->
			thingToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thingToSave
			updateThing thingToSave, testMode, (updatedThing) ->
				format = "nestedfull"
				exports.getThingInternal lsType, lsKind, format, testMode, updatedThing.codeName, (thing) ->
					callback thing

	fileSaveCompleted = (passed) ->
		if !passed
			callback "put thing internal saveFailed: file move failed"
		if --filesToSave == 0 then completeThingUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromEntityCode thingToSave.codeName
		for fv in fileVals
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, thingToSave.codeName, fileSaveCompleted
	else
		completeThingUpdate()

exports.putThing = (req, resp) ->
#	if req.query.testMode or global.specRunnerTestmode
#		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
#		thingToSave = JSON.parse(JSON.stringify(thingTestJSON.thingParent))
#	else
	thingToSave = req.body
	fileVals = serverUtilityFunctions.getFileValuesFromEntity thingToSave, true
	filesToSave = fileVals.length
	if config.all.client.solr?.updateSolrForThings?
		updateSolr = config.all.client.solr.updateSolrForThings
	else
		updateSolr = false
	if thingToSave.transactionOptions?
		thingToSave.transactionOptions.recordedBy = req.session.passport.user.username
	completeThingUpdate = =>
		if thingToSave.transactionOptions?
			transactionOptions = thingToSave.transactionOptions
			delete thingToSave.transactionOptions
		else
			transactionOptions = {
				comments: "updated thing"
			}
		transactionOptions.status = "COMPLETED"
		transactionOptions.type = "CHANGE"
		serverUtilityFunctions.createLSTransaction2 thingToSave.recordedDate, transactionOptions, (transaction) =>
			thingToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, thingToSave
			updateThing thingToSave, req.query.testMode, (updatedThing) =>
				req.query.nestedfull = true
				if updatedThing is "update lsThing failed"
					resp.json updatedThing
				else if updateSolr
					csUtilities.updateSolrIndex (updateMessage) =>
						getThing req, updatedThing.codeName, (thing) =>
							resp.json thing
				else
					getThing req, updatedThing.codeName, (thing) =>
						resp.json thing

	fileSaveCompleted = (passed) =>
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

#TODO replace putThing with call to putThingInternal
#exports.putThing = (req, resp) ->
#	exports.putThingInternal req.body, req.params.lsType, req.params.lsKind, req.req.query.testMode, (putThingResp) =>
#		if putThingResp.indexOf("saveFailed") > -1
#			resp.statusCode = 500
#			resp.json putThingResp
#		else
#			resp.json putThingResp

exports.batchesByParentCodeName = (req, resp) ->
	console.log "get batches by parent codeName"
	if req.query.testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingServiceTestJSON.batchList
	else
		if req.params.parentCode is "undefined"
			resp.json []
		else
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
			else if req.query.codetable
				codeTable = "with=codetable"
				baseurl += "?#{codeTable}"
				if req.query.labelType?
					baseurl += "&labelType=#{req.query.labelType}"
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.validateName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json true
	else
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/validate"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.data
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 202
				if json?
					resp.json json
				else
					resp.json {}
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
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/"+req.params.lsType+"/"+req.params.lsKind+"/getcomposites/"+req.params.componentCode
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingCodeByLabel = (req, resp) ->
	# Request body takes presidence 
	if !req.body.thingType? && req.params.thingType?
		req.body.thingType = req.params.thingType
	if !req.body.thingKind? && req.params.thingKind?
		req.body.thingKind = req.params.thingKind

	#Thing type and kind are required so throw an error if they are not specified
	if !req.body.thingType? || !req.body.thingKind?
		resp.statusCode = 400
		resp.end "Thing type and kind are required"
		return
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
		url = config.all.client.service.persistence.fullpath+"lsthings/getCodeNameFromNameRequest"
		queryParams = {}
		if codeRequest.thingType?
			queryParams["thingType"] = codeRequest.thingType
		if codeRequest.thingKind?
			queryParams["thingKind"] = codeRequest.thingKind
		if codeRequest.labelType?
			queryParams["labelType"] = codeRequest.labelType
		if codeRequest.labelKind?
			queryParams["labelKind"] = codeRequest.labelKind
		postBody = requests: codeRequest.requests
		console.log postBody
		console.log url
		console.log queryParams
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			qs: queryParams
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
		console.log "search req"
		console.log req
		if req.query.lsType?
			typeFilter = "lsType=" + req.query.lsType
		if req.query.lsKind?
			kindFilter = "lsKind=" + req.query.lsKind
		if req.query.with?
			format = "with=#{req.query.with}"
		searchTerm = "q=" + req.params.searchTerm

		searchParams = ""
		if typeFilter?
			searchParams += typeFilter + "&"
		if kindFilter?
			searchParams += kindFilter + "&"
		if format?
			searchParams += format + "&"
		searchParams += searchTerm

		baseurl = config.all.client.service.persistence.fullpath+"lsthings/search?"+searchParams
		#		baseurl = config.all.client.service.persistence.fullpath+"lsthings/search?lsType=batch&q="+req.params.searchTerm
		console.log "generic thing search baseurl"
		console.log baseurl
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.advancedThingSearch = (req, resp) ->
	console.log "advanced thing search"
	console.log req.query.testMode
	console.log global.specRunnerTestmode
	if req.query.testMode is true or global.specRunnerTestmode is true
		resp.end JSON.stringify "Stubs mode not implemented yet"
	else
		console.log "search req body"
		console.log req.body
		exports.advancedThingSearchInternal req.body, req.query.format, (results) =>
			if typeof response is "string" and results.indexOf("error") > -1
				resp.statusCode = 500
				resp.end results
			else 
				resp.json results

exports.advancedThingSearchInternal = (input, format, callback) ->
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/genericBrowserSearch"
		if format?
			baseurl += "?with=#{format}"
		console.log "advanced thing search baseurl"
		console.log baseurl
		requestOptions = 
			method: 'POST'
			url: baseurl
			body: input
			json: true
		request requestOptions, (error, response, object) ->
			if !error 
				if response.statusCode == 500
					callback object, response
				else 
					callback object, null
			else
				console.log 'got ajax error trying to run advancedThingSearch'
				console.log error
				console.log json
				console.log response
				callback object, error

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
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/byfirstthing?firstthing="+req.params.firstThingId
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsBySecondThing = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/bysecondthing?secondthing="+req.params.secondThingId
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsByFirstThingAndItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		exports.getThingThingItxsByFirstThingAndItxTypeKindInternal req.params.lsType, req.params.lsKind, req.params.firstThingId, req.query.with, (statusCode, itxs) ->
			resp.statusCode = statusCode
			resp.json itxs

exports.getThingThingItxsByFirstThingAndItxTypeKindInternal = (itxType, itxKind, firstThingId, withFlag, callback)	->
	baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/byfirstthing/#{itxType}/#{itxKind}?firstthing=#{firstThingId}&with=#{withFlag}"
	serverUtilityFunctions.getFromACASServerInternal(baseurl, callback)

exports.getThingThingItxsBySecondThingAndItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		exports.getThingThingItxsBySecondThingAndItxTypeKindInternal req.params.lsType, req.params.lsKind, req.params.secondThingId, req.query.with, (statusCode, itxs) ->
			resp.statusCode = statusCode
			resp.json itxs

exports.getThingThingItxsBySecondThingAndItxTypeKindInternal = (itxType, itxKind, secondThingId, withFlag, callback)	->
	baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/bysecondthing/#{itxType}/#{itxKind}?secondthing=#{secondThingId}&with=#{withFlag}"
	serverUtilityFunctions.getFromACASServerInternal(baseurl, callback)

exports.getThingThingItxsByFirstThingAndExcludeItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/byfirstthing/exclude/#{req.params.lsType}/#{req.params.lsKind}?firstthing=#{req.params.firstThingId}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingThingItxsBySecondThingAndExcludeItxTypeKind = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		resp.json thingTestJSON.thingParent
	else
		baseurl = config.all.client.service.persistence.fullpath+"/itxLsThingLsThings/bysecondthing/exclude/#{req.params.lsType}/#{req.params.lsKind}?secondthing=#{req.params.secondThingId}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getThingsByCodeNames = (req, resp) ->
	exports.getThingsByCodeNamesInternal req.body, req.params.lsType, req.params.lsKind, req.query, (returnedThings) ->
		if returnedThings.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.json returnedThings

exports.getThingsByCodeNamesInternal = (reqBody, lsType, lsKind, query, callback) ->
	if (query?.testMode and query.testMode) or global.specRunnerTestmode
		thingTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		callback thingTestJSON.thingParent
	else
		request = require 'request'
		options =
			method: 'POST'
			url: config.all.client.service.persistence.fullpath+"/lsthings/#{lsType}/#{lsKind}/codeNames/jsonArray"
			qs: query
			headers:
				'content-type': 'application/json'
			body: reqBody
			json: true
		request options, (error, response, body) ->
			if error
				callback "Failed: got error in bulk get of things: " + JSON.stringify error
			else
				callback body

exports.getThingKinds = (req, resp) ->
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

exports.getTransaction = (req, resp) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"lstransactions/"+req.params.id
	serverUtilityFunctions.getFromACASServer baseurl, resp

exports.postThings = (req, resp) ->
	exports.postThingsInternal {things: req.body.things}, (output, err) ->
			if err?
				resp.statusCode = 500
				resp.json err
				
exports.postThingsInternal = (input, callback) ->
	request = require 'request'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"lsthings/jsonArray"
	requestOptions = 
		method: 'POST'
		url: baseurl
		body: input.things
		json: true
	request requestOptions, (error, response, object) ->
			if !error 
				if response.statusCode == 500
					callback object, response
				else 
					callback object, null
			else
				console.log 'got ajax error trying to save validate thing name'
				console.log error
				console.log json
				console.log response
				callback object, error

	
	
		

	
	

exports.bulkPostThings = (req, resp) ->
	exports.bulkPostThingsInternal req.body, (response) =>
		resp.json response

exports.bulkPostThingsInternal = (thingArray, callback) ->
	console.log "bulkPostThings"
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
		console.log "bulkPutThingsInternal complete"
		console.log response.statusCode
		if !error && response.statusCode == 200
			callback json
		else
			console.log "got error bulk updating things"
			console.log error
			callback JSON.stringify "bulk update things saveFailed: " + JSON.stringify error
	)		

exports.deleteThing = (req, resp) ->
	exports.deleteThingInternal req.params.lsType, req.params.lsKind, req.params.idOrCodeName, (status, response) =>
		resp.statusCode = status
		resp.json response

exports.deleteThingInternal = (lsType, lsKind, idOrCodeName, callback) ->
	console.log "deleteThing #{idOrCodeName}"
	baseurl = config.all.client.service.persistence.fullpath+"lsthings/#{lsType}/#{lsKind}/#{idOrCodeName}"
	console.log baseurl
	request(
		method: 'DELETE'
		url: baseurl
		json: true
	, (error, response, json) =>
		console.log "deleteThingInternal complete"
		console.log response.statusCode
		if !error && response.statusCode == 200
			callback 200, json
		else
			console.log "got error deleting thing"
			console.log error
			callback 500, JSON.stringify "delete thing: " + JSON.stringify error
	)
