exports.setupRoutes = (app, loginRoutes) ->
	app.get '/excelApps', loginRoutes.ensureAuthenticated, exports.excelAppIndex

exports.excelAppIndex = (req, resp) ->
	csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'
	csUtilities.logUsage "Index requested", "#{req.url}", req.body.user

	global.specRunnerTestmode = if global.stubsMode then true else false
	config = require '../conf/compiled/conf.js'
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"

	return resp.render 'ExcelApp',
		title: 'ExcelApps'
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			testMode: global.specRunnerTestmode
			deployMode: global.deployMode
