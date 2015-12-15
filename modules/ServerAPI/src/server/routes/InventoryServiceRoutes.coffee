exports.setupAPIRoutes = (app) ->
	app.post '/api/getContainersInLocation', exports.getContainersInLocation
	app.post '/api/getContainerCodesByLabels', exports.getContainerCodesByLabels
	app.post '/api/getWellCodesByPlateBarcodes', exports.getWellCodesByPlateBarcodes
	app.post '/api/getWellContent', exports.getWellContent

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/getContainersInLocation', loginRoutes.ensureAuthenticated, exports.getContainersInLocation
	app.post '/api/getContainerCodesByLabels', loginRoutes.ensureAuthenticated, exports.getContainerCodesByLabels
	app.post '/api/getWellCodesByPlateBarcodes', loginRoutes.ensureAuthenticated, exports.getWellCodesByPlateBarcodes
	app.post '/api/getWellContent', loginRoutes.ensureAuthenticated, exports.getWellContent

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
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get getContainerCodesByLabels'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "getContainerCodesByLabels failed"
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
