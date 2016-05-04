exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/genericSearch/projects/:searchTerm', exports.genericProjectSearch

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/genericSearch/projects/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericProjectSearch


exports.genericProjectSearch = (req, resp) ->
	console.log "generic project search"
	console.log req.query.testMode
	console.log global.specRunnerTestmode
	if req.query.testMode is true or global.specRunnerTestmode is true
		resp.end JSON.stringify "Stubs mode not implemented yet"
	else
		config = require '../conf/compiled/conf.js'
		console.log "search req"
		userNameParam = "userName=" + req.user.username
		searchTerm = "q=" + req.params.searchTerm

		searchParams = ""
		searchParams += userNameParam + "&"
		searchParams += searchTerm

		baseurl = config.all.client.service.persistence.fullpath+"lsthings/searchProjects?"+searchParams
		console.log "generic project search baseurl"
		console.log baseurl
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, resp)
