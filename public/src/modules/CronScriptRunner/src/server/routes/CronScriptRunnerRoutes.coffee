exports.setupAPIRoutes = (app) ->
	app.post '/api/cronScriptRunner', exports.postCronScriptRunner
	app.get '/api/cronScriptRunner/:code', exports.getCronScriptRunner
	app.put '/api/cronScriptRunner/:code', exports.putCronScriptRunner
	#TODO awful hack to increment
	console.log "about to declare global in setup"
	global.cronCodeBaseNum = 1
	console.log "just declared global in setup"

exports.setupRoutes = (app, loginRoutes) ->
	#no public routes, 00and none can be added, they won't work since global is in context of api server

global.cronJobs = {}

exports.postCronScriptRunner = (req, resp) ->
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		cronScriptRunnerTestJSON = require '../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js'
		resp.json cronScriptRunnerTestJSON.savedCronEntry
	else
		#TODO real server save here this is a stub, make a copy
		newCode = "CRON" + global.cronCodeBaseNum++

		newCron =
			spec: JSON.parse(JSON.stringify(req.body))
		newCron.spec.cronCode = newCode

		global.cronJobs[newCode] = newCron

		if newCron.spec.active
			setupNewCron newCron

		resp.json newCron.spec

exports.putCronScriptRunner = (req, resp) ->
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		cronScriptRunnerTestJSON = require '../public/javascripts/spec/testFixtures/CronScriptRunnerTestJSON.js'
		if req.params.code.indexOf('error') > -1
			resp.send "cronCode #{code} not found", 404
		respCron = JSON.parse(JSON.stringify(cronScriptRunnerTestJSON.savedCronEntry))
		respCron.cronCode = req.params.code
		if req.body.active? then respCron.active = req.body.active
		if req.body.ignored? then respCron.ignored = req.body.ignored
		resp.json respCron
	else
		#TODO put changes to persistence
		#TODO update cron in memory with changed input JSON, script name, etc
		code = req.params.code
		cronJob = global.cronJobs[code]
		unless cronJob?
			resp.send "cronCode #{code} not found", 404
		if req.body.active?
			if !req.body.active and cronJob.spec.active
				cronJob.job.stop()
			else if req.body.active and !cronJob.spec.active
				if cronJob.job?
					cronJob.job.start()
				else
					setupNewCron cronJob
			cronJob.spec.active = req.body.active
		if req.body.ignored?
			cronJob.spec.ignored = req.body.ignored
			if req.body.ignored
				if cronJob.job?
					cronJob.job.stop()
				delete global.cronJobs[code]
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
	cronJob = global.cronJobs[cronCode]
	cronJob.spec.lastStartTime = startTime
	cronJob.spec.lastDuration = duration
	cronJob.spec.lastResultJSON = resultJSON
	if cronJob.spec.numberOfExcutions?
		cronJob.spec.numberOfExcutions++
	else
		cronJob.spec.numberOfExcutions = 1
#TODO put these changes to Roo


