

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/protocols/codename/:code', loginRoutes.ensureAuthenticated, exports.protocolByCodename
	app.get '/api/protocols/:id', loginRoutes.ensureAuthenticated, exports.protocolById
	app.post '/api/protocols', loginRoutes.ensureAuthenticated, exports.postProtocol
	app.put '/api/protocols', loginRoutes.ensureAuthenticated, exports.putProtocol
	app.get '/api/protocollabels', loginRoutes.ensureAuthenticated, exports.lsLabels
	app.get '/api/protocolCodes', loginRoutes.ensureAuthenticated, exports.protocolCodeList
	app.get '/api/protocolKindCodes', loginRoutes.ensureAuthenticated, exports.protocolKindCodeList

exports.protocolByCodename = (req, resp) ->
	console.log req.params.code

	#TODO: figure out if service should return a full protocol or just a stub
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

exports.lsLabels = (req, resp) ->
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.lsLabels
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocollabels"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.protocolCodeList = (req, resp) ->
	if req.query.protocolName?
		shouldFilterByName = true
		filterString = req.query.protocolName.toUpperCase()
	else if req.query.protocolKind?
		shouldFilterByKind = true
		#filterString = req.query.protocolKind.toUpperCase()
		filterString = req.query.protocolKind
	else
		shouldFilterByName = false
		shouldFilterByKind = false

	translateToCodes = (labels) ->
		protCodes = []
		for label in labels
			if shouldFilterByName
				match = label.labelText.toUpperCase().indexOf(filterString) > -1
			else if shouldFilterByKind
				match = label.protocol.lsKind.toUpperCase().indexOf(filterString) > -1
			else
				match = true
			if !label.ignored and !label.protocol.ignored and label.lsType=="name" and match
				protCodes.push
					code: label.protocol.codeName
					name: label.labelText
					ignored: label.ignored
		protCodes

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		labels = protocolServiceTestJSON.lsLabels
		resp.json translateToCodes(labels)

	else
		config = require '../conf/compiled/conf.js'
		#baseurl = config.all.client.service.persistence.fullpath+"protocollabels/codetable"
		baseurl = config.all.client.service.persistence.fullpath+"protocols/codetable"

		if shouldFilterByName
			baseurl += "/?protocolName="+filterString
		else if shouldFilterByKind
			#baseurl += "/?protocolKind="+filterString
			baseurl += "?lskind="+filterString

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


exports.protocolKindCodeList = (req, resp) ->
	translateToCodes = (kinds) ->
		kindCodes = []
		for kind in kinds
				kindCodes.push
					code: kind.kindName
					name: kind.kindName
					ignored: false
		kindCodes

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.json translateToCodes(protocolServiceTestJSON.protocolKinds)
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocolkinds"
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json translateToCodes(json)
			else
				console.log 'got ajax error trying to get protocol labels'
				console.log error
				console.log json
				console.log response
		)
