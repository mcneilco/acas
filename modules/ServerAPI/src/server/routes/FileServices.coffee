serverUtilityFunctions = require './ServerUtilityFunctions.js'
fs = require 'fs'
path = require 'path'
multer = require 'multer'
helmet = require("helmet");
{ Storage } = require '@google-cloud/storage'
mime = require 'mime-types'
config = require '../conf/compiled/conf.js'
TMP_DIR = "tmp"

class LocalFileHandler

	init: ->
		## No initialization required for local file handler

	moveFiles: (files, deleteSourceFileOnSuccess) ->
		config = require '../conf/compiled/conf.js'
		
		deleteSourceFileOnSuccess = if deleteSourceFileOnSuccess? then deleteSourceFileOnSuccess == true else true

		# For each of the files, move them to the new location
		for file in files
			sourceLocation = file.sourceLocation
			targetLocation = file.targetLocation

			# IF metadata is not defined then set it to an empty object
			if !file.metaData
				file.metaData = {}

			if !sourceLocation || !targetLocation
				file.error = "Source and target locations must be defined"
				continue

			# Add config.all.server.datafiles.relative_path path to sourceLocation
			# Check if relative path is already added
			if sourceLocation.indexOf(config.all.server.datafiles.relative_path) == -1
				file.fullPath = path.join(config.all.server.datafiles.relative_path, sourceLocation)
			else
				file.fullPath = sourceLocation

			# Ensure that the source file exists
			exists = !!(await (fs.promises.stat file.fullPath).catch (err) -> false)
			if !exists
				file.error = "Source file does not exist"
				console.error "Source file does not exist: #{file.fullPath}"
				continue

		# Upload each of the files to the bucket after validating all of them
		promises = []
		for file in files
			if file.fullPath?
				fullPath = file.fullPath
				delete file.fullPath
			
			if file.error
				continue

			# Switch move function based on config.all.server.datafiles.type
			# if gcs then use exports.uploadToBucket
			# if blueimp then use exports.moveFile
			moveMethod = null

			# Move the actual files and get responses
			promises.push(@copyFile(fullPath, file.targetLocation, file.metaData)
				.then (response) ->
					# Add the file to the list of uploaded files
					# Delete the source file
					if deleteSourceFileOnSuccess
						await fs.promises.unlink response.sourceLocation
				.catch (err) ->
					console.error "Error moving file #{err}"
					file.error = "Error moving file: #{err}"
			)
		console.log "awaiting uploads to complete"
		await Promise.all(promises)
		console.log "uploads complete"

		return files

	copyFile: (sourceLocation, targetLocation, metaData) ->
		# source and target locations could be a full path or a relative path config.all.server.datafiles.relative_path
		# Lets convert both to full paths
		if sourceLocation.indexOf(config.all.server.datafiles.relative_path) == -1
			sourceLocation = path.join(config.all.server.datafiles.relative_path, sourceLocation)
		if targetLocation.indexOf(config.all.server.datafiles.relative_path) == -1
			targetLocation = path.join(config.all.server.datafiles.relative_path, targetLocation)

		# Check if the target directory exists
		[exists] = await fs.promises.access(path.dirname(targetLocation)).then(() => [true]).catch(() => [false])
		if !exists
			# Create the target directory
			await fs.promises.mkdir path.dirname(targetLocation), {recursive: true}
			
		await fs.promises.copyFile(sourceLocation, targetLocation)
		return {sourceLocation: sourceLocation, targetLocation: targetLocation, metaData: {}}

	getFile: (filePath) ->
		fullPath = path.join(config.all.server.datafiles.relative_path, filePath)
		# Check if the file exists
		exists = await fs.promises.access(fullPath).then(() => true).catch(() => false)
		if !exists
			throw new Error("File does not exist: #{fullPath}")
		# Get the file metadata
		stats = await fs.promises.stat(fullPath)
		# Get the content type
		contentType = mime.lookup(fullPath) || 'application/octet-stream'
		console.log "File path: #{fullPath}"
		console.log "Content type: #{contentType}"
		metaData = {
			contentType: contentType
			size: stats.size
			updated: stats.mtime.toUTCString()
		}
		# Return the file stream and the metadata
		return {fileStream: fs.createReadStream(fullPath), metaData: metaData}

	listFiles: (folderPath, recursive) =>
		if !folderPath
			folderPath = "."

		if !recursive?
			recursive = true

		fullPath = path.join(config.all.server.datafiles.relative_path, folderPath)

		# Check if the folder exists
		exists = await fs.promises.access(fullPath).then(() => true).catch(() => false)

		if !exists
			return []

		# List all files in the folder recursively but exclude folders
		files = await fs.promises.readdir fullPath, {withFileTypes: true}
		filePaths = await Promise.all files.map((file) =>
			filePath = path.join folderPath, file.name
			if file.isDirectory()
				if recursive
					return await @listFiles filePath
				else
					# If recursive is false then return an empty array which will be flattened later
					return []
			else
				return path: filePath
		)
		return Array.prototype.concat(...filePaths)

class ExternalFileHandler extends LocalFileHandler

class GCSFileHandler extends ExternalFileHandler

	init: ->
		@bucket = await @_getOrCreateBucket()

	_getOrCreateBucket: ->
		projectID = config.all.server.datafiles.gcs.projectID
		bucketName = config.all.server.datafiles.gcs.bucketName
		region = config.all.server.datafiles.gcs.bucketRegion
		clientEmail = config.all.server.datafiles.gcs.clientEmail
		privateKey = config.all.server.datafiles.gcs.privateKey
		storage = new Storage(
			projectId: projectID,
			credentials: {
				client_email: clientEmail,
				private_key: privateKey
			}
		)
		uniformBucketLevelAccess = true
		defaultAcl = [{entity: 'allUsers',role: storage.acl.READER_ROLE}]
		
		bucket = await storage.bucket(bucketName)
		[exists] = await bucket.exists()
		if exists
			console.log "Bucket #{bucketName} already exists."
			[bucket] = await bucket.get()
			return bucket
		else
			[bucket] = await storage.createBucket bucketName,
				location: region
				uniformBucketLevelAccess: uniformBucketLevelAccess
				defaultAcl: defaultAcl
				console.log "Bucket #{bucketName} created with uniform ACLs."
			return bucket
	
	copyFile: (sourceLocation, targetLocation, metaData)->
		if metaData == undefined
			metaData = {}
		else
			metadata = {
				metadata: metaData
			};
		[file] = await @bucket.upload(sourceLocation, {destination: targetLocation, metadata: metadata})
		console.log "Uploaded file #{sourceLocation} to #{targetLocation} in bucket #{@bucket.name} with metadata #{JSON.stringify(metadata)}"
		# Return both the file and the original file path
		return {sourceLocation: sourceLocation, targetLocation: targetLocation, metaData: metaData}

	getFile: (filePath) ->
		file = await @bucket.file(filePath)
		[exists] = await file.exists()
		if !exists
			throw new Error("File does not exist: #{filePath}")
		metaData = await file.getMetadata()
		fileStream = await file.createReadStream()
		metaData[0].contentType = metaData[0].contentType || 'application/octet-stream'
		return {fileStream: fileStream, metaData: metaData[0]}

	listFiles: (folderName, recursive) ->
		# If recursive is true, list all files in the folder and subfolders

		if folderName == undefined
			folderName = ''
		if recursive == undefined
			recursive = false
		
		options = prefix: folderName
		[files] = await @bucket.getFiles(options)
		# Lets just return an object like:
		# {
		# 	"path": path
		# }

		files = files.map (file) -> path: file.name
		return files

setupRoutes = (app, loginRoutes, requireLogin) ->

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
			safeName tempFilesPath, file.originalname, (safeFileName) ->
				callback(null, safeFileName)
		
		safeName = (dir, filename, callback) ->
			exists = await fs.promises.access(path.join(dir, filename)).then(() => true).catch(() => false)
			if exists
				filename = filename.replace(/(?:(?: \(([\d]+)\))?(\.[^.]+))?$/, (s, index, ext) ->
					' (' + ((parseInt(index, 10) or 0) + 1) + ')' + (ext or '')
				)
				safeName dir, filename, callback
			else
				callback filename
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
					filesToMove = []
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
						# If fileHandler extends ExternalFileHandler then we need to move the file to the external file system
						try
							uploadTempFilesConfig = config.all.server.service.external.file.uploadTempFiles
							if exports.fileHandler instanceof ExternalFileHandler && (uploadTempFilesConfig? || uploadTempFilesConfig == true)
								filesToMove.push({sourceLocation: file.filename, targetLocation: path.join(TMP_DIR, file.filename), meta: outfile})

								# We do not delete files on success as we need to keep them in the temp folder for the file upload to work
								deleteFilesOnSuccess = false

								# We don't await this as we want to move the files asynchronously
								exports.moveDataFilesInternal(filesToMove, deleteFilesOnSuccess)
						
						catch err
							console.error "Error moving tmp file to external file system: #{err}"
							resp.send(err)
							return
								
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

					filePath = req.params[0]
					console.log "Got request for file: #{filePath}"

					# If the file is in a folder then it's a persistant file
					knownNonPersistantBaseFolders = ['exportedSearchResults']
					isPersistantFile = false
					if filePath.indexOf(path.sep) > -1
						# Get the first folder
						firstFolder = filePath.split(path.sep)[0]
						if firstFolder in knownNonPersistantBaseFolders
							isPersistantFile = false
						else
							isPersistantFile = true
		
					try 
						if !isPersistantFile
							{fileStream, metaData} = await exports.localFileHandler.getFile(filePath)
						else
							{fileStream, metaData} = await exports.fileHandler.getFile(filePath)
						# Set the content type of the response to the content type of the metaData
						resp.set('Content-Type', metaData.contentType)
						resp.set('Content-Length', metaData.size)
						resp.set('Last-Modified', metaData.updated)
						fileStream.pipe(resp)
					catch err
						console.error(err)
						resp.send(err)

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
	app.post '/api/moveDataFiles', exports.moveDataFiles

exports.setupRoutes = (app, loginRoutes) ->
	setupRoutes app, loginRoutes, true
	app.delete '/dataFiles/*', loginRoutes.ensureAuthenticated, exports.deleteFile
	app.post '/api/moveDataFiles',  loginRoutes.ensureAuthenticated, exports.moveDataFiles

exports.deleteFile = (req, resp) ->
	# Not implemented currently. We added this route in order to fully support the jquery file upload plugin
	# which requires a delete route in order to function correctly with maxNumberOfFiles.
	# See details here: https://github.com/mcneilco/acas/pull/1085
	console.log 'Got DELETE request for data file: ' + req.params[0] + ' from user: ' + req.user.username
	console.log 'Not deleting file, just returning 200 OK'
	resp.send 200


exports.moveDataFiles = (req, resp) ->
	deleteSourceFileOnSuccess = if req.query?.deleteSourceFileOnSuccess? then req.query.deleteSourceFileOnSuccess == "true" else true
	files = await exports.moveDataFilesInternal(req.body, deleteSourceFileOnSuccess)
	resp.json files

exports.moveDataFilesInternal = (files, deleteSourceFileOnSuccess) ->
	return await exports.fileHandler.moveFiles(files, deleteSourceFileOnSuccess)


exports.migrateCmpdRegBulkLoaderFilesToSubfolders = () ->
	console.log "About to migrate cmpdReg bulk loader files to subfolders"
	cmpdRegBulkLoaderRoutes = require('./CmpdRegBulkLoaderRoutes.js')
	bulkLoadFiles = await cmpdRegBulkLoaderRoutes.getBulkloadFilesInternal()
	console.log "There are #{bulkLoadFiles.length} bulk load files in the DB"
	bulkLoadSubFolderFiles = await exports.localFileHandler.listFiles(cmpdRegBulkLoaderRoutes.BULKLOAD_SUB_FOLDER, false)
	console.log "There are #{bulkLoadSubFolderFiles.length} bulk load files in the local bulkload subfolder"
	if exports.fileHandler instanceof ExternalFileHandler
		externalBulkLoadSubFolderFiles = bulkLoadSubFolderFiles.concat(await exports.fileHandler.listFiles(cmpdRegBulkLoaderRoutes.BULKLOAD_SUB_FOLDER, false))
		console.log "There are #{externalBulkLoadSubFolderFiles.length} bulk load files in the external bulkload subfolder"
		# Organize by bulk load file id which is the first subfolder under the registered folder
		storedFilesByID = {}
		for file in externalBulkLoadSubFolderFiles
			fileID = path.basename(path.dirname(file.path))
			if !storedFilesByID[fileID]
				storedFilesByID[fileID] = []
			storedFilesByID[fileID].push(file)

	# For each of the bulkLoadFiles in the DB check if the file is in the storedFilesByID dict
	filesToMove = []
	for bulkLoadFile in bulkLoadFiles
		registeredFilesFolder = path.join(cmpdRegBulkLoaderRoutes.REGISTERED_FOLDER, bulkLoadFile.id.toString())
		registeredStoredFiles = await exports.localFileHandler.listFiles(registeredFilesFolder)
		fileNameNoExtension = path.basename(bulkLoadFile.fileName, path.extname(bulkLoadFile.fileName))
		
		# Find all bulkLoadSubFolderFiles files that start with the fileNameNoExtension
		matchingBulkLoadSubFolderFiles = bulkLoadSubFolderFiles.filter (file) ->
			path.basename(file.path).startsWith(fileNameNoExtension)

		if matchingBulkLoadSubFolderFiles.length == 0 && registeredStoredFiles.length == 0
			if exports.fileHandler instanceof ExternalFileHandler and storedFilesByID[bulkLoadFile.id.toString()]
				console.info("Found #{storedFilesByID[bulkLoadFile.id.toString()].length} files in the external bulkload subfolder for #{bulkLoadFile.fileName}")
			else
				console.error "Could not find any file #{bulkLoadFile.fileName} in the #{cmpdRegBulkLoaderRoutes.BULKLOAD_SUB_FOLDER} folder or in the #{registeredFilesFolder} folder"
			continue

		console.log "Found #{matchingBulkLoadSubFolderFiles.length} files in the #{cmpdRegBulkLoaderRoutes.BULKLOAD_SUB_FOLDER} folder and #{registeredStoredFiles.length} files in the #{registeredFilesFolder} folder"
			
		for file in matchingBulkLoadSubFolderFiles
			# We move the stored DB file name
			fileToMove = {
				sourceLocation: file.path,
				targetLocation: path.join(registeredFilesFolder, path.basename(file.path))
			}
			filesToMove.push(fileToMove)
	
	if filesToMove.length > 0
		console.log "Found #{filesToMove.length} files to move"
		await exports.localFileHandler.moveFiles(filesToMove, true)
	else 
		console.log "No files to move"
		
exports.migrateFromLocalToExternalFileHandler = (lockFile) ->

	if !(exports.fileHandler instanceof ExternalFileHandler)
		console.log "File handler is local file handler. No migration needed"
		return
	
	# First list all files the dataFiles folder recursively
	allFiles = await exports.localFileHandler.listFiles(".", true)
	# Remove the lock file from the list
	allFiles = allFiles.filter (file) ->
		file.path != path.basename(lockFile)
	console.log "Found #{allFiles.length} files to migrate to external file handler"

	# Do uploads of 100 files at a time
	for i in [0...allFiles.length] by 100
		files = allFiles.slice(i, i+100)
		console.log "Migrating files #{i} to #{i+files.length}"
		filesToMove = []
		for file in files
			sourceLocation = file.path
			# Check if the file path is in a directory or not
			if path.dirname(sourceLocation) == "."
				targetLocation = path.join(TMP_DIR, file.path)
			else
				targetLocation = file.path
			
			fileToMove = {
				sourceLocation: sourceLocation,
				targetLocation: targetLocation
			}
			filesToMove.push(fileToMove)
		
		# Move the files
		await exports.fileHandler.moveFiles(filesToMove, true)


exports.init = ->
	# Local file handler is used in some cases regardless of the external file handler type
	localFileHandler = new LocalFileHandler()
	if config.all.server.service.external.file.type == 'blueimp'
		# Local File Helper
		fileHandler = localFileHandler
	else if config.all.server.service.external.file.type == 'gcs'
		# New GCS Helper
		fileHandler = new GCSFileHandler()
	else
		throw new Error("Unknown file handler type: #{config.all.server.service.external.file.type}")
	console.log "Using #{fileHandler.constructor.name} as file handler"
	await fileHandler.init()
	exports.fileHandler = fileHandler
	exports.localFileHandler = localFileHandler


exports.init()