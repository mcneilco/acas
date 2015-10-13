exports.setupAPIRoutes = (app) ->
	app.post '/api/cronScriptRunner', exports.postCronScriptRunner
	app.get '/api/cronScriptRunner/:code', exports.getCronScriptRunner
	app.put '/api/cronScriptRunner/:code', exports.putCronScriptRunner
	console.log "about to declare global in setup"
	global.cronJobs = {}
	console.log "just declared global in setup"
	addJobsOnStartup()

exports.setupRoutes = (app, loginRoutes) ->
	#no public routes, and none can be added, they won't work since global is in context of api server

# Must call through services. Direct function calls won't work because we have to keep global cron hash

config = require '../conf/compiled/conf.js'
request = require 'request'

addJobsOnStartup = ->
	cronConfig = require '../public/javascripts/conf/StartupCronJobsConfJSON.js'

	#We don't want to save these to the database, so make our own special cronCodes and launch
	codeInt = 1
	for spec in cronConfig.jobsToStart
		newCode = "CONF_CRON" + codeInt++

		newCron =
			spec: spec
		newCron.spec.cronCode = newCode
		newCron.spec.numberOfExcutions = 0
		newCron.spec.ignored = false

		global.cronJobs[newCode] = newCron

		if newCron.spec.active
			setupNewCron newCron


exports.postCronScriptRunner = (req, resp) ->
	validation = validateSpec(JSON.parse(JSON.stringify(req.body)))
	if !validation.valid
		console.log validation
		resp.send JSON.stringify(validation.messages), 500
		return

	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		cronScriptRunnerTestJSON = require '../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js'
		resp.json cronScriptRunnerTestJSON.savedCronEntry
	else
		unsavedReq = req.body
		persistenceURL = config.all.client.service.persistence.fullpath + "cronjobs"
		if not unsavedReq.numberOfExecutions
			unsavedReq.numberOfExecutions = 0
		request.post
			url: persistenceURL
			json: true
			body: unsavedReq
		, (error, response, body) =>
			@serverError = error
			@responseJSON = body
			@serverResponse = response
			if not error and response.statusCode < 400 and body.codeName?
				newCron = spec: body
				newCode = body.codeName

				global.cronJobs[newCode] = newCron

				if newCron.spec.active
					setupNewCron newCron

				resp.json newCron.spec
			else
				resp.statusCode = 500
				resp.end response.body

exports.putCronScriptRunner = (req, resp) ->
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		cronScriptRunnerTestJSON = require '../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js'
		if req.params.code.indexOf('error') > -1
			resp.send "cronCode #{code} not found", 404
			return
		respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry))
		respCron.cronCode = req.params.code
		if req.body.active? then respCron.active = req.body.active
		if req.body.ignored? then respCron.ignored = req.body.ignored
		resp.json respCron
		return
	else
		code = req.params.code
		cronJob = global.cronJobs[code]
		unless cronJob?
			resp.send "cronCode #{code} not found", 404
			return

		updateCronScriptRunner code, req.body, (err, response) ->
			if err
				resp.send 500, err
			else
				resp.json response



exports.getCronScriptRunner = (req, resp) ->
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		cronScriptRunnerTestJSON = require '../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js'
		respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry))
		respCron.lastStartTime = 1234
		respCron.lastDuration = 42
		respCron.lastResultJSON = '{"someKey": "someValue", "hasError": false}'
		respCron.numberOfExcutions = 1
		resp.json respCron
		return
	else
		code = req.params.code
		cronJob = global.cronJobs[code]
		resp.json cronJob.spec

updateCronScriptRunner = (code, newSpec, callback) ->
	cronJob = global.cronJobs[code]
	unless cronJob?
		callback "cronCode #{code} not found"
		return

	#Update supplied attributes
	for key, value of newSpec
#		console.log key + ": "+value
		cronJob.spec[key] = value
	#no matter what, stop job. Who knows what changes we got?
	if cronJob.job?
		cronJob.job.stop()
		delete cronJob.job
	persistenceURL = config.all.client.service.persistence.fullpath + "cronjobs/"
	request.put
		url: persistenceURL + code
		json: true
		body: cronJob.spec
	, (error, response, body) =>
		if not error and response.statusCode < 400 and body.codeName?
			cronJob.spec = body
			if not cronJob.spec.ignored and cronJob.spec.active? and cronJob.spec.active
				setupNewCron cronJob
			callback null, cronJob.spec
		else
			callback "Failed put request to server: " + body

setupNewCron = (cron) ->
	CronJob = require('cron').CronJob
	cron.job = new CronJob
		cronTime: cron.spec.schedule
		start: true
		onTick: ->
			launchRScript cron.spec

launchRScript = (spec) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	jobStart = new Date()
	console.log 'started r script'
	serverUtilityFunctions.runRFunctionOutsideRequest spec.user, JSON.parse(spec.scriptJSONData), spec.scriptFile, spec.functionName, (rReturn) ->
		console.log 'finished r script'
		duration = new Date() - jobStart
		scriptComplete spec.codeName, jobStart.getTime(), duration, rReturn

scriptComplete = (codeName, startTime, duration, resultJSON) ->
	cronJob = global.cronJobs[codeName]
	if cronJob? and cronJob.spec?
		cronJob.spec.lastStartTime = startTime
		cronJob.spec.lastDuration = duration
		cronJob.spec.lastResultJSON = resultJSON
		if cronJob.spec.numberOfExecutions?
			cronJob.spec.numberOfExecutions++
		else
			cronJob.spec.numberOfExecutions = 1
		updateCronScriptRunner codeName, cronJob.spec, (err, res) ->
			if err
				console.log 'unable to update job in database in scriptComplete: ' + err


validateSpec = (spec) ->
	valid = true
	messages = []

	if !spec.schedule?
		valid = false
		messages.push {attribute: "schedule", level: "error", message: "schedule must be supplied"}
	if !spec.scriptType?
		valid = false
		messages.push {attribute: "scriptType", level: "error", message: "scriptType must be supplied"}
	if spec.scriptType?
		if spec.scriptType != "R"
			valid = false
			messages.push {attribute: "scriptType", level: "error", message: "Only scriptType supported is R"}
	if !spec.scriptFile?
		valid = false
		messages.push {attribute: "scriptFile", level: "error", message: "scriptFile must be supplied"}
	if !spec.functionName?
		valid = false
		messages.push {attribute: "functionName", level: "error", message: "functionName must be supplied"}
	if !spec.scriptJSONData?
		valid = false
		messages.push {attribute: "scriptJSONData", level: "error", message: "scriptJSONData must be supplied"}
	if !spec.active?
		valid = false
		messages.push {attribute: "active", level: "error", message: "active must be supplied"}

	return {valid: valid, messages: messages}