
exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/geneDataQuery', exports.getExperimentDataForGenes
	app.post '/api/getGeneExperiments', exports.getExperimentListForGenes
	app.post '/api/getExperimentSearchAttributes', exports.getExperimentSearchAttributes
	app.post '/api/geneDataQueryAdvanced', exports.getExperimentDataForGenesAdvanced
	config = require '../conf/compiled/conf.js'
	if config.all.client.require.login
		app.get '/geneIDQuery', loginRoutes.ensureAuthenticated, exports.geneIDQueryIndex
	else
		app.get '/geneIDQuery', exports.geneIDQueryIndex

exports.getExperimentDataForGenes = (req, resp)  ->
	req.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	request = require 'request'
	fs = require 'fs'
	crypto = require('crypto');
	config = require '../conf/compiled/conf.js'

	if req.query.format?
		if req.query.format=="csv"
			if global.specRunnerTestmode
				# the following is really elegant, but the client won't support an ajax call returning a file, so start over....
#				request.get('http://localhost:3000/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv').pipe(resp)
				if config.all.client.use.ssl
					urlPref = "https://"
				else
					urlPref = "http://"

				filename = 'gene'+crypto.randomBytes(4).readUInt32LE(0)+'query.csv';
				console.log filename
				file = fs.createWriteStream './public/tempFiles/'+filename
				rem = request urlPref+'localhost:3000/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv'
				rem.on 'data', (chunk) ->
					file.write(chunk);
				rem.on 'end', ->
					file.close()
					console.log "file written"
					resp.json
						fileURL: urlPref+"localhost:3000/tempFiles/"+filename


			else
				#TODO this implementation is not tested!!!
				baseurl = config.all.client.service.rapache.fullpath+"getGeneData?format=CSV"
				request(
					method: 'POST'
					url: baseurl
					body: req.body
				).pipe(resp)

		else
			console.log "format requested not supported"
	else
		resp.writeHead(200, {'Content-Type': 'application/json'});
		if global.specRunnerTestmode
			console.log "test mode: "+global.specRunnerTestmode
			geneDataQueriesTestJSON = require '../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js'
			requestError = if req.body.maxRowsToReturn < 0 then true else false
			if req.body.geneIDs == "fiona"
				results = geneDataQueriesTestJSON.geneIDQueryResultsNoneFound
			else
				results = geneDataQueriesTestJSON.geneIDQueryResults
			responseObj =
				results: results
				hasError: requestError
				hasWarning: true
				errorMessages: [
					{errorLevel: "warning", message: "some genes not found"},
				]
			if requestError then responseObj.errorMessages.push {errorLevel: "error", message: "start offset outside allowed range, please speake to an administrator"}
			resp.end JSON.stringify responseObj
		else
			baseurl = config.all.client.service.rapache.fullpath+"getGeneData/"
			request(
				method: 'POST'
				url: baseurl
				body: req.body
				json: true
			, (error, response, json) =>
				console.log response.statusCode
				if !error
					console.log JSON.stringify json
					resp.end JSON.stringify json
				else
					console.log 'got ajax error trying to query gene data'
					console.log error
					console.log resp
			)

exports.getExperimentListForGenes = (req, resp)  ->
	req.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	resp.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		geneDataQueriesTestJSON = require '../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js'
		requestError = if req.body.maxRowsToReturn < 0 then true else false
		if req.body.geneIDs == "fiona"
			results = geneDataQueriesTestJSON.getGeneExperimentsNoResultsReturn
		else
			results = geneDataQueriesTestJSON.getGeneExperimentsReturn
		responseObj =
			results: results
			hasError: requestError
			hasWarning: true
			errorMessages: [
				{errorLevel: "warning", message: "some genes not found"},
			]
		if requestError then responseObj.errorMessages.push {errorLevel: "error", message: "start offset outside allowed range, please speake to an administrator"}
		resp.end JSON.stringify responseObj
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.rapache.fullpath+"getGeneExperiments/"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to query gene data'
				console.log error
				console.log resp
		)

exports.getExperimentSearchAttributes = (req, resp)  ->
	req.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	resp.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		geneDataQueriesTestJSON = require '../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js'
		requestError = if req.body.experimentCodes[0] == "error" then true else false
		if req.body.experimentCodes[0] == "fiona"
			results = geneDataQueriesTestJSON.experimentSearchOptionsNoMatches
		else
			results = geneDataQueriesTestJSON.experimentSearchOptions
		responseObj =
			results: results
			hasError: requestError
			hasWarning: true
			errorMessages: [
				{errorLevel: "warning", message: "some warning"},
			]
		if requestError then responseObj.errorMessages.push {errorLevel: "error", message: "no experiment attributes found, please speake to an administrator"}
		resp.end JSON.stringify responseObj
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.rapache.fullpath+"getExperimentFilters/"
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			console.log response.statusCode
			if !error
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to query gene data'
				console.log error
				console.log resp
		)

exports.geneIDQueryIndex = (req, res) ->
	#"use strict"
	scriptPaths = require './RequiredClientScripts.js'
	config = require '../conf/compiled/conf.js'
	global.specRunnerTestmode = if global.stubsMode then true else false
	scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts)
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"

	return res.render 'GeneIDQuery',
		title: "Gene ID Query"
		scripts: scriptsToLoad
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			testMode: false
			moduleLaunchParams: if moduleLaunchParams? then moduleLaunchParams else null
			deployMode: global.deployMode

exports.getExperimentDataForGenesAdvanced = (req, resp)  ->
	req.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	request = require 'request'
	fs = require 'fs'
	crypto = require('crypto');
	config = require '../conf/compiled/conf.js'
	if config.all.client.use.ssl
		urlPref = "https://"
	else
		urlPref = "http://"

	if req.query.format?
		if req.query.format=="csv"
			if global.specRunnerTestmode
				filename = 'gene'+crypto.randomBytes(4).readUInt32LE(0)+'query.csv';
				file = fs.createWriteStream './public/tempFiles/'+filename
				rem = request urlPref+'localhost:3000/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv'
				rem.on 'data', (chunk) ->
					file.write(chunk);
				rem.on 'end', ->
					file.close()
					resp.json
						fileURL: urlPref+"localhost:3000/tempFiles/"+filename
			else
				#TODO this implementation is not tested!!!
				config = require '../conf/compiled/conf.js'
				baseurl = config.all.client.service.rapache.fullpath+"getFilteredGeneData?format=CSV"
				request(
					method: 'POST'
					url: baseurl
					body: req.body
				).pipe(resp)

		else
			console.log "format requested not supported"
	else
		resp.writeHead(200, {'Content-Type': 'application/json'});
		if global.specRunnerTestmode
			console.log "test mode: "+global.specRunnerTestmode
			geneDataQueriesTestJSON = require '../public/javascripts/spec/testFixtures/GeneDataQueriesTestJson.js'
			requestError = if req.body.maxRowsToReturn < 0 then true else false
			if req.body.queryParams.batchCodes == "fiona"
				results = geneDataQueriesTestJSON.geneIDQueryResultsNoneFound
			else
				results = geneDataQueriesTestJSON.geneIDQueryResults
			responseObj =
				results: results
				hasError: requestError
				hasWarning: true
				errorMessages: [
					{errorLevel: "warning", message: "some genes not found"},
				]
			if requestError then responseObj.errorMessages.push {errorLevel: "error", message: "start offset outside allowed range, please speake to an administrator"}
			resp.end JSON.stringify responseObj
		else
			config = require '../conf/compiled/conf.js'
			baseurl = config.all.client.service.rapache.fullpath+"getFilteredGeneData/"
			request(
				method: 'POST'
				url: baseurl
				body: req.body
				json: true
			, (error, response, json) =>
				console.log response.statusCode
				if !error
					console.log JSON.stringify json
					resp.end JSON.stringify json
				else
					console.log 'got ajax error trying to query gene data'
					console.log error
					console.log resp
			)

