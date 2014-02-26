
startApp = ->

	config = require '../../conf/compiled/conf.js'
	express = require('express')
	global.deployMode = config.all.client.deployMode
	global.blueimp = express()
	blueimp.configure( ->
		blueimp.set('port', config.all.client.service.file.port)
	)

	"use strict"
	path = require("path")
	fs = require("fs")

	# Since Node 0.8, .existsSync() moved from path to fs:
	_existsSync = fs.existsSync or path.existsSync
	formidable = require("formidable")
	nodeStatic = require("node-static")
	imageMagick = require("imagemagick")
	options =
		tmpDir: __dirname + "/tmp"
		publicDir: __dirname + "/public"
		uploadDir: __dirname + "/public/files"
		uploadUrl: "/files/"
		maxPostSize: 500000000 # 500 MB
		minFileSize: 1
		maxFileSize: 100000000 # 100 MB
		acceptFileTypes: /.+/i

	# Files not matched by this regular expression force a download dialog,
	# to prevent executing any scripts in the context of the service domain:
		safeFileTypes: /\.(gif|jpe?g|png)$/i
		imageTypes: /\.(gif|jpe?g|png)$/i
		imageVersions:
			thumbnail:
				width: 80
				height: 80

		accessControl:
			allowOrigin: "*"
			allowMethods: "OPTIONS, HEAD, GET, POST, PUT, DELETE"


	# Uncomment and edit this section to provide the service via HTTPS:
	#            ssl: {
	#                key: fs.readFileSync('/Applications/XAMPP/etc/ssl.key/server.key'),
	#                cert: fs.readFileSync('/Applications/XAMPP/etc/ssl.crt/server.crt')
	#            },
	#
		nodeStatic:
			cache: 3600 # seconds to cache served files

	utf8encode = (str) ->
		unescape encodeURIComponent(str)

	fileServer = new nodeStatic.Server(options.publicDir, options.nodeStatic)
	nameCountRegexp = /(?:(?: \(([\d]+)\))?(\.[^.]+))?$/
	nameCountFunc = (s, index, ext) ->
		" (" + ((parseInt(index, 10) or 0) + 1) + ")" + (ext or "")

	FileInfo = (file) ->
		@name = file.name
		@size = file.size
		@type = file.type
		@delete_type = "DELETE"
		return

	UploadHandler = (req, res, callback) ->
		@req = req
		@res = res
		@callback = callback
		return

	serve = (req, res) ->
		res.setHeader "Access-Control-Allow-Origin", options.accessControl.allowOrigin
		res.setHeader "Access-Control-Allow-Methods", options.accessControl.allowMethods
		handleResult = (result, redirect) ->
			if redirect
				res.writeHead 302,
					Location: redirect.replace(/%s/, encodeURIComponent(JSON.stringify(result)))

				res.end()
			else
				res.writeHead 200,
					"Content-Type": (if req.headers.accept.indexOf("application/json") isnt -1 then "application/json" else "text/plain")

				res.end JSON.stringify(result)
			return

		setNoCacheHeaders = ->
			res.setHeader "Pragma", "no-cache"
			res.setHeader "Cache-Control", "no-store, no-cache, must-revalidate"
			res.setHeader "Content-Disposition", "inline; filename=\"files.json\""
			return

		handler = new UploadHandler(req, res, handleResult)
		switch req.method
			when "OPTIONS"
				res.end()
			when "HEAD", "GET"
				if req.url is "/"
					setNoCacheHeaders()
					if req.method is "GET"
						handler.get()
					else
						res.end()
				else
					fileServer.serve req, res
			when "POST"

			#		options.uploadDir = options.uploadDir +  "testingPleaseWork/"
				setNoCacheHeaders()
				handler.post()
			when "DELETE"
				handler.destroy()
			else
				res.statusCode = 405
				res.end()
		return

	fileServer.respond = (pathname, status, _headers, files, stat, req, res, finish) ->
		unless options.safeFileTypes.test(files[0])

			# Force a download dialog for unsafe file extensions:
			res.setHeader "Content-Disposition", "attachment; filename=\"" + utf8encode(path.basename(files[0])) + "\""
		else

			# Prevent Internet Explorer from MIME-sniffing the content-type:
			res.setHeader "X-Content-Type-Options", "nosniff"
		nodeStatic.Server::respond.call this, pathname, status, _headers, files, stat, req, res, finish
		return

	FileInfo::validate = ->
		if options.minFileSize and options.minFileSize > @size
			@error = "minFileSize"
		else if options.maxFileSize and options.maxFileSize < @size
			@error = "maxFileSize"
		else @error = "acceptFileTypes"  unless options.acceptFileTypes.test(@name)
		not @error

	FileInfo::safeName = ->

		# Prevent directory traversal and creating hidden system files:
		@name = path.basename(@name).replace(/^\.+/, "")

		# Prevent overwriting existing files:
		@name = @name.replace(nameCountRegexp, nameCountFunc)  while _existsSync(options.uploadDir + "/" + @name)
		return

	FileInfo::initUrls = (req) ->
		unless @error
			that = this
			baseUrl = ((if options.ssl then "https:" else "http:")) + "//" + req.headers.host + options.uploadUrl
			@url = @delete_url = baseUrl + encodeURIComponent(@name)
			Object.keys(options.imageVersions).forEach (version) ->
				that[version + "_url"] = baseUrl + version + "/" + encodeURIComponent(that.name)  if _existsSync(options.uploadDir + "/" + version + "/" + that.name)
				return

		return

	UploadHandler::get = ->
		handler = this
		files = []
		fs.readdir options.uploadDir, (err, list) ->
			list.forEach (name) ->
				stats = fs.statSync(options.uploadDir + "/" + name)
				fileInfo = undefined
				if stats.isFile()
					fileInfo = new FileInfo(
						name: name
						size: stats.size
					)
					fileInfo.initUrls handler.req
					files.push fileInfo
				return

			handler.callback files
			return

		return

	UploadHandler::post = ->
		handler = this
		form = new formidable.IncomingForm()
		tmpFiles = []
		files = []
		map = {}
		counter = 1
		redirect = undefined
		finish = ->
			counter -= 1
			unless counter
				files.forEach (fileInfo) ->
					fileInfo.initUrls handler.req
					return

				handler.callback files, redirect
			return

		form.uploadDir = options.tmpDir
		form.on("fileBegin", (name, file) ->
			tmpFiles.push file.path
			fileInfo = new FileInfo(file, handler.req, true)
			fileInfo.safeName()
			map[path.basename(file.path)] = fileInfo
			files.push fileInfo
			return
		).on("field", (name, value) ->
			redirect = value  if name is "redirect"
			return
		).on("file", (name, file) ->
			fileInfo = map[path.basename(file.path)]
			fileInfo.size = file.size
			unless fileInfo.validate()
				fs.unlink file.path
				return
			fs.renameSync file.path, options.uploadDir + "/" + fileInfo.name
			if options.imageTypes.test(fileInfo.name)
				Object.keys(options.imageVersions).forEach (version) ->
					counter += 1
					opts = options.imageVersions[version]
					imageMagick.resize
						width: opts.width
						height: opts.height
						srcPath: options.uploadDir + "/" + fileInfo.name
						dstPath: options.uploadDir + "/" + version + "/" + fileInfo.name
					, finish
					return

			return
		).on("aborted", ->
			tmpFiles.forEach (file) ->
				fs.unlink file
				return

			return
		).on("progress", (bytesReceived, bytesExpected) ->
			handler.req.connection.destroy()  if bytesReceived > options.maxPostSize
			return
		).on("end", finish).parse handler.req
		return

	UploadHandler::destroy = ->
		handler = this
		fileName = undefined
		if handler.req.url.slice(0, options.uploadUrl.length) is options.uploadUrl
			fileName = path.basename(decodeURIComponent(handler.req.url))
			fs.unlink options.uploadDir + "/" + fileName, (ex) ->
				Object.keys(options.imageVersions).forEach (version) ->
					fs.unlink options.uploadDir + "/" + version + "/" + fileName
					return

				handler.callback not ex
				return

		else
			handler.callback false
		return
	console.log "Starting blueimp file server on port: " + blueimp.get('port')
	if options.ssl
		require("https").createServer(options.ssl, serve).listen blueimp.get('port')
	else
		require("http").createServer(serve).listen blueimp.get('port')
	return

startApp()