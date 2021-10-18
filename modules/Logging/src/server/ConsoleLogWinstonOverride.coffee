path = require('path')
fs = require('fs-extra')
{ createLogger, format, transports, config: windstonconfig } = require('winston')
{ combine, timestamp, label, printf, colorize, errors } = format
packageJsonPath = path.join(process.cwd(), 'package.json')
packageObj = fs.readJsonSync(packageJsonPath)
name = packageObj.name || 'app'

ACAS_HOME="../../.."
config = require "#{ACAS_HOME}/conf/compiled/conf.js"

shouldWarn = false
if config.all.server.log?.level?
	logLevel = config.all.server.log.level.toLowerCase()
	allowedLevels = Object.keys(windstonconfig.syslog.levels)
	if logLevel not in allowedLevels
		shouldWarn = true
		warningMessage = "log level '#{logLevel}' not in #{"'"+allowedLevels.join("','")+"'"}, setting to 'info'"
		logLevel = "info"
else
	shouldWarn = true
	warningMessage = "server.log.level not set, setting to 'info'"
	logLevel = "info"

## Custom format of the logs
myFormat = printf((info) ->
  indent = undefined
  if process.env.ENVIRONMENT and process.env.ENVIRONMENT != 'production'
    indent = 2
  message = JSON.stringify(info.message, false, indent)
  return "[#{info.label}] #{info.timestamp} #{info.level}: #{message}"
)

## Custom logging handler
logger = createLogger({
  format: combine(errors({ stack: true }), colorize(), label({ label: name }), timestamp(), myFormat),
  transports: [new transports.Console()],
})
console.level = logLevel


console.log = (...args) => logger.info.call(logger, ...args);
console.info = (...args) => logger.info.call(logger, ...args);
console.warn = (...args) => logger.warn.call(logger, ...args);
if shouldWarn
	console.warn warningMessage
console.error = (...args) => logger.error.call(logger, ...args);
console.debug = (...args) => logger.debug.call(logger, ...args);