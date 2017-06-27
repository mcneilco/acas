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
	MemoryStore = express.session.MemoryStore;
	sessionStore = new MemoryStore();
	global.app = express()
	app.configure ->
		app.set 'port', config.all.client.port
		app.set 'views', __dirname + '/views'
		app.set 'view engine', 'jade'
		app.use express.favicon()
		app.use express.logger('dev')
		# added for login support
		app.use express.cookieParser()
		app.use express.session
			secret: 'acas needs login'
			cookie: maxAge: 365 * 24 * 60 * 60 * 1000
			store: sessionStore # MemoryStore is used automatically if no "store" field is set, but we need a handle on the sessionStore object for Socket.IO, so we'll manually create the store so we have a handle on the object
		app.use flash()
		app.use passport.initialize()
		app.use passport.session pauseStream:  true
#		app.use express.bodyParser()
		app.use express.json()
		app.use express.urlencoded()
		app.use express.methodOverride()
		app.use express.static path.join(__dirname, 'public')
		# It's important to start the router after everything else is configured
		app.use app.router

	loginRoutes.setupRoutes(app, passport)

	# index routes
	indexRoutes = require './routes/index.js'
	indexRoutes.setupRoutes(app, loginRoutes)


	if not config.all.client.use.ssl
		httpServer = http.createServer(app).listen(app.get('port'), ->
			console.log("ACAS API server listening on port " + app.get('port'))
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
		httpServer = https.createServer(sslOptions, app).listen(app.get('port'), ->
			console.log("Express server listening on port " + app.get('port'))
		)
		#TODO hack to prevent bug: https://github.com/mikeal/request/issues/418
		process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"
	io = require('socket.io')(httpServer)
	passportSocketIo = require('passport.socketio')
	cookieParser = require('cookie-parser')

	io.use(passportSocketIo.authorize({
		key: 'connect.sid',
		secret: 'acas needs login',
		store: sessionStore,
		passport: passport,
		cookieParser: cookieParser
	}))
	###TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES###

	options = if stubsMode then ["stubsMode"] else []
	options.push ['--color']
	forever = require("forever-monitor")
	child = new (forever.Monitor)("app_api.js",
		max: 3
		silent: false
		options: options
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
