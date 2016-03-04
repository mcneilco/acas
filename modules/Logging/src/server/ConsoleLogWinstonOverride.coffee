util = require('util')
winston = require('winston')
logger = new (winston.Logger)

# Override the built-in console methods with winston hooks
formatArgs = (args) ->
	[ util.format.apply(util.format, Array::slice.call(args)) ]

logger.add winston.transports.Console,
	colorize: true
	timestamp: true
	level: 'debug'

console.log = ->
	logger.info.apply logger, formatArgs(arguments)
	return

console.info = ->
	logger.info.apply logger, formatArgs(arguments)
	return

console.warn = ->
	logger.warn.apply logger, formatArgs(arguments)
	return

console.error = ->
	logger.error.apply logger, formatArgs(arguments)
	return

console.debug = ->
	logger.debug.apply logger, formatArgs(arguments)
	return
