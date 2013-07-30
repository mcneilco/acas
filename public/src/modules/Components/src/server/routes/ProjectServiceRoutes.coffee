### To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
#Components routes
projectServiceRoutes = require './routes/ProjectServiceRoutes.js'
app.get '/api/projects', projectServiceRoutes.getProjects
###


exports.getProjects = (req, resp) ->
	config = require '../public/src/conf/configurationNode.js'
	if global.specRunnerTestmode
		projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
		resp.end JSON.stringify projectServiceTestJSON.projects
	else
		console.log "calling live projects service"
		if config.serverConfigurationParams.configuration.projectsType == "ACAS"
			#TODO Replace with service to look in ACAS database for registered projects
			projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
			resp.end JSON.stringify projectServiceTestJSON.projects
		else
			projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
			resp.end JSON.stringify projectServiceTestJSON.projects

