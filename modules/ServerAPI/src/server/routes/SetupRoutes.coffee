exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/setup/:typeOrKind', exports.setupTypeOrKind

exports.setupTypeOrKindInternal = (typeOrKind, roles, callback) ->
	console.log "setupTypeOrKind"
	console.log typeOrKind
	console.log roles
	config = require '../conf/compiled/conf.js'
	baseurl = config.all.client.service.persistence.fullpath+"setup/"+typeOrKind
	request = require 'request'
	request(
		method: 'POST'
		url: baseurl
		body: roles
		json: true
	, (error, response, json) =>
		callback json, response.statusCode
	)


exports.setupTypeOrKind = (req, resp) ->
	exports.setupTypeOrKindInternal req.params.typeOrKind, req.body, (json, statusCode) =>
		resp.status(statusCode).json json
