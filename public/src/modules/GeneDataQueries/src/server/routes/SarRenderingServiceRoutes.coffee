exports.setupAPIRoutes = (app) ->
	app.get '/api/sarRender/geneId/:referenceCode', exports.getGeneRenderRoute
	app.get '/api/sarRender/cmpdRegBatch/:referenceCode', exports.getBatchRenderRoute
	app.post '/api/sarRender/render', exports.renderAnyRoute
	app.get '/api/sarRender/title/:displayName', exports.getTitleRoute


exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/sarRender/geneId/:referenceCode', loginRoutes.ensureAuthenticated, exports.getGeneRenderRoute
	app.get '/api/sarRender/cmpdRegBatch/:referenceCode', loginRoutes.ensureAuthenticated, exports.getBatchRenderRoute
	app.post '/api/sarRender/render', loginRoutes.ensureAuthenticated, exports.renderAnyRoute
	app.get '/api/sarRender/title/:displayName', loginRoutes.ensureAuthenticated, exports.getTitleRoute

_ = require 'underscore'
request = require 'request'
configuredEntityTypes = require '../conf/ConfiguredEntityTypes.js'
sarRenderConf = require '../conf/SarRenderConf.js'
codeService = require '../routes/PreferredEntityCodeService.js'
config = require '../conf/compiled/conf.js'


##############################################
# GENE ID
##############################################

exports.getGeneRenderRoute = (req,resp) ->
	console.log "in get gene route"
	referenceCode = req.params.referenceCode
	exports.getGeneRender referenceCode, (json) ->
		resp.json json

exports.getGeneRender = (referenceCode, callback) ->
	requestData =
		displayName: "Gene ID"
		requests:[
			{requestName: referenceCode}
		]
	csv = false
	codeService.pickBestLabels requestData, csv, (response) =>
		bestLabel = response.results[0].bestLabel
		console.log bestLabel
		callback html:'<a href="http://www.ncbi.nlm.nih.gov/gene/'+bestLabel+'"  target="_blank" align="center">'+bestLabel+'</a>'


##############################################
# CORPORATE BATCH CODE
##############################################

exports.getBatchRenderRoute = (req, resp) ->
	console.log "in get cmpd reg batch code route"
	referenceCode = req.params.referenceCode
	exports.getBatchRender referenceCode, (json) ->
		resp.json json

exports.getBatchRender = (referenceCode, callback) ->
	htmlReturn = '<img src="' + config.all.client.service.external.structure.url + referenceCode + '">'
	htmlReturn += ' <p align="center">' + referenceCode + '</p>'
	callback html: htmlReturn


##############################################
# GET COLUMN TITLE
##############################################
exports.getTitleRoute = (req, resp) ->
	displayName = req.params.displayName
	exports.getTitle displayName, (json) ->
		resp.json json

exports.getTitle = (displayName, callback) ->
	callback title: sarRenderConf.sarRender[displayName].title

##############################################
# POST ROUTE FOR ANY ENTITY
##############################################

exports.renderAnyRoute = (req, resp) ->
	# {
	#    displayName: (optional)
	#    referenceCode:
	# }
	requestData = {}
	if req.body.displayName?
		withDisplayName = true
		requestData.displayName = req.body.displayName
	else
		withDisplayName = false
	console.log "reference Code is " + req.body.referenceCode
	requestData.referenceCode = req.body.referenceCode

	exports.renderAny requestData, withDisplayName, (json) ->
		resp.json json

exports.renderAny = (requestData, withDisplayName, callback) ->
	if withDisplayName
		displayName = requestData.displayName
		sarInfo = sarRenderConf.sarRender[displayName]
		request sarInfo.route + requestData.referenceCode, (error, response, body) =>
			console.log body
			callback JSON.parse(body)

	#need to search to find displayName
	else
		requestText =
			requestText:requestData.referenceCode
		codeService.searchForEntities requestText, (response) ->
			if response.results.length != 1
				callback html: requestData.referenceCode
			displayName = response.results[0].displayName
			sarInfo = sarRenderConf.sarRender[displayName]
			request sarInfo.route + requestData.referenceCode, (error, response, body) =>
				console.log body
				callback JSON.parse(body)
