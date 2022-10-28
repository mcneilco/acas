exports.setupAPIRoutes = (app) ->
	app.get '/cmpdReg/scientists', exports.getScientists
	app.get '/cmpdReg/metalots/corpName/:lotCorpName', exports.getMetaLot
	app.delete '/cmpdReg/metalots/corpName/:lotCorpName', exports.deleteMetaLot
	app.get '/cmpdReg/metalots/checkDependencies/corpName/:lotCorpName', exports.getMetaLotDependencies
	app.post '/cmpdReg/metalots', exports.saveMetaLot
	app.get '/cmpdReg/parentLot/getAllAuthorizedLots', exports.getAllAuthorizedLots

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/cmpdReg', loginRoutes.ensureAuthenticated, exports.cmpdRegIndex
	app.get '/marvin4js-license.cxl', loginRoutes.ensureAuthenticated, exports.getMarvinJSLicense
	app.get '/cmpdReg/scientists', loginRoutes.ensureAuthenticated, exports.getScientists
	app.get '/cmpdReg/aliases/parentAliasKinds', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/units', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/solutionUnits', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/salts/sdf', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/stereoCategories', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/compoundTypes', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/parentAnnotations', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/fileTypes', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/projects', loginRoutes.ensureAuthenticated, exports.getAuthorizedCmpdRegProjects
	app.get '/cmpdReg/vendors', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/physicalStates', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/operators', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/purityMeasuredBys', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/structureimage/:type/[\\S]*', loginRoutes.ensureAuthenticated, exports.getStructureImage
	app.get '/cmpdReg/metalots/corpName/:lotCorpName', loginRoutes.ensureAuthenticated, exports.getMetaLot
	app.get '/cmpdReg/MultipleFilePicker/[\\S]*', loginRoutes.ensureAuthenticated, exports.getMultipleFilePicker
	app.post '/cmpdReg/search/cmpds', loginRoutes.ensureAuthenticated, exports.searchCmpds
	app.post '/cmpdReg/regsearches/parent', loginRoutes.ensureAuthenticated, exports.regSearch
	app.post '/cmpdReg/structuresearch', loginRoutes.ensureAuthenticated, exports.structureSearch
	app.post '/cmpdReg/filesave', loginRoutes.ensureAuthenticated, exports.fileSave
	app.post '/cmpdReg/metalots', loginRoutes.ensureAuthenticated, exports.saveMetaLot
	app.delete '/cmpdReg/metalots/corpName/:lotCorpName', loginRoutes.ensureAuthenticated, exports.deleteMetaLot
	app.get '/cmpdReg/metalots/checkDependencies/corpName/:lotCorpName',  loginRoutes.ensureAuthenticated, exports.getMetaLotDependencies
	app.post '/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.saveSalts
	app.post '/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.saveIsotopes
	app.post '/cmpdReg/api/v1/structureServices/molconvert', loginRoutes.ensureAuthenticated, exports.molConvert
	app.post '/cmpdReg/api/v1/structureServices/clean', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/api/v1/structureServices/hydrogenizer', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/api/v1/structureServices/cipStereoInfo', loginRoutes.ensureAuthenticated, exports.genericStructureService
	app.post '/cmpdReg/export/searchResults', loginRoutes.ensureAuthenticated, exports.exportSearchResults
	app.post '/cmpdReg/validateParent', loginRoutes.ensureAuthenticated, exports.validateParent
	app.post '/cmpdReg/updateParent', loginRoutes.ensureAuthenticated, exports.updateParent
	app.post '/cmpdReg/swapParentStructures', loginRoutes.ensureAuthenticated, exports.swapParentStructures
	app.post '/cmpdReg/api/v1/lotServices/update/lot/metadata', loginRoutes.ensureAuthenticated, exports.updateLotMetadata
	app.post '/cmpdReg/api/v1/lotServices/update/lot/metadata/jsonArray', loginRoutes.ensureAuthenticated, exports.updateLotsMetadata
	app.post '/cmpdReg/api/v1/parentServices/update/parent/metadata', loginRoutes.ensureAuthenticated, exports.updateParentMetadata
	app.post '/cmpdReg/api/v1/parentServices/update/parent/metadata/jsonArray', loginRoutes.ensureAuthenticated, exports.updateParentsMetadata
	app.get '/api/cmpdReg/ketcher/knocknock', loginRoutes.ensureAuthenticated, exports.ketcherKnocknock
	app.get '/api/cmpdReg/ketcher/layout', loginRoutes.ensureAuthenticated, exports.ketcherConvertSmiles
	app.post '/api/cmpdReg/ketcher/layout', loginRoutes.ensureAuthenticated, exports.ketcherLayout
	app.post '/api/cmpdReg/ketcher/calculate_cip', loginRoutes.ensureAuthenticated, exports.ketcherCalculateCip
	app.get '/cmpdReg/labelPrefixes', loginRoutes.ensureAuthenticated, exports.getAuthorizedPrefixes
	app.get '/cmpdReg/parentLot/getLotsByParent', loginRoutes.ensureAuthenticated, exports.getAPICmpdReg
	app.get '/cmpdReg/parentLot/getAllAuthorizedLots', loginRoutes.ensureAuthenticated, exports.getAllAuthorizedLots
	app.get '/cmpdReg/allowCmpdRegistration', loginRoutes.ensureAuthenticated, exports.allowCmpdRegistration
	app.get '/cmpdReg/export/corpName/:lotCorpName', loginRoutes.ensureAuthenticated, exports.exportLotToSDF
	app.post '/api/cmpdReg/renderMolStructureBase64', loginRoutes.ensureAuthenticated, exports.renderMolStructureBase64CmpdReg

_ = require 'underscore'
request = require 'request'
config = require '../conf/compiled/conf.js'
serverUtilityFunctions = require './ServerUtilityFunctions.js'
loginRoutes = require './loginRoutes.js'
authorRoutes = require './AuthorRoutes.js'
experimentServiceRoutes = require './ExperimentServiceRoutes.js'

exports.cmpdRegIndex = (req, res) ->
	scriptPaths = require './RequiredClientScripts.js'
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
			cmpdRegConfig: config.all.client.cmpdreg

exports.getAPICmpdReg = (req, resp) ->
	console.log 'in getAPICmpdReg'
	console.log req.originalUrl
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "/" +endOfUrl
	console.log cmpdRegCall
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.getAuthorizedCmpdRegProjects = (req, resp) ->
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		resp.status "200"
		resp.end JSON.stringify allowedUserProjects

exports.getScientists = (req, resp) =>
	exports.getScientistsInternal (authors) ->
		resp.json authors 

exports.getScientistsInternal = (callback) ->
	config = require '../conf/compiled/conf.js'
	roleName = null
	if config.all.client.roles.cmpdreg.chemistRole? && config.all.client.roles.cmpdreg.chemistRole != ""
		roleName = config.all.client.roles.cmpdreg.chemistRole
	loginRoutes.getAuthorsInternal {additionalCodeType: 'compound', additionalCodeKind: 'scientist', roleName: roleName}, (statusCode, authors) =>
		callback authors

exports.structureSearch = (req, resp) ->
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		_ = require "underscore"
		allowedProjectCodes = _.pluck(allowedUserProjects, "code")
		req.body.projects = allowedProjectCodes
		console.log req.body
		cmpdRegCall = config.all.client.service.persistence.fullpath + '/structuresearch/'
		req.pipe(request[req.method.toLowerCase()](
			url: cmpdRegCall
			json: req.body)).pipe resp

exports.searchCmpds = (req, resp) ->
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		_ = require "underscore"
		allowedProjectCodes = _.pluck(allowedUserProjects, "code")
		req.body.projects = allowedProjectCodes
		console.log req.body
		cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/search/cmpds'
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
				console.log 'got ajax error trying to search for compounds'
				console.log error
				console.log json
				console.log response
				resp.end JSON.stringify {error: "something went wrong :("}
		)


exports.getAllAuthorizedLots = (req, resp) ->
	req.setTimeout 86400000
	authorRoutes.allowedProjectsInternal req.user, (statusCode, allowedUserProjects) ->
		_ = require "underscore"
		allowedProjectCodes = _.pluck(allowedUserProjects, "code")
		requestJSON = allowedProjectCodes
		console.log requestJSON
		cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/getLotsByProjectsList'
		request(
			method: 'POST'
			url: cmpdRegCall
			body: requestJSON
			json: true
			timeout: 6000000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.setHeader('Content-Type', 'application/json')
				resp.end JSON.stringify json
			else
				console.log resp.stat
				console.log 'got ajax error trying to get all lots'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				console.log response.statusCode
				resp.end JSON.stringify {error: "something went wrong :("}
		)

exports.getStructureImage = (req, resp) ->
	imagePath = (req.originalUrl).replace /\/cmpdreg\/structureimage/, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/structureimage' + imagePath
	req.pipe(request(cmpdRegCall)).pipe(resp)

class HTTPResponseError extends Error
	constructor: (response, ...args) ->
		super("HTTP Error Response: #{response.status} #{response.statusText}", ...args)
		this.response = response

class InternalServerError extends Error
	# Throw an internal server error
	constructor: (text, ...args) ->
		super("Internal server error: #{text}", ...args)

checkStatus = (response) ->
	# check for http error
	if response.ok
		return response
	else
		throw new HTTPResponseError response


exports.getMetaLotDependencies = (req, resp, next) ->

	requestedLotCorpName = req.params.lotCorpName
	user = req.user
	console.log "Checking meta lot dependencies for lot #{requestedLotCorpName} with user #{user.username}"

	# Faster to get the users allowed projects up front and pass it down to other functions
	[err, allowedProjects] = await serverUtilityFunctions.promisifyRequestStatusResponse(authorRoutes.allowedProjectsInternal, [user])
	if err?
		console.log "Error checking user projects: #{err}"
		resp.statusCode = 500
		resp.json err
		return

	# Get the meta lot
	[err, metaLot, statusCode] = await exports.getMetaLotInternal(req.params.lotCorpName, req.user, allowedProjects, getDeleteAcl=true)
	if err?
		console.log "User #{req.user.username} does not have permission to check dependencies for lot #{req.params.lotCorpName}"
		resp.statusCode = statusCode
		resp.json err
		return
	
	try
		# Check the parameter for includeLinkedLots but return true by default
		if req.query.includeLinkedLots?
			# Booleans are passed as strings, so convert to boolean
			# Only set this to false if the value is actually "false" or "0"
			includeLinkedLots = if(req.query.includeLinkedLots == "false" || req.query.includeLinkedLots == "0") then false else true
		else
			includeLinkedLots = true
		dependencies = await exports.getLotDependenciesInternal(metaLot.lot, user, allowedProjects, includeLinkedLots)
		resp.json dependencies
	catch error
		console.error error
		err =  "Error getting lot"
		resp.statusCode = 500
		resp.json {error: err}

exports.getLotDependenciesByCorpNameInternal = (lotCorpName, user, allowedProjects, includeLinkedLots=true) ->
	[err, metaLot, statusCode] = await exports.getMetaLotInternal(lotCorpName, user, allowedProjects, getDeleteAcl=false)
	dependencies = await exports.getLotDependenciesInternal(metaLot.lot, user, allowedProjects, includeLinkedLots)
	return dependencies

exports.getLotDependenciesInternal = (lot, user, allowedProjects, includeLinkedLots=true) ->
	console.log "Checking lot dependencies for lot #{lot.corpName} with user #{user.username}"

	if !allowedProjects?
		[err, allowedProjects] = await serverUtilityFunctions.promisifyRequestStatusResponse(authorRoutes.allowedProjectsInternal, [user])
		if err?
			throw new InternalServerError "Error checking user projects"
			return

	lotCorpName = lot.corpName

	# Get the depdencies from the service which does not cover user ACLS
	response = await exports.fetchMetaLotDependencies(lotCorpName)

	checkStatus response
	dependencies = await response.json()

	## Add the lot to the dependencies return
	dependencies.lot = lot

	# We decorate the linkedExperiments with the acls for the user
	if dependencies.linkedExperiments? && dependencies.linkedExperiments.length > 0
		console.log "Found #{dependencies.linkedExperiments.length} linked experiments to #{lotCorpName}, checking user acls on each experiment"

		# Get the codes and experiments from the server so we can look up project codes and scientist ownership of the experiments
		experimentCodeList = _.pluck(dependencies.linkedExperiments, "code")

		# Unique the list just in case there are duplicates (there should not be)
		experimentCodeList = _.uniq experimentCodeList

		# Get the experiments from the server
		response = await experimentServiceRoutes.fetchExperimentsByCodeNames(experimentCodeList)
		experiments = await response.json()

		# It's unexpected that the server would return a list of experiments that are not in the list of codes we asked for, so we check for that and erorr
		if(experiments.length != experimentCodeList.length)
			console.log "Error: #{experimentCodeList.length} experiments were requested, but only #{experiments.length} were returned"
			console.log "Requested codes: #{experimentCodeList}"
			console.log "Returned experiments: #{JSON.stringify(experiments)}"
			throw new InternalServerError "Error: #{experimentCodeList.length} experiments were requested, but only #{experiments.length} were returned"

		# Get the acls for the experiments
		for experiment in experiments
			console.log "Checking acls for experiment #{experiment.code}"

			# This returns the acls (read, write, delete of the experiment for the user and allowed project the user has)
			acls = await experimentServiceRoutes.getExperimentACL(experiment.experiment, user, allowedProjects)
			idx = _.findIndex(dependencies.linkedExperiments, { code: experiment.experiment.codeName })
			
			# The experiment is not readable by the user, then just return the acls in the array of experiments
			# This way it'know there are experiments linked that aren't readable
			if !acls.getRead()
				console.log "Experiment #{experiment.experiment.codeName} is not readable by user #{user.username}"
				# If the experiiment is not readable we just want to include the acls but not the experiment code table
				# We include the acls so that the user can see that there is an experiment linked that they can't read
				dependencies.linkedExperiments[idx] = {acls: acls, code: null, name: null, ignored: false}
			else
				# The experiment is readable so includ the experiment and acls
				dependencies.linkedExperiments[idx].acls = acls
	else
		console.log "No experiments linked to #{lotCorpName}"

	# Look up and attach the acls of the linked lots
	# Don't show any information except acls if the user cannot read the lot
	# This data is purely informational when considering the dependencies of a lot
	# because linked lots do not mean that the user cannot delete the lot.
	if includeLinkedLots? && includeLinkedLots
		response = await exports.fetchLotsByParent(lot.parent.corpName)
		allLotsForParent = await response.json()
		console.log "Found #{allLotsForParent.length} lots for parent #{lotCorpName}"
		linkedLots = []
		for codeTable in allLotsForParent
			if codeTable.code == lotCorpName
				console.log "Ignoring #{lotCorpName} because it is the same as the lot we are checking"
				continue
			else	
				response = await exports.fetchMetaLot(codeTable.code)
				dependentMetaLot = await response.json()
				dependentLotAcls = await exports.getLotAcls(dependentMetaLot.lot, user, allowedProjects, getDeleteAcl=false)
				if dependentLotAcls.getRead()
					linkedLots.push _.extend(codeTable, {acls: dependentLotAcls})
				else
					console.log "Lot #{codeTable.code} is not readable by user #{user.username}"
					# If the lot is not readable we just want to include the acls but not the lot code table
					# We include the acls so that the user can see that there is a lot linked that they can't read
					linkedLots.push {acls: dependentLotAcls, code: null, name: null, ignored: false}
		dependencies.linkedLots = linkedLots

	# Delete the summary attribute from dependencies if it exists
	if dependencies.summary?
		delete dependencies.summary
	return dependencies

exports.fetchMetaLotDependencies = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/checkDependencies/corpName/' + lotCorpName
	response = await fetch(url, method: 'GET')
	return response
	

exports.fetchLotsByParent = (parentCorpName) ->
	urlParams = new URLSearchParams({parentCorpName: parentCorpName})
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/getLotsByParent?'
	response = await fetch(url + urlParams, method: 'GET')
	return response

exports.getMetaLotInternal = (lotCorpName, user, allowedProjects, getDeleteAcl=true) ->
	# Get the metalot and check acls
	response = await exports.fetchMetaLot(lotCorpName)
	err = null
	metaLot = null
	statusCode = 200
	try
		checkStatus response
		metaLot = await response.json()
		if Object.keys(metaLot).length == 0 || !metaLot.lot?
			statusCode = 500
			err =  "Could not find lot"
		else
			acls = await exports.getLotAcls(metaLot.lot, user, allowedProjects, getDeleteAcl)
			metaLot.lot.acls = acls
			if !acls.getRead()
				statusCode = 403
				err = "You do not have permission to view this lot"
	catch error
		console.error error
		statusCode = 500
		err =  "Error getting lot"
	return [err, metaLot, statusCode]

exports.getMetaLot = (req, resp, next) ->
	[err, metaLot, statusCode] = await exports.getMetaLotInternal req.params.lotCorpName, req.user, null, getDeleteAcl=true
	resp.statusCode = statusCode
	if err?
		resp.statusCode = statusCode
		resp.json err
	else
		resp.json metaLot

exports.deleteMetaLot = (req, resp, next) ->
	if !req.user?
		req.user = {
			username: "bob"
			roles: []
		}
	[err, metaLot, statusCode] = await exports.getMetaLotInternal req.params.lotCorpName, req.user, null, getDeleteAcl=true
	if err?
		resp.statusCode = statusCode
		resp.json err
	else
		if metaLot.lot.acls.getDelete()
			console.log "Calling delete lot"
			response = await exports.deleteLotByCorpName(metaLot.lot.corpName)
			console.log "Got response from delete lot"
			if response.status == 200
				resp.statusCode = 200
				resp.json {success: true}
			else
				resp.statusCode = 500
				jsonResponse = await response.json()
				resp.json jsonResponse
		else
			resp.statusCode = 403
			resp.json "You do not have permission to delete this lot"
	

exports.fetchMetaLot = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/corpName/' + lotCorpName
	response = await fetch(url, headers: {'Content-Type': 'application/json'})
	return response;

exports.deleteLotByCorpName = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/corpName/' + lotCorpName
	response = await fetch(url, method: 'DELETE')
	return response


exports.getLotAcls = (lot, user, allowedProjects, checkDelete=true) ->
	# Get the acls for the lot
	lotAcls = new Acls(false, false, false)

	# Check if user is cmpdreg admin
	isCmpdRegAdmin = loginRoutes.checkHasRole(user, config.all.client.roles.cmpdreg.adminRole)
	if isCmpdRegAdmin
		# If the user is a cmpd reg admin, then regardless of the lot's project or other configs they can read and write the lot
		lotAcls.setRead(true)
		lotAcls.setWrite(true)
	else
		# If the user is not a cmpd reg admin, then check if we are restricting the lot by project acls
		if lot.project? && config.all.client.cmpdreg.metaLot.useProjectRolesToRestrictLotDetails
			projectCode = lot.project
			# There are some cases where we want to call this function where we want to pass allowed projects in rather than call out to the service.
			# If the allowedProjects parameter is passed in, then we use that instead of calling the service.
			if !allowedProjects?
				# Get the allowed projects for the user
				[err, allowedProjects] = await serverUtilityFunctions.promisifyRequestStatusResponse(authorRoutes.allowedProjectsInternal, [user])
				if err?
					throw new InternalServerError "Could not get user's projects" 

			# Check if the lot's project is in the allowed projects
			console.log "Checking if lot's project #{projectCode} is in allowed projects: #{JSON.stringify(allowedProjects)}"
			if _.where(allowedProjects, {code: projectCode}).length > 0
				lotAcls.setRead(true)
			else
				# Default to not allowing read access so no need to set false here, just log it
				console.warn "User #{user.username} does not have access to project #{projectCode} for lot #{lot.corpName}"
		else
			# If we are not restricting the lot by project acls then anyone can read the lot 
			lotAcls.setRead(true)
		
		# If the user is not a cmpd reg admin, then they can only write the lot if they are allowed to read the lot
		if !lotAcls.getRead()
			lotAcls.setWrite(false)
		else
			# If the user is not a cmpd reg admin, then they can only write the lot if disableEditMyLots is false
			# and they are either the chemist or the lot registerdBy
			if config.all.client.cmpdreg.metaLot.disableEditMyLots == false
				canWrite = (lot.chemist? && lot.chemist == user.username) || (lot.registerdBy? && lot.registerdBy == user.username)
				if canWrite
					lotAcls.setWrite(true)
				else
					console.log "User #{user.username} does not have permission to edit lot #{lot.corpName} which is not their lot (registerdBy: #{lot.registerdBy}, chemist: #{lot.chemist})"
					lotAcls.setWrite(false)

	if lotAcls.getRead() && lotAcls.getWrite() && checkDelete
		console.log "Checking delete acl for lot #{lot.corpName}"

		# If disableDeleteMyLots is true then being the owner does not infer delete permission
		if config.all.client.cmpdreg.metaLot.disableDeleteMyLots == true && !isCmpdRegAdmin
			console.log "Disable delete my lots is true and user is not a cmpd reg admin so user #{user.username} cannot delete lot #{lot.corpName}"
			lotAcls.setDelete(false)
		else
			# Do not need to fetch linked lots here because they do not matter when considering delete acls (linked lots are purely informational)
			dependencies = await exports.getLotDependenciesInternal(lot, user, allowedProjects, false)
			canDelete = true
			for experiment in dependencies.linkedExperiments
				console.log "experiment"
				console.log experiment
				if !experiment.acls.getDelete()
					canDelete = false
					break
			if canDelete
				lotAcls.setDelete(true)

	console.log "User #{user.username} lot #{lot.corpName} lot acls #{JSON.stringify(lotAcls)}"
	return lotAcls

exports.fetchMetaLot = (lotCorpName) ->
	url = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots/corpName/' + lotCorpName
	response = await fetch(url, headers: {'Content-Type': 'application/json'})
	return response;

exports.regSearch = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/regsearches/parent'
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
	cmpdRegCall = (config.all.client.service.cmpdReg.persistence.basepath).replace '\/acas', "/"
	licensePath = cmpdRegCall + 'marvin4js-license.cxl'
	console.log licensePath
	req.pipe(request(licensePath)).pipe(resp)

exports.getMultipleFilePicker = (req, resp) ->
	endOfUrl = (req.originalUrl).replace /\/cmpdreg\//, ""
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + "/" +endOfUrl
	cmpdRegCall = cmpdRegCall.replace /\\/g, "%5C"
	console.log cmpdRegCall
	req.pipe(request(cmpdRegCall)).pipe(resp)

exports.fileSave = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/filesave'
	req.pipe(request[req.method.toLowerCase()](cmpdRegCall)).pipe(resp)

exports.saveMetaLot = (req, resp) ->
	metaLot = req.body;

	# Verify that lot is included as a metalot with no lot is not allowed
	if metaLot.lot?
		# If the user is in the request then update the lot's modifiedBy field as the persistence service does not
		if req.user?
			metaLot.lot.modifiedBy = req.user.username
		# If this is a saved lot then we need to check the user has permission to edit the lot
		# By checking the saved lots project, the users allowed projects
		if metaLot.lot.id? && metaLot.lot.corpName?
			# Get the saved meta lot as it returns the saved metalot and includes the acls
			[err, savedMetaLot, statusCode] = await exports.getMetaLotInternal metaLot.lot.corpName, req.user, null, getDeleteAcl=false
			if err?
				resp.statusCode = statusCode
				resp.end err
				return
			if savedMetaLot.lot.acls.getWrite() == false
				resp.statusCode = 403
				resp.json JSON.stringify {error: "You are not allowed to update to this lot"}
				return
	else
		resp.statusCode = 400
		resp.json JSON.stringify {error: "No lot specified"}
		return
	
	# We got here then then we can save the lot
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/metalots'
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, json) =>
		if !error
			console.log JSON.stringify json
			if JSON.stringify(json).indexOf("Duplicate") != -1
				resp.statusCode = 409
			else
				resp.statusCode = response.statusCode
			resp.setHeader('Content-Type', 'application/json')
			# Need to add acls here if the user just created the lot or updated it we can assume they have both read and write access checked above
			if json.metalot?.lot?
				json.metalot.lot.acls = new Acls(true, true)
			resp.end JSON.stringify json
		else
			console.log 'got ajax error trying to do metalot save'
			console.log error
			console.log json
			console.log response
			resp.end JSON.stringify {error: "something went wrong :("}
	)

exports.saveSalts = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/salts'
	if req.query?.dryrun?
		cmpdRegCall += "?dryrun=" + req.query.dryrun
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
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/isotopes'
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

exports.exportLotToSDF = (req, resp) ->

	# Get the list of lots to export
	lotCorpNames = [req.params.lotCorpName]
	
	# Verify acls on the lots requested
	[err, allowedProjects] = await serverUtilityFunctions.promisifyRequestStatusResponse(authorRoutes.allowedProjectsInternal, [req.user])

	# Get each metalot and verify the acls
	for lotCorpName in lotCorpNames
		console.log "Checking user acls for lot " + lotCorpName
		[err, metaLot, statusCode] = await exports.getMetaLotInternal(lotCorpName, req.user, allowedProjects, getDeleteAcl=false)
		if err?
			console.log "User #{req.user.username} does not have permission to export results for #{lotCorpName}"
			resp.statusCode = statusCode
			resp.json err
			return

	# Service URL
	exportCall = config.all.client.service.cmpdReg.persistence.fullpath + '/export/lotCorpNames'

	try
	# Use fetch to call the service and pipe the response to the client
		response = await fetch(exportCall,
			method: 'POST'
			body: JSON.stringify(lotCorpNames)
			headers:
				'Content-Type': 'application/json'
		)
		checkStatus response
		resp.set({
			"content-length": response.headers.get('content-length'),
			"content-disposition": "inline;filename=\"#{req.params.lotCorpName}.sdf\"",
			"content-type": response.headers.get('content-type'),        
		})
		response.body.pipe(resp);
	catch err
		console.log "Error calling service: " + err
		resp.statusCode = 500
		resp.json err


exports.exportSearchResults = (req, resp) ->
	path = require 'path'
	serverUtilityFunctions = require './ServerUtilityFunctions.js'


	# Get the lots from the req.body
	foundCompounds = req.body.foundCompounds
	JSON.stringify(foundCompounds)
	# Combine array of lotIds from each found compound
	lotCorpNames = []
	foundCompounds.forEach (foundCompound) ->
		console.log(foundCompound)
		lots = foundCompound.lotIDs
		lots.forEach (lot) ->
			console.log lots
			lotCorpNames.push lot.corpName
	console.log JSON.stringify(lotCorpNames)

	# Verify acls on the lots requested
	[err, allowedProjects] = await serverUtilityFunctions.promisifyRequestStatusResponse(authorRoutes.allowedProjectsInternal, [req.user])

	# # Get each metalot and verify the acls
	for lotCorpName in lotCorpNames
		console.log "Checking user acls for lot " + lotCorpName
		[err, metaLot, statusCode] = await exports.getMetaLotInternal(lotCorpName, req.user, allowedProjects, getDeleteAcl=false)
		if err?
			console.log "User #{req.user.username} does not have permission to export results for #{lotCorpName}"
			resp.statusCode = statusCode
			resp.json err
			return

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
	console.log "exports.updateParent"
	if req.user? && !req.body.modifiedBy?
		req.body.modifiedBy = req.user.username	
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

exports.swapParentStructures = (req, resp) ->
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/swapParentStructures'
	req.body['username'] = req.session.passport.user.username
	request(
		method: 'POST'
		url: cmpdRegCall
		body: JSON.stringify req.body
		json: true
		timeout: 6000000
	, (error, response, data) =>
		if !error
			resp.statusCode = response.statusCode
			resp.json data
		else
			console.log 'got ajax error trying to swap parent structures'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to swap parent structures: " + error
	)

exports.updateLotMetadata = (req, resp) ->
	request = require 'request'
	config = require '../conf/compiled/conf.js'
	console.log 'in update lot metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/updateLot/metadata'
	console.log cmpdRegCall
	if req.user? && !req.body.modifiedBy?
		req.body.modifiedBy = req.user.username
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
			console.log 'got ajax error trying to update Lot metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update lot: " + error;
	)
		
exports.updateLotsMetadata = (req, resp) ->
	console.log 'in update lot array metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parentLot/updateLot/metadata/jsonArray'
	console.log cmpdRegCall
	if req.user?
		req.body.map((lot) ->
			if !lot.modifiedBy?
				lot.modifiedBy = req.user.username
		)
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
			console.log 'got ajax error trying to update Lot array metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update lot: " + error;
	)

exports.updateParentMetadata = (req, resp) ->
	console.log 'in update parent metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent/metadata'
	console.log cmpdRegCall
	if req.user? && !req.body.modifiedBy?
		req.body.modifiedBy = req.user.username
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
			console.log 'got ajax error trying to update parent metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update parent: " + error;
	)
	
exports.updateParentsMetadata = (req, resp) ->
	console.log 'in update parent array metaData'
	cmpdRegCall = config.all.client.service.cmpdReg.persistence.fullpath + '/parents/updateParent/metadata/jsonArray'
	console.log cmpdRegCall

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
			console.log 'got ajax error trying to update parent array metadata'
			console.log error
			console.log json
			console.log response
			resp.statusCode = 500
			resp.end "Error trying to update parent: " + error;
	)

exports.ketcherKnocknock = (req, resp) ->
	resp.end "You are welcome!"

exports.ketcherConvertSmiles = (req, resp) ->
	if global.specRunnerTestmode
		resp.end "Ok.\n\n  -INDIGO-06301717442D\n\n  4  3  0  0  0  0  0  0  0  0999 V2000\n   -1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.7713    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  2  3  1  0  0  0  0\n  3  4  1  0  0  0  0\nM  END\n"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"/structureServices/molconvert"
		request = require 'request'
		data =
			structure: req.query.smiles
			inputFormat: 'smiles'
		request(
			method: 'POST'
			url: baseurl
			body: data
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200 and json.indexOf('<') != 0
				statusMessage = "Ok.\n"
				resp.end statusMessage+json.structure
			else
				console.log 'got ajax error trying to convert smiles to MOL'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "Smiles to MOL conversion failed"
		)

exports.ketcherLayout = (req, resp) ->
	if global.specRunnerTestmode
		resp.end "Ok.\n\n  -INDIGO-06301717442D\n\n  4  3  0  0  0  0  0  0  0  0999 V2000\n   -1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.7713    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  2  3  1  0  0  0  0\n  3  4  1  0  0  0  0\nM  END\n"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"/structureServices/clean"
		request = require 'request'
		data =
			structure: req.body.moldata
			parameters:
				dim: 2
				opts: ""
		console.log data
		request(
			method: 'POST'
			url: baseurl
			body: data
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200 and json.indexOf('<') != 0
				statusMessage = "Ok.\n"
				resp.end statusMessage+json
			else
				console.log 'got ajax error trying to clean MOL'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "Cleaning MOL conversion failed"
		)

exports.ketcherCalculateCip = (req, resp) ->
	if global.specRunnerTestmode
		resp.end "Ok.\n\n  -INDIGO-06301717442D\n\n  4  3  0  0  0  0  0  0  0  0999 V2000\n   -1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    1.3856   -0.8000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n    2.7713    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0\n  1  2  1  0  0  0  0\n  2  3  1  0  0  0  0\n  3  4  1  0  0  0  0\nM  END\n"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"/structureServices/cipStereoInfo"
		request = require 'request'
		data =
			structure: req.body.moldata
		request(
			method: 'POST'
			url: baseurl
			body: data
			json: true
		, (error, response, json) =>
			console.log response
			console.log json
			if !error && response.statusCode == 200 and json.indexOf('<') != 0
				statusMessage = "Ok.\n"
				resp.end statusMessage+json
			else
				console.log 'got ajax error trying to calculate CIP stereo descriptors'
				console.log error
				console.log json
				console.log response
				resp.statusCode = 500
				resp.end JSON.stringify "CIP stereo descriptor calculation failed"
		)

exports.getAuthorizedPrefixes = (req, resp) ->
	labelSeqRoutes = require './ACASLabelSequencesRoutes.js'
	req.query =
		labelTypeAndKind: 'id_corpName'
		thingTypeAndKind: 'parent_compound'
	labelSeqRoutes.getAuthorizedLabelSequencesInternal req, (statusCode, json) ->
		codeTables = []
		_.each json, (labelSeq) ->
			codeTable =
				id: labelSeq.id
				name: labelSeq.labelPrefix
				code: "#{labelSeq.labelPrefix}_#{labelSeq.labelTypeAndKind}_#{labelSeq.thingTypeAndKind}"
				labelTypeAndKind: labelSeq.labelTypeAndKind
				thingTypeAndKind: labelSeq.thingTypeAndKind
			codeTables.push codeTable
		resp.json codeTables

exports.allowCmpdRegistration = (req, resp) ->
	#for checking if standardization needed or if user wants to enable/disable cmpd registration
	if req.query.userOverride?
		#if req.query.userOverride = true, then always allow cmpd reg
		#if req.query.userOverride = false, then always disable cmpd reg
		allowCmpdRegistration = req.query.userOverride == "true"
		if allowCmpdRegistration
			message = "Compounds can be registerd"
		else
			message = "Compounds can not be registered at this time. Please contact an administrator for help."
		response =
			allowCmpdRegistration: allowCmpdRegistration
			message: message
		resp.json response
	else
		#check if needs standardization
		standardizationRoutes = require './StandardizationRoutes.js'
		standardizationRoutes.getStandardizationSettingsInternal (getStandardizationSettingsResp, statusCode) =>
			if statusCode is 500
				console.log "error getting current standardization settings"
				resp.statusCode = statusCode
				response =
					allowCmpdRegistration: false
					message: "Compounds can not be registered at this time due to an error getting current standardization settings. Please contact an administrator for help."
				resp.json response
			else
				allowCmpdRegistration = !getStandardizationSettingsResp.needsStandardization && getStandardizationSettingsResp.valid
				if allowCmpdRegistration
					message = "Compounds can be registered"
				else
					message = "Compounds can not be registered at this time because "
					reasons = []
					if !getStandardizationSettingsResp.valid
						reasons.push "the standardization settings are invalid"
					if getStandardizationSettingsResp.needsStandardization
						reasons.push "the registered compounds require standardization"
					message += reasons.join(" and ")
					message += ". Please contact an administrator for help."
				response =
					allowCmpdRegistration: allowCmpdRegistration
					message: message
				resp.json response

exports.renderMolStructureBase64CmpdReg = (req, resp) ->
	molecule = req.body.molStructure
	height = 200
	width = 200
	format = "png"
	if req.body.height?
		height = req.body.height
	if req.body.width?
		width = req.body.width
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.cmpdReg.persistence.fullpath+"structureimage/convertMol/base64?hsize=#{height}&wsize=#{width}&format=#{format}"
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: molecule
		json: true
	, (error, response, output) =>
		if !error && response.statusCode == 200
			resp.end output
		else
			console.log error
			console.log output
			console.log response
			resp.statusCode = 500
			resp.end JSON.stringify "render molStructure base64 CmpdReg failed"
	)