### To install this Module
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Experiment Browser", mainControllerClassName: "ExperimentBrowserController"}


###


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experimentsForProtocol/:protocolCode', loginRoutes.ensureAuthenticated, exports.experimentsForProtocol
	app.post '/api/exportExperimentFiles', loginRoutes.ensureAuthenticated, exports.exportExperimentFiles

###
This appears to be a redundant route, similar to api/experiments/protocolCodename/:protocolcode in ExperimentServiceRoutes.coffee
This function appears to return a list of experiment codes, while the other returns experiment objects
As of 9/2022, using the other route is preferred although this one is not being deleted to prevent issues with current users.
###
exports.experimentsForProtocol = (req, resp) ->
	#fixturesData = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
	config = require '../conf/compiled/conf.js'


	baseurl = config.all.client.service.persistence.fullpath+"experiments/protocol/#{req.params.protocolCode}"
	console.log "baseurl"
	console.log baseurl

	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	request = serverUtilityFunctions.requestAdapter
	request(
		method: 'GET'
		url: baseurl
		body: req.body
		json: true
	, (error, response, json) =>
		#if !error && response.statusCode == 201
		if !error
			console.log JSON.stringify json
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to save new experiment'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

	#response.send fixturesData.listOfExperiments


exports.exportExperimentFiles = (req, resp) ->
	req.setTimeout 86400000
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	fs = require 'fs'
	JSZip = require 'jszip'

	experimentFiles = req.body.mappings
	fileName = req.body.fileName
	zipFileName = fileName+".zip"
	
	#Create a zip file of the all experiment files 
	zip = new JSZip()
	for rFile in experimentFiles
		#convert the path from the route used to find the files to where they are actually located (dataFiles/ -> privateUploads/)
		rFileName = rFile.replace("dataFiles/experiments/", '')
		rFile = rFile.replace('\n', "").replace('dataFiles/', "privateUploads/")
		zip.file(rFileName, fs.readFileSync(rFile))

	#Write zip file
	origUploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
	zipFilePath = origUploadsPath + zipFileName
	console.log zipFilePath
	fstream = zip.generateNodeStream({type:"nodebuffer", streamFiles:true}).pipe(fs.createWriteStream(zipFilePath))
	fstream.on 'finish', ->
		console.log "finished create write stream"
		resp.json [zipFileName]
	fstream.on 'error', (err) ->
		console.log "error writing stream for zip"
		console.log err
		resp.end "Summary ZIP file could not be created"

