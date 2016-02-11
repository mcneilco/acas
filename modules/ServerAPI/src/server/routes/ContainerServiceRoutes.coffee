exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/containers', exports.getAllContainers
	app.get '/api/containers/:lsType/:lsKind', exports.containersByTypeKind
	app.get '/api/containers/:code', exports.containerByCodeName
	app.post '/api/containers', exports.postContainer
	app.put '/api/containers/:code', exports.putContainer
	app.post '/api/validateContainerName', exports.validateContainerName
	app.post '/api/getContainerCodesFromLabels', exports.getContainerCodesFromLabels
	app.post '/api/getContainerFromLabel', exports.getContainerFromLabel

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/containers', loginRoutes.ensureAuthenticated, exports.getAllContainers
	app.get '/api/containers/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.containersByTypeKind
	app.get '/api/containers/:code', loginRoutes.ensureAuthenticated, exports.containerByCodeName
	app.post '/api/containers', loginRoutes.ensureAuthenticated, exports.postContainer
	app.put '/api/containers/:code', loginRoutes.ensureAuthenticated, exports.putContainer
	app.post '/api/validateContainerName', loginRoutes.ensureAuthenticated, exports.validateContainerName
	app.post '/api/getContainerCodesFromLabels', loginRoutes.ensureAuthenticated, exports.getContainerCodesFromLabels
	app.post '/api/getContainerFromLabel', loginRoutes.ensureAuthenticated, exports.getContainerFromLabel


serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'


exports.getAllContainers = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json containerTestJSON.container
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers"
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.containersByTypeKind = (req, resp) ->
	config = require '../conf/compiled/conf.js'
	if req.query.format? and req.query.format=="codetable" #ie has '?format=codetable' appended to end of api route
		if req.query.testMode or global.specRunnerTestmode
			resp.end JSON.stringify "stubsMode for getting containers in codetable format not implemented yet"
		else
			baseurl = config.all.client.service.persistence.fullpath+"containers/codetable?lsType=#{req.params.lsType}&lsKind=#{req.params.lsKind}"
			stubFlag = "with=stub"
			if req.query.stub
				baseurl += "?#{stubFlag}"
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

	else
		if req.query.testMode or global.specRunnerTestmode
			thingServiceTestJSON = require '../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js'
			resp.end JSON.stringify thingServiceTestJSON.batchList
		else
			baseurl = config.all.client.service.persistence.fullpath+"containers?lsType="+req.params.lsType+"&lsKind="+req.params.lsKind
			console.log "containers by type and kind"
			console.log baseurl
			stubFlag = "with=stub"
			if req.query.stub
				baseurl += "?#{stubFlag}"
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.containerByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json containerTestJSON.container
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/"+req.params.code
		serverUtilityFunctions.getFromACASServer(baseurl, resp)


updateContainer = (container, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serverUtilityFunctions.createLSTransaction container.recordedDate, "updated experiment", (transaction) ->
		container = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, container
		if testMode or global.specRunnerTestmode
			callback container
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"containers/"+container.code
			request = require 'request'
			request(
				method: 'PUT'
				url: baseurl
				body: container
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 200
					callback json
				else
					console.log 'got ajax error trying to update lsContainer'
					console.log error
					console.log response
			)


postContainer = (req, resp) ->
	console.log "post container"
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	containerToSave = req.body
	serverUtilityFunctions.createLSTransaction containerToSave.recordedDate, "new experiment", (transaction) ->
		containerToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, containerToSave
		if req.query.testMode or global.specRunnerTestmode
			unless containerToSave.codeName?
				containerToSave.codeName = "PT00002-1"

		checkFilesAndUpdate = (container) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity container, false
			filesToSave = fileVals.length

			completeContainerUpdate = (containerToUpdate)->
				updateContainer containerToUpdate, req.query.testMode, (updatedContainer) ->
					resp.json updatedContainer

			fileSaveCompleted = (passed) ->
				if !passed
					resp.statusCode = 500
					return resp.end "file move failed"
				if --filesToSave == 0 then completeContainerUpdate(container)

			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode container.codeName
				for fv in fileVals
					console.log "updating file"
					csUtilities.relocateEntityFile fv, prefix, container.codeName, fileSaveCompleted
			else
				resp.json container

		if req.query.testMode or global.specRunnerTestmode
			checkFilesAndUpdate containerToSave
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"containers"
			request = require 'request'
			request(
				method: 'POST'
				url: baseurl
				body: containerToSave
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 201
					checkFilesAndUpdate json
				else
					console.log 'got ajax error trying to save lsContainer'
					console.log error
					console.log json
					console.log response
			)

exports.postContainer = (req, resp) ->
	postContainer req, resp

exports.putContainer = (req, resp) ->
#	if req.query.testMode or global.specRunnerTestmode
#		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
#		containerToSave = JSON.parse(JSON.stringify(containerTestJSON.container))
#	else
	containerToSave = req.body
	fileVals = serverUtilityFunctions.getFileValuesFromEntity containerToSave, true
	filesToSave = fileVals.length

	completeContainerUpdate = ->
		updateContainer containerToSave, req.query.testMode, (updatedContainer) ->
			resp.json updatedContainer

	fileSaveCompleted = (passed) ->
		if !passed
			resp.statusCode = 500
			return resp.end "file move failed"
		if --filesToSave == 0 then completeContainerUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromEntityCode req.body.codeName
		for fv in fileVals
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, req.body.codeName, fileSaveCompleted
	else
		completeContainerUpdate()

exports.validateContainerName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		containerTestJSON = require '../public/javascripts/spec/testFixtures/ContainerServiceTestJSON.js'
		resp.json true
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/validate"
#		if req.params.componentOrAssembly is "component"
#			baseurl += "?uniqueName=true"
#		else #is assembly
#			baseurl += "?uniqueName=true&uniqueInteractions=true&orderMatters=true&forwardAndReverseAreSame=true"
		request = require 'request'
		console.log "validate container name body"
		console.log req.body
		console.log req.body.container
		request(
			method: 'POST'
			url: baseurl
			body: req.body.container
			json: true
		, (error, response, json) =>
			console.log "response"
			console.log json
			console.log response.statusCode
			if !error && response.statusCode == 202
				resp.json true
			else if response.statusCode == 409
				resp.json json
			else
				console.log 'got ajax error trying to validate container name'
				console.log error
				console.log json
				console.log response
				resp.json "error"
		)

exports.getContainerCodesFromNamesOrCodes = (codeRequest, callback) ->
	console.log "got to getContainerCodesFormNamesOrCodes"
	if global.specRunnerTestmode
		results = []
		for req in codeRequest.requests
			res = requestName: req.requestName
			if req.requestName.indexOf("ambiguous") > -1
				res.referenceName = ""
				res.preferredName = ""
			else if req.requestName.indexOf("name") > -1
				res.referenceName = "CONT1111"
				res.preferredName = "1111"
			else if req.requestName.indexOf("1111") > -1
				res.referenceName = "CONT1111"
				res.preferredName = "1111"
			else
				res.referenceName = req.requestName
				res.preferredName = req.requestName
			results.push res
		response =
			containerType: codeRequest.containerType
			containerKind: codeRequest.containerKind
			results: results

		callback response
	else
		config = require '../conf/compiled/conf.js'
		#TODO: replace with new url
		baseurl = config.all.client.service.persistence.fullpath+"containers/getCodeNameFromNameRequest?"
#		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels?"
		url = baseurl+"containerType=#{codeRequest.containerType}&containerKind=#{codeRequest.containerKind}"
		postBody = requests: codeRequest.requests
		console.log postBody
		console.log url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			console.log json
			if !error and !json.error
				callback
					containerType: codeRequest.containerType
					containerKind: codeRequest.containerKind
					results: json.results
			else
				console.log 'got ajax error trying to lookup lsContainer name'
				console.log error
				console.log response
				callback json
		)

getContainerCodesFromLabels = (req, callback) ->

	if global.specRunnerTestmode
		response =
			codeName: 'CONT-0000001'
			label: 'test label'
		callback response

	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"containers/getContainerCodesByLabels?"
		url = baseurl+"containerType=#{req.body.containerType}&containerKind=#{req.body.containerKind}"
		postBody = req.body.labels
		console.log postBody
		console.log url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: postBody
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			console.log json
			if !error and !json.error
				callback json
			else
				console.log 'got ajax error trying to lookup lsContainer name'
				console.log error
				console.log response
				callback json
		)

exports.getContainerCodesFromLabels = (req, resp) ->

	getContainerCodesFromLabels req, (json) ->
		resp.json json


exports.getContainerFromLabel = (req, resp) -> #only for sending in 1 label and expecting to get 1 container back
	getContainerCodesFromLabels req, (json) ->
		if json[0]?.codeName? #assumes that labels are unique
			req.params.code = json[0].codeName
			exports.containerByCodeName req, resp
		else
			resp.json {}
