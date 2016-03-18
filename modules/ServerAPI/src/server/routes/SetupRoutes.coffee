exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/setup/:typeOrKind', exports.setupTypeOrKind

exports.setupTypeOrKind = (req, resp) ->
	console.log "setupTypeOrKind"
	if req.query.testMode or global.specRunnerTestmode
		resp.end JSON.stringify "set up type or kind"
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.persistence.fullpath+"setup/"+req.params.typeOrKind
		request = require 'request'
		request(
			method: 'POST'
			url: baseurl
			body: req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 201
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to setup type/kind'
				console.log error
				console.log json
				console.log response

		)

