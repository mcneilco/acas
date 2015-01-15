exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/internalizationAgentParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.internalizationAgentParentByCodeName
	app.post '/api/internalizationAgentParents', loginRoutes.ensureAuthenticated, exports.postInternalizationAgentParent
	app.put '/api/internalizationAgentParents/:id', loginRoutes.ensureAuthenticated, exports.putInternalizationAgentParent
	#	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName
	app.post '/api/internalizationAgentBatches', loginRoutes.ensureAuthenticated, exports.postInternalizationAgentBatch
	app.put '/api/internalizationAgentBatches/:id', loginRoutes.ensureAuthenticated, exports.putInternalizationAgentBatch

exports.internalizationAgentParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js'
		resp.end JSON.stringify internalizationAgentTestJSON.internalizationAgentParent
	else
		resp.end JSON.stringify {error: "get parent by codename not implemented yet"}

exports.postInternalizationAgentParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js'
		resp.end JSON.stringify internalizationAgentTestJSON.internalizationAgentParent
	else
		resp.end JSON.stringify {error: "post internalizationAgent parent not implemented yet"}

exports.putInternalizationAgentParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js'
		resp.end JSON.stringify internalizationAgentTestJSON.internalizationAgentParent
	else
		resp.end JSON.stringify {error: "put internalizationAgent parent not implemented yet"}

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentServiceTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify internalizationAgentServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.batchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js'
		resp.end JSON.stringify internalizationAgentTestJSON.internalizationAgentBatch
	else
		resp.end JSON.stringify {error: "get batch by codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodeName/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postInternalizationAgentBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js'
		resp.end JSON.stringify internalizationAgentTestJSON.internalizationAgentBatch
	else
		resp.end JSON.stringify {error: "post batch not implemented yet"}

exports.putInternalizationAgentBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		internalizationAgentTestJSON = require '../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js'
		resp.end JSON.stringify internalizationAgentTestJSON.internalizationAgentBatch
	else
		resp.end JSON.stringify {error: "put batch not implemented yet"}
