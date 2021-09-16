serverUtilityFunctions = require './ServerUtilityFunctions.js'
fs = require 'fs'
path = require 'path'
multer = require 'multer'

setupRoutes = (app, loginRoutes, requireLogin) ->
	config = require '../conf/compiled/conf.js'

	dataFilesPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
	tempFilesPath = serverUtilityFunctions.makeAbsolutePath config.all.server.tempfiles.relative_path


	uploads = (req, resp) ->
		if requireLogin
			if !req.isAuthenticated()
				resp.send 401
				return
			
		# Configure this route to write posted files to temp files path
		fileRename = (req, file, callback) ->
			# rename the file to the original name
			safeName dataFilesPath, file.originalname, (safeFileName) ->
				callback(null, safeFileName)
		
		safeName = (dir, filename, callback) ->
			fs.exists dir + '/' + filename, (exists) ->
				if exists
					filename = filename.replace(/(?:(?: \(([\d]+)\))?(\.[^.]+))?$/, (s, index, ext) ->
						' (' + ((parseInt(index, 10) or 0) + 1) + ')' + (ext or '')
					)
					safeName dir, filename, callback
				else
					callback filename
				return
			return


		storage = multer.diskStorage(
			destination: dataFilesPath
			filename: fileRename
		)
		dataFileUploads = multer({dest:dataFilesPath, storage: storage}).any();

		# Function to handle request after files have been saved and added
		# to the request by multer
		dataFileUploads req, resp, (err) ->
			if req.fileValidationError
				console.error(err)
				return resp.send(req.fileValidationError)
			else if !req.files
				console.error(err)
				return resp.send('Please post a file')
			else if err instanceof multer.MulterError
				console.error(err)
				return resp.send(err)
			else if err
				console.error(err)
				return resp.send(err)
			# No errors 
			else
				try
					files = []
					for file, i in req.files
						outfile = {
							"name": file.filename,
							"originalName": file.originalname,
							"size": file.size,
							"type": file.mimetype,
							"url": "http://#{req.get('Host')}/dataFiles/" + file.filename,
							"filePath": file.path
						}
						files.push(outfile)
					resp.json {"files": files}
				catch err
					console.error(err)
					resp.send(err)

	app.post '/uploads', uploads

	getBlobByteArray = (req, resp) ->
		if requireLogin
			if !req.isAuthenticated()
				resp.send 401
				return
		# Configure this route to write posted files to temp files path
		tempUploads = multer({dest:tempFilesPath}).any();

		# Function to handle request after files have been saved and added
		# to the request by multer
		tempUploads req, resp, (err) ->
			if req.fileValidationError
				console.error(err)
				return resp.send(req.fileValidationError)
			else if !req.files
				console.error(err)
				return resp.send('Please post a file')
			else if err instanceof multer.MulterError
				console.error(err)
				return resp.send(err)
			else if err
				console.error(err)
				return resp.send(err)
			# No errors 
			else
				try
					files = []
					for file, i in req.files
						console.log("Getting binary data for file saved to #{file.path}")
						data = fs.readFileSync(file.path)
						arrByte= Uint8Array.from(Buffer.from(data))
						binaryData= Array.from(arrByte)
						outfile = {
							"name": file.originalname,
							"originalName": file.originalname,
							"size": file.size,
							"type": file.mimetype,
							"url": "/tempfiles/" + path.basename(file.path),
							"binaryData": binaryData
						}
						files.push(outfile)
					resp.json {"files": files}
				catch err
					console.error(err)
					resp.send(err)

	app.post '/blobUploads', getBlobByteArray

	serverUtilityFunctions.ensureExists dataFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create data files dir: "+dataFilesPath
			process.exit -1
		else
			if config.all.server.datafiles.without.login || !requireLogin
				app.get '/dataFiles/*', (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + encodeURIComponent(req.params[0]))
			else
				app.get '/dataFiles/*', loginRoutes.ensureAuthenticated, (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + encodeURIComponent(req.params[0]))

	serverUtilityFunctions.ensureExists tempFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create temp files dir: "+dataFilesPath
			process.exit -1
		else
			if requireLogin
				app.get '/tempfiles/*', loginRoutes.ensureAuthenticated, (req, resp) ->
					resp.sendfile(tempFilesPath + encodeURIComponent(req.params[0]))
			else
				app.get '/tempfiles/*', (req, resp) ->
					resp.sendfile(tempFilesPath + encodeURIComponent(req.params[0]))


exports.setupAPIRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, false

exports.setupRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, true

