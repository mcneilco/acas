exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/about', exports.getAbout

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/about', loginRoutes.ensureAuthenticated, exports.getAbout

config = require '../conf/compiled/conf.js'

exports.getAbout = (req, resp) ->
	resp.json(config.all.client.about)
