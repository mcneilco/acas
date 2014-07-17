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

makeAbsolutePath = (relativePath) ->
	acasPath = process.env.PWD
	dotMatches = relativePath.match(/\.\.\//g)
	if dotMatches?
		numDotDots = relativePath.match(/\.\.\//g).length
		relativePath = relativePath.replace /\.\.\//g, ''
		for d in [1..numDotDots]
			acasPath = acasPath.replace /[^\/]+\/?$/, ''
	else
		acasPath+= '/'

	console.log acasPath+relativePath+'/'
	acasPath+relativePath+'/'

setupRoutes = (app, loginRoutes, requireLogin) ->
	config = require '../conf/compiled/conf.js'
#	dataFilesPath = makeAbsolutePath "../../playprivateUploads"
#	dataFilesPath = makeAbsolutePath "playprivateUploads"
	dataFilesPath = makeAbsolutePath config.all.server.datafiles.relative_path
	tempFilesPath = makeAbsolutePath config.all.server.tempfiles.relative_path
	ensureExists dataFilesPath, 0o0744, (err) ->
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

	ensureExists tempFilesPath, 0o0744, (err) ->
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

