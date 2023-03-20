serverUtilityFunctions = require './ServerUtilityFunctions.js'
fs = require 'fs'
path = require 'path'
multer = require 'multer'
helmet = require("helmet");
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
		
		fileFilterFunction = (req, file, cb) ->

			# Get config for dissallowed file types
			# Return error if dissallowed file type is found and don't write it to the file system
			disallowedTypesSetting = config.all.server.datafiles.disallowedFileTypes
			if disallowedTypesSetting?
				disallowedTypesArray = JSON.parse(disallowedTypesSetting)
				# Join the filtered file types by | and create regex
				dissallowedFileTypes = new RegExp(disallowedTypesArray.join('|'))

				# Do regex tests
				extname = dissallowedFileTypes.test(path.extname(file.originalname).toLowerCase())

				if extname
					return cb 'Error (415) - The following file types are dissallowed: ' + disallowedTypesArray.join(', ')
			
			# If no error, return null
			cb(null, true);
			return

		dataFileUploads = multer({dest:dataFilesPath, storage: storage, fileFilter: fileFilterFunction}).any();

		# Function to handle request after files have been saved and added
		# to the request by multer
		dataFileUploads req, resp, (err) ->
			if req.fileValidationError
				console.error(err)
				return resp.status(500).send(req.fileValidationError)
			else if !req.files
				# Set status to 204 No Content
				return resp.status(204).send('Please post a file')
			else if err instanceof multer.MulterError
				console.error(err)
				return resp.status(500).send(err)
			else if err
				# Set status code to 'Unsupported Media Type'
				console.error(err)
				if err.indexOf('Error (415)') == 0
					console.log(err.indexOf('Error (415)'))
					return resp.status(415).send(err)
				else
					return resp.status(500).send(err)
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
							# Note: the "delete_type" and "delete_url" are required by the jquery file upload plugin
							# They tell the plugin how to actually delete the file and adjust the maxNumberOfFiles
							# https://github.com/mcneilco/acas/blob/36f3d6cea0fda97177863818a8ccbc15c60b35c4/public/lib/jqueryFileUpload/js/jquery.fileupload-ui.js#L297
							# Without it the maxNumberOfFiles is not adjusted and the user can't upload more files even after clicking the delete button on a file
							"delete_type": "DELETE",
							"delete_url": "/dataFiles/" + file.filename,
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

	dataFilesPolicy = (req, resp, next) ->
		policy = helmet(
			contentSecurityPolicy:
				directives:
					imgSrc: ["'self'"]
					defaultSrc: ["'none'"],
					scriptSrc: ["'none'"],
					mediaSrc: ["'self'"],
					sandbox: []
		)
		policy(req, resp, next)
	
	serverUtilityFunctions.ensureExists dataFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create data files dir: "+dataFilesPath
			process.exit -1
		else
			if config.all.server.datafiles.without.login || !requireLogin
				app.get '/dataFiles/*', dataFilesPolicy, (req, resp) ->
					
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + encodeURIComponent(req.params[0]))
			else
				app.get '/dataFiles/*', dataFilesPolicy, loginRoutes.ensureAuthenticated, (req, resp) ->
					console.log dataFilesPath
					resp.sendfile(dataFilesPath + encodeURIComponent(req.params[0]))

	serverUtilityFunctions.ensureExists tempFilesPath, 0o0744, (err) ->
		if err?
			console.log "Can't find or create temp files dir: "+dataFilesPath
			process.exit -1
		else
			if requireLogin
				app.get '/tempfiles/*', dataFilesPolicy, loginRoutes.ensureAuthenticated, (req, resp) ->
					resp.sendfile(tempFilesPath + encodeURIComponent(req.params[0]))
			else
				app.get '/tempfiles/*', dataFilesPolicy, (req, resp) ->
					resp.sendfile(tempFilesPath + encodeURIComponent(req.params[0]))


exports.setupAPIRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, false
	app.delete '/dataFiles/*', exports.deleteFile

exports.setupRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, true
	app.delete '/dataFiles/*', loginRoutes.ensureAuthenticated, exports.deleteFile

exports.deleteFile = (req, resp) ->
	# Not implemented currently. We added this route in order to fully support the jquery file upload plugin
	# which requires a delete route in order to function correctly with maxNumberOfFiles.
	# See details here: https://github.com/mcneilco/acas/pull/1085
	console.log 'Got DELETE request for data file: ' + req.params[0] + ' from user: ' + req.user.username
	console.log 'Not deleting file, just returning 200 OK'
	resp.send 200