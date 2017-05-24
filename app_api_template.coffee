global.logger = require "./routes/Logger"
require './src/javascripts/Logging/ConsoleLogWinstonOverride'
csUtilities = require "./src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js"

startApp = ->
# Regular system startup
	config = require './conf/compiled/conf.js'
	express = require 'express'
	user = require './routes/user'
	http = require 'http'
	path = require 'path'

	# Added for logging support
	global.deployMode = config.all.client.deployMode

	global.stubsMode = false
	testModeOverRide = process.argv[2]
	unless typeof testModeOverRide == "undefined"
		if testModeOverRide == "stubsMode"
			global.stubsMode = true
			global.specRunnerTestmode = true
			console.log "############ Starting API in stubs mode"

	global.app = express()
	app.configure ->
		app.set 'port', config.all.server.nodeapi.port
		app.set 'views', __dirname + '/views'
		app.set 'view engine', 'jade'
		app.use express.favicon()
		app.use express.logger('dev')
		app.use express.json()
		app.use express.urlencoded()
		app.use express.methodOverride()
		app.use express.static path.join(__dirname, 'public')
		# It's important to start the router after everything else is configured
		app.use app.router

	#We just need the get user service
	loginRoutes = require './routes/loginRoutes'
	loginRoutes.setupAPIRoutes(app)
	indexRoutes = require('./routes/index.js');
	indexRoutes.setupAPIRoutes(app);

	process.on 'uncaughtException', (err) ->
		console.error 'Caught api exception: ' + err.stack
		return


	httpServer = http.createServer(app).listen(app.get('port'), ->
		console.log("ACAS API server listening on port " + app.get('port'))
	)
	io = require('socket.io')(httpServer)
	###TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES###

	csUtilities.logUsage("ACAS API server started", "started", "")

startApp()
