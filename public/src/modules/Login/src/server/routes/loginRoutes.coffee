
exports.setupAPIRoutes = (app) ->
	app.get '/api/users/:username', exports.getUsers

exports.setupRoutes = (app, passport) ->
	app.get '/login', exports.loginPage
	app.post '/login',
		passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }), exports.loginPost
	app.get '/logout', exports.logout
	app.post '/api/userAuthentication', exports.authenticationService
	app.get '/api/users/:username', exports.ensureAuthenticated, exports.getUsers
	app.get '/reset', exports.resetpage
	app.post '/reset',
		exports.resetAuthenticationService,
		exports.resetPost
	app.post '/api/userResetAuthentication', exports.resetAuthenticationService
	app.get '/change', exports.ensureAuthenticated, exports.changePage
	app.post '/change',
		exports.changeAuthenticationService,
		exports.changePost
	app.post '/api/userChangeAuthentication', exports.changeAuthenticationService

csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'

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

exports.resetPost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/reset'
	
exports.loginPost = (req, res) ->
	console.log "got to login post"
#	res.redirect '/'
	res.redirect req.session.returnTo

exports.changePost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/change'

exports.logout = (req, res) ->
	req.logout()
	res.redirect '/'

exports.ensureAuthenticated = (req, res, next) ->
	console.log "checking for login for path: "+req.url
	if req.isAuthenticated()
		return next()
	if req.session?
		req.session.returnTo = req.url
	res.redirect '/login'


exports.getUsers = (req, resp) ->
	console.log "ghet users in route file"
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
		if results.indexOf("Your new password is sent to your email address")>=0
			req.flash 'error','Your new password is sent to your email address'
			resp.redirect '/reset'
		else
			req.flash 'error','Invalid Email or Username'
			resp.redirect '/reset'

	if global.specRunnerTestmode
		callback("Success")
	else
		csUtilities.resetAuth req.body.email, callback

exports.changeAuthenticationService = (req, resp) ->
	callback = (results) ->
		console.log results
		if results.indexOf("You password has been successfully been changed")>=0
			req.flash 'error','Your new password is set'
			resp.redirect '/login'
		else
			req.flash 'error','Invalid password or new password does not match'
			resp.redirect '/change'

	if global.specRunnerTestmode
		callback("Success")
	else
		csUtilities.changeAuth req.body.user, req.body.oldPassword,req.body.newPassword,req.body.newPasswordAgain, callback

exports.resetpage = (req, res) ->
	user = null
	if req.user?
		user = req.user
	console.log req.flash
	errorMsg = ""
	error = req.flash('error')
	if error.length > 0
		errorMsg = error[0]
	res.render 'reset',
		title: "ACAS reset"
		scripts: []
		user: user
		message: errorMsg

exports.changePage = (req, res) ->
	user = null
	if req.user?
		user = req.user
	if user != null
		errorMsg = ""
		error = req.flash('error')
		if error.length > 0
			errorMsg = error[0]

		res.render 'change',
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