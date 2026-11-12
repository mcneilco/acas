config = require('../conf/compiled/conf.js')
winston = require('winston');

exports.setupRoutes = (app) ->
	return true

# MongoDB logging (logging.usemongo) was removed; logs always go to the flat file served by /api/logFile
if config.all.logging.usemongo
	console.warn "logging.usemongo is no longer supported and is ignored; logging to the flat file acas.log"
winston.add(new winston.transports.File({ filename: 'acas.log', json: false } ))


exports.writeToLog = (logLevel, application, action, data, user, transactionId) ->
	if user is null or user is ""
		user = "acas_system"
	winston.log(logLevel,  {sourceApp: application, action: action, data: data, user: user, transactionId: transactionId})
