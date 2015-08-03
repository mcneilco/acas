exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute
	app.get '/api/entitymeta/configuredEntityTypes/displayName/:displayName', exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/referenceCodes/:csv?', exports.referenceCodesRoute
	app.post '/api/entitymeta/pickBestLabels', exports.pickBestLabelsRoute
	app.post '/api/entitymeta/searchForEntities', exports.searchForEntitiesRoute

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute
	app.get '/api/entitymeta/ConfiguredEntityTypes/displayName/:displayName', loginRoutes.ensureAuthenticated, exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/referenceCodes/:csv?', loginRoutes.ensureAuthenticated, exports.referenceCodesRoute
	app.post '/api/entitymeta/pickBestLabels', loginRoutes.ensureAuthenticated, exports.pickBestLabelsRoute
	app.post '/api/entitymeta/searchForEntities', loginRoutes.ensureAuthenticated ,exports.searchForEntitiesRoute

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
		codes = for own name, et of configuredEntityTypes.entityTypes
			code: et.type+" "+et.kind #Should we store this explicitly in the config?
			name: name
			ignored: false
		callback codes
	else
		callback configuredEntityTypes.entityTypes

exports.getSpecificEntityTypeRoute = (req, resp) ->
	displayName = req.params.displayName
	exports.getSpecificEntityType displayName, (json) ->
		resp.json json

exports.getSpecificEntityType = (displayName, callback) ->
	callback configuredEntityTypes.entityTypes[displayName]

exports.referenceCodesRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName
	if req.params.csv == "csv"
		csv = true
		entityIdStringLines: req.body.entityIdStringLines
	else
		csv = false


	console.log("csv is " + csv)

	exports.referenceCodes requestData, csv, (json) ->
		resp.json json

exports.referenceCodes = (requestData, csv, callback) ->
	console.log global.specRunnerTestmode
	#Note specRunnerTestMode is handled within functions called from here

	# convert displayName to type and kind
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
					displayName: requestData.displayName
					resultCSV: formatReqArratAsCSV(prefResp.results)
			return
		else if requestData.kind is "parent name"
			console.log "looking up compound parents"
			csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
			csUtilities.getPreferredParentIds reqHashes , (prefResp) ->
				callback
					displayName: requestData.displayName
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

exports.pickBestLabelsRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName
		referenceCodes: req.body.referenceCodes

	exports.referenceCodes requestData, (json) ->
		resp.json json

exports.pickBestLabels = (requestData, callback) ->
# TODO implement

exports.searchForEntitiesRoute = (req,resp) ->
	requestData =
		requestTexts: req.body.requestTexts

	exports.searchForEntities requestData, (json) ->
		resp.json json

exports.searchForEntities = (requestData, callback) ->
#TODO implement

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
