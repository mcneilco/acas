exports.setupAPIRoutes = (app) ->
	app.get '/cmpdReg/getStandardizationSettings', exports.getStandardizationSettings
	app.get '/cmpdReg/getStandardizationHistory', exports.getStandardizationHistory
	app.get '/cmpdReg/standardizationDryRun', exports.standardizationDryRun
	app.get '/cmpdReg/standardizationDryRunStats', loginRoutes.ensureAuthenticated, exports.getDryRunStats	
	app.get '/cmpdReg/standardizationExecute', exports.standardizationExecution

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdReg/getStandardizationSettings', loginRoutes.ensureAuthenticated, exports.getStandardizationSettings
	app.get '/cmpdReg/getStandardizationHistory', loginRoutes.ensureAuthenticated, exports.getStandardizationHistory
	app.get '/cmpdReg/standardizationDryRun', loginRoutes.ensureAuthenticated, exports.standardizationDryRun
	app.get '/cmpdReg/standardizationDryRunStats', loginRoutes.ensureAuthenticated, exports.getDryRunStats
	app.get '/cmpdReg/standardizationExecute', loginRoutes.ensureAuthenticated, exports.standardizationExecution

_ = require 'underscore'
request = require 'request'
config = require '../conf/compiled/conf.js'

global.standardizationSessions = []

exports.setupChannels = (io, sessionStore, loginRoutes) ->
	nsp = io.of('/standardizationController:connected')
	console.log "io standardizerController: connected"
	nsp.on 'connection', (socket) =>
		console.log "Opened new connection #{socket.id}"
		global.standardizationSessions.push socket.id

		socket.on 'disconnect', =>
			console.log 'got disconnected in standardization...'

		socket.on 'executeDryRunOrStandardization', (runType) =>
			console.log "got executeDryRunOrStandardization, #{runType} request"
			lockStandardizationSessions socket, runType
			if runType is 'dryRun'
				exports.standardizationDryRunInternal false, (standardizationDryRunInternalResp, statusCode) =>
					console.log "standardizationDryRunInternal returned, should emit unlockStandardizationSessions"
					unlockStandardizationSessions socket, runType, standardizationDryRunInternalResp
			else if runType is 'standardization'
				exports.standardizationExecutionInternal (standardizationExecutionInternalResp, statusCode) =>
					unlockStandardizationSessions socket, runType, standardizationExecutionInternalResp

lockStandardizationSessions = (socket, runType) ->
	for sessionSocketId in global.standardizationSessions
		socket.broadcast.to(sessionSocketId).emit 'dryRunOrStandardizationInProgress', runType
	socket.emit 'dryRunOrStandardizationInProgress', runType
	#broadcast doesn't emit for the socket

unlockStandardizationSessions = (socket, runType, report) ->
	for sessionSocketId in global.standardizationSessions
		socket.broadcast.to(sessionSocketId).emit 'dryRunOrStandardizationComplete', runType, report
	socket.emit 'dryRunOrStandardizationComplete', runType, report
	#broadcast doesn't emit for the socket

exports.getStandardizationSettings = (req, resp) ->
	req.setTimeout 86400000

	exports.getStandardizationSettingsInternal (getStandardizationSettingsResp, statusCode) =>
		if statusCode is 500
			resp.statusCode = statusCode
			resp.end getStandardizationSettingsResp
		else
			resp.json getStandardizationSettingsResp
	
exports.getStandardizationSettingsInternal = (callback) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/standardization/settings'
	console.log url
	request(
		method: 'GET'
		url: url
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback json, response.statusCode
		else
			console.log 'Error getting standardization settings'
			console.log error
			console.log json
			callback error, response.statusCode
	)

exports.getStandardizationHistory = (req, resp) ->
	req.setTimeout 86400000
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/standardization/history'
	console.log url
	request(
		method: 'GET'
		url: url
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			resp.json json
		else
			console.log 'Error getting standardization history'
			console.log error
			console.log json
			resp.statusCode = response.statusCode
			resp.end JSON.stringify error
	)

exports.standardizationDryRun = (req, resp) ->
	req.setTimeout 86400000
	reportOnly = false
	if req.query?.reportOnly?
		reportOnly = req.query.reportOnly
	
	exports.standardizationDryRunInternal reportOnly, (standardizationDryRunInternalResp, statusCode) =>
		if statusCode is 500
			resp.statusCode = statusCode
			resp.end standardizationDryRunInternalResp
		else
			resp.json standardizationDryRunInternalResp
			
	
exports.standardizationDryRunInternal = (reportOnly, callback) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/standardization/dryRun'
	url += "?reportOnly="+reportOnly
	console.log url
	request(
		method: 'GET'
		url: url
		json: true
		timeout: 86400000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log "success standardizationDryRunInternal"
			callback json, response.statusCode
		else
			console.log 'Error with standardization dry run'
			console.log error
			console.log json
			callback error, response.statusCode
	)

exports.getDryRunStats = (req, resp) ->
	req.setTimeout 86400000
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/standardization/dryRunStats'
	console.log url
	request(
		method: 'GET'
		url: url
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			resp.json json
		else
			console.log 'Error getting dry run stats'
			console.log error
			console.log json
			resp.statusCode = response.statusCode
			resp.end JSON.stringify error
	)

exports.standardizationExecution = (req, resp) ->
	req.setTimeout 86400000

	exports.standardizationExecutionInternal (standardizationExecutionInternalResp, statusCode) =>
		if statusCode is 500
			resp.statusCode = statusCode
			resp.end standardizationExecutionInternalResp
		else
			resp.json standardizationExecutionInternalResp

exports.standardizationExecutionInternal = (callback) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/standardization/execute'
	console.log url
	request(
		method: 'GET'
		url: url
		json: true
		timeout: 86400000
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback json, response.statusCode
		else
			console.log 'Error with standardization execution'
			console.log error
			console.log json
			callback error, response.statusCode
	)
