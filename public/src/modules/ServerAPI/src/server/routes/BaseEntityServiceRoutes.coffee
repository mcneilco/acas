exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors

exports.getAuthors = (req, resp) ->
	console.log "getting authors"
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		baseEntityServiceTestJSON = require '../public/javascripts/spec/testFixtures/BaseEntityServiceTestJSON.js'
		resp.end JSON.stringify baseEntityServiceTestJSON.authorsList
	else
		config = require '../conf/compiled/conf.js'
		serverUtilityFunctions = require './ServerUtilityFunctions.js'
		baseurl = config.all.client.service.persistence.fullpath+"authors/codeTable"
		console.log baseurl
		serverUtilityFunctions.getFromACASServer(baseurl, resp)
