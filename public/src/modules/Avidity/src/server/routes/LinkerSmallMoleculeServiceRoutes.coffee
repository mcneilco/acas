exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/linkerSmallMoleculeParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeParentByCodeName
	app.post '/api/linkerSmallMoleculeParents', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeParent
	app.put '/api/linkerSmallMoleculeParents/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeParent
	#	app.get '/api/batches/parentCodeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName
	app.post '/api/linkerSmallMoleculeBatches', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeBatch
	app.put '/api/linkerSmallMoleculeBatches/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeBatch

exports.linkerSmallMoleculeParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
	else
		resp.end JSON.stringify {error: "get parent by codename not implemented yet"}

exports.postLinkerSmallMoleculeParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
	else
		resp.end JSON.stringify {error: "post linker small molecule parent not implemented yet"}

exports.putLinkerSmallMoleculeParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
	else
		resp.end JSON.stringify {error: "put linker small molecule parent not implemented yet"}

exports.batchesByParentCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeServiceTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeServiceTestJSON.js'
		console.log "batches by parent codeName test mode"
		resp.end JSON.stringify linkerSmallMoleculeServiceTestJSON.batchList
	else
		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.batchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
	else
		resp.end JSON.stringify {error: "get batch by codeName not implemented yet"}
#		config = require '../conf/compiled/conf.js'
#		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodeName/"+req.params.code
#		serverUtilityFunctions = require './ServerUtilityFunctions.js'
#		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postLinkerSmallMoleculeBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
	else
		resp.end JSON.stringify {error: "post batch not implemented yet"}

exports.putLinkerSmallMoleculeBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
	else
		resp.end JSON.stringify {error: "put batch not implemented yet"}
