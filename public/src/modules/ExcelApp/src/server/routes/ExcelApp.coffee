exports.setupRoutes = (app, loginRoutes) ->
	app.get '/excelApp', loginRoutes.ensureAuthenticated, exports.excelAppIndex

exports.excelAppIndex = (req, resp) ->
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
