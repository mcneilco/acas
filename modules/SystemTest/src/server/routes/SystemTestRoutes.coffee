exports.setupAPIRoutes = (app, loginRoutes) ->
	app.post '/api/runSystemTest', exports.runSystemTest
	app.get '/api/systemTest/getOrCreateACASBob', exports.getOrCreateACASBob
	app.get '/api/systemTest/getOrCreateGlobalProject', exports.getOrCreateGlobalProject
	app.get '/api/systemTest/getOrCreateGlobalProjectRole', exports.getOrCreateGlobalProjectRole
	app.get '/api/systemTest/giveBobRoles', exports.giveBobRoles
	app.get '/api/systemTest/getOrCreateCmpdRegBob', exports.getOrCreateCmpdRegBob
	app.get '/api/systemTest/syncRoles', exports.syncRoles
	app.get '/api/systemTest/getOrCreateCmpds', exports.getOrCreateCmpds
	app.get '/api/systemTest/loadSELFile', exports.loadSELFile
	app.get '/api/systemTest/deleteSELFile', exports.deleteSELFile
	app.get '/api/systemTest/purgeCmpds', exports.purgeCmpds
	app.get '/api/systemTest/deleteCmpdRegBob', exports.deleteCmpdRegBob
	app.get '/api/systemTest/deleteACASBob', exports.deleteACASBob
	app.get '/api/systemTest/deleteGlobalProject', exports.deleteGlobalProject

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/runSystemTest', loginRoutes.ensureAuthenticated, exports.runSystemTest
	app.get '/api/systemReport', loginRoutes.ensureAuthenticated, exports.systemReport

ACAS_HOME=".."
config = require "#{ACAS_HOME}/conf/compiled/conf.js"
request = require('request')
_ = require 'underscore'
fs = require 'fs'
path = require 'path'

#Create Bob User
exports.getACASBobUser = (callback) ->
	options =
		method: 'GET'
		url: "#{config.all.server.nodeapi.path}/api/users/bob"
		json: true
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		callback body

exports.getOrCreateACASBob = (req, resp) ->
	exports.getOrCreateACASBobInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.getOrCreateACASBobInternal = (callback) ->
	exports.getACASBobUser (bob) ->
		if bob?
			callback 200, {
				hasError: false
				messages: bob
				created: false
			}
		else
			options =
				method: 'POST'
				url: "#{config.all.client.service.persistence.fullpath}authors"
				headers:
					'cache-control': 'no-cache'
					accept: 'application/json'
					'content-type': 'application/json'
				body:
					firstName: 'Bob'
					lastName: 'Roberts'
					userName: 'bob'
					emailAddress: 'bob@mcneilco.com'
					version: 0
					enabled: true
					locked: false
					password: '5en6G6MezRroT3XKqkdPOmY/BfQ='
					recordedBy: 'bob'
					recordedDate: 1457542406000
					lsType: 'default'
					lsKind: 'default'
				json: true
			request options, (error, response, body) ->
				if error
					console.error response
					statusCode=500
					hasError = true
					created = false
				else
					if response.statusCode == 500
						hasError = true
						created = false
					else
						hasError = false
						created = true
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
					created: created
				}

exports.deleteACASBob = (req, resp) ->
	exports.deleteACASBobInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.deleteACASBobInternal = (callback) ->
	exports.getACASBobUser (bob) ->
		if !bob?
			callback 400, {
				hasError: true
				messages: bob
			}
		else
			options =
				method: 'DELETE'
				url: "#{config.all.client.service.persistence.fullpath}authors/#{bob.id}"
				json: true
			request options, (error, response, body) ->
				if error
					console.error response
					statusCode=500
					hasError = true
				else
					if response.statusCode == 500
						hasError = true
						created = false
					else
						hasError = false
						created = true
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
				}

exports.getGlobalProject = (callback) ->
	options =
		method: 'GET'
		json: true
		url: "#{config.all.server.nodeapi.path}/api/projects/getAllProjects/stubs?username=bob"
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		globalProject = _.findWhere body, {"name":"Global"}
		callback globalProject

exports.getOrCreateGlobalProject = (req, resp) ->
	exports.getOrCreateGlobalProjectInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.getOrCreateGlobalProjectInternal = (callback) ->
	exports.getGlobalProject (globalProject) ->
		if globalProject?
			callback 200, {
				hasError: false
				messages: globalProject
				created: false
			}
		else
			options =
				method: 'POST'
				url: "#{config.all.server.nodeapi.path}/api/things/project/project"
				headers:
					accept: 'application/json, text/javascript, */*; q=0.01'
					'content-type': 'application/json'
					origin: 'http://localhost:3000'
				body:
					lsType: 'project'
					lsKind: 'project'
					corpName: ''
					recordedBy: 'bob'
					recordedDate: 1472835742009
					shortDescription: ' '
					lsLabels: [
						{
							lsType: 'name'
							lsKind: 'project name'
							labelText: 'Global'
							ignored: false
							preferred: true
							recordedDate: 1472835742010
							recordedBy: 'bob'
							physicallyLabled: false
							imageFile: null
						}
						{
							lsType: 'name'
							lsKind: 'project alias'
							labelText: 'Global'
							ignored: false
							preferred: false
							recordedDate: 1472835742012
							recordedBy: 'bob'
							physicallyLabled: false
							imageFile: null
						}
					]
					lsStates: [ {
						lsType: 'metadata'
						lsKind: 'project metadata'
						lsValues: [
							{
								lsType: 'dateValue'
								lsKind: 'start date'
								ignored: false
								recordedDate: 1472835742015
								recordedBy: 'bob'
								value: null
								dateValue: null
							}
							{
								lsType: 'codeValue'
								lsKind: 'project status'
								ignored: false
								recordedDate: 1472835742016
								recordedBy: 'bob'
								codeKind: 'status'
								codeType: 'project'
								codeOrigin: 'ACAS DDICT'
								codeValue: 'active'
								value: 'active'
							}
							{
								lsType: 'stringValue'
								lsKind: 'short description'
								ignored: false
								recordedDate: 1472835742017
								recordedBy: 'bob'
								value: ''
								stringValue: ''
							}
							{
								lsType: 'clobValue'
								lsKind: 'project details'
								ignored: false
								recordedDate: 1472835742020
								recordedBy: 'bob'
								value: ''
								clobValue: ''
							}
							{
								lsType: 'codeValue'
								lsKind: 'is restricted'
								ignored: false
								recordedDate: 1472835742022
								recordedBy: 'bob'
								codeKind: 'restricted'
								codeType: 'project'
								codeOrigin: 'ACAS DDICT'
								codeValue: 'false'
								value: 'true'
							}
						]
						ignored: false
						recordedDate: 1472835742014
						recordedBy: 'bob'
					} ]
					firstLsThings: []
					secondLsThings: []
					lsTags: []
				json: true
			request options, (error, response, body) ->
				if error
					throw new Error(error)
					statusCode=500
					hasError = true
					created = false
				else
					if response.statusCode == 500
						hasError = true
						created = false
					else
						hasError = false
						created = true
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
					created: created
				}

exports.getGlobalProjectRole = (projectCode, callback) ->
	options =
		method: 'GET'
		url: "#{config.all.server.nodeapi.path}/api/projects/getByRoleTypeKindAndName/Project/#{projectCode}/User"
		json:true
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		callback body[0]

exports.getOrCreateGlobalProjectRole = (req, resp) ->
	exports.getOrCreateGlobalProjectRoleInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.getOrCreateGlobalProjectRoleInternal = (callback) ->
	exports.getGlobalProject (globalProject) ->
		globalProjectCode = globalProject.code
		exports.getGlobalProjectRole globalProjectCode, (globalProjectRole) ->
			if globalProjectRole?
				callback 200, {
					hasError: false
					messages: globalProjectRole
					created: false
				}
			else
				request = require('request')
				options =
					method: 'POST'
					url: "#{config.all.server.nodeapi.path}/api/projects/createRoleKindAndName"
					headers:
						accept: 'application/json, text/javascript, */*; q=0.01'
						'content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
						origin: 'http://localhost:3000'
					body: "rolekind%5B0%5D%5BtypeName%5D=Project&rolekind%5B0%5D%5BkindName%5D=#{globalProjectCode}&lsroles%5B0%5D%5BlsType%5D=Project&lsroles%5B0%5D%5BlsKind%5D=#{globalProjectCode}&lsroles%5B0%5D%5BroleName%5D=User&lsroles%5B1%5D%5BlsType%5D=Project&lsroles%5B1%5D%5BlsKind%5D=#{globalProjectCode}&lsroles%5B1%5D%5BroleName%5D=Administrator"
					json: true
				request options, (error, response, body) ->
					created = false
					if error
						throw new Error(error)
						statusCode=500
						hasError = true
					else
						if response.statusCode == 500
							hasError = true
						else
							hasError = false
							created = true
						statusCode = response.statusCode
					callback statusCode, {
						hasError: hasError
						messages: body
						created: created
					}

exports.syncRoles = (req, resp) ->
	exports.syncRolesInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.syncRolesInternal = (callback) ->
	options =
		method: 'GET'
		url: "#{config.all.server.nodeapi.path}/api/syncLiveDesignProjectsUsers"
	request options, (error, response, body) ->
		if error
			throw new Error(error)
			statusCode=500
			hasError = true
		else
			hasError = false
			statusCode = response.statusCode
		callback statusCode, {
			hasError: hasError
			messages: body
		}

exports.giveBobRoles = (req, resp) ->
	exports.giveBobRolesInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.giveBobRolesInternal = (callback) ->
	exports.getGlobalProject (globalProject) ->
		globalProjectCode = globalProject.code
		options =
			method: 'POST'
			url: "#{config.all.client.service.persistence.fullpath}authorroles/saveRoles"
			headers:
				'content-type': 'application/json'
			body: [
				{
					roleType: 'System'
					roleKind: 'ACAS'
					roleName: 'ROLE_ACAS-USERS'
					userName: 'bob'
				}
				{
					roleType: 'System'
					roleKind: 'CmpdReg'
					roleName: 'ROLE_CMPDREG-USERS'
					userName: 'bob'
				}
				{
					roleType: 'Project'
					roleKind: globalProjectCode
					roleName: 'User'
					userName: 'bob'
				}
			]
			json: true
		request options, (error, response, body) ->
			if error
				throw new Error(error)
				statusCode=500
				hasError = true
			else
				if response.statusCode == 500
					hasError = true
				else
					hasError = false
				statusCode = response.statusCode
			callback statusCode, {
				hasError: hasError
				messages: body
			}

exports.getCmpdRegBobUser = (callback) ->
	options =
		method: 'GET'
		url: 	config.all.client.service.cmpdReg.persistence.basepath + "/scientists"
		json: true
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		bob =	_.findWhere body, {"code": "bob"}
		callback bob

exports.getOrCreateCmpdRegBob = (req, resp) ->
	exports.getOrCreateCmpdRegBobInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.getOrCreateCmpdRegBobInternal = (callback)->
	exports.getCmpdRegBobUser (cmpdRegBob) ->
		if cmpdRegBob?
			callback 200, {
				hasError: false
				messages: cmpdRegBob
				created: false
			}
		else
			exports.getACASBobUser (bob) ->
				grantedRoles = _.map bob.roles, (role) ->
					role.roleEntry.roleName
				options =
					method: 'POST'
					url: config.all.client.service.cmpdReg.persistence.basepath + "/scientists/jsonArray"
					headers:
						'cache-control': 'no-cache'
						accept: 'application/json'
						'content-type': 'application/json'
					body: [
						id: bob.id
						code: bob.username
						name: bob.firstName + " " + bob.lastName
						isChemist: (config.all.client.roles.cmpdreg?.chemistRole? && config.all.client.roles.cmpdreg.chemistRole in grantedRoles)
						isAdmin: (config.all.client.roles.cmpdreg?.adminRole? && config.all.client.roles.cmpdreg.adminRole in grantedRoles)
						]
					json: true
				request options, (error, response, body) ->
					created = false
					if error
						throw new Error(error)
						statusCode=500
						hasError = true
					else
						if response.statusCode == 500
							hasError = true
						else
							hasError = false
							created = true
						statusCode = response.statusCode
					callback statusCode, {
						hasError: hasError
						messages: body
						created: created
					}

exports.deleteCmpdRegBob = (req, resp) ->
	exports.deleteCmpdRegBobInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.deleteCmpdRegBobInternal = (callback) ->
	exports.getCmpdRegBobUser (bob) ->
		if !bob?
			callback 400, {
				hasError: true
				messages: bob
			}
		else
			options =
				method: 'DELETE'
				url: "#{config.all.client.service.cmpdReg.persistence.basepath}/scientists/#{bob.id}"
				json: true
			request options, (error, response, body) ->
				if error
					console.error response
					statusCode=500
					hasError = true
				else
					if response.statusCode == 500
						hasError = true
						created = false
					else
						hasError = false
						created = true
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
				}

exports.deleteGlobalProject = (req, resp) ->
	exports.deleteGlobalProjectInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.deleteGlobalProjectInternal = (callback) ->
	exports.getGlobalProject (globalProject) ->
		if !globalProject?
			callback 400, {
				hasError: true
				messages: null
			}
		else
			options =
				method: 'DELETE'
				url: "#{config.all.client.service.persistence.fullpath}lsthings/System/Project/#{globalProject.id}"
				json: true
			console.log options
			request options, (error, response, body) ->
				if error
					console.error response
					statusCode=500
					hasError = true
				else
					if response.statusCode == 500
						hasError = true
						created = false
					else
						hasError = false
						created = true
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
				}

exports.getCmpds = (callback) ->
	request = require('request')
	options =
		method: 'GET'
		url: 	config.all.client.service.cmpdReg.persistence.basepath + "/metalots/corpName/SYSTEST-000000001-1"
		json: true
		headers:
			'cache-control': 'no-cache'
			accept: 'application/json'
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		callback body

exports.getOrCreateCmpds = (req, resp) ->
	exports.getOrCreateCmpdsInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.getOrCreateCmpdsInternal = (callback) ->
	exports.getCmpds (cmpds) ->
		if cmpds.lot?
			callback 200, {
				hasError: false
				messages: cmpds
			}
		else
			exports.getGlobalProject (globalProject) ->
				globalProjectCode = globalProject.code

				fs = require('fs');
				r = request.post
					url: "#{config.all.server.nodeapi.path}/uploads",
					json: true
				, (err, httpResponse, body) =>
					options =
						method: 'POST'
						url: "#{config.all.server.nodeapi.path}/api/cmpdRegBulkLoader/registerCmpds"
						json: true
						headers:
							accept: 'application/json, text/javascript, */*; q=0.01'
							'content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
						body: "fileName=#{encodeURIComponent(body[0].name)}&mappings%5B0%5D%5BdbProperty%5D=Parent+Corp+Name&mappings%5B0%5D%5Brequired%5D=false&mappings%5B0%5D%5BsdfProperty%5D=Parent+Corp+Name&mappings%5B0%5D%5BdefaultVal%5D=&mappings%5B1%5D%5BdbProperty%5D=Lot+Corp+Name&mappings%5B1%5D%5Brequired%5D=false&mappings%5B1%5D%5BsdfProperty%5D=Lot+Corp+Name&mappings%5B1%5D%5BdefaultVal%5D=&mappings%5B2%5D%5BsdfProperty%5D=&mappings%5B2%5D%5BdbProperty%5D=Lot+Chemist&mappings%5B2%5D%5BdefaultVal%5D=bob&mappings%5B2%5D%5Brequired%5D=true&mappings%5B3%5D%5BsdfProperty%5D=&mappings%5B3%5D%5BdbProperty%5D=Parent+Stereo+Category&mappings%5B3%5D%5BdefaultVal%5D=racemic&mappings%5B3%5D%5Brequired%5D=true&mappings%5B4%5D%5BdbProperty%5D=Project&mappings%5B4%5D%5Brequired%5D=true&mappings%5B4%5D%5BsdfProperty%5D=&mappings%5B4%5D%5BdefaultVal%5D=#{globalProjectCode}&userName=bob&fileDate=1472799600000"
					request options, (error, response, body) ->
						if error
							throw new Error(error)
							statusCode = 500
						else
							statusCode = response.statusCode
							if response.statusCode == 500
								hasError = true
							else
								hasError = false
						hasError = false
						if body[0].summary.indexOf("errors have been written") != -1
							hasError = true
						callback statusCode, {
							hasError: hasError
							messages: body[0].summary
						}
				form = r.form()
				form.append 'file', fs.createReadStream("src/assets/SystemTest/misc/nci50.sdf")

exports.getFileToPurge = (callback) ->
	options =
		method: 'GET'
		url: "#{config.all.server.nodeapi.path}/api/cmpdRegBulkLoader/getFilesToPurge"
		json: true
	request options, (error, response, body) =>
		if error
			throw new Error(error)
		#can't just do find where because bulk loader can't handle upload multiple of the same file
#		fileToPurge = _.findWhere body, {fileName: "nci50.sdf"}
		out = _.filter body, (file) ->
			file.fileName.indexOf("nci50",0)==0
		if out?[0]?
			callback out[0]
		else
			callback null

exports.purgeCmpds = (req, resp) ->
	exports.purgeCmpdsInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.purgeCmpdsInternal = (callback) ->
	exports.getFileToPurge (fileToPurge) =>
		if !fileToPurge?
			callback 200, {
				hasError: false
				messages: "nothing to purge"
			}
		else
			options =
				method: 'POST'
				url: "#{config.all.server.nodeapi.path}/api/cmpdRegBulkLoader/purgeFile"
				headers:
					'content-type': 'application/json'
					'x-requested-with': 'XMLHttpRequest'
					accept: 'application/json, text/javascript, */*; q=0.01'
				body: fileInfo:
					fileToPurge
				json: true
			request options, (error, response, body) ->
				if error
					throw new Error(error)
					statusCode=500
					hasError = true
				else
					if response.statusCode == 500
						hasError = true
					else
						hasError = false
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
				}

exports.loadSELFile = (req, resp) ->
	exports.loadSELFileInternal req.query.username, (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.loadSELFileInternal = (username, callback)->
	if !username?
		username = "bob"
	fs = require('fs');
	r = request.post
		url: "#{config.all.server.nodeapi.path}/uploads",
		json: true
	, (err, httpResponse, body) =>
		options =
			method: 'POST'
			url: "#{config.all.server.nodeapi.path}/api/genericDataParser"
			json: true
			headers:
				accept: 'application/json, text/javascript, */*; q=0.01'
				'content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
			body: "fileToParse=#{encodeURIComponent(body[0].name)}&reportFile=&imagesFile=&dryRunMode=false&user=#{username}&requireDoseResponse=true"
		request options, (error, response, body) =>
			if error
				throw new Error(error)
				statusCode = 500
			else
				statusCode = response.statusCode
			callback statusCode, body

	form = r.form()
	form.append 'file', fs.createReadStream("src/assets/SystemTest/misc/Ki Fit.csv")

exports.checkDataViewer = (req, resp) ->
	exports.checkDataViewerInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.checkDataViewerInternal = (callback) ->
	options =
		method: 'GET'
		url: "#{config.all.server.nodeapi.path}/api/writeLiveReportContentToCSVByExperimentName/#{encodeURIComponent("System Test")}?deleteLiveReport=1"
		json: true
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		if response.statusCode != 200
			callback response.statusCode, {
				hasError: true
				messages: body
			}
		else
			options =
				method: 'POST'
				url: "#{config.all.server.nodeapi.path}/api/compareLiveReportCsv"
				body:
					csv1: "src/assets/SystemTest/misc/SystemTestLiveReportContent.csv"
					csv2: body.filePath
				json: true
			request options, (error, response, body) ->
				if error
					throw new Error(error)
					hasError = true
				else
					if response.statusCode == 500
						hasError = true
					else
						hasError = false
					statusCode = response.statusCode
				callback statusCode, {
					hasError: hasError
					messages: body
				}

exports.installLiveDesignPythonClient = (req, resp) ->
	exports.checkDataViewerInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.installLiveDesignPythonClientInternal = (callback) ->
	options =
		method: 'GET'
		url: "#{config.all.server.nodeapi.path}/api/installLiveDesignPythonClient"
		json: true
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		if response.statusCode != 200
			callback response.statusCode, {
				hasError: true
				messages: body
			}
		else
			callback response.statusCode, {
				hasError: false
				messages: body
			}

exports.deleteSELFile = (req, resp) ->
	exports.deleteSELFileInternal (statusCode, output) ->
		resp.statusCode = statusCode
		resp.json output

exports.deleteSELFileInternal = (callback) ->
	options =
		method: 'GET'
		url: "#{config.all.client.service.rapache.fullpath}/cleanExperimentDelete?experimentName=System%20Test%20Experiment"
		json: true
	request options, (error, response, body) ->
		if error
			throw new Error(error)
		if response.statusCode != 200
			callback response.statusCode, {
				hasError: true
				messages: body
			}
		else
			experimentBody = body
			options =
				method: 'GET'
				url: "#{config.all.client.service.persistence.fullpath}protocols"
				json: true
				qs:
					FindByProtocolName: ''
					protocolName: 'System Test Protocol'
			request options, (error, response, body) ->
				if error
					throw new Error(error)
				if response.statusCode != 200 or (body? && body.length == 0)
					callback response.statusCode, {
						hasError: true
						messages: body
					}
				else
					options =
						method: 'DELETE'
						url: "#{config.all.server.nodeapi.path}/api/protocols/browser/#{body[0].id}"
						json: true
					request options, (error, response, body) ->
						if error
							throw new Error(error)
							statusCode=500
							hasError = true
						else
							if response.statusCode == 500
								hasError = true
							else
								hasError = false
							statusCode = response.statusCode
						callback statusCode, {
							hasError: hasError
							messages: {
								protocol: body
								experiment: experimentBody
							}
						}

exports.runSystemTest = (req, resp) ->
	force = req.body.force == true
	req.setTimeout 86400000
	exports.runSystemTestInternal force, (statusCode, response) ->
		resp.statusCode = statusCode
		resp.end response

exports.runSystemTestInternal = (force, callback) ->
	fs = require('fs')
	if !force?
		force = false
	systemTestProgressFile = path.resolve(path.join(config.all.server.datafiles.relative_path, "systemTestProgress.txt"))
	fs.stat systemTestProgressFile, (err, stat) =>
		if err == null && !force
			callback 400, "system test in progress (found #{systemTestProgressFile})"
		else if force || err.code == 'ENOENT'
			Mocha = require('mocha')
			# Instantiate a Mocha instance.
			mocha = new Mocha {
				reporter: 'mochawesome'
				reporterOptions: {
					reportDir: path.resolve(path.join(config.all.server.datafiles.relative_path, "systemReport/")),
					reportName: 'systemReport',
					reportTitle: 'ACAS System Report',
					inlineAssets: true
				}
			}

			testDir = "src/spec/SystemTest/serviceTests"
			# Add each .js file to the mocha instance
			fs.readdirSync(testDir).filter((file) =>
			# Only keep the .js files
				file.substr(-3) == '.js'
			).forEach (file) =>
				file = path.resolve(path.join(testDir, file))
				delete require.cache[file]
				mocha.addFile file
				return
			# Run the tests.
			results = []
			fs.writeFile systemTestProgressFile, "initiated - #{new Date()}", (err) =>
				if err
					throw err
				mocha.run().on('test', (test) =>
					console.debug 'Test started: ' + test.title
					return
				).on('end', (test) =>
					fs.unlink systemTestProgressFile, (err) =>
						if err
							throw err
						console.log "successfully deleted #{systemTestProgressFile}"
					fs.readFile path.resolve(path.join(config.all.server.datafiles.relative_path, "systemReport/systemReport.html")), (err, data) =>
						if callback?
							callback 200, data
					return
				).on('pass', (test) ->
					console.debug 'Test passed'
					console.debug test
					return
				).on('fail', (test, err) ->
					console.error 'Test fail'
					console.error test
					console.error err
					return
				).on 'end', ->
					console.debug 'All done'
					return
		else
			throw new Error err.code
		return


exports.systemReport = (req, resp) ->
	fs.readFile path.resolve(path.join(config.all.server.datafiles.relative_path, "systemReport/systemReport.html")), (err, data) =>
		if err?
			resp.send 400, "no system report found"
		else
			resp.writeHead(200, {'Content-Type': 'text/html'})
			resp.end data

