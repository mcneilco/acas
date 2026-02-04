_ = require "underscore"
config = require '../conf/compiled/conf.js'
serverUtilityFunctions = require './ServerUtilityFunctions.js'
request = serverUtilityFunctions.requestAdapter

exports.setupAPIRoutes = (app) ->
	app.get '/api/codetables/:type/:kind', exports.getCodeTableValues
	app.get '/api/codetables', exports.getAllCodeTableValues
	app.post '/api/codetables', exports.postCodeTable
	app.put '/api/codetables/:id', exports.putCodeTable

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/codetables/:type/:kind', loginRoutes.ensureAuthenticated, exports.getCodeTableValues
	app.get '/api/codetables', loginRoutes.ensureAuthenticated, exports.getAllCodeTableValues
	app.post '/api/codetables', loginRoutes.ensureAuthenticated, exports.postCodeTable
	app.put '/api/codetables/:id', loginRoutes.ensureAuthenticated, exports.putCodeTable



exports.getAllCodeTableValues = (req, resp) ->
	if global.specRunnerTestmode
		codeTableServiceTestJSON = require '../public/javascripts/spec/Components/testFixtures/codeTableServiceTestJSON.js'
		resp.end JSON.stringify codeTableServiceTestJSON['codes']
	else
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues?format=codetable"
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get all code table entries'
				console.log error
				console.log json
				console.log response
		)

exports.getCodeTableValues = (req, resp) ->
	exports.getCodeTableValuesInternal req.params.type, req.params.kind, req.query, (result) ->
		resp.json result

exports.getCodeTableValuesInternal = (type, kind, query, cb) ->
	if global.specRunnerTestmode
		fullCodeTableJSON = require '../public/javascripts/spec/CodeTableJSON.js'
		correctCodeTable = _.findWhere(fullCodeTableJSON.codes, {type:type, kind:kind})
		cb correctCodeTable['codes']
	else
		# For backwards compatibility, check if the query parameter is a function
		if typeof query == 'function'
			console.warn('Deprecation warning: Please provide the query parameter using the new parameter order. The old order will be removed in a future release.')
			cb = query
			query = null
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/all/#{type}/#{kind}/codetable"
		qs = {}
		if query?
			qs = query
		request(
			method: 'GET'
			url: baseurl
			qs: qs
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				cb json
			else
				console.log 'got ajax error trying to get code table entries'
				console.log error
				console.log json
				console.log response
		)


exports.postCodeTable = (req, resp) ->
	exports.postCodeTableInternal req.body.codeEntry, (statusCode, response) =>
		resp.end JSON.stringify response

exports.postCodeTableInternal = (codeTableEntry, callback) ->
	if global.specRunnerTestmode
		codeTablePostTestJSON = require '../public/javascripts/spec/Components/testFixtures/codeTablePostTestJSON.js'
		callback 201, JSON.stringify codeTablePostTestJSON.codeEntry
	else
		console.log "attempting to post new code table value"
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/codetable"
		request(
			method: 'POST'
			url: baseurl
			body: codeTableEntry
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				callback 201, JSON.stringify json
			else
				console.log 'got ajax error trying to save new code table'
				console.log error
				console.log json
				callback response.statusCode, response.json
		)

exports.putCodeTable = (req, resp) ->
	exports.putCodeTableInternal req.body.codeEntry, (statusCode, response) =>
		resp.end JSON.stringify response

exports.putCodeTableInternal = (codeTableEntry, callback) ->
	if global.specRunnerTestmode
		codeTablePostTestJSON = require '../public/javascripts/spec/Components/testFixtures/codeTablePutTestJSON.js'
		resp.end JSON.stringify codeTablePostTestJSON.codeEntry
	else
		putId = codeTableEntry.id
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/codetable/#{putId}"

		request(
			method: 'PUT'
			url: baseurl
			body: codeTableEntry
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error && response.statusCode == 200
				callback 200, JSON.stringify json
			else
				console.log 'got ajax error trying to update code table'
				console.log error
				console.log response
				callback response.statusCode, response.json
		)

exports.deleteCodeTable = (req, resp) ->
	exports.deleteCodeTableInternal req.body.codeEntry, (statusCode, response) =>
		resp.end JSON.stringify response

exports.deleteCodeTableInternal = (codeTableEntry, callback) ->
	console.log "#{config.all.client.service.persistence.fullpath}ddictvalues/#{codeTableEntry.id}"
	if global.specRunnerTestmode
		codeTablePostTestJSON = require '../public/javascripts/spec/Components/testFixtures/codeTablePostTestJSON.js'
		callback 201, JSON.stringify codeTablePostTestJSON.codeEntry
	else
		console.log "attempting to delete code table value"
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/#{codeTableEntry.id}"
		request(
			method: 'DELETE'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback 200, JSON.stringify json
			else
				console.log 'got ajax error trying to delete code table'
				console.log error
				console.log json
				callback response.statusCode, response.json
		)



