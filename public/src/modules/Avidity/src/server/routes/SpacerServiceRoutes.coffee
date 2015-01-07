exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/spacerParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.spacerParentByCodeName
	app.post '/api/spacerParents', loginRoutes.ensureAuthenticated, exports.postSpacerParent
	app.put '/api/spacerParents/:id', loginRoutes.ensureAuthenticated, exports.putSpacerParent
	#	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName
	app.post '/api/spacerBatches', loginRoutes.ensureAuthenticated, exports.postSpacerBatch
	app.put '/api/spacerBatches/:id', loginRoutes.ensureAuthenticated, exports.putSpacerBatch

exports.spacerParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerParent
	else
		resp.end JSON.stringify {error: "get parent by codename not implemented yet"}

exports.postSpacerParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerParent
	else
		resp.end JSON.stringify {error: "post spacer parent not implemented yet"}

exports.putSpacerParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerParent
	else
		resp.end JSON.stringify {error: "put spacer parent not implemented yet"}

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerServiceTestJSON = require '../public/javascripts/spec/testFixtures/SpacerServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify spacerServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.batchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerBatch
	else
		resp.end JSON.stringify {error: "get batch by codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodeName/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postSpacerBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerBatch
	else
		resp.end JSON.stringify {error: "post batch not implemented yet"}

exports.putSpacerBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		spacerTestJSON = require '../public/javascripts/spec/testFixtures/SpacerTestJSON.js'
		resp.end JSON.stringify spacerTestJSON.spacerBatch
	else
		resp.end JSON.stringify {error: "put batch not implemented yet"}
