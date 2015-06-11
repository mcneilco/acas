exports.setupAPIRoutes = (app) ->
	app.post '/api/cmpdRegBulkLoader', exports.postAssignedProperties

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex
	app.get '/api/cmpdRegBulkLoader/templates/:user', loginRoutes.ensureAuthenticated, exports.getCmpdRegBulkLoaderTemplates
	app.post '/api/cmpdRegBulkLoader/readSDF', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderReadSdf
	app.post '/api/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.postAssignedProperties

exports.cmpdRegBulkLoaderIndex = (req, res) ->
	scriptPaths = require './RequiredClientScripts.js'
	config = require '../conf/compiled/conf.js'

	global.specRunnerTestmode = if global.stubsMode then true else false
	scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts)
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"

	return res.render 'CmpdRegBulkLoader',
		title: "Compound Registration Bulk Loader"
		scripts: scriptsToLoad
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			testMode: false
			moduleLaunchParams: if moduleLaunchParams? then moduleLaunchParams else null
			deployMode: global.deployMode

exports.getCmpdRegBulkLoaderTemplates = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
		resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.templates
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"bulkload/templates?userName="+req.params.user
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.cmpdRegBulkLoaderReadSdf = (req, resp) ->
	console.log "cmpdRegBulkLoaderReadSdf"
	if req.query.testMode or global.specRunnerTestmode
		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
		console.log req.body
		if req.body.templateName is "Template 1"
			if req.body.numRecords < 300
				resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.propertiesList
			else
				resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.propertiesList2
		else
			resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.propertiesList3
	else
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		config = require '../conf/compiled/conf.js'
		uploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
		filePath = uploadsPath + req.body.fileName
		req.body.fileName = filePath
		console.log req.body
		resp.end JSON.stringify "read sdf route not implemented yet"

postAssignedProperties = (req, resp) ->
	console.log "post assigned properties"
	registerCompounds = (templateInfo, resp) ->
		if req.query.testMode or global.specRunnerTestmode
			console.log "register compounds"
			resp.end JSON.stringify "Registration Summary here"
		else
			resp.end JSON.stringify "read sdf route not implemented yet"

	saveTemplate = (templateInfo, resp) ->
		console.log "save template"
		if req.query.testMode or global.specRunnerTestmode
			registerCompounds templateInfo, resp
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"bulkload/templates/saveTemplate"
			request = require 'request'
			request(
				method: 'POST'
				url: baseurl
				body: templateInfo
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 201
					registerCompounds templateInfo, resp
				else
					console.log 'got ajax error trying to save lsThing'
					console.log error
					console.log json
					console.log response
			)


	if req.body.templateName != ""
		saveTemplate req.body, resp
	else
		registerCompounds req.body, resp

exports.postAssignedProperties = (req, resp) ->
	postAssignedProperties req, resp
