exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/codeTablesAdmin/:entityType', exports.getCodeTablesEntities
	app.get '/api/codeTablesAdmin/:entityType/d/:code', exports.validateCodeTablesEntity
	app.get '/api/codeTablesAdmin/:entityType/codeName/:code', exports.getCodeTablesEntityByCode
	app.post '/api/codeTablesAdmin/:codeType/:codeKind/validateBeforeSave', exports.validateCodeTablesEntityBeforeSave
	app.post '/api/codeTablesAdmin/:entityType',  exports.saveCodeTablesEntity
	app.put '/api/codeTablesAdmin/:codeType/:codeKind/:id', exports.updateCodeTablesEntity
	app.delete '/api/codeTablesAdmin/:codeType/:codeKind/:id', exports.deleteCodeTablesEntity

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/codeTablesAdmin/:codeType/:codeKind/search/:searchTerm', loginRoutes.ensureAuthenticated, exports.searchCodeTablesEntities
	app.post '/api/codeTablesAdmin/:codeType/:codeKind/validateBeforeSave', loginRoutes.ensureAuthenticated, exports.validateCodeTablesEntityBeforeSave
	app.post '/api/codeTablesAdmin/:codeType/:codeKind', loginRoutes.ensureAuthenticated, exports.saveCodeTablesEntity
	app.put '/api/codeTablesAdmin/:codeType/:codeKind/:id', loginRoutes.ensureAuthenticated, exports.updateCodeTablesEntity
	app.delete '/api/codeTablesAdmin/:id', loginRoutes.ensureAuthenticated, exports.deleteCodeTablesEntity

exports.validateCodeTablesEntity = (req, resp) ->
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

exports.validateCodeTablesEntityBeforeSave = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	codeTableServiceRoutes = require "./CodeTableServiceRoutes.js"
	searchTerm = req.params.searchTerm
	codeTableServiceRoutes.getCodeTableValuesInternal req.params.codeType, req.params.codeKind, (results) ->
		if !req.body.data?
			data = req.body
		else
			data = req.body.data
		if typeof(data) == 'string'
			data = JSON.parse(data)
		for r in results
			if (!data.id? || data.id!=r.id) && r.code == data.code
				resp.statusCode = 409
				resp.json [{"errorLevel": "ERROR", "message": "Code value already exists for #{req.params.codeType} #{req.params.codeKind}"}]
		resp.json data

exports.getCodeTablesEntityById = (req, resp) ->
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

exports.getCodeTablesEntityByCode = (req, resp) ->
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

exports.searchCodeTablesEntities = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	codeTableServiceRoutes = require "./CodeTableServiceRoutes.js"
	searchTerm = req.params.searchTerm.toLowerCase().trim()
	codeTableServiceRoutes.getCodeTableValuesInternal req.params.codeType, req.params.codeKind, (results) ->
		searchResults = []
		if searchTerm == "*" || searchTerm == ""
			searchResults = results
		else
			for r in results
				if (r.code? && r.code.toLowerCase().indexOf(searchTerm) >= 0) || (r.comments? && r.comments.toLowerCase().indexOf(searchTerm) >= 0) || (r.description? && r.description.toLowerCase().indexOf(searchTerm) >= 0) || (r.name? && r.name.toLowerCase().indexOf(searchTerm) >= 0) 
					searchResults.push(r)
		resp.json searchResults

exports.getCodeTablesEntities = (req, resp) ->
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

exports.saveCodeTablesEntity = (req, resp) ->
	codeTableServiceRoutes = require "./CodeTableServiceRoutes.js"
	codeEntry = {
		comments: "registered with code tables admin module",
		description: "registered with code tables admin module",
		displayOrder: null,
		ignored: req.body.ignored,
		name: req.body.name,
		codeOrigin: "ACAS"
		codeKind: req.params.codeKind,
		codeType: req.params.codeType,
		code: req.body.code
	}
	codeTableServiceRoutes.postCodeTableInternal codeEntry, (statusCode, response) ->
		resp.end response

exports.updateCodeTablesEntity = (req, resp) ->
	codeTableServiceRoutes = require "./CodeTableServiceRoutes.js"
	codeEntry = {
		comments: "registered with code tables admin module",
		description: "registered with code tables admin module",
		displayOrder: null,
		ignored: req.body.ignored,
		name: req.body.name,
		codeOrigin: "ACAS"
		codeKind: req.params.codeKind,
		codeType: req.params.codeType,
		code: req.body.code
		id: req.body.id
	}
	codeTableServiceRoutes.putCodeTableInternal codeEntry, (statusCode, response) ->
		resp.end response


exports.deleteCodeTablesEntity = (req, resp) ->
	codeTableServiceRoutes = require "./CodeTableServiceRoutes.js"

	codeTableServiceRoutes.deleteCodeTableInternal {id: req.params.id}, (statusCode, response) ->
		console.log(statusCode)
		console.log(response)
		resp.json response
