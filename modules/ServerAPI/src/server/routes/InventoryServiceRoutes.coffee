serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
_ = require 'underscore'
preferredEntityCodeService = require '../routes/PreferredEntityCodeService.js'
codeTableRoutes = require './CodeTableServiceRoutes.js'
config = require '../conf/compiled/conf.js'
RUN_CUSTOM_FLAG = "0"
fs = require('fs')
parse = require('csv-parse')
request = require 'request'


exports.setupAPIRoutes = (app) ->
	app.post '/api/getContainersInLocationWithTypeAndKind', exports.getContainersInLocationWithTypeAndKind
	app.post '/api/getContainersInLocation', exports.getContainersInLocation
	app.post '/api/getContainerCodesByLabels', exports.getContainerCodesByLabels
	app.post '/api/getContainersByLabels', exports.getContainersByLabels
	app.post '/api/getContainersByCodeNames', exports.getContainersByCodeNames
	app.post '/api/getWellCodesByPlateBarcodes', exports.getWellCodesByPlateBarcodes
	app.post '/api/getWellContent', exports.getWellContent
	app.put '/api/containersByContainerCodes', exports.updateContainersByContainerCodes
	app.put '/api/containerByContainerCode', exports.updateContainerByContainerCode
	app.get '/api/getContainerAndDefinitionContainerByContainerLabel/:label', exports.getContainerAndDefinitionContainerByContainerLabel
	app.post '/api/getContainerAndDefinitionContainerByContainerCodeNames', exports.getContainerAndDefinitionContainerByContainerCodeNames
	app.post '/api/getDefinitionContainersByContainerCodeNames', exports.getDefinitionContainersByContainerCodeNames
	app.put '/api/containers/jsonArray', exports.updateContainers
	app.post '/api/getBreadCrumbByContainerCode', exports.getBreadCrumbByContainerCode
	app.post '/api/getWellCodesByContainerCodes', exports.getWellCodesByContainerCodes
	app.get '/api/containers', exports.getAllContainers
	app.get '/api/containers/:lsType/:lsKind', exports.containersByTypeKind
	app.get '/api/containers/:code', exports.containerByCodeName
	app.post '/api/containers', exports.postContainer
	app.put '/api/containers/:code', exports.putContainer
	app.post '/api/validateContainerName', exports.validateContainerName
	app.post '/api/getContainerCodesFromLabels', exports.getContainerCodesFromLabels
	app.post '/api/getContainerFromLabel', exports.getContainerFromLabel
	app.post '/api/updateWellContent', exports.updateWellContent
	app.post '/api/updateWellContentWithObject', exports.updateWellContentWithObject
	app.post '/api/updateAmountInWell', exports.updateAmountInWell
	app.post '/api/moveToLocation', exports.moveToLocation
	app.get '/api/getWellContentByContainerLabel/:label', exports.getWellContentByContainerLabel
	app.post '/api/getWellContentByContainerLabels', exports.getWellContentByContainerLabels
	app.post '/api/cloneContainers', exports.cloneContainers
	app.post '/api/cloneContainer', exports.cloneContainer
	app.post '/api/splitContainer', exports.splitContainer
	app.post '/api/mergeContainers', exports.mergeContainers
	app.get '/api/getDefinitionContainerByNumberOfWells/:lsType/:lsKind/:numberOfWells', exports.getDefinitionContainerByNumberOfWells
	app.post '/api/searchContainers', exports.searchContainers
	app.post '/api/containerLogs', exports.containerLogs
	app.get '/api/containerLogs/:label', exports.getContainerLogs
	app.post '/api/containerLocationHistory', exports.containerLocationHistory
	app.get '/api/containerLocationHistory/:label', exports.getContainerLocationHistory
	app.post '/api/getWellContentByContainerCodes', exports.getWellContentByContainerCodes
	app.post '/api/getContainerCodeNamesByContainerValue', exports.getContainerCodeNamesByContainerValue
	app.post '/api/createTube', exports.createTube
	app.post '/api/createTubes', exports.createTubes
	app.post '/api/throwInTrash', exports.throwInTrash
	app.post '/api/updateContainerHistoryLogs', exports.updateContainerHistoryLogs
	app.post '/api/getContainerInfoFromBatchCode', exports.getContainerInfoFromBatchCode
	app.post '/api/getContainerStatesByContainerValue', exports.getContainerStatesByContainerValue
	app.post '/api/getContainerLogsByContainerCodes', exports.getContainerLogsByContainerCodes
	app.post '/api/getTubesFromBatchCode', exports.getTubesFromBatchCode
	app.post '/api/loadParentVialsFromCSV', exports.loadParentVialsFromCSV
	app.post '/api/loadDaughterVialsFromCSV', exports.loadDaughterVialsFromCSV
	app.post '/api/saveWellToWellInteractions', exports.saveWellToWellInteractions
	app.post '/api/createDaughterVials', exports.createDaughterVials
	app.post '/api/advancedSearchContainers', exports.advancedSearchContainers
	app.get '/api/getParentVialByDaughterVialBarcode', exports.getParentVialByDaughterVialBarcode
	app.get '/api/getContainerLocationTree', exports.getContainerLocationTree
	app.post '/api/checkBatchDependencies', exports.checkBatchDependencies
	app.post '/api/setLocationByBreadCrumb', exports.setLocationByBreadCrumb


exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/getContainersInLocationWithTypeAndKind', loginRoutes.ensureAuthenticated, exports.getContainersInLocationWithTypeAndKind
	app.post '/api/getContainersInLocation', loginRoutes.ensureAuthenticated, exports.getContainersInLocation
	app.post '/api/getContainerCodesByLabels', loginRoutes.ensureAuthenticated, exports.getContainerCodesByLabels
	app.post '/api/getContainersByLabels', loginRoutes.ensureAuthenticated, exports.getContainersByLabels
	app.post '/api/getContainersByCodeNames', loginRoutes.ensureAuthenticated, exports.getContainersByCodeNames
	app.post '/api/getWellCodesByPlateBarcodes', loginRoutes.ensureAuthenticated, exports.getWellCodesByPlateBarcodes
	app.post '/api/getWellContent', loginRoutes.ensureAuthenticated, exports.getWellContent
	app.put '/api/containersByContainerCodes', loginRoutes.ensureAuthenticated, exports.updateContainersByContainerCodes
	app.put '/api/containerByContainerCode', loginRoutes.ensureAuthenticated, exports.updateContainerByContainerCode
	app.get '/api/getContainerAndDefinitionContainerByContainerLabel/:label', loginRoutes.ensureAuthenticated, exports.getContainerAndDefinitionContainerByContainerLabel
	app.post '/api/getContainerAndDefinitionContainerByContainerCodeNames', loginRoutes.ensureAuthenticated, exports.getContainerAndDefinitionContainerByContainerCodeNames
	app.post '/api/getDefinitionContainersByContainerCodeNames', loginRoutes.ensureAuthenticated, exports.getDefinitionContainersByContainerCodeNames
	app.put '/api/containers/jsonArray', loginRoutes.ensureAuthenticated, exports.updateContainers
	app.post '/api/getBreadCrumbByContainerCode', loginRoutes.ensureAuthenticated, exports.getBreadCrumbByContainerCode
	app.post '/api/getWellCodesByContainerCodes', loginRoutes.ensureAuthenticated, exports.getWellCodesByContainerCodes
	app.get '/api/containers', loginRoutes.ensureAuthenticated, exports.getAllContainers
	app.get '/api/containers/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.containersByTypeKind
	app.get '/api/containers/:code', loginRoutes.ensureAuthenticated, exports.containerByCodeName
	app.post '/api/containers', loginRoutes.ensureAuthenticated, exports.postContainer
	app.put '/api/containers/:code', loginRoutes.ensureAuthenticated, exports.putContainer
	app.post '/api/validateContainerName', loginRoutes.ensureAuthenticated, exports.validateContainerName
	app.post '/api/getContainerCodesFromLabels', loginRoutes.ensureAuthenticated, exports.getContainerCodesFromLabels
	app.post '/api/getContainerFromLabel', loginRoutes.ensureAuthenticated, exports.getContainerFromLabel
	app.post '/api/updateWellContent', loginRoutes.ensureAuthenticated, exports.updateWellContent
	app.post '/api/updateWellContentWithObject', loginRoutes.ensureAuthenticated, exports.updateWellContentWithObject
	app.post '/api/updateAmountInWell', loginRoutes.ensureAuthenticated, exports.updateAmountInWell
	app.post '/api/moveToLocation', loginRoutes.ensureAuthenticated, exports.moveToLocation
	app.get '/api/getWellContentByContainerLabel/:label', loginRoutes.ensureAuthenticated, exports.getWellContentByContainerLabel
	app.post '/api/getWellContentByContainerLabels', loginRoutes.ensureAuthenticated, exports.getWellContentByContainerLabels
	app.post '/api/getWellContentByContainerLabelsObject', loginRoutes.ensureAuthenticated, exports.getWellContentByContainerLabelsObject
	app.post '/api/cloneContainers', loginRoutes.ensureAuthenticated, exports.cloneContainers
	app.post '/api/cloneContainer', loginRoutes.ensureAuthenticated, exports.cloneContainer
	app.post '/api/splitContainer', loginRoutes.ensureAuthenticated, exports.splitContainer
	app.post '/api/mergeContainers', loginRoutes.ensureAuthenticated, exports.mergeContainers
	app.get '/api/getDefinitionContainerByNumberOfWells/:lsType/:lsKind/:numberOfWells', loginRoutes.ensureAuthenticated, exports.getDefinitionContainerByNumberOfWells
	app.post '/api/searchContainers', loginRoutes.ensureAuthenticated, exports.searchContainers
	app.post '/api/containerLogs', loginRoutes.ensureAuthenticated, exports.containerLogs
	app.get '/api/containerLogs/:label', loginRoutes.ensureAuthenticated, exports.getContainerLogs
	app.post '/api/containerLocationHistory', loginRoutes.ensureAuthenticated, exports.containerLocationHistory
	app.get '/api/containerLocationHistory/:label', loginRoutes.ensureAuthenticated, exports.getContainerLocationHistory
	app.post '/api/getWellContentByContainerCodes', loginRoutes.ensureAuthenticated, exports.getWellContentByContainerCodes
	app.post '/api/getContainerCodeNamesByContainerValue', loginRoutes.ensureAuthenticated, exports.getContainerCodeNamesByContainerValue
	app.post '/api/createTube', loginRoutes.ensureAuthenticated, exports.createTube
	app.post '/api/createTubes', loginRoutes.ensureAuthenticated, exports.createTubes
	app.post '/api/throwInTrash', loginRoutes.ensureAuthenticated, exports.throwInTrash
	app.post '/api/updateContainerHistoryLogs', loginRoutes.ensureAuthenticated, exports.updateContainerHistoryLogs
	app.post '/api/getTubesFromBatchCode', loginRoutes.ensureAuthenticated, exports.getTubesFromBatchCode
	app.post '/api/loadParentVialsFromCSV', loginRoutes.ensureAuthenticated, exports.loadParentVialsFromCSV
	app.post '/api/loadDaughterVialsFromCSV', loginRoutes.ensureAuthenticated, exports.loadDaughterVialsFromCSV
	app.post '/api/saveWellToWellInteractions', loginRoutes.ensureAuthenticated, exports.saveWellToWellInteractions
	app.post '/api/createDaughterVials', loginRoutes.ensureAuthenticated, exports.createDaughterVials
	app.post '/api/advancedSearchContainers', loginRoutes.ensureAuthenticated, exports.advancedSearchContainers
	app.get '/api/getParentVialByDaughterVialBarcode', loginRoutes.ensureAuthenticated, exports.getParentVialByDaughterVialBarcode
	app.get '/api/getContainerLocationTree', loginRoutes.ensureAuthenticated, exports.getContainerLocationTree
	app.post '/api/checkBatchDependencies', loginRoutes.ensureAuthenticated, exports.checkBatchDependencies
	app.post '/api/setLocationByBreadCrumb', loginRoutes.ensureAuthenticated, exports.setLocationByBreadCrumb

exports.getContainersInLocation = (req, resp) ->
	req.setTimeout 86400000
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersInLocationResponse
	else
		queryParams = []
		if req.query.containerType?
			queryParams.push "containerType="+req.query.containerType
		if req.query.containerKind?
			queryParams.push "containerKind="+req.query.containerKind
		queryString = queryParams.join "&"
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersInLocation?"+queryString
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to get getContainersInLocation'
				console.error error
				console.error json
				console.error response
				resp.end JSON.stringify "getContainersInLocation failed"
  		)

exports.getContainersInLocationWithTypeAndKind = (req, resp) ->
	req.setTimeout 86400000
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersInLocationResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersInLocation?containerType=location&containerKind=default"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.values
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to get getContainersInLocation'
				console.error error
				console.error json
				console.error response
				resp.end JSON.stringify "getContainersInLocation failed"
		)

exports.getContainersInLocationWithTypeAndKindInternal = (values, callback) ->
	#req.setTimeout 86400000
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersInLocationResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersInLocation?containerType=location&containerKind=default"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: values
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json, response.statusCode
			else
				console.error 'got ajax error trying to get getContainersInLocation'
				console.error error
				console.error json
				console.error response
				#resp.end JSON.stringify "getContainersInLocation failed"
				callback response, response.statusCode
		)

exports.getContainersByLabels = (req, resp) ->
	req.setTimeout 86400000

	exports.getContainersByLabelsInternal req.body, req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getContainersByLabelsInternal = (containerLabels, containerType, containerKind, labelType, labelKind, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersByLabelsInternalResponse
	else
		console.debug 'incoming getContainersByLabelsInternal request: ', JSON.stringify(containerLabels), containerType, containerKind, labelType, labelKind
		exports.getContainerCodesByLabelsInternal containerLabels, containerType, containerKind, labelType, labelKind, (containerCodes, statusCode) =>
			if statusCode == 500
				callback JSON.stringify("getContainersByLabels failed"), 500
			else
				codeNames = _.map containerCodes, (code) ->
					if code.foundCodeNames[0]?
						code.foundCodeNames[0]
					else
						""
				codeNamesJSON = JSON.stringify codeNames
				exports.getContainersByCodeNamesInternal codeNamesJSON, (containers, statusCode) =>
					if statusCode == 400
						console.debug "got errors requesting code names: #{JSON.stringify containers}"
					if statusCode == 500
						callback JSON.stringify "getContainersByLabels failed", 500
					else
						response = []
						for label, index in containerLabels
							resp =
								label: label
								codeName: null
								container: null
							codeName =  containerCodes[index]
							if codeName?.foundCodeNames[0]?
								resp.codeName = codeName.foundCodeNames[0]
							container = _.findWhere(containers, {'containerCodeName': resp.codeName})
							if container?.container?
								resp.container = container.container
							if container?.level?
								resp.level = container.level
							if container?.message?
								resp.message = container.message
							response.push resp
						callback response, statusCode

exports.getContainerCodesByLabels = (req, resp) ->
	req.setTimeout 86400000

	containerLabels = req.body
	containerType = req.query.containerType
	containerKind = req.query.containerKind
	labelType = req.query.labelType
	labelKind = req.query.labelKind
	likeParameter = req.query.like
	maxResults = req.query.maxResults

	queryPayload =
		containerLabels: req.body
		containerType: containerType
		containerKind: containerKind
		labelType: labelType
		labelKind: labelKind
		likeParameter: likeParameter
		maxResults: maxResults

	console.log 'queryPayload', queryPayload

	exports.getContainerCodesByLabelsLikeMaxResultsInternal(queryPayload, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json
	)

exports.getContainerCodesByLabelsLikeMaxResultsInternal = (requestObject, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerCodesByLabelsResponse
	else
		config = require '../conf/compiled/conf.js'

		containerLabels = requestObject.containerLabels
		containerType = requestObject.containerType
		containerKind = requestObject.containerKind
		labelType = requestObject.labelType
		labelKind = requestObject.labelKind
		likeParameter = requestObject.likeParameter
		maxResults = requestObject.maxResults

		console.debug 'incoming getContainerCodesByLabelsLikeMaxResultsInternal: ', JSON.stringify(containerLabels), containerType, containerKind, labelType, labelKind, likeParameter, maxResults

		queryParams = []

		if containerType?
			queryParams.push "containerType="+containerType
		if containerKind?
			queryParams.push "containerKind="+containerKind
		if labelType?
			queryParams.push "labelType="+labelType
		if labelKind?
			queryParams.push "labelKind="+labelKind
		if likeParameter?
			queryParams.push "like="+likeParameter
		if maxResults?
			queryParams.push "maxResults="+maxResults
		queryString = queryParams.join "&"
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels?"+queryString
		console.debug 'base url: ', baseurl
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify containerLabels
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && json[0] != "<"
				callback json, response.statusCode
			else
				console.error 'got ajax error trying to get getContainerCodesByLabels'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify("getContainerCodesByLabels failed"), 500
		)

exports.getContainerCodesByLabelsInternal = (containerCodesJSON, containerType, containerKind, labelType, labelKind, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerCodesByLabelsResponse
	else
		console.warn "getContainerCodesByLabelsInternal is deprecated please use getContainerCodesByLabelsLikeMaxResultsInternal"
		console.debug 'incoming getContainerCodesByLabelsInternal request: ', JSON.stringify(containerCodesJSON), containerType, containerKind, labelType, labelKind
		config = require '../conf/compiled/conf.js'

		likeParameter = null
		maxResults = null

		queryPayload =
			containerLabels: containerCodesJSON
			containerType: containerType
			containerKind: containerKind
			labelType: labelType
			labelKind: labelKind
			likeParameter: likeParameter
			maxResults: maxResults

		exports.getContainerCodesByLabelsLikeMaxResultsInternal(queryPayload, (json, statusCode) ->
			callback json, statusCode
		)

exports.getWellCodesByPlateBarcodes = (req, resp) ->
	req.setTimeout 86400000
	exports.getWellCodesByPlateBarcodesInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getContainersInBoxPositionInternal = (values, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersInLocationResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersInLocation?containerType=container&containerKind=tube"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: values
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json, response.statusCode
			else
				console.error 'got ajax error trying to get getContainersInLocation'
				console.error error
				console.error json
				console.error response
				#resp.end JSON.stringify "getContainersInLocation failed"
				callback response, response.statusCode
		)

exports.getWellCodesByPlateBarcodes = (req, resp) ->
	req.setTimeout 86400000
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getWellCodesByPlateBarcodesResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getWellCodesByPlateBarcodes"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to get getWellCodesByPlateBarcodes'
				console.error error
				console.error json
				console.error response
				resp.end JSON.stringify "getWellCodesByPlateBarcodes failed"
  		)

exports.getWellCodesByPlateBarcodesInternal = (plateBarcodes, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		callback inventoryServiceTestJSON.getWellCodesByPlateBarcodesResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getWellCodesByPlateBarcodes"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: plateBarcodes
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.error 'got ajax error trying to get getWellCodesByPlateBarcodes'
				console.error error
				console.error json
				console.error response
				callback "getWellCodesByPlateBarcodes failed"
		)

exports.getWellContent = (req, resp) ->
	req.setTimeout 86400000
	exports.getWellContentInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getWellContentInternal = (wellCodeNames, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		callback inventoryServiceTestJSON.getWellContentResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getWellContent"
		request = require 'request'
		console.debug 'calling service', baseurl
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify wellCodeNames
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.debug 'returned success from service', baseurl
				callback json
			else
				console.error 'got ajax error trying to get getWellContent'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify "getWellContent failed"
  		)

exports.getContainerAndDefinitionContainerByContainerLabel = (req, resp) ->
	req.setTimeout 86400000
	exports.getContainerAndDefinitionContainerByContainerLabelInternal [req.params.label], req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json[0]

exports.getContainerAndDefinitionContainerByContainerLabelInternal = (labels, containerType, containerKind, labelType, labelKind, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerAndDefinitionContainerByContainerLabelInternalResponse
	else
		console.debug "incoming getContainerAndDefinitionContainerByContainerLabelInternal request: '#{JSON.stringify(labels)}'"
		exports.getContainerCodesByLabelsInternal labels, containerType, containerKind, labelType, labelKind, (containerCodes, statusCode) =>
			if statusCode == 500
				callback JSON.stringify "getContainerAndDefinitionContainerByContainerLabelInternal failed", statusCode
			else
				codeNames = _.map containerCodes, (code) ->
					if code.foundCodeNames[0]?
						code.foundCodeNames[0]
					else
						""
				exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal codeNames, (json, statusCode) =>
					if statusCode == 500
						callback JSON.stringify "getContainerAndDefinitionContainerByContainerLabelInternal failed", statusCode
					else
						callback json, statusCode

exports.getContainerAndDefinitionContainerByContainerCodeNames = (req, resp) ->
	req.setTimeout 86400000
	exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal = (containerCodes, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerAndDefinitionContainerByContainerCodeNamesInternalResponse
	else
		console.debug "incoming getContainerAndDefinitionContainerByContainerCodeNames request: '#{JSON.stringify(containerCodes)}'"
		exports.getContainersByCodeNamesInternal containerCodes, (containers, statusCode) =>
			if statusCode == 400
				console.error "got errors requesting code names: #{JSON.stringify containers}"
				callback containers, 400
				return
			if statusCode == 500
				callback JSON.stringify "getContainerAndDefinitionContainerByContainerCodeNames failed", statusCode
			else
				exports.getDefinitionContainersByContainerCodeNamesInternal containerCodes, (definitions, statusCode) =>
					if statusCode == 500
						callback JSON.stringify "getContainerAndDefinitionContainerByContainerCodeNames failed", statusCode
					else
						outArray = []
						for containerCode, index in containerCodes
							container = _.findWhere(containers, {'containerCodeName': containerCode})
							definition = _.findWhere(definitions, {'containerCodeName': containerCode})
							if container.container?
								container = container.container
								containerPreferredEntity = preferredEntityCodeService.getSpecificEntityTypeByTypeKindAndCodeOrigin container.lsType, container.lsKind, "ACAS LsContainer"
								if _.isEmpty containerPreferredEntity
									message = "could not find preferred entity for lsType '#{container.lsType}' and lsKind '#{container.lsKind}'"
									console.error message
									console.debug "here are the configured entity types"
									preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
										console.debug types
									callback message, 400
									return
								else if !containerPreferredEntity.model?
										message = "could not find model for preferred entity lsType '#{container.lsType}' and lsKind '#{container.lsKind}'"
										console.error message
										console.debug "here are the configured entity types"
										preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
											console.debug types
										callback message, 400
										return
								container = new containerPreferredEntity.model(container)
								if definition.definition?
									definitionPreferredEntity = preferredEntityCodeService.getSpecificEntityTypeByTypeKindAndCodeOrigin definition.definition.lsType, definition.definition.lsKind, "ACAS LsContainer"
									if _.isEmpty definitionPreferredEntity
										message = "could not find preferred entity for lsType '#{definition.definition.lsType}' and lsKind '#{definition.definition.lsKind}'"
										console.error message
										console.debug "here are the configured entity types"
										preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
											console.debug types
										callback message, 400
										return
									else if !definitionPreferredEntity.model?
										message = "could not find model for preferred entity lsType '#{definition.definition.lsType}' and lsKind '#{definition.definition.lsKind}'"
										console.error message
										console.debug "here are the configured entity types"
										preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
											console.debug types
										callback message, 400
										return
									definition = new definitionPreferredEntity.model(definition.definition)
									definitionValues =  definition.getValues()
									definitionCodeName = definition.get('codeName')
								else
									definitionValues = {}
									definitionCodeName = null
								containerValues =  container.getValues()
								out = _.extend containerValues, definitionValues
								out.barcode = container.get('barcode').get("labelText")
								out.codeName = containerCode
								out.definitionCodeName = definitionCodeName
								out.recordedBy = container.get('recordedBy')
								outArray.push out
							else
								console.error "could not find container #{containerCode}"
						callback outArray, 200

exports.updateContainerByContainerCode = (req, resp) ->
	req.setTimeout 86400000
	exports.updateContainersByContainerCodesInternal [req.body], req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json[0]

exports.updateContainersByContainerCodes = (req, resp) ->
	req.setTimeout 86400000
	exports.updateContainersByContainerCodesInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.updateContainersByContainerCodesInternal = (updateInformation, callCustom, callback) ->
	# If call custom doesn't equal 0 then call custom
	callCustom  = callCustom != "0"
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.updateContainerMetadataByContainerCodeResponse
	else
		console.debug "incoming updateContainersByContainerCodesInternal request: #{JSON.stringify(updateInformation)}"
		codeNames = _.pluck updateInformation, "codeName"
		console.debug "calling getContainersByCodeNamesInternal"
		exports.getContainersByCodeNamesInternal codeNames, (containers, statusCode) =>
			if statusCode == 400
				console.error "got errors requesting code names: #{JSON.stringify containers}"
				callback "error when requesting code names", 400
			if statusCode == 500
				console.error "updateContainerMetadataByContainerCodeInternal failed: #{JSON.stringify containers}"
				callback "updateContainerMetadataByContainerCodeInternal failed", 500
				return
			else
				barcodes = _.pluck updateInformation, "barcode"
				console.debug "calling getContainerCodesByLabelsInternal"
				exports.getContainerCodesByLabelsInternal barcodes, "container", null, "barcode", "barcode", (containerCodes, statusCode) =>
					if statusCode == 500
						console.error "updateContainerMetadataByContainerCodeInternal failed: #{JSON.stringify containerCodes}"
						callback "updateContainersByContainerCodesInternal failed", 500
						return
					console.debug "return from getContainerCodesByLabelsInternal with #{JSON.stringify(containerCodes)}"
					containerArray = []
					for updateInfo, index in updateInformation
						container = _.findWhere(containers, {'containerCodeName': updateInfo.codeName})
						if container.container?
							container = container.container
							console.debug "found container type: #{container.lsType}"
							console.debug "found container kind: #{container.lsKind}"
							preferredEntity = preferredEntityCodeService.getSpecificEntityTypeByTypeKindAndCodeOrigin container.lsType, container.lsKind, "ACAS LsContainer"
							if _.isEmpty preferredEntity
								message = "could not find preferred entity for lsType '#{container.lsType}' and lsKind '#{container.lsKind}'"
								console.error message
								console.debug "here are the configured entity types"
								preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
									console.debug types
								callback message, 400
								return
							container = new preferredEntity.model(container)
							if updateInfo.barcode?
								if containerCodes[index].foundCodeNames.length > 1
									message = "conflict: found more than 1 container plate barcode for label #{containerCodes[index].requestLabel}: #{containerCodes[index].foundCodeNames.join(",")}"
									console.error message
									callback message, 409
									return
								else
									if containerCodes[index].foundCodeNames.length == 0 || containerCodes[index].foundCodeNames[0] == updateInfo.codeName
										container.get('barcode').set("labelText", updateInfo.barcode)
									else
										message = "conflict: barcode '#{updateInfo.barcode}' is already associated with container code '#{containerCodes[index].foundCodeNames[0]}'"
										console.error message
										callback message, 409
										return
							container.updateValuesByKeyValue updateInfo
							container.prepareToSave updateInformation[0].recordedBy
							container.reformatBeforeSaving()
							#if container.isNew() or container.get('lsLabels').length > 0 or container.get('lsStates').length > 0
							containerArray.push container.attributes
						else
							console.error "could not find container #{updateInfo.codeName}"
					containerJSONArray = JSON.stringify(containerArray)
					exports.updateContainersInternal containerJSONArray, (savedContainers, statusCode) =>
						if statusCode == 500
							callback JSON.stringify("updateContainersByContainerCodesInternal failed"), 500
							return
						else
							if callCustom
								if csUtilities.updateContainersByContainerCodes?
									console.log "running customer specific server function updateContainersByContainerCodes"
									csUtilities.updateContainersByContainerCodes updateInformation, (response) ->
										console.log response
								else
									console.warn "could not find customer specific server function updateContainersByContainerCodes so not running it"
							for updateInfo, index in updateInformation
								preferredEntity = preferredEntityCodeService.getSpecificEntityTypeByTypeKindAndCodeOrigin savedContainers[index].lsType, savedContainers[index].lsKind, "ACAS LsContainer"
								savedContainer = new preferredEntity.model(savedContainers[index])
								updateInformation[index].barcode = savedContainer.get('barcode').get("labelText")
								values =  savedContainer.getValuesByKey(Object.keys(updateInfo))
								for key of values
									updateInformation[index][key] = values[key]
							callback updateInformation, 200

exports.getContainersByCodeNames = (req, resp) ->
	req.setTimeout 86400000
	exports.getContainersByCodeNamesInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getContainersByCodeNamesInternal = (codeNamesJSON, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersByCodeNames
	else
		console.debug 'incoming getContainersByCodeNamesInternal request: ', JSON.stringify(codeNamesJSON)
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersByCodeNames"
		console.debug 'base url: ', baseurl
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesJSON
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && json[0] != "<"
				callback json, response.statusCode
			else
				console.error 'got ajax error trying to get getContainersByCodeNames'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify("getContainersByCodeNames failed"), 500
		)

exports.getDefinitionContainersByContainerCodeNames = (req, resp) ->
	req.setTimeout 86400000
	exports.getDefinitionContainersByContainerCodeNamesInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getDefinitionContainersByContainerCodeNamesInternal = (codeNamesJSON, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getDefinitionContainersByContainerCodeNames
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getDefinitionContainersByContainerCodeNames"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesJSON
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error
				callback json, response.statusCode
			else
				console.error 'got ajax error trying to get getDefinitionContainersByContainerCodeNames'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify "getDefinitionContainersByContainerCodeNames failed", response.statusCode
		)

exports.getBreadCrumbByContainerCode = (req, resp) ->
	req.setTimeout 86400000
	exports.getBreadCrumbByContainerCodeInternal req.body, req.query.delimeter, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getBreadCrumbByContainerCodeInternal = (codeNamesJSON, delimeter, callback) ->
	if !delimeter?
		delimeter = ">"
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getBreadCrumbByContainerCodeResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.rapache.fullpath+"/getBreadCrumbByContainerCode?delimeter="+encodeURIComponent(delimeter)
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesJSON
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.log 'json in getBreadCrumbByContainerCodeInternal'
				console.log json
				callback json
			else
				console.error 'got ajax error trying to get getBreadCrumbByContainerCode'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify "getBreadCrumbByContainerCode failed"
		)

exports.getWellCodesByContainerCodes = (req, resp) ->
	req.setTimeout 86400000
	exports.getWellCodesByContainerCodesInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getWellCodesByContainerCodesInternal = (codeNamesJSON, callback) ->
	console.debug 'incoming getWellCodesByContainerCodes request: ', JSON.stringify(codeNamesJSON)
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getWellCodesByContainerCodesResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getWellCodesByContainerCodes"
		console.debug 'base url: ', baseurl
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesJSON
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.debug "returned successfully from #{baseurl}"
				callback json
			else
				console.error 'got ajax error trying to get getWellCodesByContainerCodes'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify "getWellCodesByContainerCodes failed"
		)

exports.getWellContentByContainerCodes = (req, resp) ->
	req.setTimeout 86400000
	exports.getWellContentByContainerCodesInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getWellContentByContainerCodesInternal = (containerCodeNames, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getWellContentByContainerCodesResponse
	else
		console.debug 'requesting well codes from container codes'
		uniqueCodeNames = _.uniq containerCodeNames
		exports.getWellCodesByContainerCodesInternal uniqueCodeNames, (wellCodesResponse) ->
			wellCodes = _.map wellCodesResponse, (wellCode) ->
				_.map wellCode.wellCodeNames, (codeName) ->
					{containerCode: wellCode.requestCodeName, wellCode: codeName}
			wellCodes = _.flatten wellCodes
			wellContentRequest = _.pluck wellCodes, 'wellCode'
			console.debug 'requesting well content from well container codes'
			exports.getWellContentInternal wellContentRequest, (wellContentResponse) ->
				response = []
				for containerCodeName in containerCodeNames
					containerWellCodes = _.pluck(_.where(wellCodes, {containerCode: containerCodeName}), "wellCode")
					containerWellContent = _.filter wellContentResponse, (wellContent) ->
						return wellContent.containerCodeName in containerWellCodes
					containerWellContent = _.sortBy containerWellContent, 'wellName'
					response.push {containerCodeName: containerCodeName, wellContent: containerWellContent}
				callback response

exports.updateContainers = (req, resp) ->
	req.setTimeout 86400000
	exports.updateContainersInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.updateContainersInternal = (containers, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.updateContainersResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/jsonArray"
		console.debug 'incoming updateContainersInternal request: ', containers
		console.debug "base url: #{baseurl}"
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: containers
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200 && json[0] != "<"
				callback json, 200
			else
				console.error 'got ajax error trying to get updateContainers'
				console.error error
				console.error json
				console.error "request #{containers}"
				console.error response
				callback JSON.stringify("updateContainers failed"), 500
		)

exports.getAllContainers = (req, resp) ->
	req.setTimeout 86400000
	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json containerTestJSON.container
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)



exports.containersByTypeKind = (req, resp) ->
	req.setTimeout 86400000
	exports.containersByTypeKindInternal req.params.lsType, req.params.lsKind, req.query.format, req.query.stub, req.query.testMode, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.containersByTypeKindInternal = (lsType, lsKind, format, stub, testMode, callback) ->
	config = require '../conf/compiled/conf.js'
	if testMode or global.specRunnerTestmode
		thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
		callback JSON.stringify(thingServiceTestJSON.batchList), 200
	else
		baseurl = config.all.client.service.persistence.fullpath+"containers?lsType="+lsType+"&lsKind="+lsKind
		if format?
			if format=="codetable"
				baseurl += "&format=codetable"
			else if format == "stub"
				baseurl += "&format=stub"

		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json, 200
			else
				console.error 'got ajax error'
				console.error error
				console.error json
				console.error response
				callback "containersByTypeKind failed", 500
		)

exports.containerByCodeName = (req, resp) ->
	req.setTimeout 86400000
	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json containerTestJSON.container
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/"+req.params.code
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.containerByCodeNameInteral = (containerCodeName, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"containers/" + containerCodeName
	request = require 'request'
	request(
		method: 'GET'
		url: baseurl
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback response.statusCode, json
		else
			console.log 'got ajax error'
			console.log error
			console.log json
			callback 500, {error: true, message:error}
	)

updateContainer = (container, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback container
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/"+container.code
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: container
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.error 'got ajax error trying to update lsContainer'
				console.error error
				console.error response
		)


postContainer = (req, resp) ->
	req.setTimeout 86400000
	console.debug "post container"
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	containerToSave = req.body
	if containerToSave.transactionOptions?
		transactionOptions = containerToSave.transactionOptions
		delete containerToSave.transactionOptions
	else
		transactionOptions = {
			comments: "new container"
		}
	transactionOptions.recordedBy = req.session.passport.user.username
	transactionOptions.status = "PENDING"
	transactionOptions.type = "NEW"
	serverUtilityFunctions.createLSTransaction2 containerToSave.recordedDate, transactionOptions, (transaction) ->
		containerToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, containerToSave
		if req.query.testMode or global.specRunnerTestmode
			unless containerToSave.codeName?
				containerToSave.codeName = "PT00002-1"

		checkFilesAndUpdate = (container) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity container, false
			filesToSave = fileVals.length

			completeContainerUpdate = (containerToUpdate)->
				updateContainer containerToUpdate, req.query.testMode, (updatedContainer) ->
					transaction.status = 'COMPLETED'
					serverUtilityFunctions.updateLSTransaction transaction, (transaction) ->
						resp.json container

			fileSaveCompleted = (passed) ->
				if !passed
					resp.statusCode = 500
					return resp.end "file move failed"
				if --filesToSave == 0 then completeContainerUpdate(container)

			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode container.codeName
				for fv in fileVals
					console.debug "updating file"
					csUtilities.relocateEntityFile fv, prefix, container.codeName, fileSaveCompleted
			else
				transaction.status = 'COMPLETED'
				serverUtilityFunctions.updateLSTransaction transaction, (transaction) ->
					resp.json container

		if req.query.testMode or global.specRunnerTestmode
			checkFilesAndUpdate containerToSave
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"containers"
			request = require 'request'
			request(
				method: 'POST'
				url: baseurl
				body: containerToSave
				json: true
				timeout: 86400000
			, (error, response, json) =>
				if !error && response.statusCode == 201
					checkFilesAndUpdate json
				else
					console.error 'got ajax error trying to save lsContainer'
					console.error error
					console.error json
					console.error response
			)

exports.postContainer = (req, resp) ->
	req.setTimeout 86400000
	postContainer req, resp

exports.putContainer = (req, resp) ->
	req.setTimeout 86400000
#	if req.query.testMode or global.specRunnerTestmode
#		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
#		containerToSave = JSON.parse(JSON.stringify(containerTestJSON.container))
#	else
	containerToSave = req.body
	fileVals = serverUtilityFunctions.getFileValuesFromEntity containerToSave, true
	filesToSave = fileVals.length

	if containerToSave.transactionOptions?
		containerToSave.transactionOptions.recordedBy = req.session.passport.user.username
	completeContainerUpdate = ->
		if containerToSave.transactionOptions?
			transactionOptions = containerToSave.transactionOptions
			delete containerToSave.transactionOptions
		else
			transactionOptions = {
				comments: "updated experiment"
			}
		transactionOptions.status = "COMPLETED"
		transactionOptions.type = "CHANGE"
		serverUtilityFunctions.createLSTransaction2 containerToSave.recordedDate, transactionOptions, (transaction) ->
			containerToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, containerToSave
			updateContainer containerToSave, req.query.testMode, (updatedContainer) ->
				resp.json updatedContainer

	fileSaveCompleted = (passed) ->
		if !passed
			resp.statusCode = 500
			return resp.end "file move failed"
		if --filesToSave == 0 then completeContainerUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromEntityCode req.body.codeName
		for fv in fileVals
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, req.body.codeName, fileSaveCompleted
	else
		completeContainerUpdate()

exports.validateContainerNameInternal = (container, callback) ->
	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json true
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/validate"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: container
			json: true
			timeout: 86400000
		, (error, response, json) =>
			if !error && response.statusCode == 202
				resp.json true
			else if response.statusCode == 409
				resp.json json
			else
				console.error 'got ajax error trying to validate container name'
				console.error error
				console.error json
				console.error response
				resp.json "error"
		)

exports.validateContainerName = (req, resp) ->
	req.setTimeout 86400000

	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json true
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/validate"
		#		if req.params.componentOrAssembly is "component"
		#			baseurl += "?uniqueName=true"
		#		else #is assembly
		#			baseurl += "?uniqueName=true&uniqueInteractions=true&orderMatters=true&forwardAndReverseAreSame=true"
		request = require 'request'
		console.debug "validate container name body"
		console.debug req.body
		console.debug req.body.container
		request(
			method: 'POST'
			url: baseurl
			body: req.body.container
			json: true
			timeout: 86400000
		, (error, response, json) =>
			console.debug "response"
			console.debug json
			console.debug response.statusCode
			if !error && response.statusCode == 202
				resp.json true
			else if response.statusCode == 409
				resp.json json
			else
				console.error 'got ajax error trying to validate container name'
				console.error error
				console.error json
				console.error response
				resp.json "error"
		)

exports.getContainerCodesFromNamesOrCodes = (codeRequest, callback) ->
	console.debug "got to getContainerCodesFormNamesOrCodes"
	if global.specRunnerTestmode
		results = []
		for req in codeRequest.requests
			res = requestName: req.requestName
			if req.requestName.indexOf("ambiguous") > -1
				res.referenceName = ""
				res.preferredName = ""
			else if req.requestName.indexOf("name") > -1
				res.referenceName = "CONT1111"
				res.preferredName = "1111"
			else if req.requestName.indexOf("1111") > -1
				res.referenceName = "CONT1111"
				res.preferredName = "1111"
			else
				res.referenceName = req.requestName
				res.preferredName = req.requestName
			results.push res
		response =
			containerType: codeRequest.containerType
			containerKind: codeRequest.containerKind
			results: results

		callback response
	else
		config = require '../conf/compiled/conf.js'
		#TODO: replace with new url
		baseurl = config.all.client.service.persistence.fullpath+"containers/getCodeNameFromNameRequest?"
		#		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels?"
		url = baseurl+"containerType=#{codeRequest.containerType}&containerKind=#{codeRequest.containerKind}"
		postBody = requests: codeRequest.requests
		console.debug postBody
		console.debug url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			json: true
			timeout: 86400000
		, (error, response, json) =>
			console.debug response.statusCode
			console.debug json
			if !error and !json.error
				callback
					containerType: codeRequest.containerType
					containerKind: codeRequest.containerKind
					results: json.results
			else
				console.error 'got ajax error trying to lookup lsContainer name'
				console.error error
				console.error response
				callback json
		)

getContainerCodesFromLabels = (req, callback) ->
	req.setTimeout 86400000
	if global.specRunnerTestmode
		response =
			codeName: 'CONT-0000001'
			label: 'test label'
		callback response

	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels?"
		url = baseurl+"containerType=#{req.body.containerType}&containerKind=#{req.body.containerKind}"
		postBody = req.body.labels
		console.debug postBody
		console.debug url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			json: true
			timeout: 86400000
		, (error, response, json) =>
			console.debug response.statusCode
			console.debug json
			if !error and !json.error
				callback json
			else
				console.error 'got ajax error trying to lookup lsContainer name'
				console.error error
				console.error response
				callback json
		)

getContainerCodesFromLabelsInternal = (barcodes, containerType, containerKind, callback) ->
	if global.specRunnerTestmode
		response =
			codeName: 'CONT-0000001'
			label: 'test label'
		callback response
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels?"
		url = baseurl+"containerType=#{containerType}&containerKind=#{containerKind}"
		postBody = barcodes
		console.debug postBody
		console.debug url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			json: true
			timeout: 86400000
		, (error, response, json) =>
			console.debug response.statusCode
			console.debug json
			if !error and !json.error
				callback json
			else
				console.error 'got ajax error trying to lookup lsContainer name'
				console.error error
				console.error response
				callback json
		)

exports.getContainerCodesFromLabels = (req, resp) ->
	req.setTimeout 86400000
	getContainerCodesFromLabels req, (json) ->
		resp.json json


exports.getContainerFromLabel = (req, resp) -> #only for sending in 1 label and expecting to get 1 container back
	req.setTimeout 86400000
	getContainerCodesFromLabels req, (json) ->
		if json[0]?.codeName? #assumes that labels are unique
			req.params.code = json[0].codeName
			exports.containerByCodeName req, resp
		else
			resp.json {}

exports.updateWellContent = (req, resp) ->
	req.setTimeout 86400000
	exports.updateWellContentInternal req.body, req.query.copyPreviousValues, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.updateWellContentWithObject = (req, resp) ->
	req.setTimeout 86400000
	exports.updateWellContentInternal req.body.wellsToSave, req.query.copyPreviousValues, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.updateWellContentInternal = (wellContent, copyPreviousValues, callCustom, callback) ->
	# If call custom doesn't equal 0 then call custom
	callCustom  = callCustom != "0"
	# If copyPreviousValues doesn't equal 1 then copyPreviousValues
	copyPreviousValues  = copyPreviousValues != "0"

	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerCodesByLabelsResponse
	else
		console.debug 'incoming updateWellContentInternal request: ', JSON.stringify(wellContent.wells)
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/updateWellContent?copyPreviousValues="+copyPreviousValues
		console.debug 'base url: ', baseurl
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify(wellContent)
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error & response.statusCode in [200,204]
				callback "success", response.statusCode
				if callCustom
					if csUtilities.updateWellContent?
						console.log "running customer specific server function updateWellContent"
						csUtilities.updateWellContent wellContent, (response) ->
							console.log response
					else
						console.warn "could not find customer specific server function updateWellContent so not running it"
			else
				console.error 'got ajax error trying to get updateWellContent'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify("updateWellContent failed"), 500
		)

exports.updateAmountInWell = (req, resp) ->
	req.setTimeout 86400000
	exports.updateAmountInWellInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.updateAmountInWellInternal = (updateAmountInfo, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerCodesByLabelsResponse
	else
		console.log "updateAmountInfo"
		console.log updateAmountInfo
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/updateAmountInWell"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: updateAmountInfo
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error & response.statusCode in [200,204]
				console.log "successfully updated amount in well"
				console.log json
				callback "success", response.statusCode
			else
				console.error 'got ajax error trying to get updateAmountInWell'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify("updateWellContent failed"), 500
		)



exports.moveToLocation = (req, resp) ->
	req.setTimeout 86400000
	exports.moveToLocationInternal req.body, req.query.callCustom, req.query.updateLocationHistory, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.moveToLocationInternal = (input, callCustom, updateLocationHistory, callback) ->
	#exports.updateContainerHistoryLogsInternal(input, (json, statusCode) ->
	# 	console.log 'updated history logs before moving to temp'
	# )
		# default for callCustom is true
		callCustom  = callCustom != "0"
		# default for updateLocationHistory is false
		updateLocationHistory = updateLocationHistory == "1"
		if global.specRunnerTestmode
			inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
			resp.json inventoryServiceTestJSON.moveToLocationResponse
		else
			console.debug 'incoming moveToLocationJSON request: ', JSON.stringify(input)
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"containers/moveToLocation"
			console.debug 'base url: ', baseurl
			request = require 'request'
			console.log 'request into moveToLocation'
			console.log input
			request(
				method: 'POST'
				url: baseurl
				body: input
				json: true
				timeout: 86400000
				headers: 'content-type': 'application/json'
			, (error, response, json) =>
				#add the call to updateContainerHistoryLogs here...
				console.debug "response statusCode: #{response.statusCode}"
				if !error
					shouldCallCustom = (callCustom && csUtilities.moveToLocation?)
					callFunctionOrReturnNull shouldCallCustom, csUtilities.moveToLocation, input, (customerResponse, statusCode) ->
						if updateLocationHistory
							exports.updateContainerHistoryLogsInternal(input, (json, statusCode) ->
								callback json, statusCode
							)
						else
							callback json, response.statusCode
				else
					console.error 'got ajax error trying to get moveToLocation'
					console.error error
					console.error json
					console.error response
					callback JSON.stringify("moveToLocation failed"), 500
			)
		#)

callFunctionOrReturnNull = (callFunctionBoolean, funct, input, callback) ->
	if callFunctionBoolean
		console.log "running customer specific server function"
		funct input, (customerResponse, statusCode) ->
			callback customerResponse, statusCode
	else
		console.log "not running customer specific server function"
		callback null

exports.getWellContentByContainerLabel = (req, resp) ->
	req.setTimeout 86400000
	exports.getWellContentByContainerLabelsInternal [req.params.label], req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json[0]

exports.getWellContentByContainerLabelsObject = (req, resp) ->
	exports.getWellContentByContainerLabelsInternal req.body.barcodes, req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getWellContentByContainerLabels = (req, resp) ->
	req.setTimeout 86400000
	exports.getWellContentByContainerLabelsInternal req.body, req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getWellContentByContainerLabelsInternal = (containerLabels, containerType, containerKind, labelType, labelKind, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.moveToLocationResponse
	else
		console.debug 'incoming getContainersByLabelsInternal request: ', JSON.stringify(containerLabels, containerType, containerKind, labelType, labelKind)
		exports.getContainerCodesByLabelsInternal containerLabels, containerType, containerKind, labelType, labelKind, (containerCodes, statusCode) =>
			if statusCode == 500
				callback JSON.stringify("getContainersByLabels failed"), 500
			else
				codeNames = _.map containerCodes, (code) ->
					if code.foundCodeNames[0]?
						code.foundCodeNames[0]
					else
						""
				exports.getWellContentByContainerCodesInternal codeNames, (wellContent) =>
					for label, index in containerLabels
						wellContent[index].label = label
					callback wellContent, 200

exports.cloneContainer = (req, resp) ->
	req.setTimeout 86400000
	exports.cloneContainersInternal [req.body], (json, statusCode) ->
		resp.statusCode = statusCode
		if resp.statusCode == 200
			resp.json json[0]
		else
			resp.json json

exports.cloneContainers = (req, resp) ->
	req.setTimeout 86400000
	exports.cloneContainersInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.cloneContainersInternal = (input, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.cloneContainerResponse
	else
		console.debug "incoming cloneContainerInternal request: #{JSON.stringify(input)}"
		codeNames = _.pluck input, "codeName"
		console.debug "calling getContainersByCodeNamesInternal"
		exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal codeNames, (containers, statusCode) =>
			exports.getWellContentByContainerCodesInternal codeNames, (wellContent) =>
				barcodes = _.pluck input, "barcode"
				exports.getContainerCodesByLabelsInternal barcodes, null, null, "barcode", "barcode", (containerCodes, statusCode) =>
					if statusCode == 500
						callback "getContainersByCodeNamesInternal failed", 500
						return
					outputArray = []
					for updateInfo, index in input
						if containerCodes[index].foundCodeNames.length > 0
							message = "conflict: barcode '#{containerCodes[index].requestLabel}' already being used by #{containerCodes[index].foundCodeNames.join(",")}"
							console.error message
							callback message, 409
							return
						container = _.findWhere(containers, {'codeName': updateInfo.codeName})
						container = _.extend container,updateInfo
						container = _.omit container, "codeName"
						container.definition = container.definitionCodeName
						wellContent = _.findWhere(wellContent, {'containerCodeName': updateInfo.codeName})
						if wellContent?.wellContent?
							wellContent = _.map wellContent.wellContent, (wellCont) ->
								_.omit wellCont, "containerCodeName"
							container.wells = wellContent
						compoundInventoryRoutes = require '../routes/CompoundInventoryRoutes.js'
						compoundInventoryRoutes.createPlateInternal container, "1", (newContainer, statusCode) ->
							container = _.extend container, newContainer
#							container.codeName = newContainer.codeName
							exports.updateContainersByContainerCodesInternal [container], "1", (updatedContainer, statusCode) ->
								outContainer = _.extend updatedContainer[0], newContainer
								outputArray[index-1] = outContainer
								if index == (input.length)
									callback outputArray, 200

exports.splitContainer = (req, resp) ->
	req.setTimeout 86400000
	exports.splitContainerInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.splitContainerInternal = (input, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.splitContainerResponse
	else
		console.debug "incoming splitContainer request: #{JSON.stringify(input)}"
		console.debug "calling getContainersByCodeNamesInternal"
		_.map input.quadrants, (quadrant) ->
			if typeof(quadrant.quadrant) != "number"
				console.warn "provided quadrant #{quadrant.quadrant} is typeOf #{typeof(quadrant.quadrant)} but should be typeof of number"
				quadrant.quadrant = Number(quadrant.quadrant)
				if isNaN(quadrant.quadrant)
					msg = "received #{quadrant.quadrant} when attempting to coerce quadrant"
					console.error msg
					callback msg, 400
		exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal [input.codeName], (originContainer, statusCode) =>
			if statusCode == 400
				callback originContainer, statusCode
			else if statusCode == 500
				callback "internal error", 500
			else if statusCode == 200
				if !originContainer[0].plateSize?
					message = "plate size note defined for input container #{input.codeName}"
					console.error message
					callback message, 400
				else if originContainer[0].plateSize <= 96
					message = "cannot split #{originContainer[0].plateSize} well container"
					console.error message
					callback message, 400
			if config.all.client.compoundInventory.enforceUppercaseBarcodes
				_.map input.quadrants, (quadrant) ->
					quadrant.barcode = quadrant.barcode.toUpperCase()
			barcodes = _.pluck input.quadrants, "barcode"
			barcodesUnique = _.unique(barcodes).length == barcodes.length
			if !barcodesUnique
				callback "barcodes must be unique", 400
				return
			exports.getContainerCodesByLabelsInternal barcodes, null, null, "barcode", "barcode", (containerCodes, statusCode) =>
				if statusCode == 500
					callback "internal error", 500
					return
				else
					errors = []
					for containerCode, index in containerCodes
						if containerCode.foundCodeNames.length > 0
							message = "barcode '#{containerCodes[index].requestLabel}' already being used by #{containerCodes[index].foundCodeNames.join(",")}"
							console.error message
							errors.push message
					if errors.length > 0
						callback errors, 409
						return
				destinationPlateSize = originContainer[0].plateSize/4
				exports.getDefinitionContainerByNumberOfWellsInternal "definition container", "plate", destinationPlateSize, (definitionContainer, statusCode) ->
					if statusCode == 400
						message =  "could not get definition for plate size #{destinationPlateSize}"
						console.error message
						callback message, 400
						return
					else if statusCode == 500
						callback "internal error", 500
						return
					destinationContainerCode =  definitionContainer.get('codeName')
					exports.getWellContentByContainerCodesInternal [input.codeName], (originWellContent) =>
						isOdd = (num) ->
							return (num % 2) == 1
						alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
						originWellContent[0].wellContent = _.map originWellContent[0].wellContent, (content) ->
							content = _.omit(content, ['containerCodeName', 'wellName', 'recordedDate'])
							oddRow = isOdd(content.rowIndex)
							oddColumn = isOdd(content.columnIndex)
							if oddRow && oddColumn
								content.quadrant = 1
							else if oddRow && !oddColumn
								content.quadrant = 2
							else if !oddRow && oddColumn
								content.quadrant = 3
							else if !oddRow && !oddColumn
								content.quadrant = 4
							if oddRow
								content.rowIndex = (content.rowIndex+1)/2
							else
								content.rowIndex = (content.rowIndex)/2
							if oddColumn
								content.columnIndex = (content.columnIndex+1)/2
							else
								content.columnIndex = (content.columnIndex)/2
							if content.columnIndex < 10
								text = "00"
							else
								text = "0"
							content.wellName = alphabet[content.rowIndex-1]+text+content.columnIndex
							return _.omit(content, ['containerCodeName', 'recordedDate'])
						outputArray = []
						for quadrant, index in input.quadrants
							#Get barcode
							destinationContainerValues = _.extend originContainer[0], quadrant
							destinationContainer = _.omit destinationContainerValues, "codeName"
							destinationContainer.definition = destinationContainerCode
							destinationWellContent = _.filter originWellContent[0].wellContent, (wellCont) ->
								wellCont.quadrant == quadrant.quadrant
							destinationContainer.wells = destinationWellContent
							input.quadrants[index].destinationContainer = destinationContainer
							compoundInventoryRoutes = require '../routes/CompoundInventoryRoutes.js'
							compoundInventoryRoutes.createPlateInternal destinationContainer, "1", (newContainer, statusCode) ->
								if statusCode == 200
									quadrant = _.findWhere(input.quadrants, {"barcode": newContainer.barcode})
									quadrant.newContainer = newContainer
#									quadrant.destinationContainer.codeName = newContainer.codeName
									quadrant.destinationContainer = _.extend quadrant.destinationContainer, newContainer
									quadrant.destinationContainer = _.omit quadrant.destinationContainer, ["wells", "definitionCodeName"]
									exports.updateContainersByContainerCodesInternal [quadrant.destinationContainer], "1", (updatedContainer, statusCode) ->
										quadrant = _.findWhere(input.quadrants, {"barcode": updatedContainer[0].barcode})
										quadrant.updatedContainer = updatedContainer[0]
										outContainer = _.extend quadrant.updatedContainer, quadrant.newContainer
										outputArray.push outContainer
										if outputArray.length == input.quadrants.length
											outputArray = _.sortBy outputArray, 'quadrant'
											callback outputArray, 200
								else
									outputArray.push newContainer

exports.mergeContainers = (req, resp) ->
	req.setTimeout 86400000
	exports.mergeContainersInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.mergeContainersInternal = (input, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.mergeContainersResponse
	else
		console.debug "incoming mergeContainers request: #{JSON.stringify(input)}"
		console.debug "calling getContainersByCodeNamesInternal"
		contanerCodes = _.pluck input.quadrants, "codeName"
		_.map input.quadrants, (quadrant) ->
			if typeof(quadrant.quadrant) != "number"
				console.warn "provided quadrant #{quadrant.quadrant} is typeOf #{typeof(quadrant.quadrant)} but should be typeof of number"
				quadrant.quadrant = Number(quadrant.quadrant)
				if isNaN(quadrant.quadrant)
					msg = "received #{quadrant.quadrant} when attempting to coerce quadrant"
					console.error msg
					callback msg, 400
		exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal contanerCodes, (originContainers, statusCode) =>
			if statusCode == 400
				callback originContainers, statusCode
				return
			else if statusCode == 500
				callback "internal error", statusCode
				return
			plateSizes = _.pluck originContainers, "plateSize"
			uniquePlateSizes = _.unique plateSizes
			if !uniquePlateSizes[0]?
				callback "could not determine destination plate size", 400
				return
			else if uniquePlateSizes.length > 1
				console.error "multiple different plate sizes found #{JSON.stringify(_.map(originContainers, (originContainer) -> _.pick(originContainer, "codeName","plateSize")))}", 400
				callback _.map(originContainers, (originContainer) -> _.pick(originContainer, "codeName","plateSize")), 400
				return
			destinationPlateSize = originContainers[0].plateSize*4

			if config.all.client.compoundInventory.enforceUppercaseBarcodes
				input.barcode = input.barcode.toUpperCase()

			exports.getContainerCodesByLabelsInternal [input.barcode], null, null, "barcode", "barcode", (containerCodes, statusCode) =>
				if statusCode == 500
					callback "internal error", 500
					return
				else if containerCodes[0].foundCodeNames.length > 0
						message = "barcode '#{containerCodes[0].requestLabel}' already being used by #{containerCodes[0].foundCodeNames.join(",")}"
						console.error message
						callback message, 409
						return
				exports.getDefinitionContainerByNumberOfWellsInternal "definition container", "plate", destinationPlateSize, (definitionContainer, statusCode) ->
					if statusCode == 400
						message =  "could not get definition for plate size #{destinationPlateSize}"
						console.error message
						callback message, 400
						return
					else if statusCode == 500
						callback "internal error", 500
						return
					exports.getWellContentByContainerCodesInternal contanerCodes, (originWellContent) =>
						input.definition = definitionContainer.get 'codeName'
						input.wells = []
						isOdd = (num) ->
							return (num % 2) == 1
						alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
						# for each quadrant
						_.map input.quadrants, (quadrant) ->
							# find plate whose name matches the quadrant name
							originWells = _.findWhere originWellContent, {"containerCodeName": quadrant.codeName}
							# map plate wells to merged plate wells
							_.map originWells.wellContent, (wellContent) ->
								wellContent = _.omit(wellContent, ['containerCodeName', 'wellName', 'recordedDate'])
								wellContent.recordedDate = 1455323242544
								if quadrant.quadrant == 1
									wellContent.rowIndex = 2*(wellContent.rowIndex)-1
									wellContent.columnIndex = 2*(wellContent.columnIndex)-1
								else if quadrant.quadrant == 2
									wellContent.rowIndex = 2*(wellContent.rowIndex)-1
									wellContent.columnIndex = 2*wellContent.columnIndex
								else if quadrant.quadrant == 3
									wellContent.rowIndex = 2*(wellContent.rowIndex)
									wellContent.columnIndex = 2*(wellContent.columnIndex)-1
								else if quadrant.quadrant == 4
									wellContent.rowIndex = 2*(wellContent.rowIndex)
									wellContent.columnIndex = 2*(wellContent.columnIndex)
								else
									callback "quadrant #{quadrant.quadrant} is not a valid option", 400
								if wellContent.rowIndex > 26
									text = "A"+alphabet[wellContent.rowIndex-26-1]
								else
									text = alphabet[wellContent.rowIndex-1]
								if wellContent.columnIndex < 10
									text = text+"00"
								else
									text = text+"0"
								wellContent.wellName = text+wellContent.columnIndex
								input.wells.push wellContent
						compoundInventoryRoutes = require '../routes/CompoundInventoryRoutes.js'
						compoundInventoryRoutes.createPlateInternal input, "1", (newContainer, statusCode) ->
							if statusCode == 200
								input = _.extend input, newContainer
#								input.codeName = newContainer.codeName
								containerToUpdate = _.omit input, ["wells", "definitionCodeName"]
								exports.updateContainersByContainerCodesInternal [containerToUpdate], "1", (updatedContainer, statusCode) ->
									if statusCode == 200
										updatedContainer[0].wells = input.wells
										callback updatedContainer[0], 200
									else
										callback "error updating plate after creating it", 500
							else
								callback "error creating plate", 500

exports.getDefinitionContainerByNumberOfWells = (req, resp) ->
	req.setTimeout 86400000
	exports.getDefinitionContainerByNumberOfWellsInternal req.params.lsType, req.params.lsKind, req.params.numberOfWells, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getDefinitionContainerByNumberOfWellsInternal = (lsType, lsKind, numberOfWells, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getDefinitionContainerByPlateSizeInternal
	else
		console.debug "incoming getDefinitionContainerByNumberOfWellsInternal request: #{JSON.stringify([lsType, lsKind, numberOfWells])}"
		console.debug "calling containersByTypeKindInternal"
		exports.containersByTypeKindInternal lsType, lsKind, null, false, false, (response, statusCode) ->
			definitions = []
			for container in response
				containerPreferredEntity = preferredEntityCodeService.getSpecificEntityTypeByTypeKindAndCodeOrigin container.lsType, container.lsKind, "ACAS LsContainer"
				if _.isEmpty containerPreferredEntity
					message = "could not find preferred entity for lsType '#{container.lsType}' and lsKind '#{container.lsKind}'"
					console.error message
					console.debug "here are the configured entity types"
					preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
						console.debug types
					callback message, 400
					return
				definition = new containerPreferredEntity.model(container)
				definitions.push definition
			definition = _.find definitions, (definition) ->
				return definition.get('plateSize').get('value').toString() == numberOfWells.toString()
			if definition?
				definition.prepareToSave()
				definition.reformatBeforeSaving()
				callback definition, 200
			else
				callback "could not find definition", 400


exports.searchContainers = (req, resp) ->
	req.setTimeout 86400000
	exports.searchContainersInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.searchContainersInternal = (input, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.searchContainersInternalResponse
	else
		console.debug "incoming searchContainers request: '#{JSON.stringify(input)}'"
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/searchContainers"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: input
			json: true
			timeout: 86400000
			headers:
				'content-type': 'application/json'
				'accept': 'application/json'
		, (error, response, json) =>
			console.debug "response statusCode: #{response.statusCode}"
			if !error
				_ = require 'underscore'
				codeNames = _.map json, (container) ->
					container.codeName
				exports.getContainerAndDefinitionContainerByContainerCodeNamesInternal codeNames, (json, statusCode) =>
					if statusCode == 500
						callback JSON.stringify "getContainerAndDefinitionContainerByContainerLabelInternal failed", statusCode
					else
						callback json, statusCode
			else
				console.error 'got ajax error trying to get searchContainers'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify("searchContainers failed"), 500
		)

exports.containerLogs = (req, resp) ->
	exports.containerLogsInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.containerLogsInternal = (inputs, callCustom, callback) ->
	validateContainerLogsInput inputs, (inputs, error) ->
		if error == true
			statusCode = 400
			callback inputs, statusCode
		else
			exports.addContainerLogs inputs, callCustom, (json, statusCode) ->
				callback json, statusCode

exports.containerLocationHistory = (req, resp) ->
	req.setTimeout 86400000
	exports.containerLocationHistoryInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.containerLocationHistoryInternal = (inputs, callCustom, callback) ->
	validateContainerLocationHistoryInputs inputs, (inputs, error) ->
		if error == true
			statusCode = 400
			callback inputs, statusCode
		else
			exports.addContainerLocationHistory inputs, callCustom, (json, statusCode) ->
				callback json, statusCode


exports.getContainerLogs = (req, resp) ->
	req.setTimeout 86400000
	exports.getContainerLogsInternal [req.params.label], req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getContainerLogsInternal = (labels, containerType, containerKind, labelType, labelKind, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerAndDefinitionContainerByContainerLabelInternalResponse
	else
		console.debug "incoming getContainerAndDefinitionContainerByContainerLabelInternal request: '#{JSON.stringify(labels)}'"
		exports.getContainersByLabelsInternal labels, containerType, containerKind, labelType, labelKind, (getContainersByLabelsResponse, statusCode) =>
			response = []
			for getContainer in getContainersByLabelsResponse
				responseObject =
					label: getContainer.label
					codeName: getContainer.codeName
					logs: []
				if getContainer.container?
					container = getContainerModels([getContainer])
					responseObject.logs = container[0].getLogs()
				response.push responseObject
			callback response, 200

exports.getContainerLogsByContainerCodes = (req, resp) ->
	req.setTimeout 86400000

	exports.getContainerLogsByContainerCodesInternal req.body, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getContainerLogsByContainerCodesInternal = (containerCodes, callback) =>
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerAndDefinitionContainerByContainerLabelInternalResponse
	else
		console.debug "incoming getContainerLogsByContainerCodesInternal request: '#{JSON.stringify(containerCodes)}'"
		exports.getContainersByCodeNamesInternal(containerCodes, (containersByCodeNamesResponse, statusCode) =>
			response = []
			for getContainer in containersByCodeNamesResponse
				lsLabels = getContainer.container.lsLabels
				preferredLabelObject = _.filter(lsLabels, (label) ->
  				label.preferred == true
				)
				codeName = getContainer.container.codeName
				responseObject =
					label: preferredLabelObject[0].labelText
					codeName: codeName
					logs: []
				if getContainer.container?
					container = getContainerModels([getContainer])
					responseObject.logs = container[0].getLogs()
				response.push responseObject
			callback response, 200
		)


exports.getContainerLocationHistory = (req, resp) ->
	exports.getContainerLocationHistoryInternal [req.params.label], req.query.containerType, req.query.containerKind, req.query.labelType, req.query.labelKind, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.getContainerLocationHistoryInternal = (labels, containerType, containerKind, labelType, labelKind, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerAndDefinitionContainerByContainerLabelInternalResponse
	else
		console.debug "incoming getContainerAndDefinitionContainerByContainerLabelInternal request: '#{JSON.stringify(labels)}'"
		exports.getContainersByLabelsInternal labels, containerType, containerKind, labelType, labelKind, (getContainersByLabelsResponse, statusCode) =>
			response = []
			for getContainer in getContainersByLabelsResponse
				responseObject =
					label: getContainer.label
					codeName: getContainer.codeName
					locationHistory: []
				if getContainer.container?
					container = getContainerModels([getContainer])
					responseObject.locationHistory = container[0].getLocationHistory()
				response.push responseObject
			callback response, 200

exports.getOrCreateContainer = (container, callback) ->
	label = container.lsLabels[0].labelText
	request = require 'request'
	request.post
		url: "http://localhost:"+config.all.server.nodeapi.port+"/api/getContainersByLabels?containerType=#{container.lsType}&containerKind=#{container.lsKind}"
		json: true
		body: [label]
	, (error, response, body) =>
		if !body[0].codeName?
			request.post
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/containers"
				json: true
				body: container
			, (error, response, body) =>
				callback body
		else
			callback body[0].container

exports.getOrCreateContainers = (containers, callback) ->
	responseArray = []
	containers.forEach (container) =>
		exports.getOrCreateContainer container, (response) =>
			responseArray.push response
			if responseArray.length == containers.length
				callback responseArray


exports.addContainerLogs = (inputs, callCustom, callback) ->
	callCustom  = callCustom != "0"
	codeNames = _.uniq(_.pluck(inputs, "codeName"))
	exports.getContainersByCodeNamesInternal codeNames, (containers, statusCode) =>
		containerModels = getContainerModels(containers)
		containersToSave = []
		for containerModel in containerModels
			modelInputLogs = _.filter(inputs, (input) -> input.codeName == containerModel.get("codeName"));
			containerModel.addNewLogStates(modelInputLogs)
			containerModel.prepareToSave "acas"
			containerModel.reformatBeforeSaving()
			#if containerModel.isNew() or containerModel.get('lsLabels').length > 0 or containerModel.get('lsStates').length > 0
			containersToSave.push containerModel
		containers = JSON.stringify(containersToSave)
		exports.updateContainersInternal containers, (json, statusCode) ->
			if callCustom
				if csUtilities.addContainerLogs?
					console.log "running customer specific server function addContainerLogs"
					csUtilities.addContainerLogs inputs, (response) ->
						console.log response
				else
					console.warn "could not find customer specific server function addContainerLogs so not running it"
			callback json, statusCode

exports.addContainerLocationHistory = (inputs, callCustom, callback) ->
	callCustom  = callCustom != "0"
	codeNames = _.uniq(_.pluck(inputs, "codeName"))
	exports.getContainersByCodeNamesInternal codeNames, (containers, statusCode) =>
		containerModels = getContainerModels(containers)
		containersToSave = []
		for containerModel in containerModels
			modelInputLogs = _.filter(inputs, (input) -> input.codeName == containerModel.get("codeName"));
			containerModel.addNewLocationHistoryStates(modelInputLogs)
			containerModel.prepareToSave "acas"
			containerModel.reformatBeforeSaving()
			#if containerModel.isNew() or containerModel.get('lsLabels').length > 0 or containerModel.get('lsStates').length > 0
			containersToSave.push containerModel
		containers = JSON.stringify(containersToSave)
		exports.updateContainersInternal containers, (json, statusCode) ->
			if callCustom
				if csUtilities.addContainerLocationHistory?
					console.log "running customer specific server function addContainerLocationHistory"
					csUtilities.addContainerLocationHistory inputs, (response) ->
				else
					console.warn "could not find customer specific server function addContainerLocationHistory so not running it"
			callback json, statusCode

getContainerModels = (containers) ->
	outputs = []
	for container in containers
		preferredEntity = preferredEntityCodeService.getSpecificEntityTypeByTypeKindAndCodeOrigin container.container.lsType, container.container.lsKind, "ACAS LsContainer"
		if _.isEmpty preferredEntity
			message = "could not find preferred entity for lsType '#{container.lsType}' and lsKind '#{container.lsKind}'"
			console.error message
			console.debug "here are the configured entity types"
			preferredEntityCodeService.getConfiguredEntityTypes false, (types)->
				console.debug types
			callback message, 400
			return
		outputs.push new preferredEntity.model(container.container)
	return outputs

validateContainerLogsInput = (inputs, callback) ->
	@err = false
	output = _.map inputs, (input) =>
		validateContainerLogInput input, (output, error) =>
			@err = @err || error
			output
	callback output, @err

validateContainerLogInput = (input, callback) ->
	errors = []
	if !input.codeName?
		errors.push "must have codeName"
	if !input.entryType?
		errors.push "must have entryType"
	if input.entryType? && input.entryType == ""
		errors.push "entryType cannot be \"\""
	if !input.recordedBy?
		errors.push "must have recordedBy"
	if !input.recordedDate?
		input.recordedDate = new Date().getTime()
	error = errors.length > 0
	output = input
	output.errors = errors
	callback output, error

validateContainerLocationHistoryInputs = (inputs, callback) ->
	@err = false
	output = _.map inputs, (input) =>
		validateContainerLocationHistoryInput input, (output, error) =>
			@err = @err || error
			output
	callback output, @err

validateContainerLocationHistoryInput = (input, callback) ->
	errors = []
	if !input.codeName?
		errors.push "must have codeName"
	if !input.location?
		errors.push "must have location"
	if !input.movedBy?
		errors.push "must have movedBy"
	if !input.movedDate?
		errors.push "must have movedDate"
	if input.location? && input.location == ""
		errors.push "location cannot be \"\""
	if !input.recordedBy?
		errors.push "must have recordedBy"
	if !input.recordedDate?
		input.recordedDate = new Date().getTime()
	error = errors.length > 0
	output = input
	output.errors = errors
	callback output, error

exports.getContainerCodeNamesByContainerValue = (req, resp) ->
	req.setTimeout 86400000
	exports.getContainerCodeNamesByContainerValueInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getContainerCodeNamesByContainerValueInternal = (requestObject, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		callback inventoryServiceTestJSON.getContainerCodeNamesByContainerValueResponse
	else
		queryParams = []
		if requestObject.like?
			queryParams.push "like="+requestObject.like
		if requestObject.rightLike?
			queryParams.push "rightLike="+requestObject.rightLike
		if requestObject.maxResults?
			queryParams.push "maxResults="+requestObject.maxResults
		queryString = queryParams.join "&"
		console.log 'request object in getContainerCodeNamesByContainerValue', requestObject
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodeNamesByContainerValue?"+queryString
		request = require 'request'
		console.debug 'calling service', baseurl
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify requestObject
			json: true
			timeout: 86400000
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.debug 'returned success from service', baseurl
				callback json
			else
				console.error 'got ajax error trying to get getContainerCodeNamesByContainerValue'
				console.error error
				console.error json
				console.error response
				callback JSON.stringify "getContainerCodeNamesByContainerValue failed"
		)

exports.createTube = (req, resp) ->
	exports.createTubeInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.createTubeInternal = (input, callCustom, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath + "containers/createTube"
	if input.createdDate?
		if typeof(input.createdDate) != "number"
			console.warn "#{input.createdDate} is typeof #{typeof(input.createdDate)}, created date should be a number"
			input.createdDate = parseInt input.createdDate
			if isNaN(input.createdDate)
				msg = "received #{input.createdDate} when attempting to coerce created date"
				console.error msg
				callback msg, 400
	console.log "baseurl"
	console.log baseurl
	if config.all.client.compoundInventory.enforceUppercaseBarcodes
		input.barcode = input.barcode.toUpperCase()
		console.warn input.barcode
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: JSON.stringify input
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error  && response.statusCode == 200
# If call custom doesn't equal 0 then call custom
			callCustom  = callCustom != "0"
			if callCustom && csUtilities.createTube?
				console.log "running customer specific server function createTube"
				csUtilities.createTube input, (customerResponse, statusCode) ->
					json = _.extend json, customerResponse
					callback json, statusCode
			else
				console.warn "could not find customer specific server function createTube so not running it"
				callback json, response.statusCode
		else if response.statusCode == 400
			callback response.body, response.statusCode
		else
			console.log 'got ajax error trying to create tube'
			console.log error
			console.log response
			callback response.body, 500
	)

exports.createTubes = (req, resp) ->
	exports.createTubesInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.createTubesInternal = (tubes, callCustom, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath + "containers/createTubes"
	_.each(tubes, (tube) ->
		if tube.createdDate?
			if typeof(tube.createdDate) != "number"
				console.warn "#{tube.createdDate} is typeof #{typeof(tube.createdDate)}, created date should be a number"
				tube.createdDate = parseInt tube.createdDate
				if isNaN(tube.createdDate)
					msg = "received #{tube.createdDate} when attempting to coerce created date"
					console.error msg
					callback msg, 400
	)

	console.log "baseurl"
	console.log baseurl
	if config.all.client.compoundInventory.enforceUppercaseBarcodes
		_.each(tubes, (tube) ->
			tube.barcode = tube.barcode.toUpperCase()
			console.warn tube.barcode
		)
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: JSON.stringify tubes
		json: true
		timeout: 6000000
	, (error, response, json) =>
#		console.log "error"
#		console.log error
#		console.log "response"
#		console.log response
#		console.log "json"
#		console.log json
		if !error  && response.statusCode == 200
# If call custom doesn't equal 0 then call custom
			callCustom  = callCustom != "0"
			if callCustom && csUtilities.createTube?
				console.log "running customer specific server function createTubes"
				csUtilities.createTubes tubes, (customerResponse, statusCode) ->
#					json = _.extend json, customerResponse
					callback json, statusCode
			else
				console.warn "could not find customer specific server function createTubes so not running it"
				callback json, response.statusCode
		else if response.statusCode == 400
			callback response.body, response.statusCode
		else
			console.log 'got ajax error trying to create tubes'
			console.log error
			console.log response
			callback response.body, 500
	)


exports.throwInTrash = (req, resp) ->
	exports.throwInTrashInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.throwInTrashInternal = (input, callCustom, callback) ->
	#exports.updateContainerHistoryLogsInternal(input, (json, statusCode) ->
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath + "containers/throwInTrash"
		console.log baseurl
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify input
			json: true
			timeout: 6000000
		, (error, response, json) =>
			if !error  && response.statusCode == 204
				exports.updateContainerHistoryLogsInternal(input, (json, statusCode) ->
	# If call custom doesn't equal 0 then call custom
					callCustom  = callCustom != "0"
					if callCustom && csUtilities.throwInTrash?
						console.log "running customer specific server function throwInTrash"
						csUtilities.throwInTrash input, (customerResponse, statusCode) ->
		#					json = _.extend json, customerResponse
							callback json, response.statusCode
					else
						console.warn "could not find customer specific server function throwInTrash so not running it"
						callback json, response.statusCode
				)
			else if response.statusCode == 400
				callback response.body, response.statusCode
			else
				console.log 'got ajax error trying to create tube'
				console.log error
				console.log response
				callback response.body, 500
		)
	#)

exports.updateContainerHistoryLogsInternal = (containers, callback) ->
	formattedContainers = []
	index = 0
	#_.each(containers, (container) ->
	formatContainersForLocationHistoryUpdate(containers, (statusCode, formattedContainers) ->
		exports.containerLocationHistoryInternal(formattedContainers, RUN_CUSTOM_FLAG, (json, statusCode) ->
			return callback json,statusCode
		)
		# else
		# 	return callback null, 500
	)

formatContainersForLocationHistoryUpdate = (containers, callback) ->
	createContainersWithBreadcrumb(containers, (containersWithBreadcrumb, modifiedBy, modifiedDate) ->
		formatLocationStrings(containersWithBreadcrumb, (formattedContainersWithBreadcrumb) ->
			formatContainers(formattedContainersWithBreadcrumb, modifiedBy, modifiedDate, (formattedContainers) ->
				return callback 200, formattedContainers
				)
			)
		)

createContainersWithBreadcrumb = (containers, callback) ->
	containerCodeNames = []
	modifiedBy = containers[0].modifiedBy
	modifiedDate = containers[0].modifiedDate
	_.each(containers, (container) ->
		containerCodeNames.push(container.containerCodeName)
	)
	exports.getBreadCrumbByContainerCodeInternal(containerCodeNames, "<", (containersWithBreadcrumb) ->
		return callback containersWithBreadcrumb, modifiedBy, modifiedDate
	)

formatLocationStrings = (containersWithBreadcrumb, callback) ->
	formattedContainersWithBreadcrumb = []
	_.each(containersWithBreadcrumb, (container) ->
		locationArray = container.labelBreadCrumb.split("<")
		locationArrayString = JSON.stringify(locationArray)
		container.locationArrayString = locationArrayString
		formattedContainersWithBreadcrumb.push(container)
	)
	return callback formattedContainersWithBreadcrumb

formatContainers = (containers, modifiedBy, modifiedDate, callback) ->
	formattedContainers = []
	_.each(containers, (container) ->
		formattedContainer = {
			"codeName": container.containerCode
			"recordedBy": modifiedBy
			"recordedDate": modifiedDate
			"location": container.locationArrayString
			"movedBy": modifiedBy
			"movedDate": modifiedDate
			"additionalValues": []
		}
		formattedContainers.push(formattedContainer)
	)
	statusCode = 200
	return callback formattedContainers
	#callback(formattedContainers, statusCode)

exports.getContainerInfoFromBatchCode = (req, resp) =>

	requestObject =
		batchCode: req.body.batchCode

	exports.getContainerInfoFromBatchCodeInternal(requestObject, (json, statusCode) =>
		resp.statusCode = statusCode
		resp.json json
	)


# getLocationBreadcrumb = (container, callback) ->
# 	exports.getBreadCrumbByContainerCodeInternal([container.containerCodeName], "<", (breadcrumb) ->
# 		labelBreadCrumb = breadcrumb[0].labelBreadCrumb
# 		callback labelBreadCrumb
# 		# console.log 'breadcrumb for move to locations'
# 		# console.log breadcrumb[0].labelBreadCrumb
# 		# #test breadCrumb = 'CAGE00002<SHELF1<E0059101<A01'
# 		# locationArray = breadcrumb[0].labelBreadCrumb.split("<")
# 		#callback locationArray
# 	)
#
# formatContainerForLocationHistoryUpdate = (container, callback) ->
# 	getLocationBreadcrumb(container, (labelBreadCrumb) ->
# 		createLocationArray(labelBreadCrumb, (locationArrayString) ->
# 			#buildLocationArrayString(locationArray, (locationArrayString) ->
# 			formatContainer(container, locationArrayString, (formattedContainer, statusCode) ->
# 				callback statusCode, formattedContainer
# 				)
# 			)
# 		)
#
# createLocationArray = (labelBreadCrumb, callback) ->
# 	locationArray = labelBreadCrumb.split("<")
# 	locationArrayString = JSON.stringify(locationArray)
# 	callback locationArrayString.toUpperCase()
#
# formatContainer = (container, locationArrayString, callback) ->
#
# 	formattedContainer = {
# 		"codeName": container.containerCodeName
# 		"recordedBy": container.modifiedBy
# 		"recordedDate": container.modifiedDate
# 		"location": locationArrayString
# 		"movedBy": container.modifiedBy
# 		"movedDate": container.modifiedDate
# 		"additionalValues": []
# 	}
#
# 	statusCode = 200
# 	callback(formattedContainer, statusCode)

# buildLocationArrayString = (locationArray, callback) ->
# 	locationSeparator = '\",\"'
# 	locationArrayString = '[\"' +
# 		locationArray[0] +
# 		locationSeparator +
# 		locationArray[1] +
# 		locationSeparator +
# 		locationArray[2] +
# 		locationSeparator +
# 		locationArray[3] +
# 		'\"]'
#
# 	console.log 'locationArrayString '
# 	console.log locationArrayString
# 	callback locationArrayString

exports.getContainerInfoFromBatchCodeInternal = (requestObject, callback) =>

	queryPayload =
		{
			"containerType": "well",
			"containerKind": "default",
			"stateType": "status",
			"stateKind": "content",
			"valueType": "codeValue",
			"valueKind": "batch code",
			"value": requestObject.batchCode
		}

	exports.getContainerCodeNamesByContainerValueInternal(queryPayload, (json) =>
		statusCode = 200
		if json.maxResults?
			warningMessage = "Max results of #{maxResults} reached."
			return callback {warningMessage: warningMessage}, statusCode
		else
			if json.length > 0
				exports.getWellContentInternal(json, (response) =>
					return callback response, statusCode
				)
			else
				return callback {warningMessage: "No results found for #{queryPayload.value}"}, statusCode
	)

exports.getContainerStatesByContainerValue = (req, resp) =>

	exports.getContainerStatesByContainerValueInternal(req.body, (json, statusCode) =>
		resp.statusCode = statusCode
		resp.json json
	)

exports.getContainerStatesByContainerValueInternal = (requestObject, callback) =>

	queryParams = []
	if requestObject.like?
		queryParams.push "like="+requestObject.like
	if requestObject.rightLike?
		queryParams.push "rightLike="+requestObject.rightLike
	if requestObject.maxResults?
		queryParams.push "maxResults="+requestObject.maxResults
	if requestObject.with?
		queryParams.push "with="+requestObject.with
	queryString = queryParams.join "&"


	queryPayload =
		{
			containerType: requestObject.containerType
			containerKind: requestObject.containerKind
			stateType: requestObject.stateType
			stateKind: requestObject.stateKind
			valueType: requestObject.valueType
			valueKind: requestObject.valueKind
			value: requestObject.value
		}

	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"containerstates/getContainerStatesByContainerValue?"+queryString
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: queryPayload
		json: true
		timeout: 86400000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback json, response.statusCode
		else
			console.error 'got ajax error trying to get getContainerStatesByContainerValue'
			console.error error
			console.error json
			console.error response
			callback null, 500
			#resp.end JSON.stringify "getContainerStatesByContainerValue failed"
		)

exports.getTubesFromBatchCode = (req, resp) =>

	exports.getTubesFromBatchCodeInternal(req.body, (json, statusCode) =>
		resp.statusCode = statusCode
		resp.json json
	)

exports.getTubesFromBatchCodeInternal = (input, callback) =>
	batchCode = input.batchCode

	queryPayload =
		{
    "lsType": "container" ,
    "lsKind": "tube",
#    "values":[
#        {
#            "stateType":"metadata",
#            "stateKind":"information",
#            "valueType": "codeValue",
#            "valueKind": "status",
#            "operator": "!=",
#            "value":"expired"
#        }
#        ],
    "secondInteractions":[
        {
            "interactionType": "has member",
            "interactionKind": "container_well",
            "thingType": "well",
            "thingKind": "default",
            "thingValues":[
                {
                    "stateType":"status",
                    "stateKind":"content",
                    "valueType": "codeValue",
                    "valueKind": "batch code",
                    "operator": "=",
                    "value":batchCode
                }
                ]
        }
        ]
			}

	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"containers/advancedSearchContainers?with=codeTable&labelType=barcode"
	console.log 'baseurl', baseurl
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: queryPayload
		json: true
		timeout: 86400000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			tubes = _.pluck(json.results, 'name')
			callback tubes, response.statusCode
		else
			console.error 'got ajax error trying to getTubesFromBatchCode'
			console.error error
			console.error json
			console.error response
			callback null, 500
			#resp.end JSON.stringify "getContainerStatesByContainerValue failed"
		)

PARENT_COMPOUND_LOT_INDEX = 0
PARENT_DESTINATION_VIAL_INDEX = 1
PARENT_AMOUNT_INDEX = 2
PARENT_AMOUNT_UNITS_INDEX = 3
PARENT_PREPARED_BY_INDEX = 4
PARENT_PREPARED_DATE_INDEX = 5
PARENT_PHYSICAL_STATE_INDEX = 6
PARENT_CONCENTRATION_INDEX = 7
PARENT_CONC_UNITS_INDEX = 8
PARENT_SOLVENT_INDEX = 9

DAUGHTER_SOURCE_VIAL_INDEX = 0
DAUGHTER_DESTINATION_VIAL_INDEX = 1
DAUGHTER_AMOUNT_INDEX = 2
DAUGHTER_AMOUNT_UNITS_INDEX = 3
DAUGHTER_PREPARED_BY_INDEX = 4
DAUGHTER_PREPARED_DATE_INDEX = 5
DAUGHTER_PHYSICAL_STATE_INDEX = 6
DAUGHTER_CONCENTRATION_INDEX = 7
DAUGHTER_CONC_UNITS_INDEX = 8
DAUGHTER_SOLVENT_INDEX = 9

exports.loadParentVialsFromCSV = (req, resp) ->
	resp.connection.setTimeout(6000000)
	exports.loadParentVialsFromCSVInternal req.body.fileToParse, req.body.dryRunMode, req.body.user, (response) ->
		resp.json response

exports.loadParentVialsFromCSVInternal = (csvFileName, dryRun, user, callback) ->
	if dryRun == 'true'
		exports.validateParentVialsFromCSVInternal csvFileName, dryRun, (validationResponse) ->
			callback validationResponse
	else
		exports.validateParentVialsFromCSVInternal csvFileName, dryRun, (validationResponse) ->
			if validationResponse.hasError
				callback validationResponse
			else
				exports.createParentVialsFromCSVInternal csvFileName, dryRun, user, (createVialsResponse) ->
					callback createVialsResponse

exports.validateParentVialsFromCSV = (req, resp) ->
	resp.connection.setTimeout(6000000)
	exports.validateParentVialsFromCSVInternal req.body.csvFileName, (validationResponse) ->
		resp.json validationResponse

exports.validateParentVialsFromCSVInternal = (csvFileName, dryRun, callback) ->
	getFileExists csvFileName, (exists, path) ->
		validationResponse =
			results:
				dryRun: dryRun
				fileToParse: csvFileName
				htmlSummary: ''
			hasError: false
			hasWarning: false
			errorMessages: []
			transactionId: null
		if exists
			validationResponse.results.path = path
			createParentVialFileEntryArray csvFileName, (err, fileEntryArray) ->
				if err?
					callback err
				prepareSummaryInfo fileEntryArray, (summaryInfo) ->
					checkRequiredAttributes fileEntryArray, (requiredAttributeErrors) ->
						if requiredAttributeErrors?
							validationResponse.errorMessages.push requiredAttributeErrors...
						checkDataTypeErrors fileEntryArray, (dataTypeErrors) ->
							if dataTypeErrors?
								validationResponse.errorMessages.push dataTypeErrors...
							checkBatchCodesExist fileEntryArray, (missingBatchCodeErrors) ->
								if missingBatchCodeErrors? and missingBatchCodeErrors.length > 0
									error =
										errorLevel: 'error'
										message: "The following batches do not exist: "+ missingBatchCodeErrors.join ', '
									validationResponse.errorMessages.push error
								barcodes = _.pluck fileEntryArray, 'destinationVialBarcode'
								checkBarcodesExist barcodes, (existingBarcodes, newBarcodes) ->
									if existingBarcodes? and existingBarcodes.length > 0
										error =
											errorLevel: 'error'
											message: "The following barcodes already exist: " + existingBarcodes.join ', '
										validationResponse.errorMessages.push error
									errors = _.where validationResponse.errorMessages, {errorLevel: 'error'}
									warnings = _.where validationResponse.errorMessages, {errorLevel: 'warning'}
									if errors.length > 0
										validationResponse.hasError = true
									if warnings.length > 0
										validationResponse.hasWarning = true
									validationResponse.results.htmlSummary = prepareValidationHTMLSummary validationResponse.hasError, validationResponse.hasWarning, validationResponse.errorMessages, summaryInfo
									callback validationResponse
		else
			error =
				errorLevel: 'error'
				message: "File cannot be found"
			validationResponse.errorMessages.push error
			callback validationResponse

exports.createParentVialsFromCSVInternal = (csvFileName, dryRun, user, callback) ->
	getFileExists csvFileName, (exists, path) ->
		createResponse =
			results:
				dryRun: dryRun
				fileToParse: csvFileName
				htmlSummary: ''
			hasError: true
			hasWarning: false
			errorMessages: []
			transactionId: null
			commit: false
		if exists
			createResponse.results.path = path
			createParentVialFileEntryArray csvFileName, (err, fileEntryArray) ->
				if err?
					callback err
				dealiasPhysicalStates fileEntryArray, (fileEntryArray) ->
					prepareSummaryInfo fileEntryArray, (summaryInfo) ->
						exports.getContainerTubeDefinitionCode (definitionCode) ->
							if !definitionCode?
								error =
									errorLevel: 'error'
									message: 'Could not find definition container for tube'
								createResponse.errorMessages.push error
							tubesToCreate = []
							_.each fileEntryArray, (entry) ->
								tube =
									barcode: entry.destinationVialBarcode
									definition: definitionCode
									recordedBy: user
									createdUser: entry.preparedBy
									createdDate: entry.createdDate
									physicalState: entry.physicalState
									wells: [
										wellName: "A001"
										batchCode: entry.batchCode
										amount: entry.amount
										amountUnits: entry.amountUnits
										physicalState: entry.physicalState
										recordedBy: user
										recordedDate: (new Date()).getTime()
									]
								if entry.physicalState == 'solution'
									tube.wells[0].batchConcentration = entry.concentration
									tube.wells[0].batchConcUnits = entry.concUnits
									tube.wells[0].solventCode = entry.solvent
								tubesToCreate.push tube
							console.log JSON.stringify tubesToCreate
							exports.createTubesInternal tubesToCreate, 0, (json, statusCode) ->
								console.log statusCode
								console.log json
								if statusCode != 200
									createResponse.hasError = true
									console.error json
									error =
										errorLevel: 'error'
										message: json
									createResponse.errorMessages.push error
								else
									createResponse.hasError = false
									createResponse.commit = true
								createResponse.results.htmlSummary = prepareCreateVialsHTMLSummary createResponse.hasError, createResponse.hasWarning, createResponse.errorMessages, summaryInfo
								callback createResponse
		else
			error =
				errorLevel: 'error'
				message: "File cannot be found"
			createResponse.errorMessages.push error
			callback createResponse

exports.loadDaughterVialsFromCSV = (req, resp) ->
	resp.connection.setTimeout(6000000)
	exports.loadDaughterVialsFromCSVInternal req.body.fileToParse, req.body.dryRunMode, req.body.user, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json response

exports.loadDaughterVialsFromCSVInternal = (csvFileName, dryRun, user, callback) ->
	if dryRun == 'true'
		exports.validateDaughterVialsFromCSVInternal csvFileName, dryRun, (err, validationResponse) ->
			if err?
				callback err
			else
				callback null, validationResponse
	else
		exports.validateDaughterVialsFromCSVInternal csvFileName, dryRun, (err, validationResponse) ->
			if err?
				callback err
			else if validationResponse.hasError
				callback null, validationResponse
			else
				exports.createDaughterVialsFromCSVInternal csvFileName, dryRun, user, (err, createVialsResponse) ->
					if err?
						callback err
					else
						callback null, createVialsResponse

exports.validateDaughterVialsFromCSV = (req, resp) ->
	resp.connection.setTimeout(6000000)
	exports.validateDaughterVialsFromCSVInternal req.body.csvFileName, (err, validationResponse) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json validationResponse

exports.validateDaughterVialsFromCSVInternal = (csvFileName, dryRun, callback) ->
	getFileExists csvFileName, (exists, path) ->
		validationResponse =
			results:
				dryRun: dryRun
				fileToParse: csvFileName
				htmlSummary: ''
			hasError: false
			hasWarning: false
			errorMessages: []
			transactionId: null
		if exists
			validationResponse.results.path = path
			createDaughterVialFileEntryArray csvFileName, (err, fileEntryArray) ->
				if err?
					callback err
				prepareSummaryInfo fileEntryArray, (summaryInfo) ->
					exports.validateDaughterVialsInternal fileEntryArray, (err, errorsAndWarnings) ->
						if err?
							callback err
						else
							validationResponse.errorMessages.push errorsAndWarnings...
							errors = _.where validationResponse.errorMessages, {errorLevel: 'error'}
							warnings = _.where validationResponse.errorMessages, {errorLevel: 'warning'}
							if errors.length > 0
								validationResponse.hasError = true
							if warnings.length > 0
								validationResponse.hasWarning = true
							validationResponse.results.htmlSummary = prepareValidationHTMLSummary validationResponse.hasError, validationResponse.hasWarning, validationResponse.errorMessages, summaryInfo
							callback null, validationResponse
		else
			error =
				errorLevel: 'error'
				message: "File cannot be found"
			validationResponse.errorMessages.push error
			callback validationResponse

exports.createDaughterVialsFromCSVInternal = (csvFileName, dryRun, user, callback) ->
	getFileExists csvFileName, (exists, path) ->
		createResponse =
			results:
				dryRun: dryRun
				fileToParse: csvFileName
				htmlSummary: ''
			hasError: true
			hasWarning: false
			errorMessages: []
			transactionId: null
			commit: false
		if !exists
			error =
				errorLevel: 'error'
				message: "File cannot be found"
			createResponse.errorMessages.push error
			callback createResponse
		else
			createResponse.results.path = path
			createDaughterVialFileEntryArray csvFileName, (err, fileEntryArray) ->
				if err?
					callback err
				dealiasPhysicalStates fileEntryArray, (fileEntryArray) ->
					prepareSummaryInfo fileEntryArray, (summaryInfo) ->
						exports.createDaughterVialsInternal fileEntryArray, user, (err, response) ->
							if err?
								error =
									errorLevel: 'error'
									message: err
								createResponse.errorMessages.push error
							else
								createResponse.hasError = false
								createResponse.commit = true
							createResponse.results.htmlSummary = prepareCreateVialsHTMLSummary createResponse.hasError, createResponse.hasWarning, createResponse.errorMessages,  summaryInfo
							callback null, createResponse



getFileExists = (csvFileName, callback) =>
	exists = false
	path = config.all.server.file.server.path + '/'
	fileName = csvFileName
	fs.stat path+fileName, (err, stats) ->
		console.log 'path+fileName', path+fileName
		console.log stats
		console.log err
		if stats?.isFile()
			exists = true
			callback exists, path+fileName
		else
			callback exists, path+fileName

createParentVialFileEntryArray = (csvFileName, callback) =>
	csvFileEntries = []
	path = config.all.server.file.server.path + '/'
	fileName = csvFileName
	rowCount = 0
	fs.createReadStream(path + fileName)
	.pipe(parse({delimiter: ','}))
	.on('data', (csvrow) ->
		rowCount++
		fileEntry =
			batchCode: csvrow[PARENT_COMPOUND_LOT_INDEX].trim()
			destinationVialBarcode: csvrow[PARENT_DESTINATION_VIAL_INDEX].trim()
			amount: parseFloat(csvrow[PARENT_AMOUNT_INDEX].trim())
			amountUnits: csvrow[PARENT_AMOUNT_UNITS_INDEX].trim()
			preparedBy: csvrow[PARENT_PREPARED_BY_INDEX].trim()
			preparedDate: csvrow[PARENT_PREPARED_DATE_INDEX].trim()
			physicalState: csvrow[PARENT_PHYSICAL_STATE_INDEX].trim()
			concentration: parseFloat(csvrow[PARENT_CONCENTRATION_INDEX].trim())
			concUnits:csvrow[PARENT_CONC_UNITS_INDEX].trim()
			solvent: csvrow[PARENT_SOLVENT_INDEX].trim()
			rowNumber: rowCount
		if rowCount? and rowCount > 1
			csvFileEntries.push(fileEntry)
	)
	.on('end', () ->
		return callback null, csvFileEntries
	)

createDaughterVialFileEntryArray = (csvFileName, callback) =>
	csvFileEntries = []
	path = config.all.server.file.server.path + '/'
	fileName = csvFileName
	rowCount = 0
	fs.createReadStream(path + fileName)
	.pipe(parse({delimiter: ','}))
	.on('data', (csvrow) ->
		rowCount++
		fileEntry =
			sourceVialBarcode: csvrow[DAUGHTER_SOURCE_VIAL_INDEX].trim()
			destinationVialBarcode: csvrow[DAUGHTER_DESTINATION_VIAL_INDEX].trim()
			amount: parseFloat(csvrow[DAUGHTER_AMOUNT_INDEX].trim())
			amountUnits: csvrow[DAUGHTER_AMOUNT_UNITS_INDEX].trim()
			preparedBy: csvrow[DAUGHTER_PREPARED_BY_INDEX].trim()
			preparedDate: csvrow[DAUGHTER_PREPARED_DATE_INDEX].trim()
			physicalState: csvrow[DAUGHTER_PHYSICAL_STATE_INDEX].trim()
			concentration: parseFloat(csvrow[DAUGHTER_CONCENTRATION_INDEX].trim())
			concUnits: csvrow[DAUGHTER_CONC_UNITS_INDEX].trim()
			solvent: csvrow[DAUGHTER_SOLVENT_INDEX].trim()
			rowNumber: rowCount
		if rowCount? and rowCount > 1
			csvFileEntries.push(fileEntry)
	)
	.on('end', () ->
		return callback null, csvFileEntries
	)

dealiasPhysicalStates = (fileEntryArray, callback) ->
	codeTableRoutes.getCodeTableValuesInternal 'container status', 'physical state', (configuredPhysicalStates) ->
		cleanedFileEntryArray = _.map fileEntryArray, (entry) ->
			foundPhysicalState = _.findWhere configuredPhysicalStates, {code: entry.physicalState}
			if !foundPhysicalState?
				foundPhysicalState = _.findWhere configuredPhysicalStates, {name: entry.physicalState}
			if foundPhysicalState?
				entry.physicalState = foundPhysicalState.code
			entry
		callback cleanedFileEntryArray

checkRequiredAttributes = (fileEntryArray, callback) ->
	requiredAttributeErrors = []
	_.each fileEntryArray, (entry) ->
		missingAttributes = []
		for attr in ['batchCode', 'destinationVialBarcode', 'sourceVialBarcode','preparedBy', 'preparedDate', 'physicalState']
			#not strictly required:  'amount', 'amountUnits', 'concentration', 'concUnits', 'solvent',
			if entry[attr]?
				if entry[attr] == ""
					missingAttributes.push attr
		if missingAttributes.length > 0
			error =
				errorLevel: 'error'
				message: "Row #{entry.rowNumber} is missing the required attributes: " + missingAttributes.join ', '
			requiredAttributeErrors.push error
	callback requiredAttributeErrors

checkDataTypeErrors = (fileEntryArray, callback) ->
	codeTableRoutes.getCodeTableValuesInternal 'container status', 'physical state', (configuredPhysicalStates) ->
		dataTypeErrors = []
		_.each fileEntryArray, (entry) ->
			foundPhysicalState = _.findWhere configuredPhysicalStates, {code: entry.physicalState}
			if !foundPhysicalState?
				foundPhysicalState = _.findWhere configuredPhysicalStates, {name: entry.physicalState}
			if !foundPhysicalState?
				configuredPhysicalStateCodes = _.pluck configuredPhysicalStates, 'code'
				configuredPhysicalStateCodeString = configuredPhysicalStateCodes.join(', ')
				error =
					errorLevel: 'error'
					message: "Row #{entry.rowNumber} has a physical state that was not recognized: #{entry.physicalState}. The available options are: #{configuredPhysicalStateCodeString}"
				dataTypeErrors.push error
			else
				entry.physicalState = foundPhysicalState.code
			if entry.amount? and !isNaN(entry.amount)
				if !entry.amountUnits? or entry.amountUnits.length < 1
					error =
						errorLevel: 'error'
						message: "Row #{entry.rowNumber} has an amount but no units"
					dataTypeErrors.push error
			if entry.concentration? and !isNaN(entry.concentration)
				if entry.concUnits.length < 1
					error =
						errorLevel: 'error'
						message: "Row #{entry.rowNumber} has a concentration but no units. Concentration units must be mM"
					dataTypeErrors.push error
				else if entry.concUnits != 'mM'
					error =
						errorLevel: 'error'
						message: "Row #{entry.rowNumber} must use concentration units of mM"
					dataTypeErrors.push error
			if entry.physicalState == 'liquid' or entry.physicalState == 'solution'
				if entry.amountUnits != 'uL'
					error =
						errorLevel: 'error'
						message: "Row #{entry.rowNumber} uses physical state \"#{entry.physicalState}\" and so must use units uL"
					dataTypeErrors.push error
			else if entry.amountUnits.length > 0 and entry.amountUnits != 'mg' and foundPhysicalState?
				error =
					errorLevel: 'error'
					message: "Row #{entry.rowNumber} uses physical state \"#{entry.physicalState}\" and so must use amount units mg"
				dataTypeErrors.push error
		callback dataTypeErrors

checkBatchCodesExist = (fileEntryArray, callback) ->
	requests = []
	_.each fileEntryArray, (entry) ->
		request =
			requestName: entry.batchCode
		requests.push request
	csUtilities.getPreferredBatchIds requests, (batchIdResponse) ->
		missingBatchCodes = []
		_.each batchIdResponse, (batchCodeRequest) ->
			if batchCodeRequest.preferredName? and batchCodeRequest.preferredName.length < 1
				missingBatchCodes.push batchCodeRequest.requestName
		callback missingBatchCodes

checkBarcodesExist = (barcodes, callback) ->
	getContainerCodesFromLabelsInternal barcodes, 'container', 'tube', (containerCodes) ->
		existingBarcodes = []
		newBarcodes = []
		_.each containerCodes, (containerCodeEntry) ->
			if containerCodeEntry.foundCodeNames? and containerCodeEntry.foundCodeNames.length > 0
				existingBarcodes.push containerCodeEntry.requestLabel
			else
				newBarcodes.push containerCodeEntry.requestLabel
		callback existingBarcodes, newBarcodes

exports.checkParentWellContent = (fileEntryArray, callback) ->
	#The purpose of this function is to check that the source vial content is compatible with the daughter content being loaded in, including
	#physical state must match
	#amount in parent vial would be negative if the daughter amount is removed
	#amount units match
	#concentration and concentration units match if solution
	errorMessages = []
	vialBarcodes = _.pluck fileEntryArray, 'sourceVialBarcode'
	strictMatch = config.all.client.compoundInventory.daughterVials.strictMatchPhysicalState
	flexibleErrorLevel = 'warning'
	if strictMatch? and strictMatch
		flexibleErrorLevel = 'error'
	exports.getWellContentByContainerLabelsInternal vialBarcodes, 'container', 'tube', 'barcode', 'barcode', (wellContentList, statusCode) ->
		_.each fileEntryArray, (fileEntry) ->
			parentVialAndWellContent = _.findWhere wellContentList, {label: fileEntry.sourceVialBarcode}
			if parentVialAndWellContent.wellContent?
				parentWellContent = parentVialAndWellContent.wellContent[0]
				if parentWellContent.physicalState != fileEntry.physicalState
					error =
						errorLevel: flexibleErrorLevel
						message: "Daughter vial #{fileEntry.destinationVialBarcode} must be of the same physical state as parent vial #{fileEntry.sourceVialBarcode}, which is #{parentWellContent.physicalState}."
					errorMessages.push error
				if fileEntry.physicalState == 'solution' and (Math.abs(fileEntry.concentration - parentWellContent.batchConcentration) > 0.0001 or fileEntry.concUnits != parentWellContent.batchConcUnits)
					error =
						errorLevel: flexibleErrorLevel
						message: "Daughter vial #{fileEntry.destinationVialBarcode} must have the same concentration as parent vial #{fileEntry.sourceVialBarcode}, which is #{parentWellContent.batchConcentration} #{parentWellContent.batchConcUnits}."
					errorMessages.push error
				if parentWellContent.amountUnits != fileEntry.amountUnits
					error =
						errorLevel: flexibleErrorLevel
						message: "Daughter vial #{fileEntry.destinationVialBarcode} must use the same amount units as parent vial #{fileEntry.sourceVialBarcode}, which is in #{parentWellContent.amountUnits}."
					errorMessages.push error
				else if parentWellContent.amount < fileEntry.amount
					error =
						errorLevel: 'warning'
						message: "Creating daughter vial #{fileEntry.destinationVialBarcode} will remove more than the total amount currently in parent vial #{fileEntry.sourceVialBarcode}, leaving a negative amount in the parent vial."
					errorMessages.push error
				if fileEntry.batchCode? and fileEntry.batchCode != parentWellContent.batchCode
					error =
						errorLevel: 'error'
						message: "Daughter vial #{fileEntry.destinationVialBarcode} must reference the same lot #{parentWellContent.batchCode} as the parent vial #{fileEntry.destinationVialBarcode}."
					errorMessages.push error
			else
				error =
					errorLevel: 'error'
					message: "Could not find a well for barcode #{fileEntry.sourceVialBarcode}"
				errorMessages.push error
		console.log errorMessages
		callback errorMessages




prepareValidationHTMLSummary = (hasError, hasWarning, errorMessages, summaryInfo) ->
	errors = _.where errorMessages, {errorLevel: 'error'}
	warnings = _.where errorMessages, {errorLevel: 'warning'}
	errorHeader = "<p>Please fix the following errors and use the 'Back' button at the bottom of this screen to upload a new version of the file.</p>"
	if hasWarning
		successHeader = "<p>Please review the warnings and summary before uploading.</p>"
	else
		successHeader = "<p>Please review the summary before uploading.</p>"
	errorsBlock = "\n  <h4 style=\"color:red\">Errors: #{errors.length} </h4>\n                         <ul>"
	_.each errors, (error) ->
		errorsBlock += "<li>#{error.message}</li>"
	errorsBlock += "</ul>"
	warningsBlock = "\n  <h4>Warnings: #{warnings.length}</h4>\n                            <p>Warnings provide information on issues found in the upload file. You can proceed with warnings; however, it is recommended that, if possible, you make the changes suggested by the warnings and upload a new version of the file by using the 'Back' button at the bottom of this screen.</p>\n                            <ul>"
	_.each warnings, (warning) ->
		warningsBlock += "<li>#{warning.message}</li>"
	warningsBlock += "</ul>"
	htmlSummaryInfo = "<h4>Summary</h4><p>Information:</p>\n                               <ul>\n                               "
	htmlSummaryInfo += "<li>Total Vials: #{summaryInfo.totalNumberOfVials}</li>"
	console.log summaryInfo
	stateNames = Object.keys(summaryInfo.totalsByStates)
	stateNames.sort()
	console.log stateNames
	for stateName in stateNames
		htmlSummaryInfo += "<li>#{stateName} Vials: #{summaryInfo.totalsByStates[stateName]}</li>"
	if summaryInfo.totalBatchCodes?
		htmlSummaryInfo += "<li>Unique Corporate Batch ID's: #{summaryInfo.totalBatchCodes}</li>"
	htmlSummaryInfo += "\n                               </ul>"
	htmlSummary = ""
	if hasError
		htmlSummary += errorHeader + errorsBlock
	else
		htmlSummary += successHeader
	if hasWarning
		htmlSummary += warningsBlock
	if !hasError
		htmlSummary += htmlSummaryInfo
	htmlSummary

prepareCreateVialsHTMLSummary = (hasError, hasWarning, errorMessages, summaryInfo) ->
	errors = _.where errorMessages, {errorLevel: 'error'}
	warnings = _.where errorMessages, {errorLevel: 'warning'}
	errorHeader = "<p>An error occurred during uploading. If the messages below are unhelpful, you will need to contact your system administrator.</p>"
	htmlSummaryInfo = "<h4>Summary</h4><p>Information:</p>\n                               <ul>\n                               "
	htmlSummaryInfo += "<li>Total Vials: #{summaryInfo.totalNumberOfVials}</li>"
	stateNames = Object.keys(summaryInfo.totalsByStates)
	stateNames.sort()
	console.log stateNames
	for stateName in stateNames
		htmlSummaryInfo += "<li>#{stateName} Vials: #{summaryInfo.totalsByStates[stateName]}</li>"
	if summaryInfo.totalBatchCodes?
		htmlSummaryInfo += "<li>Unique Corporate Batch ID's: #{summaryInfo.totalBatchCodes}</li>"
	htmlSummaryInfo += "\n                               </ul>"
	successHeader = "<p>Upload completed.</p>"
	errorsBlock = "\n  <h4 style=\"color:red\">Errors: #{errors.length} </h4>\n                         <ul>"
	_.each errors, (error) ->
		errorsBlock += "<li>#{error.message}</li>"
	errorsBlock += "</ul>"
	warningsBlock = "\n  <h4>Warnings: #{warnings.length}</h4>\n                            <p>Warnings provide information on issues found in the upload file. You can proceed with warnings; however, it is recommended that, if possible, you make the changes suggested by the warnings and upload a new version of the file by using the 'Back' button at the bottom of this screen.</p>\n                            <ul>"
	_.each warnings, (warning) ->
		warningsBlock += "<li>#{warning.message}</li>"
	warningsBlock += "</ul>"
	htmlSummary = ""
	if hasError
		htmlSummary += errorHeader + errorsBlock
	else
		htmlSummary += successHeader
	if hasWarning
		htmlSummary += warningsBlock
	if !hasError
		htmlSummary += htmlSummaryInfo
	htmlSummary

exports.getContainerTubeDefinitionCode = (callback) ->
	exports.containersByTypeKindInternal 'definition container', 'tube', 'codetable', false, false, (definitionContainers) ->
		callback definitionContainers[0].code

decrementAmountsFromVials = (toDecrementList, parentWellContentList, user, callback) ->
	wellsToUpdate = []
	changes = []
	_.each toDecrementList, (toDecrement) ->
		oldContainerWellContent = _.findWhere parentWellContentList, {label: toDecrement.sourceVialBarcode}
		oldWellContent = oldContainerWellContent.wellContent[0]
		#Check that the amount is valid to decrement.
		differentState = (oldWellContent.physicalState != toDecrement.physicalState)
		concentrationMismatch = (toDecrement.physicalState == 'solution' and (Math.abs(toDecrement.concentration - oldWellContent.batchConcentration) > 0.0001 or toDecrement.concUnits != oldWellContent.batchConcUnits))
		unitMismatch = (oldWellContent.amountUnits != toDecrement.amountUnits)
		if !differentState and !concentrationMismatch and !unitMismatch
			wellCode = oldWellContent.containerCodeName
			newWellContent =
				containerCodeName: wellCode
				amount: oldWellContent.amount - toDecrement.amount
				recordedBy: user
			wellsToUpdate.push newWellContent
			change =
				codeName: oldContainerWellContent.containerCodeName
				recordedBy: user
				recordedDate: new Date().getTime()
				entryType: 'UPDATE'
				entry: "Amount #{toDecrement.amount} #{toDecrement.amountUnits} taken out to create daughter vial #{toDecrement.destinationVialBarcode}"
			changes.push change
	console.log wellsToUpdate
	if wellsToUpdate.length > 0
		exports.updateWellContentInternal wellsToUpdate, true, false, (updateWellsResponse, updateWellsStatusCode) ->
			console.log updateWellsStatusCode
			if updateWellsStatusCode != 204
				callback "Error: #{updateWellsResponse}"
			else
				exports.containerLogsInternal changes, 0, (logs, statusCode) ->
					if statusCode != 200
						callback logs
					else
						callback null, updateWellsResponse
	else
		callback null

prepareSummaryInfo = (fileEntryArray, cb) ->
	codeTableRoutes.getCodeTableValuesInternal 'container status', 'physical state', (configuredPhysicalStates) ->
		summaryInfo =
			totalNumberOfVials: fileEntryArray.length
			totalsByStates: {}
		_.each configuredPhysicalStates, (configuredPhysicalState) ->
			count = (_.where fileEntryArray, {physicalState: configuredPhysicalState.code}).length + (_.where fileEntryArray, {physicalState: configuredPhysicalState.name}).length
			if count > 0
				summaryInfo.totalsByStates[configuredPhysicalState.name] = count
		batchCodes = _.pluck fileEntryArray, 'batchCode'
		batchCodes = _.filter batchCodes, (entry) ->
			entry?
		if batchCodes? and batchCodes.length > 0
			summaryInfo.totalBatchCodes = (_.uniq batchCodes).length
		cb summaryInfo


exports.saveWellToWellInteractions = (req, resp) ->
	if req.session?.passport?.user?.username?
		user = req.session.passport.user.username
	else
		user = 'anonymous'
	exports.saveWellToWellInteractionsInternal req.body, user, (err, data) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json data

exports.saveWellToWellInteractionsInternal = (interactionsToSave, user, callback) ->
	barcodes = []
	barcodes.push (_.pluck interactionsToSave, 'firstContainerBarcode')...
	barcodes.push (_.pluck interactionsToSave, 'secondContainerBarcode')...
	console.log barcodes
	exports.getWellCodesByPlateBarcodesInternal barcodes, (plateWellCodes) ->
		wellCodes = _.pluck plateWellCodes, 'wellCodeName'
		exports.getContainersByCodeNamesInternal wellCodes, (wells, statusCode) ->
			if statusCode? && statusCode != 200
				callback wells
			else
				formattedItxList = []
				_.each interactionsToSave, (itx) ->
					requiredParams = ['firstContainerBarcode', 'firstWellLabel', 'secondContainerBarcode', 'secondWellLabel', 'interactionType', 'interactionKind']
					for param in requiredParams
						if !itx[param]?
							callback "Error: all entries must include #{param}"
					firstWellCode = (_.findWhere plateWellCodes, {plateBarcode: itx.firstContainerBarcode, wellLabel: itx.firstWellLabel}).wellCodeName
					firstWell = (_.findWhere wells, {containerCodeName: firstWellCode}).container
					secondWellCode = (_.findWhere plateWellCodes, {plateBarcode: itx.secondContainerBarcode, wellLabel: itx.secondWellLabel}).wellCodeName
					secondWell = (_.findWhere wells, {containerCodeName: secondWellCode}).container
					formattedItx =
						lsType: itx.interactionType
						lsKind: itx.interactionKind
						recordedBy: user
						recordedDate: new Date().getTime()
						firstContainer: firstWell
						secondContainer: secondWell
					if itx.interactionStates?
						_.each itx.interactionStates, (state) ->
							state.recordedBy = user
							state.recordedDate = new Date().getTime()
							_.each state.lsValues, (value) ->
								value.recordedBy = user
								value.recordedDate = new Date().getTime()
						formattedItx.lsStates = itx.interactionStates
					formattedItxList.push formattedItx
				baseurl = config.all.client.service.persistence.fullpath+"itxcontainercontainers/jsonArray"
				request = require 'request'
				request(
					method: 'POST'
					url: baseurl
					body: formattedItxList
					json: true
					timeout: 86400000
				, (error, response, json) =>
					if !error && response.statusCode == 201
						callback null, json
					else
						console.error 'error trying to save container container interactions'
						console.error error
						console.log response.statusCode
						console.error json
						callback "Error trying to save container container interactions: #{error}"
				)

exports.validateDaughterVialsInternal = (vialsToValidate, callback) ->
	errorMessages = []
	checkRequiredAttributes vialsToValidate, (requiredAttributeErrors) ->
		if requiredAttributeErrors?
			errorMessages.push requiredAttributeErrors...
		checkDataTypeErrors vialsToValidate, (dataTypeErrors) ->
			if dataTypeErrors?
				errorMessages.push dataTypeErrors...
			sourceBarcodes = _.pluck vialsToValidate, 'sourceVialBarcode'
			checkBarcodesExist sourceBarcodes, (existingSourceBarcodes, missingSourceBarcodes) ->
				if missingSourceBarcodes? and missingSourceBarcodes.length > 0
					error =
						errorLevel: 'error'
						message: "The following source barcodes do not exist: " + missingSourceBarcodes.join ', '
					errorMessages.push error
				destinationBarcodes = _.pluck vialsToValidate, 'destinationVialBarcode'
				checkBarcodesExist destinationBarcodes, (existingBarcodes, newBarcodes) ->
					if existingBarcodes? and existingBarcodes.length > 0
						error =
							errorLevel: 'error'
							message: "The following destination barcodes already exist: " + existingBarcodes.join ', '
						errorMessages.push error
					if missingSourceBarcodes.length > 0
						callback null, errorMessages
					else
						exports.checkParentWellContent vialsToValidate, (parentWellContentErrors) ->
							if parentWellContentErrors?
								errorMessages.push parentWellContentErrors...
							callback null, errorMessages

exports.createDaughterVials = (req, resp) ->
	if req.session?.passport?.user?.username?
		user = req.session.passport.user.username
	else
		user = 'anonymous'
	exports.validateDaughterVialsInternal req.body, (err, errorsAndWarnings) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			errors = _.where errorsAndWarnings, {errorLevel: 'error'}
			warnings = _.where errorsAndWarnings, {errorLevel: 'warning'}
			if errors? and errors.length > 0
				resp.statusCode = 400
				resp.json errorsAndWarnings
			else
				exports.createDaughterVialsInternal req.body, user, (err, response) ->
					if err?
						resp.statusCode = 500
						resp.json err
					else
						resp.json response

exports.createDaughterVialsInternal = (vialsToCreate, user, callback) ->
	exports.getContainerTubeDefinitionCode (definitionCode) ->
		if !definitionCode?
			callback 'Could not find definition container for tube'
			return
		parentVialBarcodes = _.pluck vialsToCreate, 'sourceVialBarcode'
		exports.getWellContentByContainerLabelsInternal parentVialBarcodes, 'container', 'tube', 'barcode', 'barcode', (parentWellContentList, statusCode) ->
			tubesToCreate = []
			_.each vialsToCreate, (entry) ->
				parentVialAndWellContent = _.findWhere parentWellContentList, {label: entry.sourceVialBarcode}
				parentWellContent = parentVialAndWellContent.wellContent[0]
				batchCode = parentWellContent.batchCode
				if entry.batchCode? and entry.batchCode.length > 0
					batchCode = entry.batchCode
				tube =
					barcode: entry.destinationVialBarcode
					definition: definitionCode
					recordedBy: user
					createdUser: entry.preparedBy
					createdDate: entry.createdDate
					physicalState: entry.physicalState
					wells: [
						wellName: "A001"
						batchCode: batchCode
						amount: entry.amount
						amountUnits: entry.amountUnits
						physicalState: entry.physicalState
						recordedBy: user
						recordedDate: (new Date()).getTime()
					]
				if entry.physicalState == 'solution'
					tube.wells[0].batchConcentration = entry.concentration
					tube.wells[0].batchConcUnits = entry.concUnits
					tube.wells[0].solventCode = entry.solvent
				tubesToCreate.push tube
			console.log JSON.stringify tubesToCreate
			exports.createTubesInternal tubesToCreate, 0, (json, statusCode) ->
				console.log statusCode
				console.log json
				if statusCode != 200
					callback json
				else
					interactionsToCreate = []
					_.each vialsToCreate, (entry) ->
						interaction =
							interactionType: 'added to'
							interactionKind: 'well_well'
							firstContainerBarcode: entry.sourceVialBarcode
							secondContainerBarcode: entry.destinationVialBarcode
							firstWellLabel: 'A001'
							secondWellLabel: 'A001'
							interactionStates: [
									lsType: 'metadata'
									lsKind: 'information'
									lsValues: [
										lsType: 'numericValue'
										lsKind: 'amount added'
										numericValue: entry.amount
										unitKind: entry.amountUnits
									]
								]
						interactionsToCreate.push interaction
					exports.saveWellToWellInteractionsInternal interactionsToCreate, user, (err, itxResponse) ->
						if err?
							callback err
						else
							decrementAmountsFromVials vialsToCreate, parentWellContentList, user, (err, decrementVialsResponse) ->
								if err?
									callback err
								else
									#TODO see what this service should respond with
									callback null, 'successfully created daughter vials'

exports.advancedSearchContainers = (req, resp) ->
	exports.advancedSearchContainersInternal req.body, req.query.format, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json response

exports.advancedSearchContainersInternal = (itxSearchBody, format, callback) ->
	baseurl = config.all.client.service.persistence.fullpath+"containers/advancedSearchContainers"
	if format?
		baseurl += "?with=#{format}"
	request(
		method: 'POST'
		url: baseurl
		body: itxSearchBody
		json: true
		timeout: 86400000
		headers: 'content-type': 'application/json'
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.debug "returned successfully from #{baseurl}"
			callback null, json
		else
			console.error 'got ajax error trying to get getWellCodesByContainerCodes'
			console.error error
			console.error json
			console.error response
			callback JSON.stringify "getWellCodesByContainerCodes failed"
	)

exports.getParentVialByDaughterVialBarcode = (req, resp) ->
	exports.getParentVialByDaughterVialBarcodeInternal req.query.daughterVialBarcode, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json response

exports.getParentVialByDaughterVialBarcodeInternal = (daughterVialBarcode, callback) ->
	exports.getWellCodesByPlateBarcodesInternal [daughterVialBarcode], (plateWellCodes) ->
		plateWellCode = plateWellCodes[0]
		responseStub =
			daughterVialBarcode: plateWellCode.plateBarcode
			daughterVialCodeName: plateWellCode.plateCodeName
			daughterWellCodeName: plateWellCode.wellCodeName
			daughterWellLabel: plateWellCode.wellLabel
		itxSearch =
			lsType: 'well'
			lsKind: 'default'
			secondInteractions: [
				interactionType: 'added to'
				interactionKind: 'well_well'
				thingType: 'well'
				thingKind: 'default'
				thingCodeName: responseStub.daughterWellCodeName
			]
		format = 'nestedstub'
		exports.advancedSearchContainersInternal itxSearch, format, (err, advSearchReturn) ->
			if err?
				callback err
				return
			if advSearchReturn.results.length < 1
				callback null, responseStub
				return
			parentWell = advSearchReturn.results[0]
			responseStub.parentWellCodeName = parentWell.codeName
			parentWellLabel = _.findWhere parentWell.lsLabels, {lsType: 'name', lsKind: 'well name', ignored: false}
			responseStub.parentWellLabel = parentWellLabel.labelText
			parentVialItx = _.findWhere parentWell.firstContainers, {lsType: 'has member', lsKind: 'container_well', ignored: false}
			if !parentVialItx?
				callback 'Parent vial not found'
			else
				parentVial = parentVialItx.firstContainer
				responseStub.parentVialCodeName = parentVial.codeName
				parentVialBarcode = _.findWhere parentVial.lsLabels, {lsType: 'barcode', lsKind: 'barcode', ignored: false}
				responseStub.parentVialBarcode = parentVialBarcode.labelText
				callback null, responseStub

exports.getContainerLocationTree = (req, resp) ->
	exports.getContainerLocationTreeInternal req.query.withContainers, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.json err
		else
			resp.json response

exports.getContainerLocationTreeInternal = (withContainers, callback) ->
	rootLabel = config.all.client.compoundInventory.rootLocationLabel
	baseurl = config.all.client.service.persistence.fullpath+"containers/getLocationTreeByRootLabel?rootLabel=#{rootLabel}"
	if withContainers?
		baseurl+= "&withContainers=#{withContainers}"
	request(
		method: 'GET'
		url: baseurl
		json: true
		timeout: 86400000
		headers: 'content-type': 'application/json'
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.debug "returned successfully from #{baseurl}"
			formattedTree = []
			_.each json, (rawLocation) ->
				parent = rawLocation.parentCodeName
				if !parent?
					parent = '#'
				location =
					id: rawLocation.codeName
					parent: parent
					text: rawLocation.labelText
					breadcrumb: rawLocation.labelTextBreadcrumb
				formattedTree.push location
			callback null, formattedTree
		else
			console.error 'got ajax error trying to get getWellCodesByContainerCodes'
			console.error error
			console.error json
			console.error response
			callback JSON.stringify "getWellCodesByContainerCodes failed"
	)

exports.checkBatchDependencies = (req, resp) =>

	exports.checkBatchDependenciesInternal(req.body, (json, statusCode) =>
		resp.statusCode = statusCode
		resp.json json
	)

exports.checkBatchDependenciesInternal = (input, callback) =>
	batchCodes = input

	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"compounds/checkBatchDependencies"
	console.log 'baseurl', baseurl
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: batchCodes
		json: true
		timeout: 86400000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback json, response.statusCode
		else
			console.error 'got ajax error trying to checkBatchDependencies'
			console.error error
			console.error json
			console.error response
			callback null, 500
			#resp.end JSON.stringify "getContainerStatesByContainerValue failed"
		)

exports.setLocationByBreadCrumb = (req, resp) =>

	exports.setLocationByBreadCrumbInternal(req.body, (json, statusCode) =>
		resp.statusCode = statusCode
		resp.json json
	)

exports.setLocationByBreadCrumbInternal = (objectsToMove, callback) =>
	saveLocationAsCodeValue = config.all.client.compoundInventory.saveLocationAsCodeValue
	locationContainerCodes = []
	#objectsToMove >> {barcode: "BARCODE", modifiedBy: "user", modifiedDate: DATE, breadcrumb: "akjsd>asdj>alsd>asd"}
	locationBreadCrumbs = _.pluck(objectsToMove, "locationBreadCrumb")
	console.log 'locationBreadCrumbs from objectsToMove', locationBreadCrumbs
	rootLabel = _.pluck(objectsToMove, "rootLabel")
	if saveLocationAsCodeValue
		setLocationNameForObjects objectsToMove, (setLocationNameResponse, statusCode) =>
			console.log 'setLocationNameResponse', setLocationNameResponse
			callback setLocationNameResponse, statusCode
			#TODO: add the set to locationName
	else
		exports.getLocationCodesByBreadcrumbArrayInternal({locationBreadCrumbs: locationBreadCrumbs, rootLabel: rootLabel[0]}, (locationCodesByBreadcrumbArrayResponses, statusCode) =>
			_.each locationBreadCrumbs, (locationBreadCrumb) =>
				_.each locationCodesByBreadcrumbArrayResponses, (response) =>
					if locationBreadCrumb.indexOf(response.labelTextBreadcrumb) >-1
						locationContainerCodes.push(response.codeName)

			createMoveToLocationObjects(locationContainerCodes, objectsToMove, (moveToLocationObjects, statusCode) =>
				if statusCode is 200
					exports.moveToLocationInternal moveToLocationObjects, RUN_CUSTOM_FLAG, "1", (moveToLocationResponse, statusCode) =>
						callback moveToLocationResponse, statusCode
				else
					callback null, statusCode
			)
		)

setLocationNameForObjects = (objectsToMove, callback) =>
	barcodes = _.pluck(objectsToMove, "barcode")

	queryPayload =
		containerLabels: barcodes
		containerType: "container"
		# containerKind: "tube"
		labelType: "barcode"
		labelKind: "barcode"

	exports.getContainerAndDefinitionContainerByContainerLabelInternal barcodes, "container", null, "barcode", "barcode", (containers, containerStatusCode) =>
		if containerStatusCode is 200
			console.log 'containersReturned by getContainerAndDefinitionContainerByContainerLabelInternal', containers
			_.each containers, (container, index) =>
				container.locationName = objectsToMove[index].locationBreadCrumb

			exports.updateContainersByContainerCodesInternal containers, "", (json, statusCode) =>
				if statusCode is 200
					callback json, statusCode
				else
					callback null, statusCode
		else
			callback null, statusCode

	# exports.getContainerCodesByLabelsLikeMaxResultsInternal(queryPayload, (containerCodeQueryResponse, statusCode) =>
	# 	if statusCode is 200
	# 		barcodeContainerCodes = _.pluck(containerCodeQueryResponse, "foundCodeNames")
	# 		_.each barcodeContainerCodes, (containerCode, index) =>
	# 			if containerCode.length > 0
	# 				containersToUpdate.push({})
	# 				#TODO: now set the locatoin
	#
	# 		callback "successfully set location name as code value", statusCode
	# 	else
	# 		callback null, statusCode
	# )

exports.getLocationCodesByBreadcrumbArray = (req, resp) =>
	inputPayload =
		locationBreadCrumbs: req.body

	if req.query.rootLabel?
		inputPayload.rootLabel = req.query.rootLabel

	exports.getLocationCodesByBreadcrumbArrayInternal(inputPayload, (json, statusCode) =>
		resp.statusCode = statusCode
		resp.json json
	)

exports.getLocationCodesByBreadcrumbArrayInternal = (input, callback) =>

	locationBreadCrumbs = input.locationBreadCrumbs
	if !(input.rootLabel)?
		callback null, 500

	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"containers/getLocationCodesByBreadcrumbArray?rootLabel=#{input.rootLabel}"
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: locationBreadCrumbs
		json: true
		timeout: 86400000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback json, response.statusCode
		else
			console.error 'got ajax error trying to getLocationCodesByBreadcrumbArray'
			console.error error
			console.error json
			console.error response
			callback null, 500
		)

createMoveToLocationObjects = (locationCodeNames, objectsToMove, callback) =>

	moveToLocationObjects = []
	barcodes = _.pluck(objectsToMove, "barcode")

	queryPayload =
		containerLabels: barcodes
		containerType: "container"
		# containerKind: "tube"
		labelType: "barcode"
		labelKind: "barcode"

	exports.getContainerCodesByLabelsLikeMaxResultsInternal(queryPayload, (containerCodeQueryResponse, statusCode) =>
		if statusCode is 200
			barcodeContainerCodes = _.pluck(containerCodeQueryResponse, "foundCodeNames")
			_.each barcodeContainerCodes, (containerCode, index) =>
				if containerCode.length > 0
					moveToLocationObjects.push({containerCodeName: containerCode[0], modifiedBy: objectsToMove[index].user, modifiedDate: objectsToMove[index].date, locationCodeName: locationCodeNames[index]})
			callback moveToLocationObjects, statusCode
		else
			callback null, statusCode
	)
