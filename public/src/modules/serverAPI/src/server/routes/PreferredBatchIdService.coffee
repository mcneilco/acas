# PreferredBatchIdService.coffee
#
# John McNeil
# john@mcneilco.com
#
# Copyright 2012 John McNeil & Co. Inc.
#########################################################################
# For API docs see spec: PreferredBatchIdServiceSpec.coffee
#########################################################################


exports.preferredBatchId = (req, resp) ->
	#oracle = require "db-oracle"
	_ = require "underscore"
	each = require "each"
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serviceType = config.all.client.service.external.preferred.batchid.type


	requests = req.body.requests

	if serviceType == "SeuratCmpdReg" && !global.specRunnerTestmode
		req.body.user = "" # to bypass validation function
		serverUtilityFunctions.runRFunction(
			req,
			"public/src/modules/serverAPI/src/server/SeuratBatchCheck.R",
			"seuratBatchCodeCheck",
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
				baseurl = config.server.service.external.preferred.batchid.url
				request(
					method: 'GET'
					url: baseurl+batchName.requestName+".csv"
					json: false
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