csUtilities = require "./public/src/conf/CustomerSpecificServerFunctions.js"

startApp = ->
# Regular system startup
	config = require './conf/compiled/conf.js'
	express = require('express')
	user = require('./routes/user')
	http = require('http')
	path = require('path')

	# Added for logging support
	flash = require 'connect-flash'
	passport = require 'passport'
	util = require 'util'
	LocalStrategy = require('passport-local').Strategy
	global.deployMode = config.all.client.deployMode

	global.app = express()
	app.configure( ->
		app.set('port', config.all.client.port)
		app.set('views', __dirname + '/views')
		app.set('view engine', 'jade')
		app.use(express.favicon())
		app.use(express.logger('dev'))
		app.use(express.bodyParser())
		app.use(express.methodOverride())
		app.use(express.static(path.join(__dirname, 'public')))
	# added for login support
		app.use(express.cookieParser())
		app.use(express.session({ secret: 'acas needs login', cookie: { maxAge: 365 * 24 * 60 * 60 * 1000 } }, ))
		app.use(flash())
		app.use(passport.initialize())
		app.use(passport.session())
	# It's important to start the router after everything else is configured
		app.use(app.router)

	)
	#TODO Do we need these next three lines? What do they do?
	app.configure('development', ->
		app.use(express.errorHandler())
		console.log "node dev mode set"
	)

	# login routes
	passport.serializeUser (user, done) ->
		done null, user.username
	passport.deserializeUser (username, done) ->
		csUtilities.findByUsername username, (err, user) ->
			done err, user
	passport.use new LocalStrategy csUtilities.loginStrategy

	loginRoutes = require './public/src/modules/Login/src/server/routes/loginRoutes'
	loginRoutes.setupRoutes(app, passport)

	# index routes
	indexRoutes = require('./routes/index.js')
	indexRoutes.setupRoutes(app, loginRoutes)

	# serverAPI routes
	preferredBatchIdRoutes = require './public/src/modules/02_serverAPI/src/server/routes/PreferredBatchIdService.js'
	preferredBatchIdRoutes.setupRoutes(app)

	# ServerUtility function testing routes
	serverUtilityFunctions = require './public/src/modules/02_serverAPI/src/server/routes/ServerUtilityFunctions.js'
	serverUtilityFunctions.setupRoutes(app)

	protocolRoutes = require './public/src/modules/02_serverAPI/src/server/routes/ProtocolServiceRoutes.js'
	protocolRoutes.setupRoutes(app)

	experimentRoutes = require './public/src/modules/02_serverAPI/src/server/routes/ExperimentServiceRoutes.js'
	experimentRoutes.setupRoutes(app)

	#Components routes
	projectServiceRoutes = require './public/src/modules/01_Components/src/server/routes/ProjectServiceRoutes.js'
	projectServiceRoutes.setupRoutes(app)

	# DocForBatches routes
	docForBatchesRoutes = require './public/src/modules/DocForBatches/src/server/routes/DocForBatchesRoutes.js'
	docForBatchesRoutes.setupRoutes(app)

	# GenericDataParser routes
	genericDataParserRoutes = require './public/src/modules/GenericDataParser/src/server/routes/GenericDataParserRoutes.js'
	genericDataParserRoutes.setupRoutes(app)

	# BulkLoadContainersFromSDF routes
	bulkLoadContainersFromSDFRoutes = require './public/src/modules/BulkLoadContainersFromSDF/src/server/routes/BulkLoadContainersFromSDFRoutes.js'
	bulkLoadContainersFromSDFRoutes.setupRoutes(app)

	# BulkLoadSampleTransfers routes
	bulkLoadSampleTransfersRoutes = require './public/src/modules/BulkLoadSampleTransfers/src/server/routes/BulkLoadSampleTransfersRoutes.js'
	bulkLoadSampleTransfersRoutes.setupRoutes(app)

	# RunPrimaryAnalysisRoutes routes
	runPrimaryAnalysisRoutes = require './public/src/modules/PrimaryScreen/src/server/routes/RunPrimaryAnalysisRoutes.js'
	runPrimaryAnalysisRoutes.setupRoutes(app)

	# CurveCurator routes
	curveCuratorRoutes = require './public/src/modules/CurveAnalysis/src/server/routes/CurveCuratorRoutes.js'
	curveCuratorRoutes.setupRoutes(app)

	http.createServer(app).listen(app.get('port'), ->
		console.log("Express server listening on port " + app.get('port'))
	)
	csUtilities.logUsage("ACAS Node server started", "started", "")

startApp()

