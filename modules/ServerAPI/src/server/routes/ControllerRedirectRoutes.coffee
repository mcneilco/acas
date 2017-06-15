_ = require 'underscore'
request = require 'request'

exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/entity/edit/codeName/:code', exports.redirectToEditor
	app.get '/api/getControllerRedirectConf', exports.getControllerRedirectConf

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/entity/edit/codeName/:code', loginRoutes.ensureAuthenticated, exports.redirectToEditor
	app.get '/api/labelsequences', loginRoutes.ensureAuthenticated, exports.getLabelSequences
	app.get '/api/getControllerRedirectConf', loginRoutes.ensureAuthenticated, exports.getControllerRedirectConf

config = require '../conf/compiled/conf.js'


exports.redirectToEditor = (req, resp) ->
	controllerRedirectConfFile = require '../src/javascripts/ServerAPI/ControllerRedirectConf.js'
	controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf
	queryPrefix = null
	prefixKeyIndex = 0
	while queryPrefix is null and prefixKeyIndex < (Object.keys(controllerRedirectConf)).length
		prefix = Object.keys(controllerRedirectConf)[prefixKeyIndex] #prefix = possible entity prefix
		if req.params.code.indexOf(prefix) > -1 #the requested route has a known entity prefix
			queryPrefix = prefix
		else
			prefixKeyIndex +=1

	console.log "in redirectToEditor"
	if req.params.code.substring(0,5) is "STUDY"
		resp.redirect "/study_tracker_experiment/codeName/#{req.params.code}"
	else if req.params.code.substring(0,3) is "EXP" #TODO: refactor to get expt and then figure out kind and deeplink appropriately
		resp.redirect "/experiment_base/codeName/#{req.params.code}"
	else if req.params.code.substring(0,3) is "PRT" #TODO: refactor to get prot and then figure out kind and deeplink appropriately
		resp.redirect "/protocol_base/codeName/#{req.params.code}"

	else if queryPrefix != null
		request
			json: true
			url: config.all.server.nodeapi.path+"/api/"+controllerRedirectConf[queryPrefix]["entityName"]+"/codename/"+req.params.code #get protocol
		, (error, response, body) =>
			console.log error
			console.log response
			console.log body
			kind = response.body.lsKind
			deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"]
			resp.redirect "/"+deepLink+"/codeName/"+req.params.code
	else
		resp.redirect "/#"

exports.getLabelSequences = (req, resp) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	baseurl = config.all.client.service.persistence.fullpath+"/labelsequences"
	serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getControllerRedirectConf = (req, resp) ->
	controllerRedirectConfFile = require '../src/javascripts/ServerAPI/ControllerRedirectConf.js'
	controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf
	resp.json controllerRedirectConf
