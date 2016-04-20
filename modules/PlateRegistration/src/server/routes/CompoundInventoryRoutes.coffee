_ = require('lodash')
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/compoundInventory', loginRoutes.ensureAuthenticated, exports.compoundInventoryIndex
	app.get '/compoundInventorySpecRunner', loginRoutes.ensureAuthenticated, exports.compoundInventorySpecRunner
	app.get '/api/getWellsWithCompoundBatch/:compoundBatch', exports.getWellsWithCompoundBatch
	app.get '/api/getPlateByBarcode/:plateBarcode', exports.getPlateByBarcode
	app.get '/api/getWellContentByPlateBarcode/:plateBarcode', exports.getWellContentByPlateBarcode

	app.post '/api/updatePlate', loginRoutes.ensureAuthenticated, exports.updatePlate

	app.post '/api/validateIdentifiers', loginRoutes.ensureAuthenticated, exports.validateIdentifiers
	app.post '/api/createPlate', loginRoutes.ensureAuthenticated, exports.createPlate
	app.post '/api/updateWellStatus', loginRoutes.ensureAuthenticated, exports.updateWellStatus


exports.compoundInventoryIndex = (req, resp) ->
	return resp.render 'PlateRegistration',
		title: 'Plate Registration'

exports.compoundInventorySpecRunner = (req, resp) ->
	return resp.render ' PlateRegistrationSpecRunner',
		title: 'Plate Registration SpecRunner'

exports.validateIdentifiers = (req, resp) ->
	if global.specRunnerTestmode
		resp.end JSON.stringify {}
	else
		identifiers = req.body.identifiers.split(";")
		validatedIdentifiers = []
		throwServerError = false
		_.each(identifiers, (identifier) ->
			unless identifier is ""
				if identifier.indexOf('alias') > -1
					validatedIdentifiers.push
						requestName: identifier
						preferredName: identifier + "---aliased"
				else if identifier.indexOf('error') > -1
					validatedIdentifiers.push
						requestName: identifier
						preferredName: ""
				else
					validatedIdentifiers.push
						requestName: identifier
						preferredName: identifier
				if identifier is "barf"
					throwServerError = true
		)

		if throwServerError
			resp.status(500).send('Something  broke!')

		else
			resp.setHeader 'Content-Type', 'application/json'
			resp.end JSON.stringify validatedIdentifiers


exports.getWellsWithCompoundBatch = (req, res) ->
	console.log "req.params"
	console.log req.params
	searchForWellsBy(compoundBatch, (docs) ->
		res.send
	)

exports.createPlate = (req, resp) ->
	exports.createPlateInternal req.body, req.query.callCustom, (json, statusCode) ->
		resp.statusCode = statusCode
		resp.json json

exports.createPlateInternal = (input, callCustom, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath + "containers/createPlate"
	console.log "baseurl"
	console.log baseurl

	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: JSON.stringify input
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error  && response.statusCode == 200
			callback json, response.statusCode
			# If call custom doesn't equal 0 then call custom
			callCustom  = callCustom != "0"
			if callCustom
				if csUtilities.createPlate?
					console.log "running customer specific server function createPlate"
					csUtilities.createPlate input, (response) ->
						console.log response
				else
					console.warn "could not find customer specific server function createPlate so not running it"
		else
			console.log 'got ajax error trying to create plate'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}, 500
	)

exports.updatePlate = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	console.log "req.body - using post syntax"
	console.log req.body

	baseurl = config.all.client.service.persistence.fullpath + "containers/createPlate"
	console.log "baseurl"
	console.log baseurl

	request = require 'request'
	request(
		method: 'PUT'
		url: baseurl
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to save new experiment'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.getPlateByBarcode = (req, resp) ->
	console.log "getPlateByBarcode"
	console.log req.params['plateBarcode']
	resp.setHeader('Content-Type', 'application/json')
	resp.end JSON.stringify {barcode: "test plate"}

exports.getWellContentByPlateBarcode = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	console.log "getWellContentByPlateBarcode"
	plateBarcode = req.params['plateBarcode']
	baseurl = config.all.client.service.persistence.fullpath + "containers/getWellContentByPlateBarcode/#{plateBarcode}"
	console.log "baseurl"
	console.log baseurl

	request = require 'request'
	request(
		method: 'GET'
		url: baseurl
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to get well content for plate'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.updateWellStatus = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	#baseurl = config.all.client.service.persistence.fullpath + "containers/updateWellStatus"
	baseurl = config.all.client.service.persistence.fullpath + "containers/updateWellContent"
	console.log "baseurl"
	console.log baseurl

	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: JSON.stringify req.body.wells
		json: true
		timeout: 24000000
	, (error, response, json) =>
		console.log "error"
		console.log error
		console.log "response"
		console.log response
		console.log "json"
		console.log json

		if !error
			console.log JSON.stringify json
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to update well statuses'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)
