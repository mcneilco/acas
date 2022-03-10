###
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
###
ACAS_HOME="../../.."
serverUtilityFunctions = require "#{ACAS_HOME}/routes/ServerUtilityFunctions.js"
fs = require 'fs'
_ = require 'underscore'
util = require 'util'

exports.logUsage = (action, data, username) ->
# no ACAS logging service yet
	console.log "would have logged: "+action+" with data: "+data+" and user: "+username
	# logger = require "../../../routes/Logger"
	# global.logger.writeToLog("info", "logUsage", action, data, username, null)

exports.authCheck = (user, pass, retFun) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: config.all.server.roologin.loginLink
		form:
			j_username: user
			j_password: pass
		json: false
	, (error, response, json) =>
		if !error && response.statusCode == 200
			retFun JSON.stringify json
		else if !error && response.statusCode == 302
			if response.headers.location.indexOf("login_error")>=0
				retFun "login_error"
			else
				console.log 'Auth Successful - checking roles'
				exports.checkRoles user , (checkRoleResponse) ->
					retFun checkRoleResponse
#			retFun JSON.stringify response.headers.location
		else
			console.log 'got connection error trying authenticate a user'
			console.log error
			console.log json
			console.log response
			retFun "connection_error "+error
	)

exports.resetAuth = (email, retFun) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: config.all.client.service.persistence.fullpath+"authorization/resetPassword"
		body: email
		json: true
	, (error, response, json) =>
		console.log error
		console.log response.statusCode
		console.log json
		if !error && response.statusCode == 200
			retFun "Your new password has been sent to your email address."
		else
			console.log 'got ajax error trying reset password'
			console.log error
			console.log json
			console.log response
			retFun "connection_error "+error
	)

exports.changeAuth = (user, passOld, passNew, passNewAgain, retFun) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	request = require 'request'
	body =
		username: user
		oldPassword: passOld
		newPassword: passNew
		newPasswordAgain: passNewAgain
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: config.all.client.service.persistence.fullpath+"authorization/changePassword"
		body: body
		json: true
	, (error, response, json) =>
		console.log error
		console.log response.statusCode
		console.log json
		if !error && response.statusCode == 200
			retFun "Your password has successfully been changed"
		else if response.statusCode == 400
			retFun "Invalid password or new password does not match"
		else
			console.log 'got ajax error trying change password'
			console.log error
			console.log json
			console.log response
			retFun "connection_error "+error
	)
exports.getUser = (username, callback) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	if config.all.client.require.login
		request = require 'request'
		request(
			headers:
				accept: 'application/json'
			method: 'POST'
			url: config.all.server.roologin.getUserLink
			json:
				name:username
		, (error, response, json) =>
			if !error && response.statusCode == 200 && json.id
				callback null,
					id: json.id
					username: json.userName
					email: json.emailAddress
					firstName: json.firstName
					lastName: json.lastName
					roles: json.authorRoles
			else
				callback "user not found", null
		)
	else
		if username != "starksofwesteros"
			callback null,
				id: 0,
				username: username,
				email: username+"@nowhere.com",
				firstName: username,
				lastName: username
		else
			callback "user not found", null


exports.isUserAdmin = (user) ->
	_ = require 'underscore'
	adminRoles = _.filter user.roles, (role) ->
		role.roleEntry.roleName == 'admin'
	isAdmin = if adminRoles.length >0 then true else false

exports.findByUsername = (username, fn) ->
	return exports.getUser username, fn

formatSystemRolesFromSSOGroups = (ssoGroups) =>
	# Formats the sso roles into ACAS roles
	# Case insensitive check for "CMPDREG" in the name assigned the role to the lsKind 'CmpdReg'
	# if not matched, it assigns to role to the lsKind 'ACAS'
	roles = []
	if ssoGroups?
		if typeof ssoGroups == "string"
			groups = [ssoGroups]
		for group in ssoGroups
			roleName = group.toUpperCase()
			lsKind = 'ACAS'
			if roleName.indexOf("CMPDREG") > -1
				lsKind = 'CmpdReg'
			roles.push
				lsType: 'System'
				lsKind: lsKind
				roleName: "ROLE_#{roleName}"
	
	return roles

exports.ssoLoginStrategy = (req, profile, callback) ->
	exports.logUsage "login attempt", JSON.stringify(ip: req.ip, referer: req.headers['referer'], agent: req.headers['user-agent']), JSON.stringify(profile)
	config = require '../../../conf/compiled/conf.js'
	serverUtilityFunctions = require "#{ACAS_HOME}/routes/ServerUtilityFunctions.js"
	authorRoutes = require '../../../routes/AuthorRoutes.js'
	setupRoutes = require '../../../routes/SetupRoutes.js'

	# Expected profile keys
	expectedKeys = [config.all.server.security.saml.userNameAttribute, config.all.server.security.saml.firstNameAttribute, config.all.server.security.saml.lastNameAttribute, config.all.server.security.saml.emailAttribute]
	missingFromProfile = expectedKeys.filter (value) -> !Object.keys(profile).includes(value)
	if missingFromProfile.length > 0
		err = "Configured profile attributes are different than those configured on the IDP. Missing expected key(s) from returned user profile #{JSON.stringify(missingFromProfile)}"
		console.error err
		return callback null, false, message: err
		
	userName = profile[config.all.server.security.saml.userNameAttribute]
	newFirstName = profile[config.all.server.security.saml.firstNameAttribute]
	newLastName = profile[config.all.server.security.saml.lastNameAttribute]
	newEmail = profile[config.all.server.security.saml.emailAttribute]
	ssoGroups = profile[config.all.server.security.saml.groupAttribute]

	# Check if author exists
	[err, savedAuthor] = await serverUtilityFunctions.promisifyRequestResponseStatus(authorRoutes.getAuthorByUsernameInternal, [userName])
	if err?
		console.error("Got error checking for existing author #{err} during sso login strategy")
		return callback null, false, message: "Got error checking for existing author during sso login strategy"

	# If the author doesn't exist then create one
	# Check login ability here FIRST
	if savedAuthor? && savedAuthor.length != 0
		console.log "Found existing Author '#{savedAuthor.userName}'"
		updateAuthor = false

		if newEmail != savedAuthor.emailAddress
			console.log "SSO email address '#{newEmail}' has changed from existing author email address '#{savedAuthor.emailAddress}'"
			[err, unique] = await serverUtilityFunctions.promiseifyCatch(authorRoutes.checkEmailIsUnique, [newEmail])
			if err
				console.error(err)
				return callback null, false, message: "Got error checking for unique email addrress"

			if !unique == true
				console.error("New email address is not unique to the sytem so it belongs to another username")
				return callback null, false, message: "Email address already belongs to another user"

		if newEmail != savedAuthor.emailAddress || newFirstName != savedAuthor.firstName || newLastName != savedAuthor.lastName
			updateAuthor = true
		if updateAuthor == true
			savedAuthor.firstName = newFirstName
			savedAuthor.lastName = newLastName
			savedAuthor.emailAddress = newEmail
			[err, updatedAuthor] = await serverUtilityFunctions.promisifyRequestResponseStatus(authorRoutes.updateAuthorInternal, [savedAuthor])
			if err
				err = "Got error trying to update author using SSO user profile"
				console.log("#{err} Author: #{JSON.stringify(savedAuthor)}")
				return callback null, false, message: err
			else
				console.log "Successfully synced user profile"
				savedAuthor = updatedAuthor
	else
		author = 
			firstName: newFirstName
			lastName: newLastName
			emailAddress: newEmail
			userName: userName
			version: 0
			enabled: true
			locked: false
			password: null
			recordedBy: 'acas'
			recordedDate: new Date().getTime()
			lsType: 'default'
			lsKind: 'default'
		[err, savedAuthor] = await serverUtilityFunctions.promiseifyCatch(authorRoutes.createNewAuthorInternal, [author])
		if err?
			console.error("Got error saving new author during sso login strategy Error #{JSON.stringify(err)}")
			return callback null, false, message: "Caught error trying to save author"
		if !savedAuthor?
			console.error("Got error saving new author #{err} during sso login strategy Author json: #{JSON.stringify(author)}")
			return callback null, false, message: "Got error trying to save author"

	if config.all.server.security.saml.roles.sync
		console.log "Checking for roles to sync"

		# Format sso groups into ACAS system roles [{roleName: , lsType: 'System', lsKind: 'ACAS'/'CmpdReg'}]
		ssoSystemRoles = formatSystemRolesFromSSOGroups(ssoGroups)
		console.log("Found #{ssoSystemRoles.length} 'ACAS'/'CMPDREG' roles in sso profile for author #{savedAuthor.userName}, #{JSON.stringify(ssoSystemRoles)}")

		# Automatically sync all SSO roles to ACAS roles
		[err, saveResult] = await serverUtilityFunctions.promisifyRequestResponseStatus(setupRoutes.setupTypeOrKindInternal, ["lsroles", ssoSystemRoles])
		if err?
			console.error("Got error trying to sync roles during sso login strategy Error #{JSON.stringify(err)}")
			
		# From the saved author, filter their roles to just the ones that are of type "System"
		savedAuthorSystemRoles = authorRoutes.getRolesByLsType(savedAuthor.authorRoles, "System")
		console.log("Found #{savedAuthorSystemRoles.length} saved system roles for author #{savedAuthor.userName}, #{JSON.stringify(savedAuthorSystemRoles)}")

		# Determine which roles are missing from the saved author by diffing the sso system roles with the saved author system roles
		diffSystemRolesWithSaved = util.promisify(authorRoutes.diffSystemRolesWithSaved)
		[err, diffResult] = await serverUtilityFunctions.promiseCatch(diffSystemRolesWithSaved(savedAuthor.userName, ssoSystemRoles, savedAuthorSystemRoles, ["lsType", "lsKind", "roleName"]))
		console.log("Diff result between authors saved and SSO profile roles: #{JSON.stringify(diffResult)}")

		if err?
			console.error("Got error trying to diff current roles with new sso roles #{err}")
			return callback null, false, message: err

		rolesToSync = false
		if diffResult.rolesToAdd.length > 0
			rolesToSync = true
			console.log "Found #{diffResult.rolesToAdd.length} roles to add #{JSON.stringify(diffResult.rolesToAdd)}"
		if diffResult.rolesToDelete.length > 0
			rolesToSync = true
			console.log "Found #{diffResult.rolesToDelete.length} roles to delete #{JSON.stringify(diffResult.rolesToDelete)}"

		# Update author roles
		if rolesToSync == true
			console.log "Syncing roles"
			syncRoles = util.promisify(authorRoutes.syncRoles)
			[err, updatedAuthor] = await serverUtilityFunctions.promiseCatch(syncRoles(savedAuthor, diffResult.rolesToAdd, diffResult.rolesToDelete))
			if err?
				console.error("Got error trying to sync roles for user #{err}")
				return callback null, false, message: err
		else
			console.log "No roles to sync"

	# Get user doesn't format the user exactly like the updatedAuthor so we need to fetch the author one more time
	# Easiest to just fetch the author fresh rather than transform
	exports.checkRoles savedAuthor.userName, (results) =>
		exports.handleAuthCheckResponse(req, savedAuthor.userName, results, callback)

exports.localLoginStrategy = (req, username, password, done) ->
	exports.logUsage "login attempt", JSON.stringify(ip: req.ip, referer: req.headers['referer'], agent: req.headers['user-agent']), username
	exports.authCheck username, password, (results) =>
		exports.handleAuthCheckResponse(req, username, results, done)

exports.handleAuthCheckResponse = (req, username, results, done) ->
	if results.indexOf("login_error")>=0
		try
			exports.logUsage "User failed login: ", JSON.stringify(ip: req.ip, referer: req.headers['referer'], agent: req.headers['user-agent']), username
		catch error
			console.log "Exception trying to log:"+error
		return done(null, false,
			message: "Invalid credentials"
		)
	else if results.indexOf("role_check_error")>=0
		try
			exports.logUsage "User failed login: ", JSON.stringify(ip: req.ip, referer: req.headers['referer'], agent: req.headers['user-agent']), username
		catch error
			console.log "Exception trying to log:"+error
		return done(null, false,
			message: "Unauthorized user"
		)
	else if results.indexOf("connection_error")>=0
		try
			exports.logUsage "Connection to authentication service failed: ", JSON.stringify(ip: req.ip, referer: req.headers['referer'], agent: req.headers['user-agent']), username
		catch error
			console.log "Exception trying to log:"+error
		return done(null, false,
			message: "Cannot connect to authentication service. Please contact an administrator"
		)
	else
		try
			exports.logUsage "User logged in succesfully: ", JSON.stringify(ip: req.ip, referer: req.headers['referer'], agent: req.headers['user-agent']), username
		catch error
			console.log "Exception trying to log:"+error
		exports.getUser username,done

exports.getProjects = (req, resp) ->
	exports.getProjectsInternal req, (statusCode, response) =>
		resp.statusCode = statusCode
		resp.json response

exports.getProjectsInternal = (req, callback) ->
	config = require '../../../conf/compiled/conf.js'
	url = config.all.client.service.persistence.fullpath+"authorization/projects?find=ByUserName&userName="+req.user.username+"&format=codeTable"
	request = require 'request'
	request(
		method: 'GET'
		url: url
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback response.statusCode, json
		else
			console.log 'got ajax error trying get acas project codes'
			console.log error
			console.log json
			console.log response
			callback response.statusCode, json
	)

exports.getProjectStubs = (req, resp) ->
	exports.getProjectStubsInternal (statusCode, response) =>
		resp.statusCode = statusCode
		resp.json response

exports.getProjectStubsInternal = (callback) ->
	config = require '../../../conf/compiled/conf.js'
	request = require 'request'
	request.get
		url: config.all.client.service.persistence.fullpath+"authorization/groupsAndProjects"
		json: true
	, (error, response, body) =>

		serverError = error
		acasGroupsAndProjects = body
		#remove groups attribute
		_.each acasGroupsAndProjects.projects, (project) ->
			delete project.groups
		callback response.statusCode, acasGroupsAndProjects.projects

exports.makeServiceRequestHeaders = (user) ->
	username = if user? then user.username else "testmode"

	headers =
		"From": username

exports.getCustomerMolecularTargetCodes = (resp) ->
	molecTargetTestJSON = require "#{ACAS_HOME}/public/javascripts/spec/PrimaryScreen/testFixtures/PrimaryScreenProtocolServiceTestJSON.js"
	resp.end JSON.stringify molecTargetTestJSON.customerMolecularTargetCodeTable

exports.validateCloneAndGetTarget = (req, resp) ->
	psProtocolServiceTestJSON = require "#{ACAS_HOME}/public/javascripts/spec/PrimaryScreen/testFixtures/PrimaryScreenProtocolServiceTestJSON.js"
	resp.json psProtocolServiceTestJSON.successfulCloneValidation

exports.getAllAuthors = (opts, callback) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	serverUtilityFunctions = require "#{ACAS_HOME}/routes/ServerUtilityFunctions.js"
	baseurl = config.all.client.service.persistence.fullpath+"authors/codeTable"
	if opts.roleName?
		if opts.roleType? and opts.roleKind?
			baseurl = config.all.client.service.persistence.fullpath+"authors/findByRoleTypeKindAndName"
			baseurl += "?roleType=#{opts.roleType}&roleKind=#{opts.roleKind}&roleName=#{opts.roleName}&format=codeTable"
		else
			baseurl = config.all.client.service.persistence.fullpath+"authors/findByRoleName"
			baseurl += "?authorRoleName=#{opts.roleName}&format=codeTable"
	console.log "Calling baseurl in get all authors: #{baseurl}"
	serverUtilityFunctions.getFromACASServerInternal baseurl, (statusCode, json) ->
		# If additional codeType and codeKind parameters are supplied then append the code values for the additional authors
		# This is was added for the purpose of allowing additional non-authors to show up in picklists throughout ACAS and Creg
		if opts.additionalCodeType? and opts.additionalCodeKind?
			codeTableServiceRoutes = require "#{ACAS_HOME}/routes/CodeTableServiceRoutes.js"
			codeTableServiceRoutes.getCodeTableValuesInternal opts.additionalCodeType, opts.additionalCodeKind, (codes) ->
				Array::push.apply json, codes
				callback statusCode, json
		else
			callback statusCode, json

exports.getAllAuthorObjectsInternal = (callback) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	serverUtilityFunctions = require "#{ACAS_HOME}/routes/ServerUtilityFunctions.js"
	baseurl = config.all.client.service.persistence.fullpath+"authors"
	serverUtilityFunctions.getFromACASServerInternal baseurl, (statusCode, json) ->
		callback statusCode, json

exports.relocateEntityFile = (fileValue, entityCodePrefix, entityCode, callback) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	uploadsPath = serverUtilityFunctions.makeAbsolutePath config.all.server.datafiles.relative_path
	oldPath = uploadsPath + fileValue.fileValue
	relEntitiesFolder = serverUtilityFunctions.getRelativeFolderPathForPrefix(entityCodePrefix)
	if relEntitiesFolder==null
		callback false
		return
	relEntityFolder = relEntitiesFolder + entityCode + "/"
	absEntitiesFolder = uploadsPath + relEntitiesFolder
	absEntityFolder = uploadsPath + relEntityFolder
	if fileValue.comments != undefined and fileValue.comments != null
		newPath = absEntityFolder + fileValue.comments
	else
		newPath = absEntityFolder + fileValue.fileValue

	entitiesFolder = uploadsPath + "entities/"
	serverUtilityFunctions.ensureExists entitiesFolder, 0o0744, (err) ->
		if err?
			console.log "Can't find or create entities folder: " + entitiesFolder
			callback false
		else
			serverUtilityFunctions.ensureExists absEntitiesFolder, 0o0744, (err) ->
				if err?
					console.log "Can't find or create : " + absEntitiesFolder
					callback false
				else
					serverUtilityFunctions.ensureExists absEntityFolder, 0o0744, (err) ->
						if err?
							console.log "Can't find or create : " + absEntityFolder
							callback false
						else if fileValue.comments != undefined and fileValue.comments != null
							console.log "fileValue has comments"
							console.log oldPath
							console.log newPath
							stream = fs.createReadStream(oldPath).pipe fs.createWriteStream(newPath)
							stream.on 'error', (err) ->
								console.log "error copying file to new location"
								callback false
							stream.on 'close', ->
								fileValue.fileValue = relEntityFolder + fileValue.comments
								callback true
						else
							fs.rename oldPath, newPath, (err) ->
								if err?
									console.log err
									callback false
								else
									fileValue.comments = fileValue.fileValue
									fileValue.fileValue = relEntityFolder + fileValue.fileValue
									callback true

exports.getDownloadUrl = (fileValue) ->
	config = require "#{ACAS_HOME}/conf/compiled/conf.js"
	return config.all.client.datafiles.downloadurl.prefix+fileValue

exports.getTestedEntityProperties = (propertyList, entityList, callback) ->
# This is a stub implementation that returns empty results

	if propertyList.indexOf('ERROR') > -1
		callback null
		return

	ents = entityList.split '\n'
	out = "id,"
	for prop in propertyList
		out += prop+","
	out = out.slice(0,-1) + '\n'
	for i in [0..ents.length-2]
		out += ents[i]+","
		j=0
		for prop2 in propertyList
			if ents[i].indexOf('ERROR') < 0 then out += i + j++
			else out += ""
			out += ','
		out = out.slice(0,-1) + '\n'

	callback out



exports.getExternalReferenceCodes = (displayName, requests, callback) ->
	if displayName == "Corporate Batch ID"
		console.log "looking up compound batches"
		exports.getPreferredBatchIds requests, (response) ->
			callback response
	else if displayName == "Corporate Parent ID"
		console.log "looking up compound parents"
		exports.getPreferredParentIds requests, (response) ->
			callback response
	else
		message = "problem with external preferred Code request: code type and kind are unknown to system"
		callback message
		console.error message

exports.getExternalBestLabel = (displayName, requests, callback) ->
	if displayName == "Corporate Batch ID"
		console.log "looking up compound batches"
		exports.getBatchBestLabels requests, (response) ->
			callback response
	else if displayName == "Corporate Parent ID"
		console.log "looking up compound parents"
		exports.getParentBestLabels requests, (response) ->
			console.log(JSON.stringify(response))
			callback response
	else
		message =  "problem with external best label request: displayName is unknown to system"
		callback message
		console.error message

exports.getPreferredBatchIds = (requests, callback) ->
	if global.specRunnerTestmode
		results = []
		for req in requests
			res = requestName: req.requestName
			if req.requestName.indexOf("999999999") > -1
				res.preferredName = ""
			else if req.requestName.indexOf("673874") > -1
				res.preferredName = "CMP000001234::7"
			else
				res.preferredName = checkBatch_TestMode(req.requestName)
			results.push res
		response = results

		callback response
	else #not spec mode
		config = require "#{ACAS_HOME}/conf/compiled/conf.js"
		request = require 'request'
		request
			method: 'POST'
			url: config.all.server.service.external.preferred.batchid.url
			json: true
			body: requests
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log error
				console.log response
				console.log json
				callback null

exports.getPreferredParentIds = (requests, callback) ->
	if global.specRunnerTestmode
		results = []
		for req in requests
			res = requestName: req.requestName
			if req.requestName.indexOf("999999999") > -1
				res.preferredName = ""
			else if req.requestName.indexOf("673874") > -1
				res.preferredName = "CMP000001234"
			else if req.requestName.indexOf("compoundName") > -1
				res.preferredName = "CMPD000001234"
			else
				res.preferredName = req.requestName
			results.push res
		response = results

		callback response
	else
		config = require "#{ACAS_HOME}/conf/compiled/conf.js"
		request = require 'request'
		request
			method: 'POST'
			url: config.all.server.service.external.preferred.batchid.url+"/parent"
			json: true
			body: requests
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log error
				console.log response
				console.log json
				callback null


exports.getBatchBestLabels = (requests, callback) ->
	if global.specRunnerTestmode
		results = []
		for req in requests
			res = requestName: req.requestName
			if req.requestName.indexOf("1111") > -1
				res.preferredName = "1111"
			else if req.requestName.indexOf("1234") > -1
				res.preferredName = "1234::7"
			else
				res.preferredName = req.requestName
			results.push res
		response = results

		callback response
	else #not spec mode
		config = require "#{ACAS_HOME}/conf/compiled/conf.js"
		request = require 'request'
		request
			method: 'POST'
			url: config.all.server.service.external.preferred.batchid.url
			json: true
			body: requests
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log error
				console.log response
				console.log json
				callback null

exports.getParentBestLabels = (requests, callback) ->
	if global.specRunnerTestmode
		results = []
		for req in requests
			res = requestName: req.requestName
			if req.requestName.indexOf("1111") > -1
				res.preferredName = "1111"
			else if req.requestName.indexOf("1234") > -1
				res.preferredName = "1234"
			else if req.requestName.indexOf("CMPD000001234") > -1
				res.preferredName = "1234"
			else
				res.preferredName = req.requestName
			results.push res
		response = results

		callback response
	else
		config = require "#{ACAS_HOME}/conf/compiled/conf.js"
		request = require 'request'
		request
			method: 'POST'
			url: config.all.server.service.external.preferred.batchid.url+"/parent"
			json: true
			body: requests
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log error
				console.log response
				console.log json
				callback null

checkBatch_TestMode = (requestName) ->
	idComps = requestName.split("_")
	pref = idComps[0];
	respId = "";
	switch pref
		when "norm" then respId = batchName.requestName
		when "none" then respId = ""
		when  "alias" then respId = "norm_"+idComps[1]+"A"
		else respId = requestName
	return respId

exports.checkRoles = (user, retFun) ->
	exports.getUser user, (expectnull, author)->
		config = require "#{ACAS_HOME}/conf/compiled/conf.js"
		if author?.roles? and config.all.client.roles?.loginRole?
			roles = _.map author.roles, (role) ->
				role.roleEntry.roleName
			loginRoles = config.all.client.roles.loginRole.split ","
			console.log _.intersection loginRoles, roles
			if _.intersection(loginRoles, roles).length > 0
				console.log 'Role check successful'
				retFun 'success'
			else
				console.log 'Role check failed'
				retFun 'role_check_error'
		else if config.all.client.roles?.loginRole?
			retFun 'login_error'
		else
			retFun 'success'

exports.getExternalProjectCodes = (displayName, requests, callback) ->
	if displayName == "Corporate Batch ID"
		console.log "looking up compound batches"
		exports.getBatchProjects requests, (response) ->
			console.log "getExternalProjectCodes response"
			console.log response
			callback response
	else
		callback "failed: problem with external preferred Code request: code type and kind are unknown to system"

exports.getBatchProjects = (requests, callback) ->
	if global.specRunnerTestmode
		results = []
		for req in requests
			res = requestName: req.requestName
			if req.requestName.indexOf("999999999") > -1
				res.projectCode = ""
			else if req.requestName.indexOf("673874") > -1
				res.projectCode = "CMP000001234::7"
			else
				res.projectCode = checkBatch_TestMode(req.requestName)
			results.push res
		response = results

		callback response
	else #not spec mode
		config = require "#{ACAS_HOME}/conf/compiled/conf.js"
		request = require 'request'
		request
			method: 'POST'
			url: config.all.client.service.cmpdReg.persistence.fullpath+"projects/getBatchProjects"
			json: true
			body: requests
		, (error, response, json) =>
			if !error && response.statusCode == 200
				callback json
			else
				console.log error
				console.log response
				console.log json
				callback null

exports.createPlate = (request, callback) ->
	answer = null
	callback answer, 200
	console.debug "inside base customer specific server function createPlate"

exports.createTube = (request, callback) ->
	answer = null
	callback answer, 200
	console.debug "inside base customer specific server function createTube"

exports.createTubes = (request, callback) ->
	answer = null
	callback answer, 200
	console.debug "inside base customer specific server function createTubes"

exports.updateWellContent = (request) ->
	console.debug "inside base customer specific server function updateWellContent"

exports.updateContainersByContainerCodes = (request) ->
	console.debug "inside base customer specific server function updateContainersByContainerCodes"

exports.addContainerLogs = (request) ->
	console.debug "inside base customer specific server function addContainerLogs"

exports.moveToLocation = (request) ->
	console.debug "inside base customer specific server function moveToLocation"

exports.throwInTrash = (request, callback) ->
	callback {"successful":true}, 200
	console.debug "inside base customer specific server function throwInTrash"

exports.updateSolrIndex = (callback) ->
	answer = null
	callback answer, 200
	console.debug "inside base customer specific server function updateSolrIndex"