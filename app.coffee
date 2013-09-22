# For DNS only

global.logDnsUsage = (action, data, username) ->
	config = require './public/src/conf/configurationNode.js'
	request = require 'request'
	req = request.post config.serverConfigurationParams.configuration.loggingService , (error, response) =>
			if !error && response.statusCode == 200
				console.log "logged: "+action+" with data: "+data+" and user: "+username
			else
				console.log "got error trying log action: "+action+" with data: "+data
				console.log error
				console.log response
	form = req.form()
	form.append('application', 'acas')
	form.append('action', action)
	form.append('application_data', data)
	form.append('user_login', username)

fs = require('fs')
asyncblock = require('asyncblock');
exec = require('child_process').exec;
asyncblock((flow) ->
	global.deployMode = process.env.DNSDeployMode
	exec("java -jar ../lib/dns-config-client.jar -m "+global.deployMode+" -c acas -d 2>/dev/null", flow.add())
	config = flow.wait()
	config = config.replace(/\\/g, "")
	configLines = config.split("\n")
	settings = {}
	for line in configLines
		lineParts = line.split "="
		unless lineParts[1] is undefined
			settings[lineParts[0]] = lineParts[1]
	configTemplate = fs.readFileSync("./public/src/conf/configurationNode_Template.js").toString()
	for name, setting of settings
		configTemplate = configTemplate.replace(RegExp(name,"g"), setting)
	# deal with special cases
	jdbcParts = settings["acas.jdbc.url"].split ":"
	configTemplate = configTemplate.replace(/acas.api.db.location/g, jdbcParts[0]+":"+jdbcParts[1]+":"+jdbcParts[2]+":@")
	configTemplate = configTemplate.replace(/acas.api.db.host/g, jdbcParts[3].replace("@",""))
	configTemplate = configTemplate.replace(/acas.api.db.port/g, jdbcParts[4])
	configTemplate = configTemplate.replace(/acas.api.db.name/g, jdbcParts[5])

	# replace server name
	enableSpecRunner = true
	switch(global.deployMode)
		when "Dev" then hostName = "acas-d"
		when "Test" then hostName = "acas-t"
		when "Stage" then hostName = "acas-s"
		when "Prod"
			hostName = "acas"
			enableSpecRunner = false
	configTemplate = configTemplate.replace(RegExp("acas.api.hostname","g"), hostName)
	configTemplate = configTemplate.replace(/acas.api.enableSpecRunner/g, enableSpecRunner)
	configTemplate = configTemplate.replace(/acas.env.logDir/g, process.env.DNSLogDirectory)

	fs.writeFileSync "./public/src/conf/configurationNode.js", configTemplate
	startApp()
)
# End for DNS only


startApp = ->
# Regular system startup
	config = require './public/src/conf/configurationNode.js'
	express = require('express')
	user = require('./routes/user')

	http = require('http')
	path = require('path')

	# Added for loging support
	flash = require 'connect-flash'
	passport = require 'passport'
	util = require 'util'
	LocalStrategy = require('passport-local').Strategy

	app = express()
	app.configure( ->
		app.set('port', process.env.PORT || config.serverConfigurationParams.configuration.portNumber)
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
	loginRoutes = require './routes/loginRoutes'

	app.configure('development', ->
		app.use(express.errorHandler())
	)

	# main routes
	routes = require('./routes')
	app.get '/', loginRoutes.ensureAuthenticated, routes.index
	if config.serverConfigurationParams.configuration.enableSpecRunner
		app.get '/SpecRunner', routes.specRunner
		app.get '/LiveServiceSpecRunner', routes.liveServiceSpecRunner

	# login routes
	passport.serializeUser (user, done) ->
		done null, user.username
	passport.deserializeUser (username, done) ->
		loginRoutes.findByUsername username, (err, user) ->
			done err, user
	passport.use new LocalStrategy loginRoutes.loginStrategy

	app.get '/login', loginRoutes.loginPage
	app.post '/login',
		passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }),
		loginRoutes.loginPost
	app.get '/logout', loginRoutes.logout
#	app.post '/api/userAuthentication', loginRoutes.authenticationService
	app.get '/api/users/:username', loginRoutes.getUsers

	# serverAPI routes
	preferredBatchIdRoutes = require './routes/PreferredBatchIdService.js'
	app.post '/api/preferredBatchId', preferredBatchIdRoutes.preferredBatchId
	app.post '/api/testRoute', preferredBatchIdRoutes.testRoute
	protocolRoutes = require './routes/ProtocolServiceRoutes.js'
	app.get '/api/protocols/codename/:code', protocolRoutes.protocolByCodename
	app.get '/api/protocols/:id', protocolRoutes.protocolById
	app.post '/api/protocols', protocolRoutes.postProtocol
	app.put '/api/protocols', protocolRoutes.putProtocol
	app.get '/api/protocollabels', protocolRoutes.protocolLabels
	app.get '/api/protocolCodes', protocolRoutes.protocolCodeList
	app.get '/api/protocolCodes/filter/:str', protocolRoutes.protocolCodeList
	experimentRoutes = require './routes/ExperimentServiceRoutes.js'
	app.get '/api/experiments/codename/:code', experimentRoutes.experimentByCodename
	app.get '/api/experiments/:id', experimentRoutes.experimentById
	app.post '/api/experiments', experimentRoutes.postExperiment
	app.put '/api/experiments', experimentRoutes.putExperiment

	#Components routes
	projectServiceRoutes = require './routes/ProjectServiceRoutes.js'
	app.get '/api/projects', projectServiceRoutes.getProjects


	# DocForBatches routes
	docForBatchesRoutes = require './routes/DocForBatchesRoutes.js'
	app.get '/docForBatches/*', docForBatchesRoutes.docForBatchesIndex
	app.get '/docForBatches', docForBatchesRoutes.docForBatchesIndex
	app.get '/api/docForBatches/:id', docForBatchesRoutes.getDocForBatches
	app.post '/api/docForBatches', docForBatchesRoutes.saveDocForBatches

	# GenericDataParser routes
	genericDataParserRoutes = require './routes/GenericDataParserRoutes.js'
	app.post '/api/genericDataParser', genericDataParserRoutes.parseGenericData

	# FullPKParser routes
	fullPKParserRoutes = require './routes/FullPKParserRoutes.js'
	app.post '/api/fullPKParser', fullPKParserRoutes.parseFullPKData

	# MicroSolParser routes
	microSolRoutes = require './routes/MicroSolRoutes.js'
	app.post '/api/microSolParser', microSolRoutes.parseMicroSolData

	# PampaParser routes
	pampaRoutes = require './routes/PampaRoutes.js'
	app.post '/api/pampaParser', pampaRoutes.parsePampaData

	# MetStabParser routes
	metStabRoutes = require './routes/MetStabRoutes.js'
	app.post '/api/metStabParser', metStabRoutes.parseMetStabData

	# BulkLoadContainersFromSDF routes
	bulkLoadContainersFromSDFRoutes = require './routes/BulkLoadContainersFromSDFRoutes.js'
	app.post '/api/bulkLoadContainersFromSDF', bulkLoadContainersFromSDFRoutes.bulkLoadContainersFromSDF

	# BulkLoadSampleTransfers routes
	bulkLoadSampleTransfersRoutes = require './routes/BulkLoadSampleTransfersRoutes.js'
	app.post '/api/bulkLoadSampleTransfers', bulkLoadSampleTransfersRoutes.bulkLoadSampleTransfers

	# RunPrimaryAnalysisRoutes routes
	runPrimaryAnalysisRoutes = require './routes/RunPrimaryAnalysisRoutes.js'
	app.get '/primaryScreenExperiment/*', runPrimaryAnalysisRoutes.primaryScreenExperimentIndex
	app.get '/primaryScreenExperiment', runPrimaryAnalysisRoutes.primaryScreenExperimentIndex
	app.post '/api/primaryAnalysis/runPrimaryAnalysis', runPrimaryAnalysisRoutes.runPrimaryAnalysis

	# CurveCurator routes
	curveCuratorRoutes = require './routes/CurveCuratorRoutes.js'
	app.get '/curveCurator/*', curveCuratorRoutes.curveCuratorIndex
	app.get '/api/curves/stub/:exptCode', curveCuratorRoutes.getCurveStubs

	# ServerUtility function testing routes
	serverUtilityFunctions = require './routes/ServerUtilityFunctions.js'
	app.post '/api/runRFunctionTest', serverUtilityFunctions.runRFunctionTest

	http.createServer(app).listen(app.get('port'), ->
		console.log("Express server listening on port " + app.get('port'))
	)
	serverUtilityFunctions.logUsage("ACAS Node server started", "started", "")


### if not DNS
global.deployMode = "Dev"
startApp()
 end if not DNS
###
