exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/:entityType', exports.getCmpdRegEntities
	app.get '/api/cmpdRegAdmin/:entityType/validate/:code', exports.validateCmpdRegEntity
	app.get '/api/cmpdRegAdmin/:entityType/codeName/:code', exports.getCmpdRegEntityByCode
	app.post '/api/cmpdRegAdmin/:entityType/validateBeforeSave', exports.validateCmpdRegEntityBeforeSave
	app.post '/api/cmpdRegAdmin/:entityType',  exports.saveCmpdRegEntity
	app.put '/api/cmpdRegAdmin/:entityType/:id', exports.updateCmpdRegEntity
	app.delete '/api/cmpdRegAdmin/:entityType/:id', exports.deleteCmpdRegEntity

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/:entityType/validate/:code', loginRoutes.ensureAuthenticated, exports.validateCmpdRegEntity
	app.get '/api/cmpdRegAdmin/:entityType/codeName/:code', loginRoutes.ensureAuthenticated, exports.getCmpdRegEntityByCode
	app.get '/api/cmpdRegAdmin/:entityType', loginRoutes.ensureAuthenticated, exports.getCmpdRegEntities
	app.get '/api/cmpdRegAdmin/:entityType/search/:searchTerm', loginRoutes.ensureAuthenticated, exports.searchCmpdRegEntities
	app.post '/api/cmpdRegAdmin/:entityType/validateBeforeSave', loginRoutes.ensureAuthenticated, exports.validateCmpdRegEntityBeforeSave

	app.get '/api/cmpdRegAdmin/:entityType/:id', loginRoutes.ensureAuthenticated, exports.getCmpdRegEntityById
	app.post '/api/cmpdRegAdmin/:entityType', loginRoutes.ensureAuthenticated, exports.saveCmpdRegEntity
	app.put '/api/cmpdRegAdmin/:entityType/:id', loginRoutes.ensureAuthenticated, exports.updateCmpdRegEntity
	app.delete '/api/cmpdRegAdmin/:entityType/:id', loginRoutes.ensureAuthenticated, exports.deleteCmpdRegEntity

exports.validateCmpdRegEntity = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/validate?code=" + req.params.code
	request(
		method: 'GET'
		url: cmpdRegCall
		json: false
		timeout: 6000000
	, (error, response, validEntity) =>
		if !error and !validEntity.startsWith('<')
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end validEntity
			console.log "done validating the #{entityType} testString"
		else
			console.log 'got ajax error trying to do validate #{entityType}'
			resp.statusCode = 500
			resp.end JSON.stringify {error: "something went wrong validating the #{entityType}"}
	)

exports.validateCmpdRegEntityBeforeSave = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/validateBeforeSave"
	console.log cmpdRegCall
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body.data
		json: true
		timeout: 6000000
		headers:
			"Content-Type": 'application/json'
	, (error, response, validEntity) =>
		if !error and !validEntity.toString().startsWith('<')
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify validEntity
		else
			console.error "got ajax error trying to do validate #{entityType}"
			console.log validEntity
			resp.statusCode = 500
			resp.end JSON.stringify {error: "something went wrong validating the #{entityType} :("}
	)

exports.getCmpdRegEntityById = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/" + req.params.id
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
			console.error "got ajax error trying to do find #{entityType}"
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.getCmpdRegEntityByCode = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/findByCodeEquals?code=" + req.params.code
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
			console.log "got ajax error trying to do find #{entityType}"
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.searchCmpdRegEntities = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/search/?searchTerm=" + req.params.searchTerm
	console.debug cmpdRegCall
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
			console.log "got ajax error trying to do find #{entityType}"
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)


exports.getCmpdRegEntities = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}"
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
			console.log "got ajax error trying to do get #{entityType}"
			console.log json
			resp.statusCode = 404
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveCmpdRegEntity = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}"
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
		headers:
			"Content-Type": 'application/json'
	, (error, response, json) =>
		if !error and !json.toString().startsWith('<')
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log "got ajax error trying to save the #{entityType}"
			console.log json
			resp.statusCode = 500
			resp.end "Error trying to save #{entityType}: " + error;
	)

exports.updateCmpdRegEntity = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}"
	request(
		method: 'PUT'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
		headers:
			"Content-Type": 'application/json'
	, (error, response, json) =>
		if !error and response.statusCode == 200
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log "got ajax error trying to update #{entityType}"
			console.log json
			resp.statusCode = 500
			resp.end "Error trying to update #{entityType}: " + error;
	)

exports.deleteCmpdRegEntity = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/" + req.params.id
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
			console.log "got ajax error trying to delete #{entityType}"
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)