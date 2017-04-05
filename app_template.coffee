global.logger = require "./routes/Logger"
require './src/javascripts/Logging/ConsoleLogWinstonOverride'
csUtilities = require "./src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js"
systemTest = require "./routes/SystemTestRoutes.js"

startApp = ->
# Regular system startup
	config = require './conf/compiled/conf.js'
	express = require 'express'
	user = require './routes/user'
	http = require 'http'
	path = require 'path'

	favicon = require('serve-favicon')
	logger = require('morgan')
	methodOverride = require('method-override')
	session = require('express-session')
	bodyParser = require('body-parser')
	multer = require('multer')
	errorHandler = require('errorhandler')
	cookieParser = require('cookie-parser')

	# Added for logging support
	flash = require 'connect-flash'
	passport = require 'passport'
	util = require 'util'
	LocalStrategy = require('passport-local').Strategy
	global.deployMode = config.all.client.deployMode

	console.log "log level set to '#{console.level}'"
	global.stubsMode = false
	testModeOverRide = process.argv[2]
	unless typeof testModeOverRide == "undefined"
		if testModeOverRide == "stubsMode"
			global.stubsMode = true
			console.log "############ Starting in stubs mode"

	# login setup
	passport.serializeUser (user, done) ->
		#make sure to save only required attributes and not the password
		if user.codeName? then uCodeName=user.codeName else uCodeName=null
		userToSerialize =
			id: user.id
			username: user.username
			email: user.email
			firstName: user.firstName
			lastName: user.lastName
			roles: user.roles
			codeName: uCodeName
		done null, userToSerialize

	passport.deserializeUser (user, done) ->
		done null, user

	passport.use new LocalStrategy csUtilities.loginStrategy
#	passport.isAdmin = (req, resp, next) ->
#		if req.isAuthenticated() and csUtilities.isUserAdmin(req.user)
#			next()
#		else
#			next new handler.NotAuthorizedError "Sorry, you don't have the right!"
#	passport.isAuthenticated = (req, resp, next) ->
#		console.log "running passort.isAuthenticated"
#		unless req.isAuthenticated()
#			next new handler.NotAuthorizedError "Sorry, you don't have the right!"
#		else
#			next()

	loginRoutes = require './routes/loginRoutes'

	global.app = express()
	app.set 'port', config.all.client.port
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	# app.use favicon(path.join(__dirname, '/public/favicon.ico'))
	app.use logger('dev')
	app.use methodOverride()

	# added for login support
	app.use cookieParser()
	app.use session
		secret: 'acas needs login'
		resave: true
		saveUninitialized: true
		cookie: maxAge: 365 * 24 * 60 * 60 * 1000
	app.use flash()
	app.use passport.initialize()
	app.use passport.session pauseStream:  true
#		app.use express.bodyParser()
	app.use(bodyParser.json({limit: '100mb'}))
	app.use(bodyParser.urlencoded({limit: '100mb', extended: true,parameterLimit: 1000000}))
	app.use(multer())
	app.use(express.static(path.join(__dirname, 'public')))

	loginRoutes.setupRoutes(app, passport)

	# index routes
	indexRoutes = require './routes/index.js'
	indexRoutes.setupRoutes(app, loginRoutes)
	###TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES###

	if not config.all.client.use.ssl
		http.createServer(app).listen(app.get('port'), ->
			console.log("Express server listening on port " + app.get('port'))
		)
	else
		console.log "------ Starting in SSL Mode"
		https = require('https')
		fs = require('fs')
		sslOptions =
			key: fs.readFileSync config.all.server.ssl.key.file.path
			cert: fs.readFileSync config.all.server.ssl.cert.file.path
			ca: fs.readFileSync config.all.server.ssl.cert.authority.file.path
			passphrase: config.all.server.ssl.cert.passphrase
		https.createServer(sslOptions, app).listen(app.get('port'), ->
			console.log("Express server listening on port " + app.get('port'))
		)
		#TODO hack to prevent bug: https://github.com/mikeal/request/issues/418
		process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

	options = if stubsMode then ["stubsMode"] else []
	options.push ['--color']
	forever = require("forever-monitor")
	child = new (forever.Monitor)("app_api.js",
		max: 3
		silent: false
		args: options
	)

	child.on "exit", ->
		console.log "app_api.js has exited after 3 restarts"

	child.start()

	child.on 'exit:code', (code) ->
		console.log 'stopping child process with code '
		process.exit 0
		return
	process.once 'SIGTERM', ->
		child.stop 0
		return
	process.once 'SIGINT', ->
		child.stop 0
		return
	process.once 'exit', ->
		console.log 'clean exit of app'
		return
	process.on 'uncaughtException', (err) ->
		console.error 'Caught exception: ' + err.stack
		return

	csUtilities.logUsage("ACAS Node server started", "started", "")

	if config.all.server.systemTest?.runOnStart? && config.all.server.systemTest.runOnStart
		systemTest.runSystemTestInternal false, (status, output) ->
			console.log "system test completed"

startApp()
