###
  DNS-specific implementations of required server functions

  All functions are required with unchanged signatures
###

exports.logUsage = (action, data, username) ->
	# We generate this config file from the DNS configuration service
	config = require '../../../conf/compiled/conf.js'

	# this is a node module that is like jQuery's $.POST
	request = require 'request'

	# Setup the request with a call-back function
	req = request.post config.all.server.service.external.logging.url , (error, response) =>
		if !error && response.statusCode == 200
			# I copy the log to the node console 
			console.log "logged: "+action+" with data: "+data+" and user: "+username
		else
			console.log "got error trying log action: "+action+" with data: "+data
			console.log error
			console.log response

	#If you don't supply a username, the log fails.
	#For example, there is no username on system start, which I log
	unless username?
		username = "NA"

	#Also, if you send an empty string for application_data, the logging service won't record the user name
	if data == ""
		data = "NA"

	#The logging service will only accept a form post, you can't just do the post in one step like with most services
	#This is how you do that with the request module
	#If I have an error in this form submit, I don't want to take down ACAS, so try-catch
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

exports.authCheck = (user, pass, retFun) ->
	config = require '../../../conf/compiled/conf.js'
	request = require 'request'
	request(
		method: 'POST'
		url: config.all.server.service.external.user.authentication.url
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
	config = require '../../../conf/compiled/conf.js'
	request = require 'request'
	request(
		method: 'GET'
		url: config.all.server.service.external.user.information.url+username
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
						exports.logUsage "User logged in succesfully: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done null, user
				else
					try
						exports.logUsage "User failed login: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done(null, false,
						message: "Invalid credentials"
					)

exports.getProjects = (resp) ->
	config = require '../../../conf/compiled/conf.js'
	request = require 'request'
	request(
		method: 'GET'
		url: config.all.server.service.external.project.url
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