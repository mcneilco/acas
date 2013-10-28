###
  DNS-specific implementations of required server functions

  All functions are required with unchanged signatures
###

exports.logUsage = (action, data, username) ->
	#TODO add log level warning,error etc
	config = require './configurationNode.js'
	request = require 'request'
	req = request.post config.serverConfigurationParams.configuration.loggingService , (error, response) =>
		if !error && response.statusCode == 200
			console.log "logged: "+action+" with data: "+data+" and user: "+username
		else
			console.log "got error trying log action: "+action+" with data: "+data
			console.log error
			console.log response
	unless username?
		username = "NA"
	try
		form = req.form()
		form.append('application', 'acas')
		form.append('action', action)
		form.append('application_data', data)
		form.append('user_login', username)
	catch error
		console.log error


exports.getConfServiceVars = (sysEnv, callback) ->
	properties = require "properties"
	asyncblock = require('asyncblock');
	exec = require('child_process').exec;
	os = require 'os'


	if typeof sysEnv.DNSDeployMode == "undefined"
		sysEnv.DNSDeployMode = "Dev"
	if typeof sysEnv.DNSLogDirectory == "undefined"
		sysEnv.DNSLogDirectory = "/tmp"

	asyncblock((flow) ->
		global.deployMode = sysEnv.DNSDeployMode
		exec("java -jar ../../lib/dns-config-client.jar -m "+deployMode+" -c acas -d 2>/dev/null", flow.add())
		config = flow.wait()
		if config.indexOf("It=works") > -1
			console.log "Can't contact DNS config service. If you are doing local dev, check your VPN."
			process.exit 1
		config = config.replace(/\\/g, "")

		options =
			namespaces: true

		properties.parse config, options, (error, dnsconf) ->
			if error?
				console.log "Parsing DNS conf service output failed: "+error
			else
				if global.deployMode == "Prod"
					dnsconf.enableSpecRunner = false
				else
					dnsconf.enableSpecRunner = true

				#dnsconf.hostname = os.hostname()
				switch(global.deployMode)
					when "Dev" then dnsconf.hostname = "acas-d.dart.corp"
					when "Test" then dnsconf.hostname = "acas-t.dart.corp"
					when "Stage" then dnsconf.hostname = "acas-s.dart.corp"
					when "Prod"
						dnsconf.hostname = "acas.dart.corp"
						dnsconf.enableSpecRunner = false

				jdbcParts = dnsconf.acas.jdbc.url.split ":"
				dnsconf.acas.api.db = {}
				dnsconf.acas.api.db.location = jdbcParts[0]+":"+jdbcParts[1]+":"+jdbcParts[2]+":@"
				dnsconf.acas.api.db.host = jdbcParts[3].replace("@","")
				dnsconf.acas.api.db.port = jdbcParts[4]
				dnsconf.acas.api.db.name = jdbcParts[5]

				callback(dnsconf)
		)


exports.fillConfigTemplateFile = (callback) ->
	fs = require('fs')
	asyncblock = require('asyncblock');
	exec = require('child_process').exec;
	asyncblock((flow) ->
		global.deployMode = process.env.DNSDeployMode
		exec("java -jar ../../lib/dns-config-client.jar -m "+global.deployMode+" -c acas -d 2>/dev/null", flow.add())
		config = flow.wait()
		if config.indexOf("It=works") > -1
			console.log "Can't contact DNS config service. If you are doing local dev, check your VPN."
			process.exit 1
		config = config.replace(/\\/g, "")
		configLines = config.split("\n")
		settings = {}
		for line in configLines
			lineParts = line.split /\=(.+)?/
			unless lineParts[1] is undefined
				settings[lineParts[0]] = lineParts[1]
		configTemplate = fs.readFileSync("../public/src/conf/configurationNode_Template.js").toString()
		for name, setting of settings
			configTemplate = configTemplate.replace(RegExp(name,"g"), setting)
		# deal with special cases
		jdbcParts = settings["acas.jdbc.url"].split ":"
		configTemplate = configTemplate.replace(/acas.api.db.location/g, jdbcParts[0]+":"+jdbcParts[1]+":"+jdbcParts[2]+":@")
		configTemplate = configTemplate.replace(/acas.api.db.host/g, jdbcParts[3].replace("@",""))
		configTemplate = configTemplate.replace(/acas.api.db.port/g, jdbcParts[4])
		configTemplate = configTemplate.replace(/acas.api.db.name/g, jdbcParts[5])

		# replace server name
		enableSpecRunner = true
		switch(global.deployMode)
			when "Dev" then hostName = "acas-d"
			when "Test" then hostName = "acas-t"
			when "Stage" then hostName = "acas-s"
			when "Prod"
				hostName = "acas"
				enableSpecRunner = false
		configTemplate = configTemplate.replace(RegExp("acas.api.hostname","g"), hostName)
		configTemplate = configTemplate.replace(/acas.api.enableSpecRunner/g, enableSpecRunner)
		configTemplate = configTemplate.replace(/acas.env.logDir/g, process.env.DNSLogDirectory)

		fs.writeFileSync "../public/src/conf/configurationNode.js", configTemplate
		callback()
	)

exports.authCheck = (user, pass, retFun) ->
	config = require './configurationNode.js'
	request = require 'request'
	request(
		method: 'POST'
		url: config.serverConfigurationParams.configuration.userAuthenticationServiceURL
		form:
			username: user
			password: pass
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			retFun JSON.stringify json
		else
			console.log 'got ajax error trying authenticate a user'
			console.log error
			console.log json
			console.log response
	)

exports.getUser = (username, callback) ->
	config = require './configurationNode.js'
	request = require 'request'
	request(
		method: 'GET'
		url: config.serverConfigurationParams.configuration.userInformationServiceURL+username
		json: true
	, (error, response, json) =>
		if !error && response.statusCode == 200
			callback null,
				id: json.DNSPerson.id
				username: json.DNSPerson.id
				email: json.DNSPerson.email
				firstName: json.DNSPerson.firstName
				lastName: json.DNSPerson.lastName
		else
			console.log 'got ajax error trying get user information'
			console.log error
			console.log json
			console.log response
			callback null, null
	)


exports.findByUsername = (username, fn) ->
	return exports.getUser username, fn

exports.loginStrategy = (username, password, done) ->
	process.nextTick ->
		exports.findByUsername username, (err, user) ->
			exports.authCheck username, password, (results) ->
				if results.indexOf("Success")>=0
					try
						exports.logUsage "User logged in succesfully: ", "NA", username
					catch error
						console.log "Exception trying to log:"+error
					return done null, user
				else
					try
						exports.logUsage "User failed login: ", "NA", username
					catch error
						console.log "Exception trying to log:"+error
					return done(null, false,
						message: "Invalid credentials"
					)

exports.getProjects = (resp) ->
	config = require './configurationNode.js'
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