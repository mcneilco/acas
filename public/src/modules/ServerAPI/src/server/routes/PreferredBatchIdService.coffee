exports.setupAPIRoutes = (app) ->
	app.post '/api/preferredBatchId', exports.preferredBatchId

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/preferredBatchId', loginRoutes.ensureAuthenticated, exports.preferredBatchId
	app.post '/api/testRoute', loginRoutes.ensureAuthenticated, exports.testRoute

exports.preferredBatchId = (req, resp) ->
	#oracle = require "db-oracle"
	_ = require "underscore"
	each = require "each"
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serviceType = config.all.client.service.external.preferred.batchid.type
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	possibleServiceTypes = ['SeuratCmpdReg','GeneCodeCheckByR','AcasCmpdReg','LabSynchCmpdReg','SingleBatchNameQueryString']

	requests = req.body.requests
	if serviceType not in possibleServiceTypes
		errorMessage = "client.service.external.preferred.batchid.type '#{serviceType}' is not in possible service types #{possibleServiceTypes}"
		console.log errorMessage
		resp.end errorMessage

	if serviceType == "SeuratCmpdReg" && !global.specRunnerTestmode
		req.body.user = "" # to bypass validation function
		serverUtilityFunctions.runRFunction(
			req,
			"public/src/modules/ServerAPI/src/server/SeuratBatchCheck.R",
			"seuratBatchCodeCheck",
			(rReturn) ->
				resp.end rReturn
		)
	else if serviceType == "AcasCmpdReg" && !global.specRunnerTestmode
		req.body.user = "" # to bypass validation function
		serverUtilityFunctions.runRFunction(
			req,
			"public/src/modules/ServerAPI/src/server/AcasCmpdRegBatchCheck.R",
			"acasCmpdRegBatchCheck",
		(rReturn) ->
			resp.end rReturn
		)
	else if serviceType == "GeneCodeCheckByR" && !global.specRunnerTestmode
		req.body.user = "" # to bypass validation function
		serverUtilityFunctions.runRFunction(
			req,
			"public/src/modules/ServerAPI/src/server/AcasGeneBatchCheck.R",
			"acasGeneCodeCheck",
		(rReturn) ->
			resp.end rReturn
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
			resp.json answer


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