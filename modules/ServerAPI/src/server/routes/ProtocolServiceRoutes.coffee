exports.setupAPIRoutes = (app) ->
	app.get '/api/protocols/codename/:code', exports.protocolByCodename
	app.get '/api/protocols/:id', exports.protocolById
	app.post '/api/protocols', exports.postProtocol
	app.put '/api/protocols/:id', exports.putProtocol
	app.get '/api/protocollabels', exports.lsLabels
	app.get '/api/protocolCodes', exports.protocolCodeList
	app.get '/api/protocolKindCodes', exports.protocolKindCodeList
	app.get '/api/protocols/genericSearch/:searchTerm', exports.genericProtocolSearch
	app.delete '/api/protocols/browser/:id', exports.deleteProtocol


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/protocols/codename/:code', loginRoutes.ensureAuthenticated, exports.protocolByCodename
	app.get '/api/protocols/:id', loginRoutes.ensureAuthenticated, exports.protocolById
	app.post '/api/protocols', loginRoutes.ensureAuthenticated, exports.postProtocol
	app.put '/api/protocols/:id', loginRoutes.ensureAuthenticated, exports.putProtocol
	app.get '/api/protocollabels', loginRoutes.ensureAuthenticated, exports.lsLabels
	app.get '/api/protocolCodes', loginRoutes.ensureAuthenticated, exports.protocolCodeList
	app.get '/api/protocolKindCodes', loginRoutes.ensureAuthenticated, exports.protocolKindCodeList
	app.get '/api/protocols/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericProtocolSearch
	app.delete '/api/protocols/browser/:id', loginRoutes.ensureAuthenticated, exports.deleteProtocol

serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'

exports.protocolByCodename = (req, resp) ->

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		stubSavedProtocol = JSON.parse(JSON.stringify(protocolServiceTestJSON.stubSavedProtocol))
		if req.params.code.indexOf("screening") > -1
			stubSavedProtocol.lsKind = "Bio Activity"
		else
			stubSavedProtocol.lsKind = "default"
		resp.end JSON.stringify stubSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/codename/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.protocolById = (req, resp) ->

	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		resp.end JSON.stringify protocolServiceTestJSON.fullSavedProtocol
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

updateProt = (prot, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serverUtilityFunctions.createLSTransaction prot.recordedDate, "updated protocol", (transaction) ->
		prot = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, prot
		if testMode or global.specRunnerTestmode
			callback prot
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"protocols/"+prot.id
			request = require 'request'
			request(
				method: 'PUT'
				url: baseurl
				body: prot
				json: true
			, (error, response, json) =>
				if response.statusCode == 409
					console.log 'got ajax error trying to update protocol - not unique name'
					if response.body[0].message is "not unique protocol name"
						callback JSON.stringify response.body[0].message
				else if !error && response.statusCode == 200
					callback json
				else
					console.log 'got ajax error trying to update protocol'
					console.log error
					console.log response
					callback JSON.stringify "saveFailed"
			)

postProtocol = (req, resp) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	protToSave = req.body
	serverUtilityFunctions.createLSTransaction protToSave.recordedDate, "new protocol", (transaction) ->
		protToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, protToSave
		if req.query.testMode or global.specRunnerTestmode
			unless protToSave.codeName?
				protToSave.codeName = "PROT-00000001"

		checkFilesAndUpdate = (prot) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity prot, false
			filesToSave = fileVals.length

			completeProtUpdate = (protToUpdate)->
				updateProt protToUpdate, req.query.testMode, (updatedProt) ->
					resp.json updatedProt

			fileSaveCompleted = (passed) ->
				if !passed
					resp.statusCode = 500
					return resp.end "file move failed"
				if --filesToSave == 0 then completeProtUpdate(prot)

			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode prot.codeName
				for fv in fileVals
					csUtilities.relocateEntityFile fv, prefix, prot.codeName, fileSaveCompleted
			else
				resp.json prot

		if req.query.testMode or global.specRunnerTestmode
			unless protToSave.id?
				protToSave.id = 1
			checkFilesAndUpdate protToSave
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"protocols"
			request = require 'request'
			request(
				method: 'POST'
				url: baseurl
				body: protToSave
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 201
					checkFilesAndUpdate json
				else
					console.log 'got ajax error trying to save new protocol'
					console.log error
#					console.log json
#					console.log response
					console.log response.statusCode
					console.log response
					if response.body[0].message is "not unique protocol name"
						resp.end JSON.stringify response.body[0].message
					else
						resp.end JSON.stringify "saveFailed"
			)


exports.postProtocol = (req, resp) ->
	postProtocol req, resp

exports.putProtocol = (req, resp) ->
	protToSave = req.body
	fileVals = serverUtilityFunctions.getFileValuesFromEntity protToSave, true
	filesToSave = fileVals.length

	completeProtUpdate = ->
		updateProt protToSave, req.query.testMode, (updatedProt) ->
			resp.json updatedProt

	fileSaveCompleted = (passed) ->
		if !passed
			resp.statusCode = 500
			return resp.end "file move failed"
		if --filesToSave == 0 then completeProtUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromEntityCode req.body.codeName
		for fv in fileVals
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, req.body.codeName, fileSaveCompleted
	else
		completeProtUpdate()

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
				if label.protocol.lsKind == "default"
					match = label.protocol.lsKind.indexOf(filterString) > -1
				else
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

exports.genericProtocolSearch = (req, res) ->
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		if req.params.searchTerm == "no-match"
			emptyResponse = []
			res.end JSON.stringify emptyResponse
		else
			res.end JSON.stringify [protocolServiceTestJSON.fullSavedProtocol, protocolServiceTestJSON.fullDeletedProtocol]
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"protocols/search?q="+req.params.searchTerm
		console.log "baseurl"
		console.log baseurl
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, res)

exports.deleteProtocol = (req, res) ->
	if global.specRunnerTestmode
		protocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js'
		deletedProtocol = JSON.parse(JSON.stringify(protocolServiceTestJSON.fullDeletedProtocol))
		res.end JSON.stringify deletedProtocol
	else
		config = require '../conf/compiled/conf.js'
		protocolID = req.params.id
		baseurl = config.all.client.service.persistence.fullpath+"protocols/browser/"+protocolID
		console.log "baseurl"
		console.log baseurl
		request = require 'request'

		request(
			method: 'DELETE'
			url: baseurl
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error && response.statusCode == 200
				console.log JSON.stringify json
				res.end JSON.stringify json
			else
				console.log 'got ajax error trying to delete protocol'
				console.log error
				console.log response
		)
