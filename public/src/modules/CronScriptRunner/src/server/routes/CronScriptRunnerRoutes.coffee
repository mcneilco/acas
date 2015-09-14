exports.setupAPIRoutes = (app) ->
	app.post '/api/cronScriptRunner', exports.postCronScriptRunner
	app.get '/api/cronScriptRunner/:code', exports.getCronScriptRunner
	app.put '/api/cronScriptRunner/:code', exports.putCronScriptRunner
	#TODO awful hack to increment, remove and replace with code from Roo persistance
	console.log "about to declare global in setup"
	global.cronCodeBaseNum = 1
	global.cronJobs = {}
	console.log "just declared global in setup"
	addJobsOnStartup()

exports.setupRoutes = (app, loginRoutes) ->
	#no public routes, and none can be added, they won't work since global is in context of api server

# Must call through services. Direct function calls won't work because we have to keep global cron hash

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
		#TODO real server save here this is a stub, make a copy
		newCode = "CRON" + global.cronCodeBaseNum++

		newCron =
			spec: JSON.parse(JSON.stringify(req.body))
		newCron.spec.cronCode = newCode
		newCron.spec.numberOfExcutions = 0
		newCron.spec.ignored = false

		global.cronJobs[newCode] = newCron

		if newCron.spec.active
			setupNewCron newCron

		resp.json newCron.spec

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
		#TODO put changes to persistence
		code = req.params.code
		cronJob = global.cronJobs[code]
		unless cronJob?
			resp.send "cronCode #{code} not found", 404
			return

		#Update supplied attributes
		for key, value of req.body
			console.log key + ": "+value
			cronJob.spec[key] = value
		#no matter what, stop job. Who knows what changes we got?
		if cronJob.job?
			cronJob.job.stop()
			delete cronJob.job
		if not cronJob.spec.ignored
			if cronJob.spec.active?
				if cronJob.spec.active
					setupNewCron cronJob

		resp.json cronJob.spec

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
	serverUtilityFunctions.runRFunctionOutsideRequest spec.user, JSON.parse(spec.scriptJSONData), spec.scriptFile, spec.functionName, (rReturn) ->
		duration = new Date() - jobStart
		scriptComplete spec.cronCode, jobStart.getTime(), duration, rReturn

scriptComplete = (cronCode, startTime, duration, resultJSON) ->
	console.log "cronCode: "+cronCode
	cronJob = global.cronJobs[cronCode]
	cronJob.spec.lastStartTime = startTime
	cronJob.spec.lastDuration = duration
	cronJob.spec.lastResultJSON = resultJSON
	if cronJob.spec.numberOfExcutions?
		cronJob.spec.numberOfExcutions++
	else
		cronJob.spec.numberOfExcutions = 1
#TODO put these changes to Roo


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