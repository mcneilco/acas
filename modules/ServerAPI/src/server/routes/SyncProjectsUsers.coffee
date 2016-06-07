exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/syncLiveDesignProjectsUsers', loginRoutes.ensureAuthenticated, exports.syncLiveDesignProjectsUsers


exports.syncLiveDesignProjectsUsers = (req, resp) ->
	exports.getGroupsJSON (groupsJSON, acasGroupsAndProjects) ->
		exports.getProjectsJSON (projectsJSON) ->
			exports.getConfigJSON (configJSON) ->
				caughtPythonErrors = false
				pythonErrors = []
				exports.syncLiveDesignProjects caughtPythonErrors, pythonErrors, configJSON, projectsJSON, (caughtPythonErrors, pythonErrors) ->
					console.debug caughtPythonErrors
					console.debug pythonErrors
					exports.syncCmpdRegProjects req, acasGroupsAndProjects, (syncCmpdRegProjectsCallback) ->
						exports.syncLiveDesignRoles caughtPythonErrors, pythonErrors, configJSON, groupsJSON, (caughtPythonErrors, pythonErrors) ->
							if !caughtPythonErrors
								resp.statusCode = 200
								console.log "Successfully synced projects and permissions with LiveDesign and Compound Reg"
								resp.end "Successfully synced projects and permissions with LiveDesign and Compound Reg"
							else
								resp.statusCode = 500
								console.log "An error has occurred trying to sync projects and permissions with LiveDesign and Compound Reg. Please contact an administrator."
								resp.end "An error has occurred trying to sync projects and permissions with LiveDesign and Compound Reg. Please contact an administrator."

exports.getGroupsJSON = (callback) ->
	request = require 'request'
	_ = require "underscore"
	config = require '../conf/compiled/conf.js'
	request.get
		url: config.all.client.service.persistence.fullpath+"authorization/groupsAndProjects"
		json: true
	, (error, response, body) =>
		serverError = error
		acasGroupsAndProjects = body
		#Re-map results from Roo authorization/groupsAndProjects route to new data structures - groupsJSON and projectsJSON
		groupsJSON = {}
		groupsJSON.groups = {}
		groupsJSON.projects = []
		_.each acasGroupsAndProjects.groups, (group) ->
			groupsJSON.groups[ group.name ] = group.members
		_.each acasGroupsAndProjects.projects, (project) ->
			projectGroups =
				alias: project.code
				groups: project.groups
			groupsJSON.projects.push projectGroups
		callback groupsJSON, acasGroupsAndProjects


exports.getProjectsJSON = (callback) ->
	request = require 'request'
	_ = require "underscore"
	config = require '../conf/compiled/conf.js'
	request.get
		url: config.all.client.service.persistence.fullpath+"authorization/groupsAndProjects"
		json: true
	, (error, response, body) =>
		serverError = error
		acasGroupsAndProjects = body
		#Re-map results from Roo authorization/groupsAndProjects route to new data structures - groupsJSON and projectsJSON
		projectsJSON = {}
		projectsJSON.projects = []
		_.each acasGroupsAndProjects.projects, (project) ->
			projectEntry =
				id: project.id
				name: project.name
				code: project.code
				active: if project.active? then ['N','Y'][+project.active] else 'Y'
				is_restricted: if project.isRestricted? then +project.isRestricted else 0
				project_desc: project.name
			projectsJSON.projects.push projectEntry
		callback projectsJSON

exports.getConfigJSON = (callback) ->
	config = require '../conf/compiled/conf.js'
	#Build configJSON object of LiveDesign connection info to pass to python scripts
	configJSON =
		ld_server:
			ld_url: config.all.client.service.result.viewer.liveDesign.baseUrl
			ld_username: config.all.client.service.result.viewer.liveDesign.username
			ld_password: config.all.client.service.result.viewer.liveDesign.password
		livedesign_db:
			dbname: config.all.client.service.result.viewer.liveDesign.database.name
			user: config.all.client.service.result.viewer.liveDesign.database.username
			password: config.all.client.service.result.viewer.liveDesign.database.password
			host: config.all.client.service.result.viewer.liveDesign.database.hostname
			port: config.all.client.service.result.viewer.liveDesign.database.port
	callback configJSON

exports.syncLiveDesignProjects = (caughtPythonErrors, pythonErrors, configJSON, projectsJSON, callback) ->
	exec = require('child_process').exec
	config = require '../conf/compiled/conf.js'
	#Call sync_projects.py to update list of projects in LiveDesign
	command = "python ./public/src/modules/ServerAPI/src/server/syncProjectsUsers/sync_projects.py "
	command += "\'"+(JSON.stringify configJSON)+"\' "+"\'"+(JSON.stringify projectsJSON)+"\'"
	#		data = {"compounds":["V035000","CMPD-0000002"],"assays":[{"protocolName":"Target Y binding","resultType":"curve id"}]}
	#		command += (JSON.stringify data)+"'"
	console.log "About to call python using command: "+command
	child = exec command,  (error, stdout, stderr) ->
		reportURLPos = stdout.indexOf config.all.client.service.result.viewer.liveDesign.baseUrl
		reportURL = stdout.substr reportURLPos
		#console.warn "stderr: " + stderr
		console.log "stdout: " + stdout
		if error?
			caughtPythonErrors = true
			console.error error
			pythonErrors.push error
		callback caughtPythonErrors, pythonErrors

exports.syncCmpdRegProjects = (req, acasGroupsAndProjects, callback) ->
	cmpdRegRoutes = require '../routes/CmpdRegRoutes.js'
	_ = require "underscore"
	#Get or create projects in CmpdReg
	projectCodes = _.pluck acasGroupsAndProjects.projects, 'code'
	console.debug 'project codes are:' + JSON.stringify projectCodes
	cmpdRegRoutes.getProjects req, (projectResponse) ->
		foundProjects = JSON.parse projectResponse
		foundProjectCodes = _.pluck foundProjects, 'code'
		console.debug 'found projects are: '+foundProjectCodes
		newProjectCodes = _.difference projectCodes, foundProjectCodes
		newProjects = _.filter acasGroupsAndProjects.projects, (project) ->
			return project.code in newProjectCodes
		projectsToUpdate = _.filter acasGroupsAndProjects.projects, (project) ->
			found = (_.findWhere foundProjects, {code: project.code})?
			unchanged = (_.findWhere foundProjects, {code: project.code, name: project.name})?
			return (found and !unchanged)
		if (newProjects? and newProjects.length > 0) or (projectsToUpdate? and projectsToUpdate.length > 0)
			if (newProjects? and newProjects.length > 0)
				console.debug 'saving new projects with JSON: '+ JSON.stringify newProjects
				cmpdRegRoutes.saveProjects newProjects, (saveProjectsResponse) ->
			else
				for projectToUpdate in projectsToUpdate
					oldProject = _.findWhere foundProjects, {code: projectToUpdate.code}
					projectToUpdate.id = oldProject.id
					projectToUpdate.version = oldProject.version
				console.debug 'updating projects with JSON: '+ JSON.stringify projectsToUpdate
				cmpdRegRoutes.updateProjects projectsToUpdate, (updateProjectsResponse) ->
		else
			console.debug 'CmpdReg projects are up-to-date'
		callback 'CmpdReg projects are up-to-date'

exports.syncLiveDesignRoles = (caughtPythonErrors, pythonErrors, configJSON, groupsJSON, callback) ->
	exec = require('child_process').exec
	config = require '../conf/compiled/conf.js'
	#Call ld_entitlements.py to update list of user-project ACLs in LiveDesign
	command = "python ./public/src/modules/ServerAPI/src/server/syncProjectsUsers/ld_entitlements.py "
	command += "\'"+(JSON.stringify configJSON.ld_server)+"\' "+"\'"+(JSON.stringify groupsJSON)+"\'"
	#		data = {"compounds":["V035000","CMPD-0000002"],"assays":[{"protocolName":"Target Y binding","resultType":"curve id"}]}
	#		command += (JSON.stringify data)+"'"
	console.log "About to call python using command: "+command
	child = exec command,  (error, stdout, stderr) ->
		reportURLPos = stdout.indexOf config.all.client.service.result.viewer.liveDesign.baseUrl
		reportURL = stdout.substr reportURLPos
		#console.warn "stderr: " + stderr
		console.log "stdout: " + stdout
		if error?
			caughtPythonErrors = true
			console.error error
			pythonErrors.push error
		callback caughtPythonErrors, pythonErrors