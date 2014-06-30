ensureExists = (path, mask, cb) ->
	fs = require 'fs'
	fs.mkdir path, mask, (err) ->
		if err
			if err.code is "EEXIST" # ignore the error if the folder already exists
				cb null
			else # something else went wrong
				cb err
		else # successfully created folder
			console.log "Created new directory: "+path
			cb null
		return

	return


exports.setupAPIRoutes = (app, loginRoutes) ->

exports.setupRoutes = (app, loginRoutes) ->
	config = require '../conf/compiled/conf.js'
	dataFilesPath = process.env.PWD+'/'+config.all.server.datafiles.relative_path+'/'
	tempFilesPath = process.env.PWD+'/'+config.all.server.tempfiles.relative_path+'/'
	ensureExists dataFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create data files dir: "+dataFilesPath
			process.exit -1
		else
			if config.all.server.datafiles.without.login
				app.get '/dataFiles/*', (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + req.params[0])
			else
				app.get '/dataFiles/*', loginRoutes.ensureAuthenticated, (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + req.params[0])

	ensureExists tempFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create temp files dir: "+dataFilesPath
			process.exit -1
		else
			app.get '/tempfiles/*', loginRoutes.ensureAuthenticated, (req, resp) ->
				resp.sendfile(tempFilesPath + req.params[0])
