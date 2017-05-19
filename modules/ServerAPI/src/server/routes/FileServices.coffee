serverUtilityFunctions = require './ServerUtilityFunctions.js'


setupRoutes = (app, loginRoutes, requireLogin) ->
	config = require '../conf/compiled/conf.js'
	upload = require 'jquery-file-upload-middleware'

	dataFilesPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
	tempFilesPath = serverUtilityFunctions.makeAbsolutePath config.all.server.tempfiles.relative_path

	#configure upload middleware
	upload.configure
		uploadDir: dataFilesPath
		ssl: config.all.client.use.ssl
		uploadUrl: "/dataFiles"

	app.use '/uploads', (req, res, next) ->
		if requireLogin
			if !req.isAuthenticated()
				res.send 401
				return
		upload.fileHandler() req, res, next


	upload.on "error", (e) ->
		console.log "fileUpload: ", e.message
	upload.on "end", (fileInfo) ->
		console.log fileInfo
		app.emit "file-uploaded", fileInfo


	serverUtilityFunctions.ensureExists dataFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create data files dir: "+dataFilesPath
			process.exit -1
		else
			if config.all.server.datafiles.without.login || !requireLogin
				app.get '/dataFiles/*', (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + req.params[0])
			else
				app.get '/dataFiles/*', loginRoutes.ensureAuthenticated, (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + req.params[0])

	serverUtilityFunctions.ensureExists tempFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create temp files dir: "+dataFilesPath
			process.exit -1
		else
			if requireLogin
				app.get '/tempfiles/*', loginRoutes.ensureAuthenticated, (req, resp) ->
					resp.sendfile(tempFilesPath + req.params[0])
			else
				app.get '/tempfiles/*', (req, resp) ->
					resp.sendfile(tempFilesPath + req.params[0])

exports.setupAPIRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, false
#	app.get '/dataFiles/*', (req, resp) ->
#		resp.sendfile('/Users/jam/Projects/ACAS/dev/acas-master-dev/acas/privateUploads/'+ req.params[0])

exports.setupRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, true

