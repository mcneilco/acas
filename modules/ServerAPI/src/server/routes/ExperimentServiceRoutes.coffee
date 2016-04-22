exports.setupAPIRoutes = (app) ->
	app.get '/api/experiments/codename/:code', exports.experimentByCodename
	app.get '/api/experiments/experimentName/:name', exports.experimentByName
	app.get '/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', exports.experimentById
	app.get '/api/experiments/:idOrCode/exptvalues/bystate/:stateType/:stateKind/byvalue/:valueType/:valueKind', exports.experimentValueByStateTypeKindAndValueTypeKind
	app.post '/api/experiments', exports.postExperiment
	app.put '/api/experiments/:id', exports.putExperiment
	app.get '/api/experiments/resultViewerURL/:code', exports.resultViewerURLByExperimentCodename
	app.delete '/api/experiments/:id', exports.deleteExperiment
	app.get '/api/getItxExptExptsByFirstExpt/:firstExptId', exports.getItxExptExptsByFirstExpt
	app.post '/api/createAndUpdateExptExptItxs', exports.createAndUpdateExptExptItxs
	app.post '/api/postExptExptItxs', exports.postExptExptItxs
	app.put '/api/putExptExptItxs', exports.putExptExptItxs
	app.post '/api/screeningCampaign/analyzeScreeningCampaign', exports.analyzeScreeningCampaign
	app.post '/api/experiments/getByCodeNamesArray', exports.experimentsByCodeNamesArray
	app.post '/api/getExptExptItxsToDisplay/:firstExptId', exports.getExptExptItxsToDisplay

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename
	app.get '/api/experiments/experimentName/:name', loginRoutes.ensureAuthenticated, exports.experimentByName
	app.get '/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename
	app.get '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById
	app.get '/api/experiments/:idOrCode/exptvalues/bystate/:stateType/:stateKind/byvalue/:valueType/:valueKind', loginRoutes.ensureAuthenticated, exports.experimentValueByStateTypeKindAndValueTypeKind
	app.post '/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment
	app.put '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment
	app.get '/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch
	app.delete '/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.deleteExperiment
	app.get '/api/experiments/resultViewerURL/:code', loginRoutes.ensureAuthenticated, exports.resultViewerURLByExperimentCodename
	app.get '/api/experiments/values/:id', loginRoutes.ensureAuthenticated, exports.experimentValueById
	app.get '/api/getItxExptExptsByFirstExpt/:firstExptId', loginRoutes.ensureAuthenticated, exports.getItxExptExptsByFirstExpt
	app.post '/api/createAndUpdateExptExptItxs', loginRoutes.ensureAuthenticated, exports.createAndUpdateExptExptItxs
	app.post '/api/postExptExptItxs', loginRoutes.ensureAuthenticated, exports.postExptExptItxs
	app.put '/api/putExptExptItxs', loginRoutes.ensureAuthenticated, exports.putExptExptItxs
	app.post '/api/screeningCampaign/analyzeScreeningCampaign', loginRoutes.ensureAuthenticated, exports.analyzeScreeningCampaign
	app.post '/api/experiments/getByCodeNamesArray', loginRoutes.ensureAuthenticated, exports.experimentsByCodeNamesArray
	app.post '/api/getExptExptItxsToDisplay/:firstExptId', loginRoutes.ensureAuthenticated, exports.getExptExptItxsToDisplay

serverUtilityFunctions = require './ServerUtilityFunctions.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
_ = require 'underscore'

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
			serverUtilityFunctions.getFromACASServer(baseurl, resp)
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
					callback JSON.stringify "saveFailed"
			)

postExperiment = (req, resp) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	exptToSave = req.body
	serverUtilityFunctions.createLSTransaction exptToSave.recordedDate, "new experiment", (transaction) ->
		exptToSave = serverUtilityFunctions.insertTransactionIntoEntity transaction.id, exptToSave
		if req.query.testMode or global.specRunnerTestmode
			unless exptToSave.codeName?
				exptToSave.codeName = "EXPT-00000001"
			unless exptToSave.id?
				exptToSave.id = 1

		checkFilesAndUpdate = (expt) ->
			fileVals = serverUtilityFunctions.getFileValuesFromEntity expt, false
			filesToSave = fileVals.length

			completeExptUpdate = (exptToUpdate)->
				updateExpt exptToUpdate, req.query.testMode, (updatedExpt) ->
					resp.json updatedExpt

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
				resp.json expt

		if req.query.testMode or global.specRunnerTestmode
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
						resp.end JSON.stringify response.body[0].message
					else
						resp.end JSON.stringify "saveFailed"
			)

exports.postExperiment = (req, resp) ->
	postExperiment req, resp

exports.putExperiment = (req, resp) ->
	exptToSave = req.body
	fileVals = serverUtilityFunctions.getFileValuesFromEntity exptToSave, true
	filesToSave = fileVals.length

	completeExptUpdate = ->
		updateExpt exptToSave, req.query.testMode, (updatedExpt) ->
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
		baseurl = config.all.client.service.persistence.fullpath+"experiments/search?q="+req.params.searchTerm
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

postExptExptItxs = (exptExptItxs, testMode, callback) ->
	if testMode or global.specRunnerTestmode
		callback JSON.stringify "stubsMode not implemented"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"/itxexperimentexperiments/jsonArray"
		console.log "post expt expt itx body"
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

exports.createAndUpdateExptExptItxs = (req, resp) ->
	putExptExptItxs req.body.exptExptItxsToIgnore, req.query.testMode, (updatedExptExptItxs) ->
		if updatedExptExptItxs.indexOf("saveFailed") > -1
			resp.statusCode = 500
			resp.json updatedExptExptItxs
		else
			postExptExptItxs req.body.newExptExptItxs, req.query.testMode, (newExptExptItxs) ->
				if newExptExptItxs.indexOf("saveFailed") > -1
					resp.statusCode = 500
					resp.json newExptExptItxs
				else
					resp.json updatedExptExptItxs.concat newExptExptItxs

exports.analyzeScreeningCampaign = (req, resp) ->
	req.connection.setTimeout 180000000

	resp.writeHead(200, {'Content-Type': 'application/json'});

	if global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			req,
			"src/r/ScreeningCampaign/ScreeningCampaignDataAnalysisStub.R",
			"analyzeScreeningCampaign",
			(rReturn) ->
				resp.end rReturn
		)
	else #TODO: add real implementation
		serverUtilityFunctions.runRFunction(
			req,
			"src/r/ScreeningCampaign/ScreeningCampaignDataAnalysisStub.R",
			"analyzeScreeningCampaign",
			(rReturn) ->
				resp.end rReturn
		)

exports.experimentsByCodeNamesArray = (req, resp) ->
	experimentsByCodeNamesArray req.body.data, req.query.option, req.query.testMode, (returnedExpts) ->
		if returnedExpts.indexOf("Failed") > -1
			resp.statusCode = 500
		resp.json returnedExpts


experimentsByCodeNamesArray = (codeNamesArray, returnOption, testMode, callback) ->
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
			experimentsByCodeNamesArray secondExpts, "stubwithprot", req.query.testMode, (returnedExpts) ->
				#add returnedExpts information into the secondExperiment attribute
				_.each exptExptItxs, (itx) ->
					secondExptInfo = _.where(returnedExpts, experimentCodeName: itx.secondExperiment.codeName)[0]
					itx.secondExperiment = secondExptInfo.experiment
				resp.json exptExptItxs
