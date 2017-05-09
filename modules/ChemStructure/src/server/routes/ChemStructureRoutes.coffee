exports.setupAPIRoutes = (app) ->
	app.get '/api/chemStructure/renderStructureByThingCode', exports.renderStructureByThingCode
	app.get '/api/chemStructure/codename/:structureCode', exports.getStructureByCode
	app.post '/api/chemStructure', exports.postStructure
	app.put '/api/chemStructure/:id', exports.putStructure
	app.post '/api/chemStructure/calculateMoleculeProperties', exports.calculateMoleculeProperties
	app.post '/api/chemStructure/renderMolStructure', exports.renderMolStructure



exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/chemStructure/renderStructureByThingCode', loginRoutes.ensureAuthenticated, exports.renderStructureByThingCode
	app.get '/api/chemStructure/codename/:structureCode', loginRoutes.ensureAuthenticated, exports.getStructureByCode
	app.post '/api/chemStructure', loginRoutes.ensureAuthenticated, exports.postStructure
	app.put '/api/chemStructure/:id', loginRoutes.ensureAuthenticated, exports.putStructure
	app.post '/api/chemStructure/calculateMoleculeProperties', loginRoutes.ensureAuthenticated, exports.calculateMoleculeProperties
	app.post '/api/chemStructure/renderMolStructure', loginRoutes.ensureAuthenticated, exports.renderMolStructure


_ = require 'underscore'

acasHome = '../../../..'
#reagentData = require "/home/runner/build/public/javascripts/spec/ReagentRegistration/testFixtures/ReagentRegistrationServiceTestJSON.js"


exports.renderStructureByThingCode = (req, resp) ->
	if global.specRunnerTestmode
		console.debug process.cwd()
	else
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}structure/renderStructureByLsThingCodeName"
		request = require 'request'
		queryParams = req._parsedUrl.query
		rooUrl = baseurl + '?' + queryParams
		console.log rooUrl
		req.pipe(request(rooUrl)).pipe(resp)

exports.getStructureByCode = (req, resp) ->
	if global.specRunnerTestmode
		console.debug process.cwd()
	else
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}structure/getByCodeName/"+req.params.structureCode
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to get structure by codename'
				console.error error
				console.error json
				console.error response
				resp.status(500).send "got ajax error"
		)

exports.putStructure = (req, resp) ->
	thing = req.body
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"structure/"+req.params.id
	request = require 'request'
	request(
		method: 'PUT'
		url: baseurl
		body: thing
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200 and json.codeName?
			resp.json json
		else
			console.log 'got ajax error trying to update lsThing'
			console.log error
			console.log response
			resp.statusCode = 500
			resp.end JSON.stringify "update lsThing failed"
	)

exports.postStructure = (req, resp) ->
	thingToSave = req.body
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"structure"
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: thingToSave
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 201
			resp.json json
		else
			console.log 'got ajax error trying to save lsThing'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end JSON.stringify "save lsThing failed"
	)

exports.calculateMoleculeProperties = (req, resp) ->
	if global.specRunnerTestmode
		resp.json {molStructure: req.body[0].molStructure}
	else
		molecule = req.body
		console.log "molecule to calculate props for"
		console.log molecule
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"structure/calculateMoleculeProperties"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: molecule
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to calculate molecule properties'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "calculate molecule properties failed"
		)

exports.renderMolStructure = (req, resp) ->
	if global.specRunnerTestmode
		resp.json {molStructure: req.body[0].molStructure, height: req.body[0].height, width: req.body[0].width, format: req.body[0].format}
	else
		molecule = req.body
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"structure/renderMolStructure"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: molecule
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to render molStructure'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "render molStructure failed"
		)
