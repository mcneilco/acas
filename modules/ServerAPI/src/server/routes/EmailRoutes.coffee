exports.setupAPIRoutes = (app) ->
	app.post '/api/sendMail', exports.sendMail

exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/sendMail', loginRoutes.ensureAuthenticated, exports.sendMail

exports.sendMail = (req, resp) ->
	serverUtilityFunctions = require './ServerUtilityFunctions.js'
	request = serverUtilityFunctions.requestAdapter
	config = require '../conf/compiled/conf.js'
	redirectQuery = req._parsedUrl.query
	rapacheCall = config.all.client.service.rapache.fullpath + '/sendMail?' + redirectQuery
	req.pipe(request(rapacheCall)).pipe(resp)
