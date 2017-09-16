exports.setupAPIRoutes = (app) ->
	app.get '/api/labelSequences', exports.getAllLabelSequences
	app.get '/api/labelSequences/reagents/codename', exports.getReagentByCodename

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/labelSequences', loginRoutes.ensureAuthenticated, exports.getAllLabelSequences
	app.get '/api/labelSequences/getAuthorizedLabelSequences', loginRoutes.ensureAuthenticated, exports.getAuthorizedLabelSequences
	app.get '/api/labelSequences/:id', loginRoutes.ensureAuthenticated, exports.getLabelSequenceById
	app.post '/api/labelSequences', loginRoutes.ensureAuthenticated, exports.saveLabelSequence
	app.post '/api/labelSequences/jsonArray', loginRoutes.ensureAuthenticated, exports.saveLabelSequenceArray
	app.put '/api/labelSequences/:id', loginRoutes.ensureAuthenticated, exports.updateLabelSequence
	app.put '/api/labelSequences/jsonArray', loginRoutes.ensureAuthenticated, exports.updateLabelSequenceArray
	app.delete '/api/labelSequences/:id', loginRoutes.ensureAuthenticated, exports.deleteLabelSequence
	app.get '/api/lsRoles/codeTable', loginRoutes.ensureAuthenticated, exports.getLsRoleCodeTables
	app.get '/api/labelTypeAndKinds/codeTable', loginRoutes.ensureAuthenticated, exports.getLabelTypeAndKindCodeTables
	app.get '/api/thingTypeAndKinds/codeTable', loginRoutes.ensureAuthenticated, exports.getThingTypeAndKindCodeTables

config = require '../conf/compiled/conf.js'
request = require 'request'
serverUtilityFunctions = require './ServerUtilityFunctions.js'
_ = require 'underscore'

exports.getAllLabelSequences = (req, resp) ->
	exports.getAllLabelSequencesInternal req, (statusCode, json) ->
		resp.json json

exports.getAllLabelSequencesInternal = (req, callback) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		callback labelSequenceTestJSON.labelSequenceArray
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences"
		if req.query?.thingTypeAndKind? and req.query?.labelTypeAndKind?
			baseurl += "?thingTypeAndKind=#{req.query.thingTypeAndKind}&labelTypeAndKind=#{req.query.labelTypeAndKind}"
		else if req.query?.thingTypeAndKind?
			baseurl += "?thingTypeAndKind=#{req.query.thingTypeAndKind}"
		else if req.query?.labelTypeAndKind?
			baseurl += "?labelTypeAndKind=#{req.query.labelTypeAndKind}"
		serverUtilityFunctions.getFromACASServerInternal(baseurl, callback)

exports.getAuthorizedLabelSequences = (req, resp) ->
	exports.getAuthorizedLabelSequencesInternal req, (statusCode, json) ->
		resp.json json

exports.getAuthorizedLabelSequencesInternal = (req, callback) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		callback labelSequenceTestJSON.labelSequenceArray
	else
		username = req.session.passport.user.username
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences/getAuthorizedLabelSequences?userName=#{username}"
		if req.query?.thingTypeAndKind?
			baseurl += "&thingTypeAndKind=#{req.query.thingTypeAndKind}"
		if req.query?.labelTypeAndKind?
			baseurl += "&labelTypeAndKind=#{req.query.labelTypeAndKind}"
		serverUtilityFunctions.getFromACASServerInternal(baseurl, callback)

exports.getLabelSequenceById = (req, resp) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		resp.json labelSequenceTestJSON.labelSequence
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences/#{req.params.id}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.saveLabelSequence = (req, resp) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		resp.json labelSequenceTestJSON.labelSequence
	else
		console.log req.body
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences"
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			console.log json
			if !error && response.statusCode == 201
				resp.json json
			else
				console.error 'got ajax error trying to save label sequence'
				resp.statusCode =  500
				resp.end "saveFailed"
		)

exports.saveLabelSequenceArray = (req, resp) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		resp.json labelSequenceTestJSON.labelSequenceArray
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences/jsonArray"
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				resp.json json
			else
				console.error 'got ajax error trying to save label sequence array'
				resp.end "saveFailed"
		)

exports.updateLabelSequence = (req, resp) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		resp.json labelSequenceTestJSON.labelSequence
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences"
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to update label sequence'
				resp.end "updateFailed"
		)

exports.updateLabelSequenceArray = (req, resp) ->
	if global.specRunnerTestmode
		labelSequenceTestJSON = require '../public/javascripts/spec/testFixtures/ACASLabelSequenceTestJSON.js'
		resp.json labelSequenceTestJSON.labelSequenceArray
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences/jsonArray"
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.error 'got ajax error trying to update label sequence array'
				resp.end "updateFailed"
		)

exports.deleteLabelSequence = (req, resp) ->
	if global.specRunnerTestmode
		resp.end 'stub delete complete'
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelsequences/#{req.params.id}"
		request(
			method: 'DELETE'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end 'delete successful'
			else
				console.error 'Unable to delete label sequence'
				resp.statusCode = 404
				resp.end "deleted failed"
		)

exports.getLsRoleCodeTables = (req, resp) ->
	if global.specRunnerTestmode
		resp.end 'TODO'
	else
		baseurl = config.all.client.service.persistence.fullpath+"lsRoles?format=codeTable"
		if req.query.lsType?
			baseurl += "&lsType=#{lsType}"
		if req.query.lsKind?
			baseurl += "&lsKind=#{lsKind}"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getLabelTypeAndKindCodeTables = (req, resp) ->
	if global.specRunnerTestmode
		resp.end 'TODO'
	else
		baseurl = config.all.client.service.persistence.fullpath+"labelkinds"
		request(
			url: baseurl
			json: true
		, (error, response, json) ->
			if !error && response.statusCode == 200
				codeTables = []
				_.each json, (kind) ->
					codeTable =
						id: kind.id
						code: kind.lsTypeAndKind
						name: kind.lsTypeAndKind
					codeTables.push codeTable
				resp.json codeTables
			else
				console.error 'error getting labelKinds'
				resp.statusCode = 404
				resp.end 'could not get labelKinds'
		)

exports.getThingTypeAndKindCodeTables = (req, resp) ->
	if global.specRunnerTestmode
		resp.end 'TODO'
	else
		baseurl = config.all.client.service.persistence.fullpath+"thingkinds"
		request(
			url: baseurl
			json: true
		, (error, response, json) ->
			if !error && response.statusCode == 200
				codeTables = []
				_.each json, (kind) ->
					codeTable =
						id: kind.id
						code: kind.lsTypeAndKind
						name: kind.lsTypeAndKind
					codeTables.push codeTable
				resp.json codeTables
			else
				console.error 'error getting thingKinds'
				resp.statusCode = 404
				resp.end 'could not get thingKinds'
		)