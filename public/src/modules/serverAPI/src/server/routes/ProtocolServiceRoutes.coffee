### To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
protocolRoutes = require './routes/ProtocolServiceRoutes.js'
app.get '/api/protocols/codename/:code', protocolRoutes.protocolByCodename
app.get '/api/protocols/:id', protocolRoutes.protocolById
app.post '/api/protocols', protocolRoutes.postProtocol
app.put '/api/protocols', protocolRoutes.putProtocol
app.get '/api/protocollabels', protocolRoutes.protocolLabels
app.get '/api/protocolCodeList', protocolRoutes.protocolCodeList
app.get '/api/protocolCodeList/:filter', protocolRoutes.protocolCodeList


###

exports.protocolByCodename = (req, resp) ->
	console.log req.params.code

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.stubSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/codename/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.protocolById = (req, resp) ->
	console.log req.params.id

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.fullSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postProtocol = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
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
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
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

exports.protocolLabels = (req, resp) ->
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.protocolLabels
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocollabels"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.protocolCodeList = (req, resp) ->
	console.log req.params
	if req.params.str?
		shouldFilter = true
		filterString = req.params.str
	else
		shouldFilter = false

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		labels = protocolServiceTestJSON.protocolLabels
		resp.json translateToCodes(labels)

	else
		config = require '../conf/compiled/conf.js'
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


