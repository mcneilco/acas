
exports.setupRoutes = (app, loginRoutes) ->
	app.get '/curveCurator/*', loginRoutes.ensureAuthenticated, exports.curveCuratorIndex
	app.get '/api/curves/stub/:exptCode', loginRoutes.ensureAuthenticated, exports.getCurveStubs


requiredScripts = [
	'/src/lib/jquery.min.js'
	'/src/lib/json2.js'
	'/src/lib/underscore.js'
	'/src/lib/backbone-min.js'
	'/src/lib/bootstrap/bootstrap.min.js'
	'/src/lib/bootstrap/bootstrap-tooltip.js'
	'/src/lib/jqueryFileUpload/js/vendor/jquery.ui.widget.js'
	'/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js'
	'/src/lib/bootstrap/bootstrap.min.js'
	'/src/lib/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js'
]

applicationScripts = [
	'/src/conf/conf.js'
	#Curve Analysis module
	'/javascripts/src/CurveCurator.js'
	'/javascripts/src/CurveCuratorAppController.js'
]

exports.getCurveStubs = (req, resp) ->
	if global.specRunnerTestmode
		console.log req.params
		curveCuratorTestData = require '../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js'
		resp.end JSON.stringify curveCuratorTestData.curveStubs
	else
		config = require '../conf/compiled/conf.js'
		baseurl = config.all.client.service.rapache.fullpath+"/experimentcode/curvids/?experimentcode="
		request = require 'request'
		request(
			method: 'GET'
			url: baseurl+req.params.exptCode
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else
				console.log 'got ajax error trying to save new experiment'
				console.log error
				console.log json
				console.log response
		)


exports.curveCuratorIndex = (request, response) ->
	global.specRunnerTestmode = false
	scriptsToLoad = requiredScripts.concat applicationScripts

	return response.render 'CurveCurator',
		title: 'Curve Curator'
		scripts: scriptsToLoad
		appParams:
			exampleParam: null

