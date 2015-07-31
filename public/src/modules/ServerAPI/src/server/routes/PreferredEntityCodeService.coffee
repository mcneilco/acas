exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute
	app.post '/api/entitymeta/preferredCodes', exports.preferredCodesRoute
	app.get '/api/entitymeta/configuredEntityTypes/displayName/:displayName', exports.getSpecificEntityTypeRoute

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute
	app.post '/api/entitymeta/preferredCodes', loginRoutes.ensureAuthenticated, exports.preferredCodesRoute
	app.get '/api/entitymeta/ConfiguredEntityTypes/displayName/:displayName', loginRoutes.ensureAuthenticated, exports.getSpecificEntityTypeRoute

configuredEntityTypes = require '../conf/ConfiguredEntityTypes.js'
_ = require 'underscore'

exports.getConfiguredEntityTypesRoute = (req, resp) ->
	if req.params.asCodes?
		asCodes = true
	else
		asCodes = false
	exports.getConfiguredEntityTypes asCodes, (json) ->
		resp.json json

exports.getConfiguredEntityTypes = (asCodes, callback) ->
	console.log "asCodes: "+asCodes
	if asCodes
		codes = for et in configuredEntityTypes.entityTypes
			code: et.type+" "+et.kind #Should we store this explicitly in the config?
			name: et.displayName
			ignored: false
		callback codes
	else
		callback configuredEntityTypes.entityTypes

exports.preferredCodesRoute = (req, resp) ->
	requestData =
		type: req.body.type
		kind: req.body.kind
		entityIdStringLines: req.body.entityIdStringLines

	exports.preferredCodes requestData, (json) ->
		resp.json json

exports.preferredCodes = (requestData, callback) ->
	console.log global.specRunnerTestmode
	#Note specRunnerTestMode is handled within functions called from here
	if requestData.type is "compound"
		reqHashes = formatCSVRequestAsReqArray(requestData.entityIdStringLines)
		if requestData.kind is "batch name"
			preferredBatchService = require "./PreferredBatchIdService.js"
			preferredBatchService.getPreferredCompoundBatchIDs reqHashes , (json) ->
				prefResp = JSON.parse(json)
				callback
					type: requestData.type
					kind: requestData.kind
					resultCSV: formatReqArratAsCSV(prefResp.results)
			return
		else if requestData.kind is "parent name"
			console.log "looking up compound parents"
			csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
			csUtilities.getPreferredParentIds reqHashes , (prefResp) ->
				callback
					type: requestData.type
					kind: requestData.kind
					resultCSV: formatReqArratAsCSV(prefResp)
			return
	else
		entityType = _.where configuredEntityTypes.entityTypes, type: requestData.type, kind: requestData.kind
		if entityType.length is 1 and entityType[0].codeOrigin is "ACAS LSThing"
			preferredThingService = require "./ThingServiceRoutes.js"
			reqHashes =
				thingType: entityType[0].type
				thingKind: entityType[0].kind
				requests: formatCSVRequestAsReqArray(requestData.entityIdStringLines)
			preferredThingService.getThingCodesFromNamesOrCodes reqHashes, (codeResponse) ->
				out = for res in codeResponse.results
					res.requestName + "," + res.preferredName
				outStr =  "Requested Name,Preferred Code\n"+out.join('\n')
				callback
					type: codeResponse.thingType
					kind: codeResponse.thingKind
					resultCSV: outStr
			return
	#this is the fall-through. All trapped cases should "return"
	resp.statusCode = 500
	resp.end "problem with preferred Code request: code type and kind are unknown to system"

exports.getSpecificEntityTypeRoute = (req, resp) ->
	resp.json configuredEntityTypes.entityTypesbyDisplayName[req.params.displayName]

exports.getSpecificEntityType = (displayName, callback) ->
	callback configuredEntityTypes.entityTypesbyDisplayName[displayName]

formatCSVRequestAsReqArray = (csvReq) ->
	requests = []
	for req in csvReq.split '\n'
		unless req is ""
			requests.push requestName: req

	return requests

formatReqArratAsCSV = (prefResp) ->
	preferreds = prefResp
	outStr =  "Requested Name,Preferred Code\n"
	for pref in preferreds
		outStr += pref.requestName + ',' + pref.preferredName + '\n'

	return outStr
