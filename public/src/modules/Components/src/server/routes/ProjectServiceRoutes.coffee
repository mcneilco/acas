### To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
#Components routes
projectServiceRoutes = require './routes/ProjectServiceRoutes.js'
app.get '/api/projects', projectServiceRoutes.getProjects
###


exports.getProjects = (req, resp) ->
	if global.specRunnerTestmode
		projectServiceTestJSON = require '../public/javascripts/spec/testFixtures/projectServiceTestJSON.js'
		resp.end JSON.stringify projectServiceTestJSON.projects
	else
		console.log "calling live projects service"
		dnsGetProjects resp

dnsGetProjects = (resp) ->
	config = require '../public/src/conf/configurationNode.js'
	request = require 'request'
	request(
		method: 'GET'
		url: config.serverConfigurationParams.configuration.projectsServiceURL
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log JSON.stringify json
			console.log JSON.stringify dnsFormatProjectResponse json
			resp.json dnsFormatProjectResponse json
		else
			console.log 'got ajax error trying get project list'
			console.log error
			console.log json
			console.log response
	)

dnsFormatProjectResponse =  (json) ->
	_ = require 'underscore'
	projects = []
	_.each json, (proj) ->
		p = proj.DNSCode
		projects.push
			code: p.code
			name: p.name
			ignored: !p.active

	projects