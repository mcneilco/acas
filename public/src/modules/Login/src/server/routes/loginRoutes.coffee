users = [
	id: 1
	username: "bob"
	password: "secret"
	email: "bob@example.com"
,
	id: 2
	username: "joe"
	password: "birthday"
	email: "joe@example.com"
,
	id: 3
	username: "ldap-query"
	password: "Est@P7uRi5SyR+"
	email: "sdfsdfdfsfds"
]

exports.findById = (id, fn) ->
	idx = id - 1
	if users[idx]
		fn null, users[idx]
	else
		fn new Error("User " + id + " does not exist")

exports.findByUsername = (username, fn) ->
	i = 0
	len = users.length
	while i < len
		user = users[i]
		return fn(null, user)  if user.username is username
		i++
	fn null, null

exports.loginStrategy = (username, password, done) ->
	process.nextTick ->
		exports.findByUsername username, (err, user) ->
			return done(err)  if err
			unless user
				return done(null, false,
					message: "Unknown user " + username
				)
			unless user.password is password
				return done(null, false,
					message: "Invalid password"
				)
			done null, user

exports.loginPage = (req, res) ->
	user = null
	if req.user?
		user = req.user

	errorMsg = ""
	error = req.flash('error')
	if error.length > 0
		errorMsg = error[0]

	res.render 'login',
		title: "ACAS Login"
		scripts: []
		user: user
		message: errorMsg

exports.loginPost = (req, res) ->
	res.redirect '/'

exports.logout = (req, res) ->
	req.logout()
	res.redirect '/'

exports.ensureAuthenticated = (req, res, next) ->
	if req.isAuthenticated()
		return next()
	res.redirect '/login'

exports.authenticationService = (req, resp) ->
	config = require '../public/src/conf/configurationNode.js'
	callback = (results) ->
		if results.indexOf("Success")>=0
			resp.json
				status: "Success"
		else
			resp.json
				status: "Fail"

	if global.specRunnerTestmode
		callback("Success")
	else
		if config.serverConfigurationParams.configuration.userAuthenticationType == "Demo"
			callback("Success")
		else if config.serverConfigurationParams.configuration.userAuthenticationType == "DNS"
			dnsAuthCheck req.body.user, req.body.password, callback

dnsAuthCheck = (user, pass, retFun) ->
	config = require '../public/src/conf/configurationNode.js'
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
			console.log JSON.stringify json
			retFun JSON.stringify json
		else
			console.log 'got ajax error trying authenticate a user'
			console.log error
			console.log json
			console.log response
	)

