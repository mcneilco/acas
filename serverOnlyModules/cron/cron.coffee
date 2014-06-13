exports.startCron = ->
	config = require './../../conf/compiled/conf.js'
	serverUtilityFunctions = require '../../routes/ServerUtilityFunctions.js'
	CronJob = require("cron").CronJob

	if typeof config.all.server.cron != "undefined"
		if typeof config.all.server.cron.pingpong != "undefined"
			try
				new CronJob(config.all.server.cron.pingpong, ->
					console.log 'running ping pong cron'
					serverUtilityFunctions.runRScript('serverOnlyModules/PingPongTables/pingPong.R')
					return
				, # This function is executed when the job starts
					null, # This function is executed when the job stops
					true, # Start the job right now
					null  # Time zone of this job
				)
				console.log 'installed Ping Pong cron on schedule: ' + config.all.server.cron.pingpong
			catch ex
				console.log "Ping Pong cron pattern not valid"
		if typeof config.all.server.cron.summarystatistics != "undefined"
			try
				new CronJob(config.all.server.cron.summarystatistics, ->
					console.log 'running summary statistics cron'
					serverUtilityFunctions.runRScript('serverOnlyModules/SummaryStatistics/generateSummaryStatistics.R')
					return
				, # This function is executed when the job starts
					null, # This function is executed when the job stops
					true, # Start the job right now
					null  # Time zone of this job
				)
				console.log 'installed Summary Statistics cron on schedule: ' + config.all.server.cron.summarystatistics
			catch ex
				console.log "Summary Statistics cron pattern not valid"
