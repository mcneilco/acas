exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/linkerSmallMoleculeParents/codename/:code', exports.linkerSmallMoleculeParentByCodeName
	app.get '/api/linkerSmallMoleculeParents/:code', exports.linkerSmallMoleculeParentByCodeName
	app.post '/api/linkerSmallMoleculeParents', exports.postLinkerSmallMoleculeParent
	app.put '/api/linkerSmallMoleculeParents/:id', exports.putLinkerSmallMoleculeParent
#	app.get '/api/batches/parentCodeName/:parentCode', exports.batchesByParentCodeName
	app.get '/api/linkerSmallMoleculeBatches/codename/:code', exports.linkerSmallMoleculeBatchesByCodeName
	app.post '/api/linkerSmallMoleculeBatches/:parentCode', exports.postLinkerSmallMoleculeBatch
	app.put '/api/linkerSmallMoleculeBatches/:id', exports.putLinkerSmallMoleculeBatch

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/linkerSmallMoleculeParents/codename/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeParentByCodeName
	app.get '/api/linkerSmallMoleculeParents/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeParentByCodeName
	app.post '/api/linkerSmallMoleculeParents', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeParent
	app.put '/api/linkerSmallMoleculeParents/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeParent
#	app.get '/api/batches/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName
	app.get '/api/linkerSmallMoleculeBatches/codename/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeBatchesByCodeName
	app.post '/api/linkerSmallMoleculeBatches/:parentCode', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeBatch
	app.put '/api/linkerSmallMoleculeBatches/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeBatch

exports.linkerSmallMoleculeParentByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/linker small molecule/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postLinkerSmallMoleculeParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/linker small molecule"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save linker small molecule parent'
				console.log error
				console.log json
				console.log response
		)

exports.putLinkerSmallMoleculeParent = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/parent/linker small molecule/"+req.params.code
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to update linker small molecule parent'
				console.log error
				console.log response
		)
#
#exports.batchesByParentCodeName = (req, resp) ->
#	if req.query.testMode or global.specRunnerTestmode
#		linkerSmallMoleculeServiceTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeServiceTestJSON.js'
#		console.log "batches by parent codeName test mode"
#		resp.end JSON.stringify linkerSmallMoleculeServiceTestJSON.batchList
#	else
#		resp.end JSON.stringify {error: "get batches by parent codeName not implemented yet"}
##		config = require '../conf/compiled/conf.js'
##		baseurl = config.all.client.service.persistence.fullpath+"batches/parentCodename/"+req.params.code
##		serverUtilityFunctions = require './ServerUtilityFunctions.js'
##		serverUtilityFunctions.getFromACASServer(baseurl, resp)


exports.linkerSmallMoleculeBatchesByCodeName = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/linker small molecule/"+req.params.code
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.postLinkerSmallMoleculeBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/linker small molecule/?parentIdOrCodeName="+req.params.parentCode
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new linker small molecule batch'
				console.log error
				console.log json
				console.log response
		)

exports.putLinkerSmallMoleculeBatch = (req, resp) ->
	if req.query.testMode or global.specRunnerTestmode
		linkerSmallMoleculeTestJSON = require '../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js'
		resp.end JSON.stringify linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/batch/linker small molecule/"+req.params.code
		request = require 'request'
		request(
			method: 'PUT'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log response
		)
