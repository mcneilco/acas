
exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/geneDataQuery', loginRoutes.ensureAuthenticated, exports.getExperimentDataForGenes
	app.post '/api/getGeneExperiments', loginRoutes.ensureAuthenticated, exports.getExperimentListForGenes
	app.post '/api/getExperimentSearchAttributes', loginRoutes.ensureAuthenticated, exports.getExperimentSearchAttributes
	app.post '/api/geneDataQueryAdvanced', loginRoutes.ensureAuthenticated, exports.getExperimentDataForGenesAdvanced
	config = require '../conf/compiled/conf.js'
	#	if config.all.client.require.login
	app.get '/geneIDQuery', loginRoutes.ensureAuthenticated, exports.geneIDQueryIndex


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
				if config.all.client.use.ssl
					urlPref = "https://"
				else
					urlPref = "http://"
				filename = 'gene'+crypto.randomBytes(4).readUInt32LE(0)+'query.csv';
				file = fs.createWriteStream './privateTempFiles/'+filename
				rem = request urlPref+'localhost:'+config.all.client.port+'/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv'
				rem.on 'data', (chunk) ->
					file.write(chunk);
				rem.on 'end', ->
					file.close()
					console.log "file written"
					resp.json
						fileURL: urlPref+"localhost:'+config.all.client.port+'/tempFiles/"+filename
			else
				config = require '../conf/compiled/conf.js'
				baseurl = config.all.client.service.rapache.fullpath+"getGeneData?format=CSV"
				request = require 'request'
				request(
					method: 'POST'
					url: baseurl
					body: JSON.stringify req.body
					json: true
				, (error, response, json) =>
					if !error && response.statusCode == 200
						dirName = 'gene'+crypto.randomBytes(4).readUInt32LE(0)+'query';
						fs.mkdir('./privateTempFiles/' + dirName, (err) ->
							if err
								console.log 'there was an error creating a gene id query directory'
								console.log err
								resp.end "gene query directory could not be saved"
							else
								filename = 'GeneQuery.csv';
								fs.writeFile('./privateTempFiles/' + dirName + "/" + filename, json, (err) ->
									if err
										console.log 'there was an error saving a gene id query csv file'
										console.log err
										resp.end "File could not be saved"
									else
										if config.all.client.use.ssl
											urlPref = "https://"
										else
											urlPref = "http://"
										resp.json
											fileURL: urlPref + config.all.client.host + ":" + config.all.client.port + "/tempfiles/" + dirName + "/" + filename
									return
								)
							return
						)
					else
						console.log 'got ajax error trying to get gene data csv from the server'
						console.log error
						console.log json
						console.log response
				)

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
				file = fs.createWriteStream './privateTempFiles/'+filename
				rem = request urlPref+'localhost:'+config.all.client.port+'/src/modules/GeneDataQueries/spec/testFiles/geneQueryResult.csv'
				rem.on 'data', (chunk) ->
					file.write(chunk);
				rem.on 'end', ->
					file.close()
					resp.json
						fileURL: urlPref+"localhost:'+config.all.client.port+'/tempFiles/"+filename
			else
				config = require '../conf/compiled/conf.js'
				baseurl = config.all.client.service.rapache.fullpath+"getFilteredGeneData?format=CSV"
				request = require 'request'
				request(
					method: 'POST'
					url: baseurl
					body: JSON.stringify req.body
					json: true
				, (error, response, json) =>
					if !error && response.statusCode == 200
						dirName = 'gene'+crypto.randomBytes(4).readUInt32LE(0)+'query';
						fs.mkdir('./privateTempFiles/' + dirName, (err) ->
							if err
								console.log 'there was an error creating a gene id query directory'
								console.log err
								resp.end "gene query directory could not be saved"
							else
								filename = 'GeneQuery.csv';
								fs.writeFile('./privateTempFiles/' + dirName + "/" + filename, json, (err) ->
									if err
										console.log 'there was an error saving a gene id query csv file'
										console.log err
										resp.end "File could not be saved"
									else
										if config.all.client.use.ssl
											urlPref = "https://"
										else
											urlPref = "http://"
										resp.json
											fileURL: urlPref + config.all.client.host + ":" + config.all.client.port + "/tempfiles/" + dirName + "/" + filename
									return
								)
							return
						)
					else
						console.log 'got ajax error trying to get gene data csv from the server'
						console.log error
						console.log json
						console.log response
				)
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
			baseurl = config.all.client.service.rapache.fullpath+"getFilteredGeneData"
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
