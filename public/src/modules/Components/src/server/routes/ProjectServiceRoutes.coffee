### To install this Module
1) Add these lines to app.coffee
	#Components routes
	projectServiceRoutes = require './public/src/modules/01_Components/src/server/routes/ProjectServiceRoutes.js'
	projectServiceRoutes.setupRoutes(app)
###

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/projects', loginRoutes.ensureAuthenticated, exports.getProjects

exports.getProjects = (req, resp) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
		resp.end JSON.stringify projectServiceTestJSON.projects
	else
		csUtilities.getProjects resp


