exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cationicBlockParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName
	app.post '/api/cationicBlockParents', loginRoutes.ensureAuthenticated, exports.postCationicBlockParent
	app.put '/api/cationicBlockParents/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockParent
	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName
	app.post '/api/cationicBlockBatches', loginRoutes.ensureAuthenticated, exports.postCationicBlockBatch
	app.put '/api/cationicBlockBatches/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockBatch

exports.cationicBlockParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/cationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "get parent by codename not implemented yet"}

exports.postCationicBlockParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "post cationic block parent not implemented yet"}

exports.putCationicBlockParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "put cationic block parent not implemented yet"}

exports.batchesByParentCodeName = (request, response) ->
	if request.query.testMode or global.specRunnerTestmode
		cationicBlockServiceTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		response.end JSON.stringify cationicBlockServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+request.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, response)


exports.batchesByCodeName = (request, response) ->
	if request.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		response.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		resp.end JSON.stringify {error: "get batch by codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodeName/"+request.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, response)

exports.postCationicBlockBatch = (request, response) ->
	if request.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		response.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		resp.end JSON.stringify {error: "post batch not implemented yet"}

exports.putCationicBlockBatch = (request, response) ->
	if request.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		response.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		resp.end JSON.stringify {error: "put batch not implemented yet"}
