exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cationicBlockParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName
	app.post '/api/cationicBlockParents', loginRoutes.ensureAuthenticated, exports.postCationicBlockParent
	app.put '/api/cationicBlockParents/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockParent
#	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName
	app.post '/api/cationicBlockBatches', loginRoutes.ensureAuthenticated, exports.postCationicBlockBatch
	app.put '/api/cationicBlockBatches/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockBatch

exports.cationicBlockParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		resp.end JSON.stringify {error: "get parent by codename not implemented yet"}

exports.postCationicBlockParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		console.log 'post cbp in test mode'
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

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockServiceTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify cationicBlockServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.batchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		resp.end JSON.stringify {error: "get batch by codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodeName/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postCationicBlockBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		resp.end JSON.stringify {error: "post batch not implemented yet"}

exports.putCationicBlockBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		resp.end JSON.stringify {error: "put batch not implemented yet"}
