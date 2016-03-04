exports.setupAPIRoutes = (app) ->
	app.post '/api/getContainersInLocation', exports.getContainersInLocation
	app.post '/api/getContainerCodesByLabels', exports.getContainerCodesByLabels
	app.post '/api/getWellCodesByPlateBarcodes', exports.getWellCodesByPlateBarcodes
	app.post '/api/getWellContent', exports.getWellContent
	app.get '/api/getPlateMetadataAndDefinitionMetadataByPlateBarcode/:plateBarcode', exports.getPlateMetadataAndDefinitionMetadataByPlateBarcode
	app.post '/api/getPlateMetadataAndDefinitionMetadataByPlateBarcodes', exports.getPlateMetadataAndDefinitionMetadataByPlateBarcodes

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/getContainersInLocation', loginRoutes.ensureAuthenticated, exports.getContainersInLocation
	app.post '/api/getContainerCodesByLabels', loginRoutes.ensureAuthenticated, exports.getContainerCodesByLabels
	app.post '/api/getWellCodesByPlateBarcodes', loginRoutes.ensureAuthenticated, exports.getWellCodesByPlateBarcodes
	app.post '/api/getWellContent', loginRoutes.ensureAuthenticated, exports.getWellContent
	app.get '/api/getPlateMetadataAndDefinitionMetadataByPlateBarcode/:plateBarcode', loginRoutes.ensureAuthenticated, exports.getPlateMetadataAndDefinitionMetadataByPlateBarcode
	app.post '/api/getPlateMetadataAndDefinitionMetadataByPlateBarcodes', loginRoutes.ensureAuthenticated, exports.getPlateMetadataAndDefinitionMetadataByPlateBarcodes

exports.getContainersInLocation = (req, resp) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersInLocation
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersInLocation"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get getContainersInLocation'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "getContainersInLocation failed"
  		)

exports.getContainerCodesByLabels = (req, resp) ->
	exports.getContainerCodesByLabelsInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getContainerCodesByLabelsInternal = (plateBarcodesJSON, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainerCodesByLabelsResponse
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: plateBarcodesJSON
			json: true
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log 'got ajax error trying to get getContainerCodesByLabels'
				console.log error
				console.log json
				console.log response
				callback JSON.stringify "getContainerCodesByLabels failed"
		)


exports.getWellCodesByPlateBarcodes = (req, resp) ->
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
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get getWellCodesByPlateBarcodes'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "getWellCodesByPlateBarcodes failed"
  		)

exports.getWellContent = (req, resp) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getWellContent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getWellContent"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get getWellContent'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "getWellContent failed"
  		)

exports.getPlateMetadataAndDefinitionMetadataByPlateBarcodes = (req, resp) ->
	exports.getPlateMetadataAndDefinitionMetadataByPlateBarcodesInternal req.body, (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json

exports.getPlateMetadataAndDefinitionMetadataByPlateBarcode = (req, resp) ->
	exports.getPlateMetadataAndDefinitionMetadataByPlateBarcodesInternal [req.params.plateBarcode], (json) ->
		if json.indexOf('failed') > -1
			resp.statusCode = 500
		else
			resp.json json[0]

exports.getPlateMetadataAndDefinitionMetadataByPlateBarcodesInternal = (plateBarcodes, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getPlateMetadataAndDefinitionMetadataByPlateBarcodeResponse
	else
		exports.getContainerCodesByLabelsInternal plateBarcodes, (containerCodes) =>
			if containerCodes.indexOf('failed') > -1
				callback JSON.stringify "getPlateMetadataAndDefinitionMetadataByPlateBarcodes failed"
			else
				_ = require 'underscore'
				codeNames = _.pluck containerCodes, "codeName"
				codeNamesJSON = JSON.stringify codeNames
				exports.getContainersByCodeNamesInternal codeNamesJSON, (containers) =>
					if containers.indexOf('failed') > -1
						callback JSON.stringify "getPlateMetadataAndDefinitionMetadataByPlateBarcodes failed"
					else
						serverUtilityFunctions = require './ServerUtilityFunctions.js'
						exports.getDefinitionContainersByContainerCodeNamesInternal codeNamesJSON, (definitions) =>
							if definitions.indexOf('failed') > -1
								callback JSON.stringify "getPlateMetadataAndDefinitionMetadataByPlateBarcodes failed"
							else
								responseArray = []
								for barcode, index in plateBarcodes
									response =
										barcode: barcode
										codeName: null
										description: null
										plateSize: null
										numberOfRows: null
										numberOfColumns: null
										type: null
										status: null
										createdDate: null
										supplier: null
									containerCode =  _.findWhere containerCodes, {label: barcode}
									if containerCode?
										response.codeName = containerCode.codeName
										container =  _.findWhere containers, {containerCodeName: containerCode.codeName}
										if container?
											state = serverUtilityFunctions.getStatesByTypeAndKind container.container, 'metadata', 'information'
											if state.length > 0
												description = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'stringValue', 'description')
												if description.length > 0
													response.description = description[0].stringValue
												type = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'stringValue', 'plate type')
												if type.length > 0
													response.type = type[0].stringValue
												status = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'stringValue', 'status')
												if status.length > 0
													response.status = status[0].stringValue
												createdDate = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'dateValue', 'created date')
												if createdDate.length > 0
													response.createdDate = createdDate[0].dateValue
												supplier = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'stringValue', 'supplier code')
												if supplier.length > 0
													response.supplier = supplier[0].stringValue

										definition =  _.findWhere definitions, {containerCodeName: containerCode.codeName}
										if definition?
												state = serverUtilityFunctions.getStatesByTypeAndKind definition.definition, 'constants', 'format'
												if state.length > 0
													plateSize = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'numericValue', 'wells')
													if plateSize.length > 0
														response.plateSize = plateSize[0].numericValue
													numberOfRows = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'numericValue', 'rows')
													if numberOfRows.length > 0
														response.numberOfRows = numberOfRows[0].numericValue
													numberOfColumns = serverUtilityFunctions.getValuesByTypeAndKind(state[0], 'numericValue', 'columns')
													if numberOfColumns.length > 0
														response.numberOfColumns = numberOfColumns[0].numericValue
								responseArray.push response
								callback responseArray

exports.getContainersByCodeNamesInternal = (codeNamesJSON, callback) ->
	if global.specRunnerTestmode
		inventoryServiceTestJSON = require '../public/javascripts/spec/ServerAPI/testFixtures/InventoryServiceTestJSON.js'
		resp.json inventoryServiceTestJSON.getContainersByCodeNames
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainersByCodeNames"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesJSON
			json: true
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log 'got ajax error trying to get getContainersByCodeNames'
				console.log error
				console.log json
				console.log response
				callback JSON.stringify "getContainersByCodeNames failed"
		)

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
			headers: 'content-type': 'application/json'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log 'got ajax error trying to get getDefinitionContainersByContainerCodeNames'
				console.log error
				console.log json
				console.log response
				callback JSON.stringify "getDefinitionContainersByContainerCodeNames failed"
		)
