exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute
	app.post '/api/entitymeta/referenceCodes', exports.referenceCodesRoute
	app.get '/api/entitymeta/configuredEntityTypes/displayName/:displayName', exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/pickBestLabels', exports.pickBestLabelsRoute

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute
	app.post '/api/entitymeta/referenceCodes', loginRoutes.ensureAuthenticated, exports.referenceCodesRoute
	app.get '/api/entitymeta/ConfiguredEntityTypes/displayName/:displayName', loginRoutes.ensureAuthenticated, exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/pickBestLabels', loginRoutes.ensureAuthenticated, exports.pickBestLabelsRoute

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

exports.referenceCodesRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName
		entityIdStringLines: req.body.entityIdStringLines

	exports.referenceCodes requestData, (json) ->
		resp.json json

exports.referenceCodes = (requestData, callback) ->
	console.log global.specRunnerTestmode
	#Note specRunnerTestMode is handled within functions called from here

	# type and kind
	exports.getSpecificEntityType requestData.displayName, (json) ->
		requestData.type = json.type
		requestData.kind = json.kind

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
					res.requestName + "," + res.referenceName
				outStr =  "Requested Name,Reference Code\n"+out.join('\n')
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

exports.pickBestLabelsRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName
		referenceCodes: req.body.referenceCodes

	exports.referenceCodes requestData, (json) ->
		resp.json json

exports.pickBestLabels = (requestData, callback) ->


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
