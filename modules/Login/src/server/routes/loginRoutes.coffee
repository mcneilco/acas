
config = require '../conf/compiled/conf.js'
csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'

exports.setupAPIRoutes = (app) ->
	app.get '/api/users/:username', exports.getUsers
	app.get '/api/authors', exports.getAuthors

exports.setupRoutes = (app, passport) ->
	if config.all.server.security.saml.use == true
		app.get '/login', ((req, res, next) ->
			# If the redirect_url is set, pass it to the passport request as a relay state query
			# This will then be returned as part of the body on callback
			req.query.RelayState = req.query.redirect_url
			next()
		), passport.authenticate('saml',{failureRedirect: '/', failureFlash: true})
		app.post '/login/callback', passport.authenticate('saml',
			failureRedirect: '/login/ssoFailure'
			failureFlash: true
		), (req, res) =>
			# If relay state value is set, it's because we set it to the redirect_url above
			# So if it's set then redirect the user to the RelayState value
			if req.body?.RelayState? && req.body.RelayState != ""
				console.log "redirecting to #{req.body.RelayState}"
				res.redirect(req.body.RelayState)
			else
				res.redirect('/');
	else
		app.get '/login', exports.loginPage
	app.get '/login/direct', exports.loginPage
	app.post '/login',
		passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }), exports.loginPost
	app.get '/logout*', exports.logout
	app.post '/api/userAuthentication', exports.authenticationService
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
	app.get '/api/users/:username', exports.ensureAuthenticated, exports.getUsers
	app.get '/login/ssoFailure', exports.ssoFailure


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
		logoText: config.all.client.moduleMenus.logoText

exports.resetPost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/passwordReset'
	
exports.loginPost = (req, res) ->
	console.log "got to login post"
	if req.session.returnTo? && req.session.returnTo != "/"
		res.redirect req.session.returnTo
	else
		if config.all.client.basePath?
			res.redirect config.all.client.basePath
		else
			res.redirect '/'

exports.changePost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/passwordChange'

exports.logout = (req, res) ->
	req.logout =>
		if config.all.server.security.saml.use == true && config.all.server.security.saml.logoutRedirectURL?
			redirectMatch = config.all.server.security.saml.logoutRedirectURL
		else 
			redirectMatch = req.originalUrl.match(/^\/logout\/(.*)\/?$/i)
			if redirectMatch?
				redirectMatch = redirectMatch[1]
			else
				if config.all.client.basePath?
					redirectMatch = config.all.client.basePath
				else
					redirectMatch = '/'
				redirectMatch = "/"
		res.redirect redirectMatch

exports.ssoFailure = (req, res, next) ->
	errorMsg = ""
	error = req.flash('error')
	if error.length > 0
		errorMsg = error[0]
	console.error errorMsg
	res.render 'PermissionDenied',
		title: "Permission denied"
		scripts: []
		message: errorMsg
		logoText: config.all.client.moduleMenus.logoText
		logoLink: config.all.client.moduleMenus.logoTextLink
		permissionDeniedText: "Single Sign-on failure: Permission Denied"

exports.ensureAuthenticated = (req, res, next) ->
	console.log "checking for login for path: "+req.url
	if req.isAuthenticated()
		return next()
	if req.session?
		req.session.returnTo = req.url

	basePath = req.protocol + '://' + req.get('host')
	if req.originalUrl == "/" && config.all.client.basePath?
		redirectURL = "#{basePath}#{config.all.client.basePath}"
	else
		redirectURL = "#{basePath}#{req.originalURL || req.url}"
	res.redirect '/login?redirect_url='+redirectURL

exports.ensureCmpdRegAdmin = (req, res, next) ->
	if req.session?.passport?.user?
		user = req.session.passport.user
	else
		user =
			username: 'anonymous'
			roles: []
	hasRole = exports.checkHasRole(user, config.all.client.roles.cmpdreg.adminRole)
	if !hasRole
		res.statusCode = 401
		res.json 'Unathorized: You have attempted an action that requires CmpdReg Admin permissions! This incident will be reported to your system administrator.'
	else
		return next()

exports.ensureACASAdmin = (req, res, next) ->
	if req.session?.passport?.user?
		user = req.session.passport.user
	else
		user =
			username: 'anonymous'
			roles: []
	hasRole = exports.checkHasRole(user, config.all.client.roles.acas.adminRole)
	if !hasRole
		res.statusCode = 401
		res.json 'Unathorized: You have attempted an action that requires ACAS Admin permissions! This incident will be reported to your system administrator.'
	else
		return next()

exports.checkHasRole = (user, roleConfig, callback) ->
	_ = require 'underscore'
	userRoles = parseUserRoles user
	hasRole = false
	if !roleConfig
		validRoles = []
	else
		validRoles = roleConfig.split(",")
	if validRoles? and validRoles.length > 0
		hasRole = ((_.intersection userRoles, validRoles).length > 0)
	return hasRole

parseUserRoles = (user) ->
	_ = require 'underscore'
	userRoles = []
	if user.roles?
		_.each user.roles, (authorRole) ->
			userRoles.push authorRole.roleEntry.roleName
	return userRoles

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

exports.ensureAuthenticatedService = (req, resp, next) ->
	callback = (results) ->
		console.log results
		if results.indexOf("Success")>=0
			console.log "in authentication service success"
			next()
		else
			console.log "in authentication service fail"
			resp.json
				status: "Fail"

	console.log "ensureAuthenticatedService -- req.body"
	console.log req.body

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
		if results.indexOf("Your password has successfully been changed")>=0
			req.flash 'error','Your new password is set.'
			req.session.returnTo = '/'
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
		user = req.session.passport.user.username
		csUtilities.changeAuth user, req.body.oldPassword, req.body.newPassword, req.body.newPasswordAgain, callback

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
		if csUtilities.getAuthors?
			csUtilities.getAuthors req, resp
		else
			opts = req.query
			exports.getAuthorsInternal opts, (statusCode, response) =>
				resp.json response

exports.getAuthorsInternal = (opts, callback) ->
	csUtilities.getAllAuthors(opts, (statusCode, response) ->
		callback statusCode, response
	)