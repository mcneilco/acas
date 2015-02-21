exports.setupAPIRoutes = (app) ->
	app.get '/api/configuredEntityTypes', exports.getConfiguredEntityTypes

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypes

configuredEntityTypes = require '../conf/ConfiguredEntityTypes.js'

exports.getConfiguredEntityTypes = (req, resp) ->
	console.log req.query
	if req.query.asCodes?
		codes = for et in configuredEntityTypes.entityTypes
			code: et.type+" "+et.kind #Should we store this explicitly in teh config?
			name: et.displayName
			ignored: false
		resp.json codes
	else
		resp.json configuredEntityTypes.entityTypes