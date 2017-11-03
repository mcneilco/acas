exports.setupAPIRoutes = (app) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute
	app.get '/api/entitymeta/configuredEntityTypes/displayName/:displayName', exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/referenceCodes/:csv?', exports.referenceCodesRoute
	app.post '/api/entitymeta/pickBestLabels/:csv?', exports.pickBestLabelsRoute
	app.post '/api/entitymeta/searchForEntities', exports.searchForEntitiesRoute
	app.post '/api/entitymeta/projectCodes/:csv?', exports.projectCodesRoute

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/entitymeta/configuredEntityTypes/:asCodes?', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute
	app.get '/api/entitymeta/ConfiguredEntityTypes/displayName/:displayName', loginRoutes.ensureAuthenticated, exports.getSpecificEntityTypeRoute
	app.post '/api/entitymeta/referenceCodes/:csv?', loginRoutes.ensureAuthenticated, exports.referenceCodesRoute
	app.post '/api/entitymeta/pickBestLabels/:csv?', loginRoutes.ensureAuthenticated, exports.pickBestLabelsRoute
	app.post '/api/entitymeta/searchForEntities', loginRoutes.ensureAuthenticated ,exports.searchForEntitiesRoute
	app.post '/api/entitymeta/projectCodes/:csv?', loginRoutes.ensureAuthenticated, exports.projectCodesRoute

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
	console.debug "asCodes: "+asCodes
	if asCodes
		codes = for type in configuredEntityTypes.entityTypes
			code: type.code
			name: type.displayName
			ignored: false
		callback codes
	else
		callback configuredEntityTypes.entityTypes


exports.getSpecificEntityTypeRoute = (req, resp) ->
	displayName = req.params.displayName
	exports.getSpecificEntityType displayName, (json) ->
		resp.json json

exports.getSpecificEntityType = (displayName, callback) ->
	entityType = _.findWhere configuredEntityTypes.entityTypes, {displayName:displayName}
	if !entityType?
		entityType = _.findWhere configuredEntityTypes.entityTypes, {code:displayName}
	entityType ?= {}
	if callback?
		callback entityType
	else
		return entityType

exports.getSpecificEntityTypeByTypeKindAndCodeOrigin = (type, kind, codeOrigin) ->
	entityType = _.findWhere configuredEntityTypes.entityTypes, {type: type, kind: kind, codeOrigin: codeOrigin}
	if entityType?
		return entityType
	else
		return {}

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
	console.debug "stubs mode is: "+global.specRunnerTestmode 	#Note specRunnerTestMode is handled within functions called from here
	console.debug("csv is " + csv)

	# convert displayName to type and kind
	entityType = exports.getSpecificEntityType requestData.displayName
	if _.isEmpty entityType
		#this is the fall-through for internal. External fall-through is in csUtilities.getExternalReferenceCodes
			message = "problem with internal preferred Code request: code type and kind are unknown to system"
			callback message
			console.error message
			return
	requestData.type = entityType.type
	requestData.kind = entityType.kind
	requestData.sourceExternal = entityType.sourceExternal

	if csv
		reqList = formatCSVRequestAsReqArray(requestData.entityIdStringLines)
	else
		reqList = requestData.requests

	if requestData.sourceExternal
		console.debug("looking up external entity")
		csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
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
		if entityType.codeOrigin is "ACAS LsThing"
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
		else if entityType.codeOrigin is "ACAS LsContainer"
			console.debug "entityType.codeOrigin is ACAS LsContainer"
			console.debug reqList
			preferredContainerService = require "./InventoryServiceRoutes.js"
#			reqList = [reqList[0].requestName]
			if entityType.code == "Solution Container Tube"
				reqHashes =
					containerType: entityType.type
					containerKind: entityType.kind
					requests: reqList
				labels =  _.pluck reqList, 'requestName'
				preferredContainerService.getWellContentByContainerLabelsInternal labels, null, null, null, null, (response, statusCode) ->
					out = []
					for res in response
						if res.containerCodeName? && res.wellContent? && res.wellContent.length == 1 && res.wellContent[0].physicalState == "solution"
							codeName = res.containerCodeName
						else
							codeName = ""
						out.push
							requestName: res.label
							referenceCode: codeName
					if csv
						out = for res in out
							res.requestName + "," + res.referenceCode
						outStr =  "Requested Name,Reference Code\n"+out.join('\n')
						callback
							displayName: requestData.displayName
							resultCSV: outStr
					else
						callback
							displayName: requestData.displayName
							results: out
			else 
				reqHashes =
					containerType: entityType.type
					containerKind: entityType.kind
					requests: reqList
				preferredContainerService.getContainerCodesFromNamesOrCodes reqHashes, (codeResponse) ->
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
	entityType = exports.getSpecificEntityType requestData.displayName
	requestData.type = entityType.type
	requestData.kind = entityType.kind
	requestData.sourceExternal = entityType.sourceExternal

	if csv
		reqList = formatCSVRequestAsReqArray(requestData.referenceCodes)
	else
		reqList = requestData.requests

	if requestData.sourceExternal
		console.log("looking up external entity")
		csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
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
		if entityType.codeOrigin is "ACAS LsThing"
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
		else if entityType.codeOrigin is "ACAS LsContainer"
			console.log "entityType.codeOrigin is ACAS LSContainer"
			console.log reqList
			preferredContainerService = require "./InventoryServiceRoutes.js"
			reqHashes =
				containerType: entityType.type
				containerKind: entityType.kind
				requests: reqList
			preferredContainerService.getContainerCodesFromNamesOrCodes reqHashes, (codeResponse) ->
				console.log "codeResponse"
				console.log codeResponse
				callback
					displayName: requestData.displayName
					results: formatJSONBestLabel(codeResponse.results, "preferredName")
			return
		else
			message = "problem with internal best label request: code type and kind are unknown to system"
			callback "problem with internal best label request: code type and kind are unknown to system"
			console.error "problem with internal best label request: code type and kind are unknown to system"

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
			displayName: entity.name
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
	outStr =  "Requested Name,Best Label\n"
	for pref in preferreds
		outStr += pref.requestName + ',' + pref.preferredName + '\n'

	return outStr

formatProjectCodesArrayAsCSV = (prefResp) ->
	preferreds = prefResp
	outStr =  "Requested Name,Project Code\n"
	if prefResp?
		for pref in preferreds
			outStr += pref.requestName + ',' + pref.projectCode + '\n'
	else
		outStr += ',\n'
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

formatJSONProjectCode = (prefResp,projectCodeLocation) ->
	out = []
	for pref in prefResp
		out.push
			requestName: pref.requestName
			projectCode: pref[projectCodeLocation]
	return out

####################################################################
#   PROJECT CODES
####################################################################

exports.projectCodesRoute = (req, resp) ->
	requestData =
		displayName: req.body.displayName

	if req.params.csv == "csv"
		csv = true
		requestData.entityIdStringLines = req.body.entityIdStringLines
	else
		csv = false
		requestData.requests = req.body.requests

	exports.projectCodes requestData, csv, (json) ->
		if typeof json is "string" and json.indexOf("failed") > -1
			resp.statusCode = 500
			resp.json json
		resp.json json

exports.projectCodes = (requestData, csv, callback) ->
	console.log "stubs mode is: "+global.specRunnerTestmode 	#Note specRunnerTestMode is handled within functions called from here
	console.log("csv is " + csv)
	console.log "requestData.displayName is " + requestData.displayName

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
		csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
		csUtilities.getExternalProjectCodes requestData.displayName, reqList, (prefResp) ->
			if typeof prefResp is "string" and prefResp.indexOf("failed") > -1
				callback prefResp
			if csv
				callback
					displayName: requestData.displayName
					resultCSV: formatProjectCodesArrayAsCSV(prefResp)
			else
				callback
					displayName: requestData.displayName
					results: formatJSONProjectCode(prefResp, "projectCode")
		return

	else  # internal source
		entityType = configuredEntityTypes.entityTypes[requestData.displayName]
		console.log "entityType: " + entityType
		if entityType.codeOrigin is "ACAS LsThing"
			preferredThingService = require "./ThingServiceRoutes.js"
			reqHashes =
				thingType: entityType.type
				thingKind: entityType.kind
				requests: reqList
			preferredThingService.getProjectCodesFromNamesOrCodes reqHashes, (codeResponse) ->
				if csv
					out = for res in codeResponse.results
						res.requestName + "," + res.projectCode
					outStr =  "Requested Name,Project Code\n"+out.join('\n')
					callback
						displayName: requestData.displayName
						resultCSV: outStr
				else
					callback
						displayName: requestData.displayName
						results: formatJSONProjectCode(codeResponse.results, "projectCode")
			return
		#this is the fall-through for internal. External fall-through is in csUtilities.getExternalReferenceCodes
		callback.statusCode = 500
		callback "problem with internal preferred Code request: code type and kind are unknown to system"
