exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cationicBlockParents/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName
	app.post '/api/cationicBlockParents', loginRoutes.ensureAuthenticated, exports.postCationicBlockParent
	app.put '/api/cationicBlockParents/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockParent
	app.get '/api/batches/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/cationicBlockBatches/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockBatchesByCodeName
	app.post '/api/cationicBlockBatches', loginRoutes.ensureAuthenticated, exports.postCationicBlockBatch
	app.put '/api/cationicBlockBatches/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockBatch

exports.cationicBlockParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/cationic block/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postCationicBlockParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		console.log 'post cbp in test mode'
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/cationic block/"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.putCationicBlockParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/cationic block/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockServiceTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify cationicBlockServiceTestJSON.batchList
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/cationic block/getbatches/"+req.params.parentCode
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.cationicBlockBatchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/cationic block/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postCationicBlockBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/cationic block/"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.putCationicBlockBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		cationicBlockTestJSON = require '../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js'
		resp.end JSON.stringify cationicBlockTestJSON.cationicBlockBatch
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/cationic block/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)
