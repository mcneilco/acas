_ = require 'underscore'
request = require 'request'


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/entity/edit/codeName/:code', loginRoutes.ensureAuthenticated, exports.redirectToEditor
	app.get '/api/labelsequences', loginRoutes.ensureAuthenticated, exports.getLabelSequences

config = require '../conf/compiled/conf.js'


exports.redirectToEditor = (req, resp) ->
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		controllerRedirectConfFile = require '../conf/ControllerRedirectConf.js'
		controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf
		queryPrefix = null
		prefixKeyIndex = 0
		while queryPrefix is null and prefixKeyIndex < (Object.keys(controllerRedirectConf)).length
			prefix = Object.keys(controllerRedirectConf)[prefixKeyIndex] #prefix = possible entity prefix
			if req.params.code.indexOf(prefix) > -1 #the requested route has a known entity prefix
				queryPrefix = prefix
			else
				prefixKeyIndex +=1

		if queryPrefix != null
			isStub = controllerRedirectConf[queryPrefix]["stub"] #true if getting entity returns a stub
			request
				json: true
				url: "http://localhost:"+config.all.server.nodeapi.port+"/api/"+controllerRedirectConf[queryPrefix]["entityName"]+"/codename/"+req.params.code #redirect route
			, (error, response, body) =>
				if isStub
					stub = response.body[0]
					kind = stub.lsKind
				else
					kind = response.body.lsKind
				deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"]
				resp.redirect "/"+deepLink+"/codeName/"+req.params.code

		else
			resp.redirect "/#"

	else
		controllerRedirectConfFile = require '../conf/ControllerRedirectConf.js'
		controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf
		queryPrefix = null
		prefixKeyIndex = 0
		while queryPrefix is null and prefixKeyIndex < (Object.keys(controllerRedirectConf)).length
			prefix = Object.keys(controllerRedirectConf)[prefixKeyIndex] #prefix = possible entity prefix
			if req.params.code.indexOf(prefix) > -1 #the requested route has a known entity prefix
				queryPrefix = prefix
			else
				prefixKeyIndex +=1

		if queryPrefix != null
			request
				json: true
				url: config.all.server.nodeapi.path+"/api/"+controllerRedirectConf[queryPrefix]["entityName"]+"/codename/"+req.params.code #get protocol
			, (error, response, body) =>
#				kind = response.body.lsKind #from lsThing-eva
				console.log error
				console.log response
				console.log body
				kind = response.body[0].lsKind #from development
				deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"]
				resp.redirect "/"+deepLink+"/codeName/"+req.params.code

		else
			resp.redirect "/#"

exports.getLabelSequences = (req, resp) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"/labelsequences"
	serverUtilityFunctions.getFromACASServer(baseurl, resp)
