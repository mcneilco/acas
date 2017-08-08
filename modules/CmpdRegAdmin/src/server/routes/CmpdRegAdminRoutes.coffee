exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/vendors', exports.getCmpdRegVendors
	app.get '/api/cmpdRegAdmin/vendors/validate/:code', exports.validateCmpdRegVendor
	app.get '/api/cmpdRegAdmin/vendors/codeName/:code', exports.getCmpdRegVendorByCode
	app.post '/api/cmpdRegAdmin/vendors/validateBeforeSave', exports.validateCmpdRegVendorBeforeSave
	app.post '/api/cmpdRegAdmin/vendors',  exports.saveCmpdRegVendor
	app.put '/api/cmpdRegAdmin/vendors/:id', exports.updateCmpdRegVendor
	app.delete '/api/cmpdRegAdmin/vendors/:id', exports.deleteCmpdRegVendor

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/vendors/validate/:code', loginRoutes.ensureAuthenticated, exports.validateCmpdRegVendor
	app.get '/api/cmpdRegAdmin/vendors/codeName/:code', loginRoutes.ensureAuthenticated, exports.getCmpdRegVendorByCode
	app.get '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.getCmpdRegVendors
	app.get '/api/cmpdRegAdmin/vendors/search/:searchTerm', loginRoutes.ensureAuthenticated, exports.searchCmpdRegVendors
	app.post '/api/cmpdRegAdmin/vendors/validateBeforeSave', loginRoutes.ensureAuthenticated, exports.validateCmpdRegVendorBeforeSave

	app.get '/api/cmpdRegAdmin/vendors/:id', loginRoutes.ensureAuthenticated, exports.getCmpdRegVendorById
	app.post '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.saveCmpdRegVendor
	app.put '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.updateCmpdRegVendor
	app.delete '/api/cmpdRegAdmin/vendors/:id', loginRoutes.ensureAuthenticated, exports.deleteCmpdRegVendor

exports.validateCmpdRegVendor = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors/validate?code=' + req.params.code
	console.log 'attempting vendor call to the following route'
	console.log cmpdRegCall
	request(
		method: 'GET'
		url: cmpdRegCall
		json: false
		timeout: 6000000
	, (error, response, validVendor) =>
		if !error
			console.log validVendor
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end validVendor
			console.log 'done validating the vendor'
		else
			console.log 'got ajax error trying to do validate vendor'
			console.log validVendor
			resp.end JSON.stringify {error: "something went wrong validating the vendor :("}
	)

exports.validateCmpdRegVendorBeforeSave = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors/validateBeforeSave'
	console.log 'attempting vendor call to the following route --- line 49'
	console.log cmpdRegCall
	console.log req.body.data
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body.data
		json: true
		timeout: 6000000
		headers:
			"Content-Type": 'application/json'
	, (error, response, validVendor) =>
		if !error
			console.log 'line 60 -- is a valid vendor'
			console.log validVendor
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify validVendor
			console.log resp.statusCode
			console.log 'done validating the vendor'
		else
			console.log 'got ajax error trying to do validate vendor'
			console.log validVendor
			resp.end JSON.stringify {error: "something went wrong validating the vendor :("}
	)

exports.getCmpdRegVendorById = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors/' + req.params.id
	console.log 'attempting vendor call to the following route'
	console.log cmpdRegCall
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			resp.statusCode = 404
			console.log 'got ajax error trying to do find vendor'
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.getCmpdRegVendorByCode = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors/findByCodeEquals?code=' + req.params.code
	console.log 'attempting vendor call to the following route'
	console.log cmpdRegCall
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			resp.statusCode = 404
			console.log 'got ajax error trying to do find vendor'
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.searchCmpdRegVendors = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors/search/?searchTerm=' + req.params.searchTerm
	console.log 'attempting vendor call to the following route'
	console.log cmpdRegCall
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			resp.statusCode = 404
			console.log 'got ajax error trying to do find vendor'
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)


exports.getCmpdRegVendors = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors'
	console.log 'attempting vendor call to the following route'
	console.log cmpdRegCall
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			console.log 'got ajax error trying to do get vendors'
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveCmpdRegVendor = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log "line 134 --- exports.saveCmpdRegVendor"
	console.log JSON.stringify req.body

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
		headers:
			"Content-Type": 'application/json'
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to save the vendor'
			console.log json
			resp.statusCode = 500
			resp.end "Error trying to save vendor: " + error;
	)

exports.updateCmpdRegVendor = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log "exports.updateCmpdRegVendor"

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors'
	request(
		method: 'PUT'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
		headers:
			"Content-Type": 'application/json'
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update vendor'
			console.log json
			resp.statusCode = 500
			resp.end "Error trying to update vendor: " + error;
	)

exports.deleteCmpdRegVendor = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors/' + req.params.id
	console.log 'attempting vendor call to the following route'
	console.log cmpdRegCall
	request(
		method: 'DELETE'
		url: cmpdRegCall
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			resp.statusCode = 404
			console.log 'got ajax error trying to delete vendor'
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)