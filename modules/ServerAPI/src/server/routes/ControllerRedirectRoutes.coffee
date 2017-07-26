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
	code = req.params.code
	controllerRedirectConfFile = require '../src/javascripts/ServerAPI/ControllerRedirectConf.js'
	controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf
	queryPrefix = null
	prefixKeyIndex = 0
	while queryPrefix is null and prefixKeyIndex < (Object.keys(controllerRedirectConf)).length
		prefix = Object.keys(controllerRedirectConf)[prefixKeyIndex] #prefix = possible entity prefix
		if code.indexOf(prefix) > -1 #the requested route has a known entity prefix
			queryPrefix = prefix
		else
			prefixKeyIndex +=1

	console.log "in redirectToEditor"
	console.log config.all.client.entity.saveInitialsCorpName

	getEntityByName = (protOrExpt, resp) =>
		console.log "getEntityByName"
		protocolServiceRoutes = require './ProtocolServiceRoutes.js'
		experimentServiceRoutes = require './ExperimentServiceRoutes.js'
		if protOrExpt is 'protocolsWithCorpNames'
			protocolServiceRoutes.getProtocolByLabelInternal code, (statusCode, json) ->
				console.log "getEntityByName - getProtocolByLabelInternal "
				if statusCode is 500
					resp.redirect "/"
				else
					kind = json[0].lsKind
					deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"]
					console.log "/"+deepLink+"/codeName/"+code
					resp.redirect "/"+deepLink+"/codeName/"+code

		else if protOrExpt is 'experimentsWithCorpNames'
			experimentServiceRoutes.getExperimentByLabelInternal code, (statusCode, json) ->
				console.log "getEntityByName - getExperimentByLabelInternal"
				if statusCode is 500
					resp.redirect "/"
				else
					kind = json[0].lsKind
					deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"]
					console.log controllerRedirectConf[queryPrefix][kind]["deepLink"]
					resp.redirect "/"+deepLink+"/codeName/"+code

	getEntityByCodeName = (resp) =>
		request
			json: true
			url: config.all.server.nodeapi.path+"/api/"+controllerRedirectConf[queryPrefix]["entityName"]+"/codename/"+code
		, (error, response, body) =>
			console.log error
			console.log response
			console.log body
			kind = response.body.lsKind
			deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"]
			resp.redirect "/"+deepLink+"/codeName/"+code

	if queryPrefix != null
		console.log "url to get entity - in redirectToEditor"

		if config.all.client.entity.saveInitialsCorpName
			entityName = controllerRedirectConf[queryPrefix]["entityName"]
			if entityName is "protocolsWithCorpNames" or entityName is "experimentsWithCorpNames"
				#get entity by name
				getEntityByName entityName, resp
			else
				getEntityByCodeName resp
		else
			getEntityByCodeName resp
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
