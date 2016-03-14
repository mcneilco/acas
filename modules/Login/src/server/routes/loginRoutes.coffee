
exports.setupAPIRoutes = (app) ->
	app.get '/api/users/:username', exports.getUsers
	app.get '/api/authors', exports.getAuthors

exports.setupRoutes = (app, passport) ->
	app.get '/login', exports.loginPage
	app.post '/login',
		passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }), exports.loginPost
	app.get '/logout*', exports.logout
	app.post '/api/userAuthentication', exports.authenticationService
	app.get '/api/users/:username', exports.ensureAuthenticated, exports.getUsers
	app.get '/passwordReset', exports.resetpage
	app.post '/passwordReset',
		exports.resetAuthenticationService,
		exports.resetPost
	app.post '/api/userResetAuthentication', exports.resetAuthenticationService
	app.get '/passwordChange', exports.ensureAuthenticated, exports.changePage
	app.post '/passwordChange',
		exports.changeAuthenticationService,
		exports.changePost
	app.post '/api/userChangeAuthentication', exports.changeAuthenticationService
	app.get '/api/authors', exports.ensureAuthenticated, exports.getAuthors

csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
config = require '../conf/compiled/conf.js'

exports.loginPage = (req, res) ->
	user = null
	if req.user?
		user = req.user

	errorMsg = ""
	error = req.flash('error')
	if error.length > 0
		errorMsg = error[0]
	if config.all.server.security.authstrategy is "database"
		resetPasswordOption = true
	else
		resetPasswordOption = false

	res.render 'login',
		title: "ACAS Login"
		scripts: []
		user: user
		message: errorMsg
		resetPasswordOption: resetPasswordOption

exports.resetPost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/passwordReset'
	
exports.loginPost = (req, res) ->
	console.log "got to login post"
	if req.session.returnTo?
		res.redirect req.session.returnTo
	else
		res.redirect '/'

exports.changePost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/passwordChange'

exports.logout = (req, res) ->
	req.logout()
	redirectMatch = req.originalUrl.match(/^\/logout\/(.*)\/?$/i)
	if redirectMatch?
		redirectMatch = redirectMatch[1]
	else
		redirectMatch = "/"
	res.redirect redirectMatch

exports.ensureAuthenticated = (req, res, next) ->
	console.log "checking for login for path: "+req.url
	if req.isAuthenticated()
		return next()
	if req.session?
		req.session.returnTo = req.url
	res.redirect '/login'

exports.ensureAuthenticatedAPI = (req, res, next) ->
	console.log "checking for login for path: "+req.url
	if req.isAuthenticated()
		return next()
	if req.session?
		req.session.returnTo = req.url
	res.redirect 401, '/login'

exports.getUsers = (req, resp) ->
	console.log "get users in route file"
	callback = (err, user) ->
		if user == null
			resp.send(204)
		else
			delete user.password
			resp.json user
	csUtilities.getUser req.params.username, callback

exports.authenticationService = (req, resp) ->
	callback = (results) ->
		console.log results
		if results.indexOf("Success")>=0
			console.log "in authentication service success"
			resp.json
				status: "Success"
		else
			console.log "in authentication service fail"
			resp.json
				status: "Fail"

	if global.specRunnerTestmode
		callback("Success")
	else
		csUtilities.authCheck req.body.user, req.body.password, callback

exports.resetAuthenticationService = (req, resp) ->
	callback = (results) ->
		console.log results
		if results.indexOf("Your new password has been sent to your email address.")>=0
			req.flash 'error','Your new password has been sent to your email address.'
			resp.redirect '/passwordReset'
		else if results.indexOf("connection_error")>=0
			req.flash 'error','Cannot connect to authentication service. Please contact an administrator.'
			resp.redirect '/passwordReset'
		else
			req.flash 'error','Invalid Email or Username'
			resp.redirect '/passwordReset'

	if global.specRunnerTestmode
		callback("Success")
	else
		csUtilities.resetAuth req.body.email, callback

exports.changeAuthenticationService = (req, resp) ->
	callback = (results) ->
		console.log results
		if results.indexOf("You password has been successfully been changed")>=0
			req.flash 'error','Your new password is set.'
			resp.redirect '/login'
		else if results.indexOf("connection_error")>=0
			req.flash 'error','Cannot connect to authentication service. Please contact an administrator.'
			resp.redirect '/passwordChange'
		else
			req.flash 'error','Invalid password or new password does not match.'
			resp.redirect '/passwordChange'

	if global.specRunnerTestmode
		callback("Success")
	else
		csUtilities.changeAuth req.body.user, req.body.oldPassword, req.body.newPassword, req.body.newPasswordAgain, callback

exports.resetpage = (req, res) ->
	user = null
	if req.user?
		user = req.user
	console.log req.flash
	errorMsg = ""
	error = req.flash('error')
	if error.length > 0
		errorMsg = error[0]
	if config.all.server.security.authstrategy is "database"
		res.render 'passwordReset',
			title: "ACAS reset"
			scripts: []
			user: user
			message: errorMsg
	else
		res.redirect '/login'

exports.changePage = (req, res) ->
	user = null
	if req.user?
		user = req.user
	if user != null
		errorMsg = ""
		error = req.flash('error')
		if error.length > 0
			errorMsg = error[0]

		res.render 'passwordChange',
			title: "ACAS reset"
			scripts: []
			user: user
			message: errorMsg
	else
		res.render 'login',
			title: "ACAS login"
			scripts: []
			user: user
			message: "need login or admin"

exports.getAuthors = (req, resp) ->
	console.log "getting authors"
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		baseEntityServiceTestJSON = require '../src/javascripts/spec/testFixtures/BaseEntityServiceTestJSON.js'
		resp.end JSON.stringify baseEntityServiceTestJSON.authorsList
	else
		csUtilities.getAuthors req, resp