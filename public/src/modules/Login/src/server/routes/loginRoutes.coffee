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

###
exports.setupRoutes = (app, passport) ->
	app.get '/login', exports.loginPage
	app.post '/login',
		passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }),
		exports.loginPost
#	app.post '/login', passport.authenticate 'local',
#		failureRedirect: '/login'
#		failureFlash: true
#		successReturnToOrRedirect: session.returnTo
	app.get '/logout', exports.logout
	app.post '/api/userAuthentication', exports.authenticationService
	app.get '/api/users/:username', exports.getUsers
	app.get '/reset', exports.resetpage
	app.post '/reset',
		exports.resetAuthenticationService,
		exports.resetPost
	app.post '/api/userResetAuthentication', exports.resetAuthenticationService
	app.get '/change', exports.changePage
	app.post '/change',
		exports.changeAuthenticationService,
		exports.changePost
	app.post '/api/userChangeAuthentication', exports.changeAuthenticationService

csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'

exports.loginPage = (req, res) ->
	req.session.returnTo = '/'
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
	console.log req.session
#	res.redirect '/'
	res.redirect req.session.returnTo

exports.resetPost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/reset'

exports.changePost = (req, res) ->
	console.log req.session
	#	res.redirect '/'
	res.redirect '/change'


exports.logout = (req, res) ->
	req.logout()
	res.redirect '/'

exports.ensureAuthenticated = (req, res, next) ->
	if req.isAuthenticated()
		return next()
	req.session.returnTo = req.url
	res.redirect '/login'

exports.getUsers = (req, resp) ->
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
			resp.json
				status: "Success"
		else
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
		if results.indexOf("Success")>=0
			resp.json
				status: "Success"
		else
			resp.redirect '/change'

	if global.specRunnerTestmode
		callback("Success")
	else
		csUtilities.changeAuth req.body.user, req.body.oldPassword,req.body.oldPassword,req.body.oldPassword, callback


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

	errorMsg = ""
	error = req.flash('error')
	if error.length > 0
		errorMsg = error[0]

	res.render 'change',
		title: "ACAS reset"
		scripts: []
		user: user
		message: errorMsg