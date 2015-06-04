exports.setupAPIRoutes = (app) ->
	app.post '/api/cmpdRegBulkLoader', exports.postAssignedProperties

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex
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

exports.cmpdRegBulkLoaderReadSdf = (req, resp) ->
	console.log "cmpdRegBulkLoaderReadSdf"
	if req.query.testMode or global.specRunnerTestmode
		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
		console.log req.body
		console.log req.body.numRecords
		console.log req.body.fileName
		if req.body.template is "Template 1"
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
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"lsthings/validate"
#		if req.params.componentOrAssembly is "component"
#			baseurl += "?uniqueName=true"
#		else #is assembly
#			baseurl += "?uniqueName=true&uniqueInteractions=true&orderMatters=true&forwardAndReverseAreSame=true"
#		request = require 'request'
#		request(
#			method: 'POST'
#			url: baseurl
#			body: req.body.modelToSave
#			json: true
#		, (error, response, json) =>
#			if !error && response.statusCode == 202
#				resp.json json
#			else if response.statusCode == 409
#				console.log "conflict in name"
#				resp.json "not unique name"
#			else
#				console.log 'got ajax error trying to save thing parent'
#				console.log error
#				console.log json
#				console.log response
#		)

exports.postAssignedProperties = (req, resp) ->
	console.log "postAssignedProperties"
	if req.query.testMode or global.specRunnerTestmode
#		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
		console.log req.body.properties
		resp.end JSON.stringify "Registration Summary here"
#		if req.body.template is "Template 1"
#			if req.body.numRecords < 300
#				resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.propertiesList
#			else
#				resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.propertiesList2
#		else
#			resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.propertiesList3
	else
		resp.end JSON.stringify "read sdf route not implemented yet"
