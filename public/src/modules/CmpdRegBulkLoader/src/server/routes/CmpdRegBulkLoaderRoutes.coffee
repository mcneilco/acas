exports.setupAPIRoutes = (app) ->
	app.post '/api/cmpdRegBulkLoader', exports.postAssignedProperties

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex
	app.get '/api/cmpdRegBulkLoader/templates/:user', loginRoutes.ensureAuthenticated, exports.getCmpdRegBulkLoaderTemplates
	app.get '/api/cmpdRegBulkLoader/getFilesToPurge', loginRoutes.ensureAuthenticated, exports.getFilesToPurge
	app.post '/api/cmpdRegBulkLoader/readSDF', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderReadSdf
	app.post '/api/cmpdRegBulkLoader/saveTemplate', loginRoutes.ensureAuthenticated, exports.saveTemplate
	app.post '/api/cmpdRegBulkLoader/registerCmpds', loginRoutes.ensureAuthenticated, exports.registerCmpds
	app.post '/api/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.postAssignedProperties
	app.post '/api/cmpdRegBulkLoader/checkFileDependencies', loginRoutes.ensureAuthenticated, exports.checkFileDependencies
	app.post '/api/cmpdRegBulkLoader/purgeFile', loginRoutes.ensureAuthenticated, exports.purgeFile

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
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/templates?userName="+req.params.user
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getFilesToPurge = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
		resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.filesToPurge
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/files"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.cmpdRegBulkLoaderReadSdf = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
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
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/getSdfProperties"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to read sdf'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "Error"
		)

exports.saveTemplate = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cmpdRegBulkLoaderTestJSON = require '../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js'
		resp.end JSON.stringify cmpdRegBulkLoaderTestJSON.savedTemplateReturn
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/templates/saveTemplate"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to save template'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "Error"
		)

exports.registerCmpds = (req, resp) ->
	createSummaryZip = (fileName, json) ->
		#remove .sdf from fileName
		fileName = fileName.substring(0, fileName.length-4)
		zipFileName = fileName+".zip"
		fs = require 'fs'
		JSZip = require 'jszip'
		zip = new JSZip()

		for rFile in json.reportFiles
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			config = require '../conf/compiled/conf.js'
			splitNames = rFile.split ("/cmpdreg_bulkload/")
			rFileName = splitNames[1]
			zip.file(rFileName, fs.readFileSync(rFile))
		origUploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
		movedUploadsPath = origUploadsPath + "cmpdreg_bulkload/"
		zipFilePath = movedUploadsPath+zipFileName

		buffer = zip.generate({type:"nodebuffer"})
		zipFilePath = config.all.server.service.persistence.filePath+"/cmpdreg_bulkload/"+zipFileName
		fs.writeFile zipFilePath, buffer, (err) ->
			if err
				resp.end "Summary ZIP file could not be created"
			else
				resp.json [json, zipFileName]

	registerCmpds = (req, resp) ->
		if req == "error"
			resp.end JSON.stringify "Error"
		else
			if req.query.testMode or global.specRunnerTestmode
				resp.end JSON.stringify "Registration Summary here"
			else
				fileName = req.body.fileName
				delete req.body.fileName
				config = require '../conf/compiled/conf.js'
				baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/registerSdf"
				request = require 'request'
				request(
					method: 'POST'
					url: baseurl
					body: req.body
					json: true
				, (error, response, json) =>
					if !error && response.statusCode == 200
						createSummaryZip fileName, json
					else
						console.log 'got ajax error trying to register compounds'
						console.log error
						console.log json
						console.log response
						resp.end JSON.stringify "Error"
				)

	moveSdfFile = (req, resp, callback) ->
		fileName = req.body.fileName
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		config = require '../conf/compiled/conf.js'
		fs = require 'fs'
		uploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
		oldPath = uploadsPath + fileName
		bulkLoadFolder = uploadsPath + "cmpdreg_bulkload/"
		while fs.existsSync(bulkLoadFolder + '/' + fileName)
			fileName = fileName.replace(/(?:(?: \(([\d]+)\))?(\.[^.]+))?$/, (s, index, ext) ->
				' (' + ((parseInt(index, 10) or 0) + 1) + ')' + (ext or '')
			)

		newPath = bulkLoadFolder + fileName
		serverUtilityFunctions.ensureExists bulkLoadFolder, 0o0744, (err) ->
			if err?
				console.log "Can't find or create bulkload folder: " + bulkLoadFolder
				callback "error", resp
			else
				fs.rename oldPath, newPath, (err) ->
					if err?
						console.log err
						callback "error", resp
					else
						req.body.filePath = newPath
						req.body.fileName = fileName
						callback req, resp

	moveSdfFile req, resp, registerCmpds

exports.checkFileDependencies = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		resp.end JSON.stringify "File has 10 parents and 10 lots"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/checkDependencies"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.fileInfo
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to check dependencies'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "Error"
		)


exports.purgeFile = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		resp.end JSON.stringify "Successful purge in stubsMode."
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/purge"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body.fileInfo
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.json json
			else
				console.log 'got ajax error trying to purge'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify "Error"
		)
