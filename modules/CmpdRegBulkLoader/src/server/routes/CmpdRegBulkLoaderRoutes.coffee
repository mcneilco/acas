path = require 'path'

exports.setupAPIRoutes = (app, loginRoutes) ->
	app.post '/api/cmpdRegBulkLoader/registerCmpds', exports.registerCmpds
	app.post '/api/cmpdRegBulkLoader/validateCmpds', exports.validateCmpds
	app.post '/api/cmpdRegBulkLoader/validationProperties', exports.validationProperties
	app.get '/api/cmpdRegBulkLoader/getFilesToPurge', exports.getFilesToPurge
	app.post '/api/cmpdRegBulkLoader/purgeFile', exports.purgeFile
	app.get '/api/cmpdRegBulkLoader/getSDFFromBulkLoadFileId/:bulkFileID', exports.getSDFFromBulkLoadFileId



exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex
	app.get '/api/cmpdRegBulkLoader/templates/:user', loginRoutes.ensureAuthenticated, exports.getCmpdRegBulkLoaderTemplates
	app.get '/api/cmpdRegBulkLoader/getFilesToPurge', loginRoutes.ensureAuthenticated, exports.getFilesToPurge
	app.post '/api/cmpdRegBulkLoader/readSDF', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderReadSdf
	app.post '/api/cmpdRegBulkLoader/saveTemplate', loginRoutes.ensureAuthenticated, exports.saveTemplate
	app.post '/api/cmpdRegBulkLoader/registerCmpds', loginRoutes.ensureAuthenticated, exports.registerCmpds
	app.post '/api/cmpdRegBulkLoader/validateCmpds', loginRoutes.ensureAuthenticated, exports.validateCmpds
	app.post '/api/cmpdRegBulkLoader/checkFileDependencies', loginRoutes.ensureAuthenticated, exports.checkFileDependencies
	app.post '/api/cmpdRegBulkLoader/purgeFile', loginRoutes.ensureAuthenticated, exports.purgeFile
	app.get '/api/cmpdRegBulkLoader/getSDFFromBulkLoadFileId/:bulkFileID', loginRoutes.ensureAuthenticated, exports.getSDFFromBulkLoadFileId

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
			cmpdRegConfig: config.all.client.cmpdreg

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
		request = require 'request'
		#in the first request, get all the file data
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.statusCode = response.statusCode

				#after getting the file data, we need to check if the each file has been updated or not
				for fileData in json
					try
						#get all lots associated with each file
						baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/getLotsByBulkLoadFileID?bulkLoadFileID=" + fileData.id 
						response = await fetch(baseurl, method: 'GET')
						checkStatus response
						lotCorpNames = await response.json()

						#If one of the lots has been modified, we say the bulkFile has been updated
						bulkFileUpdated = "No"

						#run a loop to find out if each lot has been modified, and if so who/when
						for lotName in lotCorpNames
							baseurl = config.all.client.service.cmpdReg.persistence.fullpath + "/metalots/corpName/" + lotName
							response = await fetch(baseurl, method: 'GET')

							checkStatus response
							lotMetadata = await response.json()
							lotModifiedBy = lotMetadata.lot.modifiedBy
							# TODO - Add sorting for who last modified the bulk file, and when it was last modified
							# TODO - When you edit a lot in ACAS, it doesn't seem to record the modified date 
							#lotModifiedDate = lotMetadata.lot.modifiedDate

							#if there is a user who modified one of the lots, we know that the lots in file have been udpated and end the loop
							if lotModifiedBy != null
								bulkFileUpdated = "Yes"
								break

						#Update whether the file has been updated or not
						fileData.bulkFileUpdated = bulkFileUpdated
				
					catch err
						fileData.bulkFileUpdated = "N/A" 
						console.log "Error checking for if file has been modified: " + err
			
				resp.json json
			else
				console.log 'got ajax error'
				console.log error
				console.log json
				callback 500, {error: true, message:error}
		)
			
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

exports.validationProperties = (req, resp) ->
	req.connection.setTimeout 6000000
	exports.validationPropertiesInternal req.body, (json) =>
		resp.json json

exports.validationPropertiesInternal = (reqObject, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/validationProperties"
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: reqObject
		json: true
	, (error, response, json) =>
		console.log json
		if !error && response.statusCode == 200
			callback json
		else
			console.error 'got ajax error trying to validate sdf properties'
			console.error error
			console.error json
			console.error response
			callback {error: json}
	)

exports.getScientistsInternal = (callback) ->
	loginRoutes = require './loginRoutes.js'
	config = require '../conf/compiled/conf.js'
	roleName = null
	if config.all.client.roles.cmpdreg.chemistRole? && config.all.client.roles.cmpdreg.chemistRole != ""
		roleName = config.all.client.roles.cmpdreg.chemistRole
	loginRoutes.getAuthorsInternal {additionalCodeType: 'compound', additionalCodeKind: 'scientist', roleName: roleName}, (statusCode, authors) =>
		callback authors

exports.validateCmpds = (req, resp) ->
	req.body.validate = true
	exports.registerCmpds(req, resp)

exports.registerCmpds = (req, resp) ->
	req.connection.setTimeout 6000000
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
			splitNames = rFile.split (path.sep+"cmpdreg_bulkload"+path.sep)
			rFileName = splitNames[1]
			rFileName = rFileName.replace(path.sep, '');
			zip.file(rFileName, fs.readFileSync(rFile))
		origUploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
		zipFilePath = origUploadsPath + "cmpdreg_bulkload" + path.sep + zipFileName
		console.log zipFilePath
		fstream = zip.generateNodeStream({type:"nodebuffer", streamFiles:true}).pipe(fs.createWriteStream(zipFilePath))
		fstream.on 'finish', ->
			console.log "finished create write stream"
			resp.json [json, zipFileName]
		fstream.on 'error', (err) ->
			console.log "error writing stream for zip"
			console.log err
			resp.end "Summary ZIP file could not be created"

	registerCmpds = (req, resp) ->
		if req == "error"
			resp.end JSON.stringify "Error"
		else
			if req.query.testMode or global.specRunnerTestmode
				resp.end JSON.stringify "Registration Summary here"
			else
				fileName = req.body.fileName
				delete req.body.fileName

				# get a list of scientists that are allowed to be registered chemists
				exports.getScientistsInternal (authors) =>
					_ = require 'underscore'
					authorCodes = _.pluck authors, "code"

					# get a list of allowed projects for the user doing the registration
					authorRoutes = require './AuthorRoutes.js'
					authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
						projectCodes = _.pluck allowedUserProjects, "code"

						# get the list of chemists/projects in the SDF file/DB mappings
						exports.validationPropertiesInternal req.body, (sdfProperties) =>
						    # find chemists and projects that are invalid
							missingAuthorCodes = _.difference sdfProperties.chemists, authorCodes
							missingProjectCodes = _.difference sdfProperties.projects, projectCodes

							# if any chemists are invalid then pass those invalid users to the registration service
							# Also pass validCodes in case there are case differences that can be solved by substition
							if missingAuthorCodes.length > 0
								_.extend(_.findWhere(req.body.mappings, { dbProperty: 'Lot Chemist' }), {invalidValues: missingAuthorCodes, validValues: authorCodes});
							# if any projects are invalid then pass those invalid users to the registration
							# service for automatic failure
							if missingProjectCodes.length > 0
								_.extend(_.findWhere(req.body.mappings, { dbProperty: 'Project' }), {invalidValues: missingProjectCodes});

							config = require '../conf/compiled/conf.js'
							baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/registerSdf"
							request = require 'request'
							request(
								method: 'POST'
								url: baseurl
								body: req.body
								json: true
							, (error, response, json) =>
								if !error && response.statusCode == 200 && json.reportFiles?
									createSummaryZip fileName, json
								else
									console.log 'got ajax error trying to register compounds'
									console.log error
									console.log json
									console.log response
									if json.summary?
										resp.json [json]
									else
										resp.end JSON.stringify "Error"
							)

	moveSdfFile = (req, resp, callback) ->
		fileName = req.body.fileName
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		config = require '../conf/compiled/conf.js'
		fs = require 'fs'
		uploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
		oldPath = uploadsPath + fileName
		bulkLoadFolder = uploadsPath + "cmpdreg_bulkload" + path.sep
		while fs.existsSync(bulkLoadFolder + path.sep + fileName)
			fileName = fileName.replace(/(?:(?: \(([\d]+)\))?(\.[^.]+))?$/, (s, index, ext) ->
				' (' + ((parseInt(index, 10) or 0) + 1) + ')' + (ext or '')
			)

		newPath = bulkLoadFolder + fileName
		serverUtilityFunctions.ensureExists bulkLoadFolder, 0o0744, (err) ->
			if err?
				console.log "Can't find or create bulkload folder: " + bulkLoadFolder
				callback "error", resp
			else
				if req.body.validate
					# new node has fs.copyFile but we don't currently:(
					fsFuct = (oldPath, newPath, callback) ->
						stream = fs.createReadStream(oldPath).pipe fs.createWriteStream(newPath)
						stream.on 'error', (err) ->
							callback err
						stream.on 'close', ->
							callback null
				else
					fsFuct = fs.rename
				fsFuct oldPath, newPath, (err) ->
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
		req.setTimeout 86400000
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

checkStatus = (response) ->
	# check for http error
	if response.ok
		return response
	else
		throw new HTTPResponseError response

class HTTPResponseError extends Error
	constructor: (response, ...args) ->
		super("HTTP Error Response: #{response.status} #{response.statusText}", ...args)
		this.response = response

exports.getSDFFromBulkLoadFileId = (req, resp) ->
	req.setTimeout 86400000
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"bulkload/getLotsByBulkLoadFileID?bulkLoadFileID=" +req.params.bulkFileID
	request = require 'request'
	request(
		method: 'GET'
		url: baseurl
		json: true
	, (error, response, lotCorpNames) =>
		if !error && response.statusCode == 200
			#make a second call using the returned lots to get an SDF file
			baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"export/lotCorpNames"
			try
			# Use fetch to call the service and pipe the response to the client
				response = await fetch(baseurl,
					method: 'POST'
					body: JSON.stringify(lotCorpNames)
					headers:
						'Content-Type': 'application/json'
				)
				checkStatus response
				resp.set({
					"content-length": response.headers.get('content-length'),
					"content-type": response.headers.get('content-type'),
				})
				response.body.pipe(resp);
			catch err
				console.log "Error calling service: " + err
				resp.statusCode = 500
				resp.json err

		else
			console.log 'got ajax error trying to retrieve lots from bulk file ID'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify "Error"
	)
