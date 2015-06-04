exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors

exports.getAuthors = (req, resp) ->
	console.log "getting authors"
	if (req.query.testMode is true) or (global.specRunnerTestmode is true)
		baseEntityServiceTestJSON = require '../public/javascripts/spec/testFixtures/BaseEntityServiceTestJSON.js'
		resp.end JSON.stringify baseEntityServiceTestJSON.authorsList
	else
		csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
		csUtilities.getAuthors resp

