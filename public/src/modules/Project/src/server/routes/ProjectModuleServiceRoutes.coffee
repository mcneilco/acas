exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/genericSearch/projects/:searchTerm', exports.genericProjectSearch
	app.get '/api/projects/getByRoleTypeKindAndName/:roleType/:roleKind/:roleName', exports.getProjectByRoleTypeKindAndName
	app.post '/api/projects/createRoleKindAndName', exports.createProjectRoleKindAndName
	app.post '/api/projects/updateProjectRoles', exports.updateProjectRoles

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/genericSearch/projects/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericProjectSearch
	app.get '/api/projects/getByRoleTypeKindAndName/:roleType/:roleKind/:roleName', loginRoutes.ensureAuthenticated, exports.getProjectByRoleTypeKindAndName
	app.post '/api/projects/createRoleKindAndName', loginRoutes.ensureAuthenticated, exports.createProjectRoleKindAndName
	app.post '/api/projects/updateProjectRoles', loginRoutes.ensureAuthenticated, exports.updateProjectRoles


exports.genericProjectSearch = (req, resp) ->
	console.log "generic project search"
	console.log req.query.testMode
	console.log global.specRunnerTestmode
	if req.query.testMode is true or global.specRunnerTestmode is true
		projectTestJSON = require '../public/javascripts/spec/testFixtures/ProjectTestJSON.js'
		resp.end JSON.stringify[projectTestJSON.project]
	else
		config = require '../conf/compiled/conf.js'
		console.log "search req"
		userNameParam = "userName=" + req.user.username
		searchTerm = "q=" + req.params.searchTerm

		searchParams = ""
		searchParams += userNameParam + "&"
		searchParams += searchTerm

		baseurl = config.all.client.service.persistence.fullpath+"lsthings/searchProjects?"+searchParams
		console.log "generic project search baseurl"
		console.log baseurl
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.getProjectByRoleTypeKindAndName = (req, resp) ->
	if req.query.testMode is true or global.specRunnerTestmode is true
		projectTestJSON = require '../public/javascripts/spec/testFixtures/ProjectTestJSON.js'
		resp.end JSON.stringify[projectTestJSON.projectUsers]
	else
		config = require '../conf/compiled/conf.js'
		roleType = req.params.roleType
		roleKind = req.params.roleKind
		roleName = req.params.roleName
		baseurl = config.all.client.service.persistence.fullpath+"authors/findByRoleTypeKindAndName?roleType=#{roleType}&roleKind=#{roleKind}&roleName=#{roleName}"
		if req.query.format? and req.query.format.toLowerCase() =="codetable"
			baseurl += "&format=codetable"
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)

exports.createProjectRoleKindAndName = (req, resp) ->
	getOrCreateProjectRoleKindAndName req.body.rolekind, req.body.lsroles, req.query.testMode, (err, response) ->
		if err?
			resp.statusCode = 500
			resp.end err
		else
			resp.json response

getOrCreateProjectRoleKindAndName = (rolekind, lsroles, testMode, callback) ->
	if testMode is true or global.specRunnerTestmode is true
		projectTestJSON = require '../public/javascripts/spec/testFixtures/ProjectTestJSON.js'
		callback null, JSON.stringify[projectTestJSON.projectUsers]
	else
		saveRolekinds rolekind, (err1) ->
			if err1?
				callback err1
			saveLsroles lsroles, (err2, response) ->
				if err2?
					callback err2
				else
					callback null, response

saveRolekinds = (rolekind, callback) ->
	config = require '../conf/compiled/conf.js'
	rolekindUrl = config.all.client.service.persistence.fullpath+"setup/rolekinds"
	console.log "rolekind"
	console.log rolekind
	request = require 'request'
	request(
		method: 'POST'
		url: rolekindUrl
		body: JSON.stringify rolekind
		json: true
		headers:
			"Content-Type": 'application/json'
	, (error, response, json) =>
		if !error && response.statusCode == 201
			console.log "successfully added project role kind"
			callback null
		else
			console.log "error saving project role kind"
			console.log response.statusCode
			console.log response.json
			callback "saveFailed for project rolekind"
	)

saveLsroles = (lsroles, callback) ->
	config = require '../conf/compiled/conf.js'
	lsrolesUrl = config.all.client.service.persistence.fullpath+"setup/lsroles"
	console.log "lsroles"
	console.log lsroles
	request = require 'request'
	request(
		method: 'POST'
		url: lsrolesUrl
		body: JSON.stringify lsroles
		json: true
		headers:
			"Content-Type": 'application/json'
	, (error2, response2, json2) =>
		if !error2 && response2.statusCode == 201
			console.log "successfully added lsroles"
			callback null, json2
		else
			console.log "error saving project role names"
			console.log error2
			console.log response2
			console.log response2.statusCode
			callback "saveFailed for project lsrole"
	)


exports.updateProjectRoles = (req, resp) ->
	if req.query.testMode is true or global.specRunnerTestmode is true
		projectTestJSON = require '../public/javascripts/spec/testFixtures/ProjectTestJSON.js'
		resp.end JSON.stringify[projectTestJSON.project]
	else
		config = require '../conf/compiled/conf.js'
		request = require 'request'
		_ = require '../public/src/lib/underscore.js'

		#delete author roles
		console.log "req.body.authorRolesToDelete"
		console.log req.body.authorRolesToDelete
		deleteAuthorRoles req.body.authorRolesToDelete, (err) =>
			if err?
				resp.statusCode = 500
				resp.end err
			else
				#save new author roles
				console.log "req.body.newAuthorRoles"
				console.log req.body.newAuthorRoles
				postAuthorRoles req.body.newAuthorRoles, (err2) =>
					if err2?
						resp.statusCode = 500
						resp.end err2
					else
						console.log "post author roles success"
						resp.end JSON.stringify 'saved author roles successfully'

deleteAuthorRoles = (authorRoles, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"authorroles/deleteRoles"
	console.log baseurl
	request = require 'request'

	request(
		method: 'POST'
		url: baseurl
		body: authorRoles
		json: true
	, (error, response, json) =>
		console.log response.statusCode
		if !error && response.statusCode == 200
			console.log "successfully deleted author roles"
			#returns empty json
			callback null
		else
			console.log 'got ajax error trying to delete author roles'
			console.log error
			callback "saveFailed for deleting author roles" + error
	)

postAuthorRoles = (authorRoles, callback) ->
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"authorroles/saveRoles"
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: authorRoles
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 201
			#json is empty
			callback null
		else
			callback "saveFailed posting new author roles"
	)