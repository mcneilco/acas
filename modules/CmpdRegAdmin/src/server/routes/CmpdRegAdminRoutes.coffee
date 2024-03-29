exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/:entityType', exports.getCmpdRegEntities
	app.get '/api/cmpdRegAdmin/:entityType/validate/:code', exports.validateCmpdRegEntity
	app.get '/api/cmpdRegAdmin/:entityType/codeName/:code', exports.getCmpdRegEntityByCode
	app.get '/api/cmpdRegAdmin/:entityType/search/:searchTerm', exports.searchCmpdRegEntities
	app.get '/api/cmpdRegAdmin/:entityType/sdf', exports.getSDFCmpdRegEntities
	app.post '/api/cmpdRegAdmin/:entityType/validateBeforeSave', exports.validateCmpdRegEntityBeforeSave
	app.post '/api/cmpdRegAdmin/:entityType',  exports.saveCmpdRegEntity
	app.put '/api/cmpdRegAdmin/:entityType/:id', exports.updateCmpdRegEntity
	app.put '/api/cmpdRegAdmin/:entityType/edit/:id', exports.editCmpdRegEntity
	app.delete '/api/cmpdRegAdmin/:entityType/:id', exports.deleteCmpdRegEntity

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cmpdRegAdmin/:entityType/validate/:code', loginRoutes.ensureAuthenticated, exports.validateCmpdRegEntity
	app.get '/api/cmpdRegAdmin/:entityType/codeName/:code', loginRoutes.ensureAuthenticated, exports.getCmpdRegEntityByCode
	app.get '/api/cmpdRegAdmin/:entityType', loginRoutes.ensureAuthenticated, exports.getCmpdRegEntities
	app.get '/api/cmpdRegAdmin/:entityType/search/:searchTerm', loginRoutes.ensureAuthenticated, exports.searchCmpdRegEntities
	app.get '/api/cmpdRegAdmin/:entityType/sdf', loginRoutes.ensureAuthenticated, exports.getSDFCmpdRegEntities
	app.post '/api/cmpdRegAdmin/:entityType/validateBeforeSave', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.validateCmpdRegEntityBeforeSave
	app.get '/api/cmpdRegAdmin/:entityType/:id', loginRoutes.ensureAuthenticated, exports.getCmpdRegEntityById
	app.post '/api/cmpdRegAdmin/:entityType', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.saveCmpdRegEntity
	app.put '/api/cmpdRegAdmin/:entityType/:id', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.updateCmpdRegEntity
	app.put '/api/cmpdRegAdmin/:entityType/edit/:id', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.editCmpdRegEntity
	app.delete '/api/cmpdRegAdmin/:entityType/:id', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.deleteCmpdRegEntity
	app.post '/api/cmpdRegAdmin/lotServices/reparent/lot', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.reparentLot
	app.post '/api/cmpdRegAdmin/lotServices/reparent/lot/jsonArray', loginRoutes.ensureAuthenticated, loginRoutes.ensureCmpdRegAdmin, exports.reparentLots

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
	# consolidate x-www-form-urlencoded from UI and JSON from API requests
	if !req.body.data?
		data = req.body
	else
		data = req.body.data
	if typeof(data) == 'string'
		data = JSON.parse(data)
	request(
		method: 'POST'
		url: cmpdRegCall
		body: data
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

exports.getSDFCmpdRegEntities = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/sdf" 
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
			console.log "got ajax error trying to do export sdf of #{entityType}"
			console.log json
			resp.end JSON.stringify {error: "got ajax error trying to do export sdf of #{entityType}"}
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
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/?dryrun=" + req.query.dryrun
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

exports.editCmpdRegEntity = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	entityType = req.params.entityType
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "#{entityType}/edit/" + req.params.id + "/?dryrun=" + req.query.dryrun
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
			console.log "got ajax error trying to edit #{entityType}"
			resp.statusCode = 500
			resp.end JSON.stringify(response)
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
		if response.statusCode == 409
			console.log "Conflict! something is preventing CmpdRegEntity to be removed."
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.json json
		else
			resp.statusCode = 404
			console.log "got ajax error trying to delete #{entityType}"
			console.log json
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.reparentLot = (req, resp) ->
	console.log 'in reparent lot'
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegRoutes = require './CmpdRegRoutes.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/reparentLot'
	console.log cmpdRegCall
	req.body.modifiedBy = req.session.passport.user.username

	if req.query.dryRun == 'true'
		dryRun = true
		cmpdRegCall += '?dryRun=true'
	else
		dryRun = false
		cmpdRegCall += '?dryRun=false'
	
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		console.log response.statusCode
		if !error && response.statusCode == 200
			if json?.newLot?
				# Fetch the new lot dependencies and attach it to the json
				# We don't want to include the analysis group values in the dependencies because this could be a lot of data and be slow
				includeAnalysisGroupValues = false
				if dryRun
					console.log "Dry run is true, returning dependencies for original lot corp name #{json.originalLotCorpName}"
					dependencies = await cmpdRegRoutes.getLotDependenciesByCorpNameInternal(json.originalLotCorpName, req.session.passport.user, null, true, includeAnalysisGroupValues)
				else
					console.log "Dry run is false, returning dependencies for new lot corp name #{json.newLot}"
					dependencies = await cmpdRegRoutes.getLotDependenciesInternal(json.newLot, req.session.passport.user, null, true, includeAnalysisGroupValues)

				json.dependencies = dependencies
			resp.json json
		else
			if response.statusCode == 409
			# This is a conflict error meaning that the attempt at saving the lot failed because of a lot corp name conflict
				resp.statusCode = 409
				resp.send json
			else
				console.log 'got ajax error trying to reparent lot'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end "Error trying to reparent lot: " + error;
	)

exports.reparentLots = (req, resp) ->
	console.log 'in reparent lot'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/reparentLot/jsonArray'
	console.log cmpdRegCall

	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error || response.statusCode != 200
			resp.json json
		else
			if response.statusCode == 409
			# This is a conflict error meaning that the attempt at saving the lot failed because of a lot corp name conflict
				resp.statusCode = 409
				resp.text =  json
			else
				console.log 'got ajax error trying to reparent lot array'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end "Error trying to reparent lot array: " + error;
	)
