exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/components/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericComponentsSearch

exports.genericComponentsSearch = (req, res) ->
	if global.specRunnerTestmode
		componentBrowserServiceTestJSON = require '../public/javascripts/spec/testFixtures/ComponentBrowserServiceTestJSON.js'
		if req.params.searchTerm == "no-match"
			emptyResponse = []
			res.end JSON.stringify emptyResponse
		else
			res.end JSON.stringify [componentBrowserServiceTestJSON.cationicBlockBatch]
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"lsthings/search?lsType=batch&q="+req.params.searchTerm
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		serverUtilityFunctions.getFromACASServer(baseurl, res)
