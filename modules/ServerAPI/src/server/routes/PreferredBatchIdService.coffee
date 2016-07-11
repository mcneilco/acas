exports.setupAPIRoutes = (app) ->
	app.post '/api/preferredBatchId', exports.preferredBatchId

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/preferredBatchId', loginRoutes.ensureAuthenticated, exports.preferredBatchId
	app.post '/api/testRoute', loginRoutes.ensureAuthenticated, exports.testRoute

exports.preferredBatchId = (req, resp) ->
	requests = req.body.requests
	exports.getPreferredCompoundBatchIDs requests, (results) ->
		resp.end results

exports.getPreferredCompoundBatchIDs = (requests, callback) ->
	_ = require "underscore"
	each = require "each"
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serviceType = config.all.client.service.external.preferred.batchid.type
	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	possibleServiceTypes = ['NewLineSepBulkPost','SeuratCmpdReg','GeneCodeCheckByR','AcasCmpdReg','LabSynchCmpdReg','SingleBatchNameQueryString', 'AllPass']

	if serviceType not in possibleServiceTypes
		errorMessage = "client.service.external.preferred.batchid.type '#{serviceType}' is not in possible service types #{possibleServiceTypes}"
		console.log errorMessage
		callback errorMessage

	if serviceType == "NewLineSepBulkPost" && !global.specRunnerTestmode
		csUtilities.getPreferredBatchIds requests, (preferredResp) ->
			callback JSON.stringify
				error: false
				errorMessages: []
				results: preferredResp
	else if serviceType == "AllPass" && !global.specRunnerTestmode
		results = ({requestName: req.requestName, preferredName: req.requestName} for req in requests)
		callback JSON.stringify
			error: false
			errorMessages: []
			results: results
	else if serviceType == "SeuratCmpdReg" && !global.specRunnerTestmode
		req =
			testMode: false
			requests: requests
			user: ""
		serverUtilityFunctions.runRFunctionOutsideRequest(
			"",
			req,
			"public/src/modules/ServerAPI/src/server/SeuratBatchCheck.R",
			"seuratBatchCodeCheck",
			(rReturn) ->
				callback rReturn
			,
			null,
			false
		)
	else if serviceType == "AcasCmpdReg" && !global.specRunnerTestmode
		req.body.user = "" # to bypass validation function
		serverUtilityFunctions.runRFunction(
			req,
			"public/src/modules/ServerAPI/src/server/AcasCmpdRegBatchCheck.R",
			"acasCmpdRegBatchCheck",
		(rReturn) ->
			callback rReturn
		)
	else if serviceType == "GeneCodeCheckByR" && !global.specRunnerTestmode
		req.body.user = "" # to bypass validation function
		serverUtilityFunctions.runRFunction(
			req,
			"public/src/modules/ServerAPI/src/server/AcasGeneBatchCheck.R",
			"acasGeneCodeCheck",
		(rReturn) ->
			callback rReturn
		)
	else
		each(requests
		).parallel(1).on("item", (batchName, next) ->
			if global.specRunnerTestmode
				console.log "running fake batch check"
				checkBatch_TestMode(batchName)
				next()
			else if serviceType == "LabSynchCmpdReg"
				console.log "running LabSynchCmpdReg batch check"
				baseurl = config.all.server.service.external.preferred.batchid.url
				request(
					method: 'GET'
					url: baseurl+batchName.requestName
					json: true
				, (error, response, json) =>
					if !error && response.statusCode == 200
						if json.lot?
							if json.lot.corpName?
								batchName.preferredName = batchName.requestName
						else
							batchName.preferredName = ""
					else
						console.log 'got ajax error trying to validate batch name'
					next()
				)
			else if serviceType == "SingleBatchNameQueryString"
				console.log "running SingleBatchNameQueryString batch check"
				baseurl = config.all.server.service.external.preferred.batchid.url
				request(
					method: 'GET'
					url: baseurl+batchName.requestName+".csv"
					json: false
					headers: csUtilities.makeServiceRequestHeaders(req.user)
				, (error, response, body) =>
					if !error && response.statusCode == 200
						console.log body
						batchName.preferredName = body
					else if !error && response.statusCode == 204
						batchName.preferredName = ""
					else
						console.log 'got ajax error trying to validate batch name'
					next()
				)
		).on("error", (err, errors) ->
			console.log err.message
			_.each errors, (error) ->
				console.log "  " + error.message
		).on "end", ->
			answer =
				error: false
				errorMessages: []
				results: requests
			console.log JSON.stringify(answer)
			callback JSON.stringify(answer)


checkBatch_TestMode = (batchName) ->
	idComps = batchName.requestName.split("_")
	pref = idComps[0];
	respId = "";
	switch pref
		when "norm" then respId = batchName.requestName
		when "none" then respId = ""
		when  "alias" then respId = "norm_"+idComps[1]+"A"
		else respId = batchName.requestName
	batchName.preferredName = respId

exports.testRoute = (req, resp) ->
	console.log req.body
	resp.json {hello: "world"}