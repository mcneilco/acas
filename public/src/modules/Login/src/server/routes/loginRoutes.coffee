### To install this module add
  to app.coffee
# login routes
passport.serializeUser (user, done) ->
	done null, user.username
passport.deserializeUser (username, done) ->
	loginRoutes.findByUsername username, (err, user) ->
		done err, user
passport.use new LocalStrategy loginRoutes.loginStrategy

app.get '/login', loginRoutes.loginPage
app.post '/login',
	passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }),
	loginRoutes.loginPost
app.get '/logout', loginRoutes.logout
app.post '/api/userAuthentication', loginRoutes.authenticationService
app.get '/api/users/:username', loginRoutes.getUsers

  to index.coffee under specScripts:
		#For Login module
		'javascripts/spec/AuthenticationServiceSpec.js'

###



users = [
	id: 1
	username: "bob"
	password: "secret"
	email: "bob@example.com"
	firstName: "Bob"
	lastName: "Roberts"
,
	id: 2
	username: "jmcneil"
	password: "birthday"
	email: "jmcneil@example.com"
	firstName: "John"
	lastName: "McNeil"
,
	id: 3
	username: "ldap-query"
	password: "Est@P7uRi5SyR+"
	email: ""
	firstName: "ldap-query"
	lastName: ""
]

exports.findById = (id, fn) ->
	idx = id - 1
	if users[idx]
		fn null, users[idx]
	else
		fn new Error("User " + id + " does not exist")

exports.findByUsername = (username, fn) ->
	config = require '../public/src/conf/configurationNode.js'
	if global.specRunnerTestmode or config.serverConfigurationParams.configuration.userAuthenticationType == "Demo"
		i = 0
		len = users.length
		while i < len
			user = users[i]
			return fn(null, user)  if user.username is username
			i++
	else
		console.log "no authorization service configured"
	if config.serverConfigurationParams.configuration.userAuthenticationType != "Demo"
		return fn null, null
	else
		return fn null, {username: username}

exports.loginStrategy = (username, password, done) ->
	config = require '../public/src/conf/configurationNode.js'
	process.nextTick ->
		exports.findByUsername username, (err, user) ->
			if config.serverConfigurationParams.configuration.userAuthenticationType == "Demo"
				return done(err)  if err
				unless user
					return done(null, false,
						message: "Unknown user " + username
					)
				unless user.password is password
					return done(null, false,
						message: "Invalid password"
					)
				return done null, user
			else
				console.log "no authentication service configured"

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
		else
			console.log "no authentication service configured"


exports.getUsers = (req, resp) ->
	callback = (err, user) ->
		if user == null
			resp.send(204)
		else
			delete user.password
			resp.json user

	exports.findByUsername req.params.username, callback
