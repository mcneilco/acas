_ = require "underscore"

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
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues?format=codetable"
		request = require 'request'
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
	exports.getCodeTableValuesInternal req.params.type, req.params.kind, (result) ->
		resp.json result

exports.getCodeTableValuesInternal = (type, kind, cb) ->
	if global.specRunnerTestmode
		fullCodeTableJSON = require '../public/javascripts/spec/CodeTableJSON.js'
		correctCodeTable = _.findWhere(fullCodeTableJSON.codes, {type:type, kind:kind})
		cb correctCodeTable['codes']
	else
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/all/#{type}/#{kind}/codetable"
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				if json.length > 0 and !json[0].displayOrder? and json[0].name?
					json = json.sort (a, b) ->
						if a.name.toUpperCase() < b.name.toUpperCase()
							return -1
						if a.name.toUpperCase() > b.name.toUpperCase()
							return 1
						return 0
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
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/codetable"
		request = require 'request'
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
		config = require '../conf/compiled/conf.js'
		putId = codeTableEntry.id
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/codetable/#{putId}"

		request = require 'request'
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
	config = require '../conf/compiled/conf.js'
	console.log "#{config.all.client.service.persistence.fullpath}ddictvalues/#{codeTableEntry.id}"
	if global.specRunnerTestmode
		codeTablePostTestJSON = require '../public/javascripts/spec/Components/testFixtures/codeTablePostTestJSON.js'
		callback 201, JSON.stringify codeTablePostTestJSON.codeEntry
	else
		console.log "attempting to delete code table value"
		config = require '../conf/compiled/conf.js'
		baseurl = "#{config.all.client.service.persistence.fullpath}ddictvalues/#{codeTableEntry.id}"
		request = require 'request'
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



