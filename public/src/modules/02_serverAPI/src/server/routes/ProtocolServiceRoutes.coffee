### To install this Module
1) Add these lines to app.coffee:
	protocolRoutes = require './public/src/modules/02_serverAPI/src/server/routes/ProtocolServiceRoutes.js'
	protocolRoutes.setupRoutes(app)


###
exports.setupRoutes = (app) ->
	app.get '/api/protocols/codename/:code', exports.protocolByCodename
	app.get '/api/protocols/:id', exports.protocolById
	app.post '/api/protocols', exports.postProtocol
	app.put '/api/protocols', exports.putProtocol
	app.get '/api/protocollabels', exports.lsLabels
	app.get '/api/protocolCodes', exports.protocolCodeList
	app.get '/api/protocolCodes/filter/:str', exports.protocolCodeList

exports.protocolByCodename = (req, resp) ->
	console.log req.params.code

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../../../spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.stubSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/codename/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.protocolById = (req, resp) ->
	console.log req.params.id

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../../..//spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.fullSavedProtocol
	else
		config = require '../../../../../../../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postProtocol = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../../../spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullSavedProtocol
	else
		config = require '../../../../../../../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log json
				console.log response
		)

exports.putProtocol = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../../../spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullSavedProtocol
	else
		config = require '../../../../../../../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols"
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log json
				console.log response
		)

exports.lsLabels = (req, resp) ->
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../../../spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.lsLabels
	else
		config = require '../../../../../../../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocollabels"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.protocolCodeList = (req, resp) ->
	console.log req.params
	if req.params.str?
		shouldFilter = true
		filterString = req.params.str.toUpperCase()
	else
		shouldFilter = false

	translateToCodes = (labels) ->
		protCodes = []
		for label in labels
			if shouldFilter
				match = label.labelText.toUpperCase().indexOf(filterString) > -1
			else
				match = true
			if !label.ignored and !label.protocol.ignored and label.lsType=="name" and match
				protCodes.push
					code: label.protocol.codeName
					name: label.labelText
					ignored: label.ignored
		protCodes

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../../../spec/testFixtures/ProtocolServiceTestJSON.js'
		labels = protocolServiceTestJSON.lsLabels
		resp.json translateToCodes(labels)

	else
		config = require '../../../../../../../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocollabels/codetable"
		if shouldFilter
			baseurl += "/?protocolName="+filterString
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to get protocol labels'
				console.log error
				console.log json
				console.log response
		)



