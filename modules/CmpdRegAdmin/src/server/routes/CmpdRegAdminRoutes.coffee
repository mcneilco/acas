exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/vendors', exports.getCmpdRegVendors
	app.get '/api/cmpdRegAdmin/vendors/validate/:code', exports.validateCmpdRegVendor
	app.get '/api/cmpdRegAdmin/vendors/findByCode/:code', exports.getCmpdRegVendorByCode

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/vendors/validate/:code', loginRoutes.ensureAuthenticated, exports.validateCmpdRegVendor
	app.get '/api/cmpdRegAdmin/vendors/findByCode/:code', loginRoutes.ensureAuthenticated, exports.getCmpdRegVendorByCode
	app.get '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.getCmpdRegVendors
	app.get '/api/cmpdRegAdmin/vendors/:searchTerm', loginRoutes.ensureAuthenticated, exports.searchCmpdRegVendors
	app.post '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.saveCmpdRegVendors
	app.put '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.updateCmpdRegVendors
	app.delete '/api/cmpdRegAdmin/vendors', loginRoutes.ensureAuthenticated, exports.deleteCmpdRegVendors

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
		else
			console.log 'got ajax error trying to do validate vendor'
			console.log error
			console.log validVendor
			console.log response
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
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			console.log 'got ajax error trying to do get vendor'
			console.log error
			console.log json
			console.log response
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
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveParent = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log "exports.updateParent"

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/vendors'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to save the vendor'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to save vendor: " + error;
	)

exports.updateParent = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log "exports.updateParent"

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update vendor'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update vendor: " + error;
	)