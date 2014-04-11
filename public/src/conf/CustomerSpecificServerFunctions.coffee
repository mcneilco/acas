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
	config = require '../../../conf/compiled/conf.js'
	console.log config.all.client.require.login.loginLink
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
##  http://host3.labsynch.com:8080/acas/resources/j_spring_security_check
##  http://host3.labsynch.com:8080/acas/login
		url: config.all.client.require.login.loginLink
		form:
			j_username: user
			j_password: pass
		json: false
	, (error, response, json) =>
		if !error && response.statusCode == 200
			retFun JSON.stringify json
		else if !error && response.statusCode == 302
			retFun JSON.stringify response.headers.location
		else
			console.log 'got ajax error trying authenticate a user'
			console.log error
			console.log json
			console.log response
	)

exports.resetAuth = (email, retFun) ->
	config = require '../../../conf/compiled/conf.js'
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: config.all.client.require.login.resetLink
		form:
			emailAddress: email
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

exports.changeAuth = (user, passOld,passNew,passNewAgain, retFun) ->
	config = require '../../../conf/compiled/conf.js'
	request = require 'request'
	request(
		headers:
			accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
		method: 'POST'
		url: config.all.client.require.login.changeLink
		form:
			username: user
			oldPassword: passOld
			newPassword: passNew
			newPasswordAgain: passNewAgain
		json: false
	, (error, response, json) =>
		console.log response.statusCode
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
		request = require 'request'
		request(
			headers:
				accept: 'application/json'
			method: 'POST'
			url: config.all.client.require.login.getUserLink
			json: '{"name":"guy@mcneilco.com"}'
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.log json
				callback null,
					id: "bob"
					username: "bob"
					email: "bob@nowwhere.com"
					firstName: "Bob2"
					lastName: "Roberts1"
					role: "admin"
			else
				callback "user not found", null
		)
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
			exports.getUser username,done



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

