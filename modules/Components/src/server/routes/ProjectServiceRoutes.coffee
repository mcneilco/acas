exports.setupAPIRoutes = (app) ->
	app.get '/api/projects/:username', exports.getProjects
	app.get '/api/projects/getAllProjects/stubs', exports.getProjectStubs


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/projects', loginRoutes.ensureAuthenticated, exports.getProjects
	app.get '/api/projects/getAllProjects/stubs', loginRoutes.ensureAuthenticated, exports.getProjectStubs

exports.getProjects = (req, resp) ->
	authorRoutes = require './AuthorRoutes.js'
	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	callback = (err, user) =>
		authorRoutes.allowedProjectsInternal user, (statusCode, allowedUserProjects) ->
			resp.status "200"
			resp.end JSON.stringify allowedUserProjects
	if req.params.username?
		user = csUtilities.getUser req.params.username, callback
	else
		user = req.user
		callback null, user


exports.getProjectStubs = (req, resp) ->
	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	if !req.user?
		req.user = {}
		req.user.username = req.query.username
	if global.specRunnerTestmode
		projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
		resp.end JSON.stringify projectServiceTestJSON.projectStubs
	else
		csUtilities.getProjectStubs req, resp
