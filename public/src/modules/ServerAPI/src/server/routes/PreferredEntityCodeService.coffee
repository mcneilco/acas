exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute
	app.get '/api/entitymeta/configuredEntityTypes/displayName/:displayName', exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/referenceCodes/:csv?', exports.referenceCodesRoute
	app.post '/api/entitymeta/pickBestLabels/:csv?', exports.pickBestLabelsRoute
	app.post '/api/entitymeta/searchForEntities', exports.searchForEntitiesRoute

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute
	app.get '/api/entitymeta/ConfiguredEntityTypes/displayName/:displayName', loginRoutes.ensureAuthenticated, exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/referenceCodes/:csv?', loginRoutes.ensureAuthenticated, exports.referenceCodesRoute
	app.post '/api/entitymeta/pickBestLabels/:csv?', loginRoutes.ensureAuthenticated, exports.pickBestLabelsRoute
	app.post '/api/entitymeta/searchForEntities', loginRoutes.ensureAuthenticated ,exports.searchForEntitiesRoute

configuredEntityTypes = require '../conf/ConfiguredEntityTypes.js'
_ = require 'underscore'


####################################################################
#   ENTITY TYPES
####################################################################

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
			code: name
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
	if configuredEntityTypes.entityTypes[displayName]?
		callback configuredEntityTypes.entityTypes[displayName]
	else
		callback {}


####################################################################
#   REFERENCE CODES
####################################################################

exports.referenceCodesRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName

	if req.params.csv == "csv"
		csv = true
		requestData.entityIdStringLines = req.body.entityIdStringLines
	else
		csv = false
		requestData.requests = req.body.requests

	exports.referenceCodes requestData, csv, (json) ->
		resp.json json

exports.referenceCodes = (requestData, csv, callback) ->
	console.log global.specRunnerTestmode 	#Note specRunnerTestMode is handled within functions called from here
	console.log("csv is " + csv)

	# convert displayName to type and kind
	exports.getSpecificEntityType requestData.displayName, (json) ->
		requestData.type = json.type
		requestData.kind = json.kind
		requestData.sourceExternal = json.sourceExternal

	if csv
		reqList = formatCSVRequestAsReqArray(requestData.entityIdStringLines)
	else
		reqList = requestData.requests

	if requestData.sourceExternal
		console.log("looking up external entity")
		csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
		csUtilities.getExternalReferenceCodes requestData.displayName, reqList, (prefResp) ->
			if csv
				callback
					displayName: requestData.displayName
					resultCSV: formatReqArrayAsCSV(prefResp)
			else
				callback
					displayName: requestData.displayName
					results: formatJSONReferenceCode(prefResp, "preferredName")
		return

	else  # internal source
		entityType = configuredEntityTypes.entityTypes[requestData.displayName]
		if entityType.codeOrigin is "ACAS LSThing"
			preferredThingService = require "./ThingServiceRoutes.js"
			reqHashes =
				thingType: entityType.type
				thingKind: entityType.kind
				requests: reqList
			preferredThingService.getThingCodesFromNamesOrCodes reqHashes, (codeResponse) ->
				if csv
					out = for res in codeResponse.results
						res.requestName + "," + res.referenceName
					outStr =  "Requested Name,Reference Code\n"+out.join('\n')
					callback
						displayName: requestData.displayName
						resultCSV: outStr
				else
					callback
						displayName: requestData.displayName
						results: formatJSONReferenceCode(codeResponse.results, "referenceName")
			return
		#this is the fall-through for internal. External fall-through is in csUtilities.getExternalReferenceCodes
		callback.statusCode = 500
		callback.end "problem with internal preferred Code request: code type and kind are unknown to system"

####################################################################
# BEST LABELS
####################################################################

exports.pickBestLabelsRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName

	if req.params.csv == "csv"
		csv = true
		requestData.referenceCodes = req.body.referenceCodes
	else
		csv = false
		requestData.requests = req.body.requests

	exports.pickBestLabels requestData, csv, (json) ->
		resp.json json

exports.pickBestLabels = (requestData, csv, callback) ->
	exports.getSpecificEntityType requestData.displayName, (json) ->
		requestData.type = json.type
		requestData.kind = json.kind
		requestData.sourceExternal = json.sourceExternal

	if csv
		reqList = formatCSVRequestAsReqArray(requestData.referenceCodes)
	else
		reqList = requestData.requests

	if requestData.sourceExternal
		console.log("looking up external entity")
		csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
		csUtilities.getExternalBestLabel requestData.displayName, reqList, (prefResp) ->
			if csv
				callback
					displayName: requestData.displayName
					resultCSV: formatBestLabelsAsCSV(prefResp)
			else
				callback
					displayName: requestData.displayName
					results: formatJSONBestLabel(prefResp, "preferredName")
		return

	else  # sourceExternal = false
		entityType = configuredEntityTypes.entityTypes[requestData.displayName]
		if entityType.codeOrigin is "ACAS LSThing"
			preferredThingService = require "./ThingServiceRoutes.js"
			reqHashes =
				thingType: entityType.type
				thingKind: entityType.kind
				requests: reqList
			preferredThingService.getThingCodesFromNamesOrCodes reqHashes, (codeResponse) ->
				if csv
					out = for res in codeResponse.results
						res.requestName + "," + res.preferredName
					outStr =  "Requested Name,Best Label\n"+out.join('\n')
					callback
						displayName: requestData.displayName
						resultCSV: outStr
				else
					callback
						displayName: requestData.displayName
						results: formatJSONBestLabel(codeResponse.results, "preferredName")
			return
		callback.statusCode = 500
		callback.end "problem with internal best label request: code type and kind are unknown to system"

####################################################################
# ENTITY SEARCH
####################################################################

exports.searchForEntitiesRoute = (req,resp) ->
	requestData =
		requestText: req.body.requestText

	exports.searchForEntities requestData, (json) ->
		resp.json json

exports.searchForEntities = (requestData, callback) ->
	if requestData.requestText == ''
		callback results: []

	# get a list of all entity types
	asCodes = true
	exports.getConfiguredEntityTypes asCodes, (json) ->
		requestData.entityTypes = json

	console.log("request Text is: "+ requestData.requestText)
	console.log "there are "+requestData.entityTypes.length+" types of entities to search"
	matchList = []
	counter = 0
	numTypes = requestData.entityTypes.length
	csv = false

	# Search using referenceCodes
	for entity in requestData.entityTypes
		console.log "searching for entity: "+entity.displayName
		entitySearchData =
			displayName: entity.displayName
			requests:
				[requestName: requestData.requestText]

		runSingleSearch entitySearchData, csv, (result) ->
			if result != 0
				matchList.push(result)
			counter = counter + 1
			console.log "returned number "+counter
			console.log("found "+ matchList.length+ " possible matches")
			if counter == numTypes
				callback
					results: matchList


runSingleSearch = (searchData, csv, callback) ->
	exports.referenceCodes searchData, csv, (searchResults) ->
		if searchResults.results[0].referenceCode != ""
			match =
				displayName: searchData.displayName
				referenceCode: searchResults.results[0].referenceCode
				requestName: searchResults.results[0].requestName
				requests:
					[requestName: searchResults.results[0].referenceCode]

			exports.pickBestLabels match, csv, (results1) ->
				finalObject =
					displayName: match.displayName
					requestText: match.requestName
					referenceCode: match.referenceCode
					bestLabel: results1.results[0].bestLabel
				callback finalObject
		else callback 0


####################################################################
# HELPER FUNCTIONS
####################################################################

formatCSVRequestAsReqArray = (csvReq) ->
	requests = []
	for req in csvReq.split '\n'
		unless req is ""
			requests.push requestName: req

	return requests

formatReqArrayAsCSV = (prefResp) ->
	preferreds = prefResp
	outStr =  "Requested Name,Reference Code\n"
	for pref in preferreds
		outStr += pref.requestName + ',' + pref.preferredName + '\n'

	return outStr

formatBestLabelsAsCSV = (prefResp) ->
	preferreds = prefResp
	outStr =  "Requested Name,Reference Code\n"
	for pref in preferreds
		outStr += pref.requestName + ',' + pref.preferredName + '\n'

	return outStr

# Needed to make names match spec
formatJSONReferenceCode = (prefResp,referenceCodeLocation) ->
	out = []
	for pref in prefResp
		out.push
			requestName: pref.requestName
			referenceCode: pref[referenceCodeLocation]
	return out

formatJSONBestLabel = (prefResp,referenceCodeLocation) ->
	out = []
	for pref in prefResp
		out.push
			requestName: pref.requestName
			bestLabel: pref[referenceCodeLocation]
	return out
