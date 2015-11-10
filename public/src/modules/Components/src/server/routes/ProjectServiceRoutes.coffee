exports.setupAPIRoutes = (app) ->
  app.get '/api/projects/:username', exports.getProjects

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/projects', loginRoutes.ensureAuthenticated, exports.getProjects

exports.getProjects = (req, resp) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if !req.user?
		req.user = {}
		req.user.username = req.params.username
	if global.specRunnerTestmode
		projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
		resp.end JSON.stringify projectServiceTestJSON.projects
	else
		csUtilities.getProjects req, resp


