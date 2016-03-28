ACAS_HOME="../../.."
util = require('util')
winston = require('winston')
logger = new (winston.Logger)
config = require "#{ACAS_HOME}/conf/compiled/conf.js"

shouldWarn = false
warningMessage = ""

if config.all.server.log?.level?
	logLevel = config.all.server.log.level.toLowerCase()
	allowedLevels = Object.keys(winston.levels)
	if logLevel not in allowedLevels
		shouldWarn = true
		warningMessage = "log level '#{logLevel}' not in #{"'"+allowedLevels.join("','")+"'"}, setting to 'info'"
		logLevel = "info"
else
	shouldWarn = true
	warningMessage = "server.log.level not set, setting to 'info'"
	logLevel = "info"

# Override the built-in console methods with winston hooks
formatArgs = (args) ->
	[ util.format.apply(util.format, Array::slice.call(args)) ]

logger.add winston.transports.Console,
	colorize: true
	timestamp: true
	level: logLevel

console.level = logLevel

console.log = ->
	logger.info.apply logger, formatArgs(arguments)
	return

console.info = ->
	logger.info.apply logger, formatArgs(arguments)
	return

console.warn = ->
	logger.warn.apply logger, formatArgs(arguments)
	return

if shouldWarn
	console.warn warningMessage

console.error = ->
	logger.error.apply logger, formatArgs(arguments)
	return

console.debug = ->
	logger.debug.apply logger, formatArgs(arguments)
	return
