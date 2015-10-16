exports.setupRoutes = (app) ->
	app.get '/api/logger/', exports.getAllLogStatements
	app.get '/api/logger/:level/:application/:user', exports.getAllLogStatementOfLevel
	app.get '/api/logger/applicationSources', exports.getApplicationSources
	app.get '/api/logger/users', exports.getUsers
	app.get '/api/logger/query/afterTimeStamp/:timestamp', exports.getAllLogStatementsAfterTimeStamp
	app.get '/api/logger/query/beforeTimeStamp/:timestamp', exports.getAllLogStatementsBeforeTimeStamp
	app.get '/api/loggerQueryBetweenTimeStamps/:start/:end', exports.getAllLogStatementsBetweenTimeStamps
	app.get '/api/logFile', exports.getLogFlatFile

config = require('../conf/compiled/conf.js')


exports.getAllLogStatements = (req, res) ->
	global.logger.writeToLog("info", "Logging", "load data", "return all data from logging service", "", null)

	global.logger.queryLogs({}, (logs) ->
		res.send logs
	)

exports.getAllLogStatementsAfterTimeStamp = (req, res) ->
	timestamp = req.params.timestamp

	global.logger.getAllLogStatementsAfterTimeStamp(timestamp, (logs) ->
		res.send logs
	)

exports.getAllLogStatementsBeforeTimeStamp = (req, res) ->
	timestamp = req.params.timestamp

	global.logger.getAllLogStatementsBeforeTimeStamp(timestamp, (logs) ->
		res.send logs
	)

exports.getAllLogStatementsBetweenTimeStamps = (req, res) ->
	start = req.params.start
	end = req.params.end

	global.logger.getAllLogStatementsBetweenTimeStamps(start, end, (logs) ->
		res.send logs
	)

exports.getAllLogStatementOfLevel = (req, res) ->
	queryPredicate = {}
	unless req.params.level is "all"
		queryPredicate["meta.level"] = req.params.level
	unless req.params.application is "all"
		queryPredicate["meta.sourceApp"] = req.params.application
	unless req.params.user is "all"
		queryPredicate["meta.user"] = req.params.user

	global.logger.queryLogs(queryPredicate, (logs) ->
		res.send logs
	)

exports.getApplicationSources = (req, res) ->
	global.logger.getApplicationSources( (applications) ->
		res.send applications
	)

exports.getUsers = (req, res) ->
	global.logger.getUsers( (users) ->
		res.send users
	)

exports.getLogFlatFile = (req, res) ->
	fileSystem = require('fs')
	path = require('path')
	pathToLogFile = path.join(__dirname, "../acas.log");
	stat = fileSystem.statSync(pathToLogFile);
	res.writeHead(200, {
		'Content-Type': 'text/plain',
		'Content-Length': stat.size
	});

	readStream = fileSystem.createReadStream(pathToLogFile);
	readStream.pipe(res)
