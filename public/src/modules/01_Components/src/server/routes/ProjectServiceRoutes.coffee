### To install this Module
1) Add these lines to app.coffee
	#Components routes
	projectServiceRoutes = require './public/src/modules/01_Components/src/server/routes/ProjectServiceRoutes.js'
	projectServiceRoutes.setupRoutes(app)
###

exports.setupRoutes = (app) ->
	app.get '/api/projects', exports.getProjects

exports.getProjects = (req, resp) ->
	csUtilities = require '../../../../../conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		projectServiceTestJSON = require '../../../spec/testFixtures/projectServiceTestJSON.js'
		resp.end JSON.stringify projectServiceTestJSON.projects
	else
		csUtilities.getProjects resp


