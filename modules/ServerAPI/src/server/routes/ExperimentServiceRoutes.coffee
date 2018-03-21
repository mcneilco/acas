exports.setupAPIRoutes = (app) ->
	app.get '/api/experiments/codename/:code', exports.experimentByCodename
	app.get '/api/experiments/experimentName/:name', exports.experimentByName
	app.get '/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', exports.experimentById
	app.get '/api/experiments', exports.experimentsAll
	app.get '/api/experiments/:idOrCode/exptvalues/bystate/:stateType/:stateKind/byvalue/:valueType/:valueKind', exports.experimentValueByStateTypeKindAndValueTypeKind
	app.post '/api/experiments', exports.postExperiment
	app.put '/api/experiments/:id', exports.putExperiment
	app.get '/api/experiments/resultViewerURL/:code', exports.resultViewerURLByExperimentCodename
	app.delete '/api/experiments/:id', exports.deleteExperiment
	app.get '/api/getItxExptExptsByFirstExpt/:firstExptId', exports.getItxExptExptsByFirstExpt
	app.get '/api/getItxExptExptsBySecondExpt/:secondExptId', exports.getItxExptExptsBySecondExpt
	app.post '/api/createAndUpdateExptExptItxs', exports.createAndUpdateExptExptItxs
	app.post '/api/postExptExptItxs', exports.postExptExptItxs
	app.put '/api/putExptExptItxs', exports.putExptExptItxs
	app.post '/api/experiments/getByCodeNamesArray', exports.experimentsByCodeNamesArray
	app.post '/api/getExptExptItxsToDisplay/:firstExptId', exports.getExptExptItxsToDisplay
	app.post '/api/experiments/parentExperiment', exports.postParentExperiment
	app.put '/api/experiments/parentExperiment/:id', exports.putParentExperiment
	app.get '/api/experiments/genericSearch/:searchTerm', exports.genericExperimentSearch
	app.get '/api/experiments/:lsType/:lsKind', exports.experimentsByTypeKind
	app.get '/api/getExperimentByLabel/:exptLabel', exports.getExperimentByLabel
	app.post '/api/experiments/getExperimentCodeByLabel/:exptType/:exptKind', exports.getExperimentCodeByLabel
	app.post '/api/bulkPostExperiments', exports.bulkPostExperiments
	app.put '/api/bulkPutExperiments', exports.bulkPutExperiments

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename
	app.get '/api/experiments/experimentName/:name', loginRoutes.ensureAuthenticated, exports.experimentByName
	app.get '/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById
	app.get '/api/experiments', loginRoutes.ensureAuthenticated, exports.experimentsAll
	app.get '/api/experiments/:idOrCode/exptvalues/bystate/:stateType/:stateKind/byvalue/:valueType/:valueKind', loginRoutes.ensureAuthenticated, exports.experimentValueByStateTypeKindAndValueTypeKind
	app.post '/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment
	app.put '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment
	app.get '/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch
	app.delete '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.deleteExperiment
	app.get '/api/experiments/resultViewerURL/:code', loginRoutes.ensureAuthenticated, exports.resultViewerURLByExperimentCodename
	app.get '/api/experiments/values/:id', loginRoutes.ensureAuthenticated, exports.experimentValueById
	app.get '/api/getItxExptExptsByFirstExpt/:firstExptId', loginRoutes.ensureAuthenticated, exports.getItxExptExptsByFirstExpt
	app.get '/api/getItxExptExptsBySecondExpt/:secondExptId', loginRoutes.ensureAuthenticated, exports.getItxExptExptsBySecondExpt
	app.post '/api/createAndUpdateExptExptItxs', loginRoutes.ensureAuthenticated, exports.createAndUpdateExptExptItxs
	app.post '/api/postExptExptItxs', loginRoutes.ensureAuthenticated, exports.postExptExptItxs
	app.put '/api/putExptExptItxs', loginRoutes.ensureAuthenticated, exports.putExptExptItxs
	app.post '/api/experiments/getByCodeNamesArray', loginRoutes.ensureAuthenticated, exports.experimentsByCodeNamesArray
	app.post '/api/getExptExptItxsToDisplay/:firstExptId', loginRoutes.ensureAuthenticated, exports.getExptExptItxsToDisplay
	app.post '/api/experiments/parentExperiment', loginRoutes.ensureAuthenticated, exports.postParentExperiment
	app.put '/api/experiments/parentExperiment/:id', loginRoutes.ensureAuthenticated, exports.putParentExperiment
	app.get '/api/experiments/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.experimentsByTypeKind
	app.get '/api/getExperimentByLabel/:exptLabel', loginRoutes.ensureAuthenticated, exports.getExperimentByLabel
	app.post '/api/experiments/getExperimentCodeByLabel/:exptType/:exptKind', loginRoutes.ensureAuthenticated, exports.getExperimentCodeByLabel
	app.post '/api/bulkPostExperiments', loginRoutes.ensureAuthenticated, exports.bulkPostExperiments
	app.put '/api/bulkPostExperiments', loginRoutes.ensureAuthenticated, exports.bulkPutExperiments

serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
_ = require 'underscore'
config = require '../conf/compiled/conf.js'
request = require 'request'

exports.experimentByCodename = (req, resp) ->
	console.log req.params.code
	console.log req.query.testMode
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
#		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
		expt = JSON.parse(JSON.stringify (experimentServiceTestJSON.fullExperimentFromServer))

		if req.params.code.indexOf("screening") > -1
			expt.lsKind = "Bio Activity"

		else
			expt.lsKind = "default"

		resp.json expt

	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+req.params.code
		fullObjectFlag = "with=fullobject"
		if req.query.fullObject
			baseurl += "?#{fullObjectFlag}"
		if req.user? && config.all.server.project.roles.enable
			serverUtilityFunctions.getRestrictedEntityFromACASServerInternal baseurl, req.user.username, "metadata", "experiment metadata", (statusCode, json) =>
				#if expt is deleted, need to check if user has privs to view deleted experiments
				if json.codeName?
					if json.ignored
						if json.deleted
							resp.statusCode = 500
							resp.end JSON.stringify "Experiment does not exist"
						else
							if config.all.client.entity?.viewDeletedRoles?
								viewDeletedRoles = config.all.client.entity.viewDeletedRoles.split(",")
							else
								viewDeletedRoles = []
							grantedRoles = _.map req.user.roles, (role) ->
								role.roleEntry.roleName
							canViewDeleted = (viewDeletedRoles in grantedRoles)
							if canViewDeleted
								resp.statusCode = statusCode
								resp.end JSON.stringify json
							else
								resp.statusCode = 500
								resp.end JSON.stringify "Experiment does not exist"
					else
						resp.statusCode = statusCode
						resp.json json
				else
					resp.statusCode = statusCode
					resp.end JSON.stringify json
		else
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.experimentByName = (req, resp) ->
	console.log "exports.experiment by name"
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		#		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
		resp.end JSON.stringify [experimentServiceTestJSON.fullExperimentFromServer]

	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments?findByName&name="+req.params.name
		console.log baseurl
#		fullObjectFlag = "with=fullobject"
#		if req.query.fullObject
#			baseurl += "?#{fullObjectFlag}"
#			serverUtilityFunctions.getFromACASServer(baseurl, resp)
#		else
#			serverUtilityFunctions.getFromACASServer(baseurl, resp)
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.experimentsByProtocolCodename = (request, response) ->
	console.log request.params.code
	console.log request.query.testMode

	if request.query.testMode or global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		response.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/protocolCodename/"+request.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, response)

exports.experimentById = (req, resp) ->
	console.log req.params.id
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.experimentsAll = (req, resp) ->
	console.log req.params.id
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer
	else
		config = require '../conf/compiled/conf.js'
		if req.query?.lsType? && req.query?.lsKind?
			baseurl = config.all.client.service.persistence.fullpath+"experiments/bytypekind/"+req.query.lsType+"/"+req.query.lsKind
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			serverUtilityFunctions.getFromACASServer(baseurl, resp)
		else
			baseurl = config.all.client.service.persistence.fullpath+"experiments"
			serverUtilityFunctions = require './ServerUtilityFunctions.js'
			serverUtilityFunctions.getFromACASServer(baseurl, resp)

updateExpt = (expt, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	serverUtilityFunctions.createLSTransaction expt.recordedDate, "updated experiment", (transaction) ->
		expt = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, expt
		if testMode or global.specRunnerTestmode
			callback expt
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"experiments/"+expt.id
			request = require 'request'
			console.log "put expt"
			console.log JSON.stringify expt
			request(
				method: 'PUT'
				url: baseurl
				body: expt
				json: true
			, (error, response, json) =>
				if response.statusCode == 409
					console.log 'got ajax error trying to update experiment - not unique name'
					if response.body[0].message is "not unique experiment name"
						callback JSON.stringify response.body[0].message
				else if !error && response.statusCode == 200
					callback json
				else
					console.log 'got ajax error trying to update experiment'
					console.log error
					console.log response
					callback "saveFailed"
			)

exports.postExperimentInternal = (exptToSave, testMode, callback) ->
	console.log "posting experiment"
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
#	exptToSave = req.body
	serverUtilityFunctions.createLSTransaction exptToSave.recordedDate, "new experiment", (transaction) ->
		exptToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, exptToSave
		if testMode or global.specRunnerTestmode
#		if req.query.testMode or global.specRunnerTestmode
			unless exptToSave.codeName?
				exptToSave.codeName = "EXPT-00000001"
			unless exptToSave.id?
				exptToSave.id = 1

		checkFilesAndUpdate = (expt) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity expt, false
			filesToSave = fileVals.length

			completeExptUpdate = (exptToUpdate)->
				updateExpt exptToUpdate, testMode, (updatedExpt) ->
					callback updatedExpt

			fileSaveCompleted = (passed) ->
				if !passed
					resp.statusCode = 500
					return resp.end "file move failed"
				if --filesToSave == 0 then completeExptUpdate(expt)

			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode expt.codeName
				for fv in fileVals
					csUtilities.relocateEntityFile fv, prefix, expt.codeName, fileSaveCompleted
			else
				callback expt

		if testMode or global.specRunnerTestmode
			checkFilesAndUpdate exptToSave
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"experiments"
			request = require 'request'
			request(
				method: 'POST'
				url: baseurl
				body: exptToSave
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 201
					checkFilesAndUpdate json
				else
					console.log 'got ajax error trying to save experiment - not unique name'
					if response.body[0].message is "not unique experiment name"
						callback "saveFailed: " + response.body[0].message
					else
						callback "saveFailed"
			)

exports.saveNewExpriment = (exptToSave, testMode, callback) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	#exptToSave = req.body
	serverUtilityFunctions.createLSTransaction exptToSave.recordedDate, "new experiment", (transaction) ->
		#console.log "exptToSave"
		#console.log exptToSave
		#console.log "transaction"
		#console.log transaction
		exptToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, exptToSave
		if testMode or global.specRunnerTestmode
			unless exptToSave.codeName?
				exptToSave.codeName = "EXPT-00000001"
			unless exptToSave.id?
				exptToSave.id = 1

		checkFilesAndUpdate = (expt) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity expt, false
			filesToSave = fileVals.length

			completeExptUpdate = (exptToUpdate)->
				updateExpt exptToUpdate, testMode, (updatedExpt) ->
					callback null, updatedExpt

			fileSaveCompleted = (passed) ->
				if !passed
					callback "file move failed", null
					#return resp.end "file move failed"
				if --filesToSave == 0 then completeExptUpdate(expt)

			if filesToSave > 0
				prefix = serverUtilityFunctions.getPrefixFromEntityCode expt.codeName
				for fv in fileVals
					csUtilities.relocateEntityFile fv, prefix, expt.codeName, fileSaveCompleted
			else
				callback null, expt

		if testMode or global.specRunnerTestmode
			checkFilesAndUpdate exptToSave
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.persistence.fullpath+"experiments"
			request = require 'request'
			request(
				method: 'POST'
				url: baseurl
				body: exptToSave
				json: true
			, (error, response, json) =>
				if !error && response.statusCode == 201
					checkFilesAndUpdate json
				else
					console.log 'got ajax error trying to save experiment - not unique name'
					console.log "response"
					console.log response
					if response.body[0].message is "not unique experiment name"
						callback null, exptToSave # JSON.stringify response.body[0].message
					else
						callback "saveFailed", exptToSave #null
			)

exports.postExperiment = (req, resp) ->
	#remove the itxs attributes if needed
	newExptExptItxs = []
	exptExptItxsToIgnore = []
	if req.body.exptExptItxsToIgnore?
		exptExptItxsToIgnore = req.body.exptExptItxsToIgnore
		exptExptItxsToIgnore = JSON.parse exptExptItxsToIgnore
		delete req.body.exptExptItxsToIgnore
	if req.body.newExptExptItxs?
		newExptExptItxs = req.body.newExptExptItxs
		newExptExptItxs = JSON.parse newExptExptItxs
		delete req.body.newExptExptItxs
		
	exports.postExperimentInternal req.body, req.query.testMode, (response) =>
		if response.codeName? and (newExptExptItxs.length > 0 or exptExptItxsToIgnore.length > 0)
			_.each exptExptItxsToIgnore, (itx) =>
				itx.secondExperiment = {id: response.id}
			_.each newExptExptItxs, (itx) =>
				itx.secondExperiment = {id: response.id}
			console.log "exptExptItxsToIgnore"
			console.log exptExptItxsToIgnore
			console.log "newExptExptItxs"
			console.log JSON.stringify newExptExptItxs
			exports.createAndUpdateExptExptItxsInternal JSON.stringify(exptExptItxsToIgnore), JSON.stringify(newExptExptItxs), req.query.testMode, (json) =>
				console.log "finished createAndUpdateExptExptItxs"
				console.log exptExptItxsToIgnore
				console.log newExptExptItxs
				console.log json
				if json.indexOf("saveFailed") > -1
					console.log "error creating and updating expt expt itxs"
					resp.statusCode = 500
					resp.json "error creating and updating expt expt itxs"
				else
					resp.json response
		else
			resp.json response

exports.putExperimentInternal = (experiment, testMode, callback) ->
	exptToSave = experiment

	#remove the itxs attributes if needed
	newExptExptItxs = []
	exptExptItxsToIgnore = []
	if exptToSave.exptExptItxsToIgnore?
		exptExptItxsToIgnore = exptToSave.exptExptItxsToIgnore
		exptExptItxsToIgnore = JSON.parse exptExptItxsToIgnore
		delete exptToSave.exptExptItxsToIgnore
	if exptToSave.newExptExptItxs?
		newExptExptItxs = exptToSave.newExptExptItxs
		newExptExptItxs = JSON.parse newExptExptItxs
		delete exptToSave.newExptExptItxs

	fileVals = serverUtilityFunctions.getFileValuesFromEntity exptToSave, true
	filesToSave = fileVals.length

	completeExptUpdate = ->
		updateExpt exptToSave, testMode, (updatedExpt) ->
			if updatedExpt.codeName? and (newExptExptItxs.length > 0 or exptExptItxsToIgnore.length > 0) and updatedExpt.lsKind != "study"
				#is default/expt base
				_.each exptExptItxsToIgnore, (itx) =>
					itx.secondExperiment = {id: updatedExpt.id}
				_.each newExptExptItxs, (itx) =>
					itx.secondExperiment = {id: updatedExpt.id}
				exports.createAndUpdateExptExptItxsInternal JSON.stringify(exptExptItxsToIgnore), JSON.stringify(newExptExptItxs), testMode, (json) =>
					console.log "finished createAndUpdateExptExptItxs"
					console.log exptExptItxsToIgnore
					console.log newExptExptItxs
					console.log json
					if json.indexOf("saveFailed") > -1
						console.log "error creating and updating expt expt itxs"
						callback "Error creating and updating expt expt itxs: " + json
					else
						callback updatedExpt
			else
				callback updatedExpt

	fileSaveCompleted = (passed) ->
		if !passed
			callback "put experiment internal saveFailed: file move failed"
		if --filesToSave == 0 then completeExptUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromEntityCode exptToSave.codeName
		for fv in fileVals
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, exptToSave.codeName, fileSaveCompleted
	else
		completeExptUpdate()


exports.putExperiment = (req, resp) ->
	console.log "put experiment"
	
	#remove the itxs attributes if needed
	newExptExptItxs = []
	exptExptItxsToIgnore = []
	if req.body.exptExptItxsToIgnore?
		exptExptItxsToIgnore = req.body.exptExptItxsToIgnore
		exptExptItxsToIgnore = JSON.parse exptExptItxsToIgnore
		delete req.body.exptExptItxsToIgnore
	if req.body.newExptExptItxs?
		newExptExptItxs = req.body.newExptExptItxs
		newExptExptItxs = JSON.parse newExptExptItxs
		delete req.body.newExptExptItxs

	exptToSave = req.body
	fileVals = serverUtilityFunctions.getFileValuesFromEntity exptToSave, true
	filesToSave = fileVals.length

	completeExptUpdate = ->
		updateExpt exptToSave, req.query.testMode, (updatedExpt) ->
			if updatedExpt.codeName? and (newExptExptItxs.length > 0 or exptExptItxsToIgnore.length > 0) and updatedExpt.lsKind != "study"
				#is default/expt base
				_.each exptExptItxsToIgnore, (itx) =>
					itx.secondExperiment = {id: updatedExpt.id}
				_.each newExptExptItxs, (itx) =>
					itx.secondExperiment = {id: updatedExpt.id}
				exports.createAndUpdateExptExptItxsInternal JSON.stringify(exptExptItxsToIgnore), JSON.stringify(newExptExptItxs), req.query.testMode, (json) =>
					console.log "finished createAndUpdateExptExptItxs"
					console.log exptExptItxsToIgnore
					console.log newExptExptItxs
					console.log json
					if json.indexOf("saveFailed") > -1
						console.log "error creating and updating expt expt itxs"
						resp.statusCode = 500
						resp.json "error creating and updating expt expt itxs"
					else
						resp.json updatedExpt
			else
				resp.json updatedExpt

	fileSaveCompleted = (passed) ->
		if !passed
			resp.statusCode = 500
			return resp.end "file move failed"
		if --filesToSave == 0 then completeExptUpdate()

	if filesToSave > 0
		prefix = serverUtilityFunctions.getPrefixFromEntityCode req.body.codeName
		for fv in fileVals
			if !fv.id?
				csUtilities.relocateEntityFile fv, prefix, req.body.codeName, fileSaveCompleted
	else
		completeExptUpdate()

#TODO replace putExperiment with call to putExperimentInternal
#exports.putExperiment = (req, resp) ->
#	exports.putExperimentInternal req.body, req.query.testMode, (putExperimentResp) =>
#		if typeof(putExperimentResp) is "string" and putExperimentResp.indexOf("saveFailed") > -1
#			resp.statusCode = 500
#			resp.json putExperimentResp
#		else
#			resp.json putExperimentResp

exports.genericExperimentSearch = (req, res) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		if req.params.searchTerm == "no-match"
			emptyResponse = []
			res.end JSON.stringify emptyResponse
		else
			res.end JSON.stringify [experimentServiceTestJSON.fullExperimentFromServer, experimentServiceTestJSON.fullDeletedExperiment]
	else
		config = require '../conf/compiled/conf.js'
		if req.user?.username?
			username = req.user.username
		else if req.query?.username?
			username = req.query.username
		else
			username = "none"
		baseurl = config.all.client.service.persistence.fullpath+"experiments/search?q="+req.params.searchTerm+"&userName="+username
		console.log "baseurl"
		console.log baseurl
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, res)

exports.editExperimentLookupAndRedirect = (req, res) ->
	if global.specRunnerTestmode
		json = {message: "got to edit experiment redirect"}
		res.end JSON.stringify json
	else
		json = {message: "genericExperimentSearch not implemented yet"}
		res.end JSON.stringify json

exports.deleteExperiment = (req, res) ->
	# route to handle deleting experiments
	#curl -i -X DELETE -H Accept:application/json -H Content-Type:application/json  http://host4.labsynch.com:8080/acas/experiments/406773
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		deletedExperiment = JSON.parse(JSON.stringify(experimentServiceTestJSON.fullDeletedExperiment))
		res.end JSON.stringify deletedExperiment
	else
		config = require '../conf/compiled/conf.js'
		experimentId = req.params.id
		baseurl = config.all.client.service.persistence.fullpath+"experiments/browser/"+experimentId
		console.log baseurl
		request = require 'request'

		request(
			method: 'DELETE'
			url: baseurl
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error && response.statusCode == 200
				console.log JSON.stringify json
				res.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log response
		)

exports.resultViewerURLByExperimentCodename = (request, resp) ->
	if (request.query.testMode is true) or (global.specRunnerTestmode is true)
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.resultViewerURLByExperimentCodeName
	else
		exports.resultViewerURLFromExperimentCodeName request.params.code, (err, res) ->
			if err? or not res.resultViewerURL?
				resp.statusCode = 500
				if err.error? and typeof err.error is 'object'
					resp.json err.error
				else
					resp.send err.error
			else if res.resultViewerURL is ""
				resp.status(404).json res
			else
				resp.json res

exports.resultViewerURLFromExperimentCodeName = (codeName, callback) ->
	# Error callback should be json
	_ = require '../public/lib/underscore.js'
	config = require '../conf/compiled/conf.js'
	if config.all.client.service.result && config.all.client.service.result.viewer and
		 config.all.client.service.result.viewer.experimentPrefix? and
		 config.all.client.service.result.viewer.protocolPrefix? and
		 config.all.client.service.result.viewer.experimentNameColumn?
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/"+codeName
		request = require 'request'
		request
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, experiment) =>
			if !error && response.statusCode == 200
				if experiment.length == 0
					callback null,
						resultViewerURL: ""
				else
					baseurl = config.all.client.service.persistence.fullpath+"protocols/"+experiment.protocol.id
					request = require 'request'
					request
						method: 'GET'
						url: baseurl
						json: true
					, (error, response, protocol) =>
						if response.statusCode == 404
							callback null,
								resultViewerURL: ""
						else
							if !error && response.statusCode == 200
								preferredExperimentLabel = _.filter experiment.lsLabels, (lab) ->
									lab.preferred && lab.ignored==false
								preferredExperimentLabelText = preferredExperimentLabel[0].labelText
								if config.all.client.service.result.viewer.experimentNameColumn == "EXPERIMENT_NAME"
									experimentName = experiment.codeName + "::" + preferredExperimentLabelText
								else
									experimentName = preferredExperimentLabelText
								preferredProtocolLabel = _.filter protocol.lsLabels, (lab) ->
									lab.preferred && lab.ignored==false
								preferredProtocolLabelText = preferredProtocolLabel[0].labelText
								callback null,
									resultViewerURL: config.all.client.service.result.viewer.protocolPrefix +
									 encodeURIComponent(preferredProtocolLabelText) +
									 config.all.client.service.result.viewer.experimentPrefix +
									 encodeURIComponent(experimentName)
							else
								console.log error
								console.log response
								callback
									error: 'got error trying to get protocol'
			else
				console.log error
				console.log response
				callback
					error: 'got error trying to get experiment'
	else
		callback
			error: "configuration client.service.result.viewer.protocolPrefix and experimentPrefix and experimentNameColumn must exist"

exports.experimentValueById = (req, resp) ->
	console.log req.params.id
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify experimentServiceTestJSON.fullExperimentFromServer.lsStates[1] #return experiment metadata state
	else
#		json = {message: "experiment state by id not implemented yet"}
#		res.end JSON.stringify json
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experimentvalues/"+req.params.id
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.experimentValueByStateTypeKindAndValueTypeKind = (req, resp) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify(experimentServiceTestJSON.experimentValueByStateTypeKindAndValueTypeKind[req.params.stateType][req.params.stateKind][req.params.valueType][req.params.valueKind])
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/experiments/"+req.params.idOrCode+"/exptvalues/bystate/"+req.params.stateType+"/"+req.params.stateKind+"/byvalue/"+req.params.valueType+"/"+req.params.valueKind+"/json"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

getItxExptExptsByFirstExpt = (firstExptId, callback) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		callback JSON.stringify [experimentServiceTestJSON.fullExperimentFromServer, experimentServiceTestJSON.fullDeletedExperiment]
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxexperimentexperiments/findByFirstExperiment/"+firstExptId
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback JSON.stringify json
			else
				callback JSON.stringify "Failed: Could not get expt expt itx by first expt from ACAS Server"
				console.log 'got ajax error'
				console.log error
				console.log json
				console.log response
		)

exports.getItxExptExptsByFirstExpt = (req, resp) ->
	getItxExptExptsByFirstExpt req.params.firstExptId, (exptExptItxs) ->
		if exptExptItxs.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.end exptExptItxs

getItxExptExptsBySecondExpt = (secondExptId, callback) ->
	if global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		callback JSON.stringify [experimentServiceTestJSON.fullExperimentFromServer, experimentServiceTestJSON.fullDeletedExperiment]
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxexperimentexperiments/findBySecondExperiment/"+secondExptId
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback JSON.stringify json
			else
				callback JSON.stringify "Failed: Could not get expt expt itx by second expt from ACAS Server"
				console.log 'got ajax error'
				console.log error
				console.log json
				console.log response
		)

exports.getItxExptExptsBySecondExpt = (req, resp) ->
	getItxExptExptsBySecondExpt req.params.secondExptId, (exptExptItxs) ->
		if exptExptItxs.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.end exptExptItxs

postExptExptItxs = (exptExptItxs, testMode, callback) ->
	console.log "post expt expt itxs"
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxexperimentexperiments/jsonArray"
		console.log "post expt expt itx body"
		console.log exptExptItxs
		console.log JSON.stringify exptExptItxs
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: exptExptItxs
			json: true
		, (error, response, json) =>
			console.log "postExptExptItxs json"
			console.log json
			console.log "response.statusCode"
			console.log response.statusCode
			console.log response
			if !error && response.statusCode == 201
				callback json
			else
				console.log "got error posting expt expt itxs"
				callback "postExptExptItxs saveFailed: " + JSON.stringify error
		)


exports.postExptExptItxs = (req, resp) ->
	postExptExptItxs req.body, req.query.testMode, (newExptExptItxs) ->
		if newExptExptItxs.indexOf("saveFailed") > -1
			resp.statusCode = 500
		resp.json newExptExptItxs

putExptExptItxs = (exptExptItxs, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxexperimentexperiments/jsonArray"
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: exptExptItxs
			json: true
		, (error, response, json) =>
			console.log "putExptExptItxs json"
			console.log json
			console.log "response.statusCode"
			console.log response.statusCode
			console.log response
			if !error && response.statusCode == 200
				callback json
			else
				console.log "got error putting expt expt itxs"
				callback "putExptExptItxs saveFailed: " + JSON.stringify error
		)

exports.putExptExptItxs = (req, resp) ->
	putExptExptItxs req.body, req.query.testMode, (updatedExptExptItxs) ->
		if updatedExptExptItxs.indexOf("saveFailed") > -1
			resp.statusCode = 500
		resp.json updatedExptExptItxs

exports.createAndUpdateExptExptItxsInternal = (exptExptItxsToIgnore, newExptExptItxs, testMode, callback) ->
	putExptExptItxs exptExptItxsToIgnore, testMode, (updatedExptExptItxs) ->
		if updatedExptExptItxs.indexOf("saveFailed") > -1
			callback updatedExptExptItxs
		else
			postExptExptItxs newExptExptItxs, testMode, (newExptExptItxs) ->
				if newExptExptItxs.indexOf("saveFailed") > -1
					callback newExptExptItxs
				else
					callback updatedExptExptItxs.concat newExptExptItxs

exports.createAndUpdateExptExptItxs = (req, resp) ->
	exports.createAndUpdateExptExptItxsInternal req.body.exptExptItxsToIgnore, req.body.newExptExptItxs, req.query.testMode, (json) =>
		if json.indexOf("saveFailed") > -1
			resp.statusCode = 500
		resp.json json

exports.experimentsByCodeNamesArray = (req, resp) ->
	exports.experimentsByCodeNamesArrayInternal req.body.data, req.query.option, req.query.testMode, (returnedExpts) ->
		if returnedExpts.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.json returnedExpts


exports.experimentsByCodeNamesArrayInternal = (codeNamesArray, returnOption, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/codename/jsonArray"
		#returnOption are analysisgroups, analysisgroupstates, analysisgroupvalues, fullobject, prettyjson, prettyjsonstub, stubwithprot, and stub
		if returnOption?
			baseurl += "?with=#{returnOption}"
		console.log "experimentsByCodeNamesArray"
		console.log baseurl
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: codeNamesArray
			json: true
		, (error, response, json) =>
			console.log "experimentsByCodeNamesArray json"
			console.log json
			console.log "response.statusCode"
			console.log response.statusCode
			console.log response
			if !error && response.statusCode == 200
				callback json
			else
				console.log "Failed: got error in bulk get of experiments"
				callback "Bulk get experiments saveFailed: " + JSON.stringify error
		)

exports.getExptExptItxsToDisplay = (req, resp) ->
	console.log "getExptExptItxsToDisplay"
	getItxExptExptsByFirstExpt req.params.firstExptId, (exptExptItxs) ->
		if exptExptItxs.indexOf("Failed") > -1
			resp.statusCode = 500
			resp.end exptExptItxs
		else
			#filter out the ignored
			exptExptItxs = _.filter JSON.parse(exptExptItxs), (itx) ->
				!itx.ignored
			secondExpts = _.pluck (_.pluck exptExptItxs, 'secondExperiment'), 'codeName'
			exports.experimentsByCodeNamesArrayInternal secondExpts, "stubwithprot", req.query.testMode, (returnedExpts) ->
				#add returnedExpts information into the secondExperiment attribute
				_.each exptExptItxs, (itx) ->
					secondExptInfo = _.where(returnedExpts, experimentCodeName: itx.secondExperiment.codeName)[0]
					itx.secondExperiment = secondExptInfo.experiment
				resp.json exptExptItxs


exports.postParentExperiment = (req, resp) ->
	if global.specRunnerTestmode
		parentExperiment = require '../public/javascripts/spec/ParentExperiment/testFixtures/ParentExperimentServiceTestJSON.js'
		resp.end JSON.stringify parentExperiment['savedParentExperiment']
	else
		console.log "post parent experiment"
#		console.log req.body
#		console.log "parent experiment"
#		console.log req.body.parentExperiment
#		console.log "child experiments"
#		console.log req.body.childExperiments
		config = require '../conf/compiled/conf.js'
		request = require 'request'

		#post parent experiment first, get file value and update fileValues for childExperiments

		#post parent experiment
		parentExperiment = JSON.parse req.body.parentExperiment
		exports.postExperimentInternal parentExperiment, req.query.testMode, (saveParentExptResp) =>
			console.log "post experiment response"
			console.log saveParentExptResp
			if typeof saveParentExptResp is "string" and saveParentExptResp.indexOf("saveFailed") > -1
				resp.statusCode = 500
				resp.json saveParentExptResp
			else
				#get fileValue
				sourceFileVal = serverUtilityFunctions.getFileValuesFromEntity(saveParentExptResp, false)[0]
				console.log "sourceFileVal"
				console.log sourceFileVal

				#update fileValue for all child experiments
				childExperiments = JSON.parse req.body.childExperiments
				_.each childExperiments, (childExpt) =>
					childExptFileVal = serverUtilityFunctions.getFileValuesFromEntity(childExpt, false)[0]
					childExptFileVal.fileValue = sourceFileVal.fileValue
					childExptFileVal.comments = sourceFileVal.comments

				console.log "childExpts to bulk post"
				console.log childExperiments

				#bulk post of all the experiments
				exports.bulkPostExperimentsInternal childExperiments, (saveChildExptsResp) =>
					if typeof saveChildExptsResp is "string" and saveChildExptsResp.indexOf("saveFailed") > -1
						resp.statusCode = 500
						resp.json saveChildExptsResp
					else
						#save itxs between parent and child experiments
						exptExptItxs = []
						_.each saveChildExptsResp, (childExpt) =>
							exptExptItxs.push
								lsType: "has member"
								lsKind: "collection member"
								recordedBy: childExpt.recordedBy #window.AppLaunchParams.loginUser.username
								recordedDate: new Date().getTime()
								ignored: false
								firstExperiment: saveParentExptResp
								secondExperiment: childExpt
						postExptExptItxs exptExptItxs, false, (saveExptExptItxsResp) ->
							console.log "saveExptExptItxsResp"
							console.log saveExptExptItxsResp
							if saveExptExptItxsResp.indexOf("saveFailed") > -1
								resp.statusCode = 500
								resp.json saveExptExptItxsResp
							else
								#return
								resp.json saveParentExptResp

exports.bulkPostExperiments = (req, resp) ->
	exports.bulkPostExperimentsInternal req.body, (response) =>
		resp.json response

exports.bulkPostExperimentsInternal = (exptsArray, callback) ->
	console.log "bulkPostExperiments"
	console.log JSON.stringify exptsArray
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"/experiments/jsonArray"
	request(
		method: 'POST'
		url: baseurl
		body: exptsArray
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 201
			callback json
		else
			console.log "got error posting child experiments"
			callback JSON.stringify "bulk post experiments saveFailed: " + JSON.stringify error
	)

exports.bulkPutExperiments = (req, resp) ->
	exports.bulkPutExperimentsInternal req.body, (response) =>
		resp.json response

exports.bulkPutExperimentsInternal = (exptsArray, callback) ->
	console.log "bulkPutExperiments"
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"/experiments/jsonArray"
	console.log "bulkPutExperimentsInternal"
	console.log baseurl
	console.log exptsArray
	request(
		method: 'PUT'
		url: baseurl
		body: exptsArray
		json: true
	, (error, response, json) =>
		console.log "bulkPutExperimentsInternal"
		console.log response.statusCode
		if !error && response.statusCode == 200
			callback json
		else
			console.log "got error bulk updating experiments"
			console.log error
			callback JSON.stringify "bulk update experiments saveFailed: " + JSON.stringify error
	)

exports.putParentExperiment = (req, resp) ->
	console.log "put parent experiment"
	exports.putExperiment req, resp

exports.experimentsByTypeKind = (req, resp) ->
	console.log "experiments by type and kind"
	if req.query.testMode or global.specRunnerTestmode
		experimentServiceTestJSON = require '../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js'
		resp.end JSON.stringify [experimentServiceTestJSON.fullExperimentFromServer]
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/bytypekind/"+req.params.lsType+"/"+req.params.lsKind
		console.log baseurl
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getExperimentByLabel = (req, resp) ->
	exports.getExperimentByLabelInternal req.params.exptLabel, (statusCode, json) ->
		resp.statusCode = statusCode
		resp.json json

exports.getExperimentByLabelInternal = (label, callback) ->
	config = require '../conf/compiled/conf.js'
	url = config.all.client.service.persistence.fullpath+"experiments?FindByExperimentName&experimentName=#{label}"
	console.log "getExperimentByLabelInternal url"
	console.log url
	request = require 'request'
	request(
		method: 'GET'
		url: url
		json: true
	, (error, response, json) =>
		console.log response.statusCode
		console.log json
		if !error and !json.error
			callback response.statusCode, json
		else
			console.log 'got ajax error trying to get experiment by label'
			callback 500, json.errorMessages
	)

exports.getExperimentCodeByLabel = (req, resp) ->
	if global.specRunnerTestmode
		results = []
		for req in req.body.requests
			res = requestName: req.requestName
			if req.requestName.indexOf("ambiguous") > -1
				res.referenceName = ""
				res.preferredName = ""
			else if req.requestName.indexOf("STUDY") > -1
				res.referenceName = "EXPT-00000001"
				res.preferredName = "STUDY-0000001"
			else
				res.referenceName = req.requestName
				res.preferredName = req.requestName
			results.push res

		response =
			error: false
			errorMessages: []
			results: results

		resp.json response

	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"experiments/getCodeNameFromNameRequest?"
		url = baseurl+"experimentType=#{req.params.exptType}&experimentKind=#{req.params.exptKind}"
		console.log "getExperimentCodeByLabel url"
		console.log url
		request = require 'request'
		request(
			method: 'POST'
			url: url
			body: req.body
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			console.log json
			if !error and !json.error
				resp.json json
			else
				console.log 'got ajax error trying to lookup experiment code by label'
				resp.statusCode = 500
				resp.json json.errorMessages
		)
