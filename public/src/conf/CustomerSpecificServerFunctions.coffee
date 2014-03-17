###
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
###

exports.logUsage = (action, data, username) ->
	# no ACAS logging service yet
	console.log "would have logged: "+action+" with data: "+data+" and user: "+username


exports.getConfServiceVars = (sysEnv, callback) ->
	conf = {}
	callback(conf)

exports.authCheck = (user, pass, retFun) ->
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
##  http://host3.labsynch.com:8080/acas/resources/j_spring_security_check
##  http://host3.labsynch.com:8080/acas/login
		url: 'http://host3.labsynch.com:8080/acas/resources/j_spring_security_check'
		form:
			j_username: user
			j_password: pass
		json: false
	, (error, response, json) =>
		if !error && response.statusCode == 200
			console.log json
			retFun JSON.stringify json
		else if !error && response.statusCode == 302
			console.log response.headers.location
			retFun JSON.stringify response.headers.location
		else
			console.log 'got ajax error trying authenticate a user'
			console.log error
			console.log json
			console.log response
	)

exports.resetAuth = (email, retFun) ->
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: 'http://host3.labsynch.com:8080/acas/forgotpassword/update'
		form:
			emailAddress: email
		json: false
	, (error, response, json) =>
		if !error && response.statusCode == 200
			retFun JSON.stringify message: "Already Reset"
		else
			console.log 'got ajax error trying authenticate a user'
			console.log error
			console.log json
			console.log response
	)

exports.changeAuth = (user, passOld,passNew,passNewAgain, retFun) ->
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: 'http://host3.labsynch.com:8080/acas/changepassword/update'
		form:
			username: user
			oldPassword: passOld
			newPassword: passNew
			newPasswordAgain: passNewAgain
		json: false
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
	if config.all.client.require.login
		if username == "bob"
			callback null,
				id: "bob"
				username: "bob"
				email: "bob@nowwhere.com"
				firstName: "Bob"
				lastName: "Roberts"
		else
			callback "user not found", null
	else
		callback null,
			id: 0,
			username: username,
			email: username+"@nowhere.com",
			firstName: "",
			lastName: username



exports.findByUsername = (username, fn) ->
	return exports.getUser username, fn

exports.loginStrategy = (username, password, done) ->
	process.nextTick ->
		exports.findByUsername username, (err, user) ->
			exports.authCheck username, password, (results) ->
				if results.indexOf("login_error")>=0
					try
						exports.logUsage "User failed login: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done(null, false,
						message: "Invalid credentials"
					)
				else
					try
						exports.logUsage "User logged in succesfully: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done null, user

exports.resetStrategy = (username, done) ->
	process.nextTick ->
		exports.findByUsername username, (err, user) ->
			exports.resetAuth username, (results) ->
				if results.indexOf("Your new password is sent to your email address")>=0
					try
						exports.logUsage "Can't find email or user name: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done(null, false,
						message: "Invalid username or email"
					)
				else
					try
						exports.logUsage "User password reset succesfully: ", "", username
					catch error
						console.log "Exception trying to log:"+error
					return done null, user

exports.getProjects = (resp) ->
	projects = 	exports.projects = [
		code: "project1"
		name: "Project 1"
		ignored: false
	,
		code: "project2"
		name: "Project 2"
		ignored: false
	]

	resp.end JSON.stringify projects

