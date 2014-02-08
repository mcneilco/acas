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
	app.get '/logout', exports.logout
	app.post '/api/userAuthentication', exports.authenticationService
	app.get '/api/users/:username', exports.getUsers

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

exports.loginPost = (req, res) ->
	res.redirect '/'

exports.logout = (req, res) ->
	req.logout()
	res.redirect '/'

exports.ensureAuthenticated = (req, res, next) ->
	if req.isAuthenticated()
		return next()
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

