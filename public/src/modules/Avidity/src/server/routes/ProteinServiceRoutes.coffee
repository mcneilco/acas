exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/proteinParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.proteinParentByCodeName
	app.post '/api/proteinParents', loginRoutes.ensureAuthenticated, exports.postProteinParent
	app.put '/api/proteinParents/:id', loginRoutes.ensureAuthenticated, exports.putProteinParent
	#	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName
	app.post '/api/proteinBatches', loginRoutes.ensureAuthenticated, exports.postProteinBatch
	app.put '/api/proteinBatches/:id', loginRoutes.ensureAuthenticated, exports.putProteinBatch

exports.proteinParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinParent
	else
		resp.end JSON.stringify {error: "get parent by codename not implemented yet"}

exports.postProteinParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinParent
	else
		resp.end JSON.stringify {error: "post protein parent not implemented yet"}

exports.putProteinParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinParent
	else
		resp.end JSON.stringify {error: "put protein parent not implemented yet"}

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinServiceTestJSON = require '../public/javascripts/spec/testFixtures/ProteinServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify proteinServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.batchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinBatch
	else
		resp.end JSON.stringify {error: "get batch by codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodeName/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postProteinBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinBatch
	else
		resp.end JSON.stringify {error: "post batch not implemented yet"}

exports.putProteinBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		proteinTestJSON = require '../public/javascripts/spec/testFixtures/ProteinTestJSON.js'
		resp.end JSON.stringify proteinTestJSON.proteinBatch
	else
		resp.end JSON.stringify {error: "put batch not implemented yet"}
