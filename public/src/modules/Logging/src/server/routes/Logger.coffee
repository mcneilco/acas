config = require('../conf/compiled/conf.js')
winston = require('winston');
require('winston-mongodb').MongoDB;

exports.setupRoutes = (app) ->
	return true

if true
	db = require("mongojs").connect(config.all.logging.database, ["logs"])
	db.createCollection("logs")
winstonLoggingOptions = {db: config.all.logging.database}
winston.add(winston.transports.MongoDB, winstonLoggingOptions)

exports.writeToLog = (logLevel, application, action, data, user, transactionId) ->
	if user is null or user is ""
		user = "acas_system"
	winston.log(logLevel,  {sourceApp: application, action: action, data: data, user: user, transactionId: transactionId})

exports.getUsers = (callback) ->
	db = require("mongojs").connect(config.all.logging.database, ["logs"])
	response = []
	db.logs.distinct( 'meta.user', (err, sources) ->
		sources.forEach (source) ->
			response.push({value: source})
		callback response
	)

exports.getApplicationSources = (callback) ->
	db = require("mongojs").connect(config.all.logging.database, ["logs"])
	response = []
	db.logs.distinct( 'meta.sourceApp', (err, sources) ->
		sources.forEach (source) ->
			response.push({value: source})
		callback response
	)

exports.queryLogs = (queryPredicate, callback) ->
	console.log "queryLogs"
	console.dir queryPredicate
	db = require("mongojs").connect(config.all.logging.database, ["logs"])

	db.logs.find(queryPredicate, (err, logs) ->
		callback logs
	)

exports.getAllLogStatementsBetweenTimeStamps = (start, end, callback) ->
	console.log "start: " + start
	console.log "end: " + end
	start = new Date(parseInt(start))
	end = new Date(parseInt(end))
	console.log "start: " + start
	console.log "end: " + end
	db = require("mongojs").connect(config.all.logging.database, ["logs"])
	db.logs.find({timestamp: {$gte: start, $lt: end}}, (err, logs) ->
		callback logs
	)

exports.getAllLogStatementsBeforeTimeStamp = (timestamp, callback) ->
	timestamp = new Date(parseInt(timestamp))
	db = require("mongojs").connect(config.all.logging.database, ["logs"])
	db.logs.find({timestamp: {$lte: timestamp}}, (err, logs) ->
		callback logs
	)

exports.getAllLogStatementsAfterTimeStamp = (timestamp, callback) ->
	timestamp = new Date(parseInt(timestamp))
	db = require("mongojs").connect(config.all.logging.database, ["logs"])
	db.logs.find({timestamp: {$gte: timestamp}}, (err, logs) ->
		callback logs
	)