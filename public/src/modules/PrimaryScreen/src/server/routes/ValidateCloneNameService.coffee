exports.setupAPIRoutes = (app) ->
	app.get '/api/cloneValidation/:name', exports.cloneValidation

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/cloneValidation/:name', loginRoutes.ensureAuthenticated, exports.cloneValidation

csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'

exports.cloneValidation = (req, resp) ->
	console.log "clone validation"
	console.log req.params.name
	if global.specRunnerTestmode
		psProtocolServiceTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenProtocolServiceTestJSON.js'
		if req.params.name is "fake"
			resp.json []
		else
			resp.json psProtocolServiceTestJSON.successfulCloneValidation
	else
		csUtilities.validateCloneAndGetTarget req, resp

