exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/about', exports.getAbout

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/about', loginRoutes.ensureAuthenticated, exports.getAbout

config = require '../conf/compiled/conf.js'

exports.getAbout = (req, resp) ->
	about = 
			acas:
				version: config.all.client.version,
				buildTime: config.all.client.buildTime,
				revision: config.all.client.revision
	resp.json(about)
