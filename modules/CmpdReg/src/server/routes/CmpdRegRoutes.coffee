exports.setupAPIRoutes = (app) ->
	app.post '/api/cmpdReg', exports.postAssignedProperties
	app.get '/cmpdReg/scientists', exports.getBasicCmpdReg
	app.get '/cmpdReg/metalots/corpName/[\\S]*', exports.getMetaLot

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdReg', loginRoutes.ensureAuthenticated, exports.cmpdRegIndex
	app.get '/marvin4js-license.cxl', loginRoutes.ensureAuthenticated, exports.getMarvinJSLicense
	app.get '/cmpdReg/scientists', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/parentAliasKinds', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/units', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/solutionUnits', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/stereoCategorys', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/compoundTypes', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/parentAnnotations', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/fileTypes', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/projects', loginRoutes.ensureAuthenticated, exports.getAuthorizedCmpdRegProjects
	app.get '/cmpdReg/vendors', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/physicalStates', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/operators', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/purityMeasuredBys', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg
	app.get '/cmpdReg/structureimage/:type/[\\S]*', loginRoutes.ensureAuthenticated, exports.getStructureImage
	app.get '/cmpdReg/metalots/corpName/[\\S]*', loginRoutes.ensureAuthenticated, exports.getMetaLot
	app.get '/cmpdReg/MultipleFilePicker/[\\S]*', loginRoutes.ensureAuthenticated, exports.getMultipleFilePicker
	app.post '/cmpdReg/search/cmpds', loginRoutes.ensureAuthenticated, exports.searchCmpds
	app.post '/cmpdReg/regsearches/parent', loginRoutes.ensureAuthenticated, exports.regSearch
	app.post '/cmpdReg/filesave', loginRoutes.ensureAuthenticated, exports.fileSave
	app.post '/cmpdReg/metalots', loginRoutes.ensureAuthenticated, exports.metaLots
	app.post '/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.saveSalts
	app.post '/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.saveIsotopes
	app.post '/cmpdReg/api/v1/structureServices/molconvert', loginRoutes.ensureAuthenticated, exports.molConvert
	app.post '/cmpdReg/api/v1/structureServices/clean', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/api/v1/structureServices/hydrogenizer', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/api/v1/structureServices/cipStereoInfo', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/export/searchResults', loginRoutes.ensureAuthenticated, exports.exportSearchResults
	app.post '/cmpdReg/validateParent', loginRoutes.ensureAuthenticated, exports.validateParent
	app.post '/cmpdReg/updateParent', loginRoutes.ensureAuthenticated, exports.updateParent

exports.cmpdRegIndex = (req, res) ->
	scriptPaths = require './RequiredClientScripts.js'
	config = require '../conf/compiled/conf.js'
	cmpdRegConfig = require '../public/CmpdReg/client/custom/configuration.json'
	_ = require 'underscore'
	grantedRoles = _.map req.user.roles, (role) ->
		role.roleEntry.roleName
	console.log grantedRoles
	isChemist = !config.all.client.roles.cmpdreg?.chemistRole? || (config.all.client.roles.cmpdreg?.chemistRole? && config.all.client.roles.cmpdreg.chemistRole in grantedRoles)
	isAdmin = !config.all.client.roles.cmpdreg?.adminRole? || (config.all.client.roles.cmpdreg?.adminRole? && config.all.client.roles.cmpdreg.adminRole in grantedRoles)
	global.specRunnerTestmode = if global.stubsMode then true else false
	scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts)
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
		cmpdRegUser =
			id: req.user.id
			code: req.user.username
			name: req.user.firstName + " " + req.user.lastName
			isChemist: isChemist
			isAdmin: isAdmin
		syncCmpdRegUser req, cmpdRegUser
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"
		cmpdRegUser =
			id: 0
			code: "nouser"
			name: "no user"
			isChemist: true
			isAdmin : true

	return res.render 'CmpdReg',
		title: "Compound Registration"
		scripts: scriptsToLoad
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			cmpdRegUser: cmpdRegUser
			testMode: false
			moduleLaunchParams: if moduleLaunchParams? then moduleLaunchParams else null
			deployMode: global.deployMode
			cmpdRegConfig: cmpdRegConfig

syncCmpdRegUser = (req, cmpdRegUser) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	_ = require "underscore"
	exports.getScientists req, (scientistResponse) ->
		foundScientists = JSON.parse scientistResponse
		if (_.findWhere foundScientists, {code: cmpdRegUser.code})?
			#update scientist
			console.debug 'found scientist '+cmpdRegUser.code
			if (_.findWhere foundScientists, {code: cmpdRegUser.code, isAdmin: cmpdRegUser.isAdmin, isChemist: cmpdRegUser.isChemist, name: cmpdRegUser.name})?
				console.debug 'CmpdReg scientists are up-to-date'
			else
				oldScientist = _.findWhere foundScientists, {code: cmpdRegUser.code}
				cmpdRegUser.id = oldScientist.id
				cmpdRegUser.ignore = oldScientist.ignore
				cmpdRegUser.version = oldScientist.version
				console.debug 'updating scientist with JSON: '+ JSON.stringify cmpdRegUser
				exports.updateScientists [cmpdRegUser], (updateScientistsResponse) ->
		else
			#create new scientist
			console.debug 'scientist '+cmpdRegUser.code+' not found.'
			console.debug 'creating new scientist' + JSON.stringify cmpdRegUser
			exports.saveScientists [cmpdRegUser], (saveScientistsResponse) ->

exports.getBasicCmpdReg = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in getBasicCmpdReg'
	console.log req.originalUrl
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" +endOfUrl
	console.log cmpdRegCall
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.getAuthorizedCmpdRegProjects = (req, resp) ->
	exports.getAuthorizedCmpdRegProjectsInternal req, (response) =>
		resp.status "200"
		resp.end JSON.stringify response

exports.getAuthorizedCmpdRegProjectsInternal = (req, callback) ->
	_ = require "underscore"
	exports.getACASProjects req, (statusCode, acasProjectsResponse)->
		acasProjects = acasProjectsResponse
		exports.getProjects req, (cmpdRegProjectsResponse)->
			cmpdRegProjects = JSON.parse cmpdRegProjectsResponse
			allowedProjectCodes = _.pluck acasProjects, 'code'
			allowedProjects = _.filter cmpdRegProjects, (cmpdRegProject) ->
				return (cmpdRegProject.code in allowedProjectCodes)
			callback allowedProjects


exports.getACASProjects = (req, callback) ->
	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	if !req.user?
		req.user = {}
		req.user.username = req.params.username
	if global.specRunnerTestmode
		resp.end JSON.stringify "testMode not implemented"
	else
		csUtilities.getProjectsInternal req, callback

exports.getProjects = (req, callback) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in getProjects'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/projects"
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
	, (error, response, json)=>
		if !error
			console.log JSON.stringify json
			callback JSON.stringify json
		else
			console.log 'got ajax error trying to get CmpdReg projects'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}
	)

exports.saveProjects = (jsonBody, callback) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in saveProjects'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/projects/jsonArray"
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify jsonBody
		json: true
	, (error, response, json)=>
		if !error
			console.log JSON.stringify json
			callback JSON.stringify json
		else
			console.log 'got ajax error trying to save CmpdReg projects'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}
	)

exports.updateProjects = (jsonBody, callback) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in updateProjects'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/projects/jsonArray"
	request(
		method: 'PUT'
		url: cmpdRegCall
		body: JSON.stringify jsonBody
		json: true
	, (error, response, json)=>
		if !error
			console.log JSON.stringify json
			callback JSON.stringify json
		else
			console.log 'got ajax error trying to update CmpdReg projects'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}
	)

exports.getScientists = (req, callback) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in getScientists'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/scientists"
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
	, (error, response, json)=>
		if !error
			console.log JSON.stringify json
			callback JSON.stringify json
		else
			console.log 'got ajax error trying to get CmpdReg scientists'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}
	)

exports.saveScientists = (jsonBody, callback) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in saveScientists'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/scientists/jsonArray"
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify jsonBody
		json: true
	, (error, response, json)=>
		if !error
			console.log JSON.stringify json
			callback JSON.stringify json
		else
			console.log 'got ajax error trying to save CmpdReg scientists'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}
	)

exports.updateScientists = (jsonBody, callback) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in updateScientists'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/scientists/jsonArray"
	request(
		method: 'PUT'
		url: cmpdRegCall
		body: JSON.stringify jsonBody
		json: true
	, (error, response, json)=>
		if !error
			console.log JSON.stringify json
			callback JSON.stringify json
		else
			console.log 'got ajax error trying to update CmpdReg scientists'
			console.log error
			console.log json
			console.log response
			callback JSON.stringify {error: "something went wrong :("}
	)

exports.searchCmpds = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/search/cmpds'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to search for compounds'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.getStructureImage = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	imagePath = (req.originalUrl).replace /\/cmpdreg\/structureimage/, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/structureimage' + imagePath
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.getMetaLot = (req, resp) ->
	request = require 'request'
	_ = require 'underscore'
	config = require '../conf/compiled/conf.js'
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\/metalots/, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/metalots' + endOfUrl
	console.log cmpdRegCall
	cmpdRegConfig = require '../public/CmpdReg/client/custom/configuration.json'
	request(
		method: 'GET'
		url: cmpdRegCall
		json: true
	, (error, response, json)=>
		console.log "metalot return"
		console.log error
		console.log response
		console.log json

		if !error
			if not json.lot?
				resp.statusCode = 500
				resp.end JSON.stringify "Could not find lot"
				return			

			if json?.lot?.project?.code?
				projectCode = json.lot.project.code
				if cmpdRegConfig.metaLot.useProjectRolesToRestrictLotDetails
					exports.getACASProjects req, (statusCode, acasProjectsForUsers) =>
						if statusCode != 200
							resp.statusCode = statusCode
							resp.end JSON.stringify acasProjectsForUsers
						if _.where(acasProjectsForUsers, {code: projectCode}).length > 0
							resp.json json
						else
							console.log "user does not have permissions to the lot's project"
							resp.statusCode = 500
							resp.end JSON.stringify "Lot does not exist"
				else
					resp.json json
			else #no project attr in lot
				if cmpdRegConfig.metaLot.useProjectRolesToRestrictLotDetails
					resp.statusCode = 500
					resp.end JSON.stringify "Could not find lot"
				else
					resp.json json

		else
			console.log 'got ajax error trying to get CmpdReg MetaLot'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify error
	)

exports.regSearch = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/regsearches/parent'
	console.log cmpdRegCall
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do registration search'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.getMarvinJSLicense = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = (config.all.client.service.cmpdReg.persistence.basepath).replace '\/cmpdreg', "/"
	licensePath = cmpdRegCall + 'marvin4js-license.cxl'
	console.log licensePath
	req.pipe(request(licensePath)).pipe(resp)

exports.getMultipleFilePicker = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" +endOfUrl
	cmpdRegCall = cmpdRegCall.replace /\\/g, "%5C"
	console.log cmpdRegCall
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.fileSave = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/filesave'
	req.pipe(request[req.method.toLowerCase()](cmpdRegCall)).pipe(resp)

exports.metaLots = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/metalots'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do metalot save'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveSalts = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/salts'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do save salts'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveIsotopes = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/isotopes'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do save isotopes'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.molConvert = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" +endOfUrl
	#	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/api/v1/structureServices/molconvert'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do generic structure service'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.genericStructureService = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" +endOfUrl
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log json
			resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'plain/text')
			resp.end json
		else
			console.log 'got ajax error trying to do generic structure service'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.exportSearchResults = (req, resp) ->
	path = require 'path'
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/export/searchResults'

	uploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
	exportedSearchResults = uploadsPath + "exportedSearchResults/"

	serverUtilityFunctions.ensureExists exportedSearchResults, 0o0744, (err) ->
		if err?
			console.log "Can't find or create exportedSearchResults folder: " + exportedSearchResults
			resp.statusCode = 500
			resp.end "Error trying to export search results to sdf: Can't find or create exportedSearchResults folder " + exportedSearchResults
		else
			date = new Date();
			monthNum = date.getMonth()+1;
			currentDate = (date.getFullYear()+'_'+("0" + monthNum).slice(-2)+'_'+("0" + date.getDate()).slice(-2));
			fileName = currentDate+"_"+date.getTime()+"_searchResults.sdf";
			dataToPost = {
				filePath: exportedSearchResults + fileName,
				searchFormResultsDTO: req.body
			}
			request(
				method: 'POST'
				url: cmpdRegCall
				body: dataToPost
				json: true
				timeout: 6000000
			, (error, response, json) =>
				if !error
					resp.setHeader('Content-Type', 'plain/text')
					absFilePath = json.reportFilePath
					console.log absFilePath
					relPath = config.all.server.datafiles.relative_path
					if relPath.substr(-1) is '/'
						relPath = relPath.substring(0, relPath.length-1)
					relFilePath = absFilePath.split(relPath+path.sep)[1]
					console.log relFilePath
					downloadFilePath = config.all.client.datafiles.downloadurl.prefix + relFilePath
					json.reportFilePath = downloadFilePath
					resp.json json
				else
					console.log 'got ajax error trying to export search results to sdf'
					console.log error
					console.log json
					console.log response
					resp.statusCode = 500
					resp.end "Error trying to export search results to sdf: " + error;

			)

exports.validateParent = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log "exports.validateParent"

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/validateParent'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to validate parent'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to validate parent: " + error;
	)

exports.updateParent = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log "exports.updateParent"

	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			resp.setHeader('Content-Type', 'plain/text')
			resp.json json
		else
			console.log 'got ajax error trying to update parent'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update parent: " + error;
	)