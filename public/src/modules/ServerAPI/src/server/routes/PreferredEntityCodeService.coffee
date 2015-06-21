exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes', exports.getConfiguredEntityTypes
	app.post '/api/entitymeta/preferredCodes', exports.preferredCodes

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypes
	app.post '/api/entitymeta/preferredCodes', loginRoutes.ensureAuthenticated, exports.preferredCodes

configuredEntityTypes = require '../conf/ConfiguredEntityTypes.js'
_ = require 'underscore'

exports.getConfiguredEntityTypes = (req, resp) ->
	if req.query.asCodes?
		codes = for et in configuredEntityTypes.entityTypes
			code: et.type+" "+et.kind #Should we store this explicitly in the config?
			name: et.displayName
			ignored: false
		resp.json codes
	else
		resp.json configuredEntityTypes.entityTypes

exports.preferredCodes = (req, resp) ->
	#Note specRunnerTestMode is handled within functions called from here
	if req.body.type is "compound"
		reqHashes = formatCSVRequestAsReqArray(req.body.entityIdStringLines)
		if req.body.kind is "batch name"
			preferredBatchService = require "./PreferredBatchIdService.js"
			preferredBatchService.getPreferredCompoundBatchIDs reqHashes , (json) ->
				prefResp = JSON.parse(json)
				resp.json resultCSV: formatReqArratAsCSV(prefResp.results)
			return
		else if req.body.kind is "parent name"
			console.log "looking up compound parents"
			csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
			csUtilities.getPreferredParentIds reqHashes , (prefResp) ->
				resp.json resultCSV: formatReqArratAsCSV(prefResp)
			return
	else
		entityType = _.where configuredEntityTypes.entityTypes, type: req.body.type, kind: req.body.kind
		if entityType.length is 1 and entityType[0].codeOrigin is "ACAS LSThing"
			preferredThingService = require "./ThingServiceRoutes.js"
			reqHashes =
				thingType: entityType[0].type
				thingKind: entityType[0].kind
				requests: formatCSVRequestAsReqArray(req.body.entityIdStringLines)
			preferredThingService.getThingCodesFormNamesOrCodes reqHashes, (codeResponse) ->
				out = for res in codeResponse.results
					res.requestName + "," + res.preferredName
				outStr =  "Requested Name,Preferred Code\n"+out.join('\n')
				resp.json resultCSV: outStr
			return
	#this is the fall-through. All trapped cases should "return"
	resp.statusCode = 500
	resp.end "problem with preferred Code request: code type and kind are unknown to system"

formatCSVRequestAsReqArray = (csvReq) ->
	requests = []
	for req in csvReq.split '\n'
		requests.push requestName: req

	return requests

formatReqArratAsCSV = (prefResp) ->
	preferreds = prefResp
	outStr =  "Requested Name,Preferred Code\n"
	for pref in preferreds
		outStr += pref.requestName + ',' + pref.preferredName + '\n'

	return outStr
