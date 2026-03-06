config = require '../conf/compiled/conf.js'
serverUtilityFunctions = require './ServerUtilityFunctions.js'
request = serverUtilityFunctions.requestAdapter

exports.setupAPIRoutes = (app, loginRoutes) ->
	app.get '/api/curves/stubs/:exptCode', exports.getCurveStubs
	app.post '/api/curves/detail', exports.getCurveDetailCurveIds
	app.get '/api/curve/detail/:id', exports.getCurveDetail
	app.get  '/api/curve/render/*', exports.renderCurve
	app.post  '/api/curve/render/*', exports.renderCurve

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/curves/stubs/:exptCode', loginRoutes.ensureAuthenticated, exports.getCurveStubs
	app.get '/api/curve/detail/:id', loginRoutes.ensureAuthenticated, exports.getCurveDetail
	app.post '/api/curves/detail', loginRoutes.ensureAuthenticated, exports.getCurveDetailCurveIds
	app.put '/api/curve/detail/:id', loginRoutes.ensureAuthenticated, exports.updateCurveDetail
	app.post '/api/curve/stub/:id', loginRoutes.ensureAuthenticated, exports.updateCurveStub
	app.get  '/api/curve/render/*', loginRoutes.ensureAuthenticated, exports.renderCurve
	app.post  '/api/curve/render/*', loginRoutes.ensureAuthenticated, exports.renderCurve
	app.get '/curveCurator/*', loginRoutes.ensureAuthenticated, exports.curveCuratorIndex

exports.getCurveStubs = (req, resp) ->
	if global.specRunnerTestmode
		if req.params.exptCode == "EXPT-ERROR"
			resp.send "Experiment code not found", 404
		else
			curveCuratorTestData = require '../public/spec/testFixtures/curveCuratorTestFixtures.js'
			resp.end JSON.stringify curveCuratorTestData.curveCuratorThumbs
	else
		baseurl = config.all.client.service.rapache.fullpath+"/experimentcode/curveids/?experimentcode="
		request(
			method: 'GET'
			url: baseurl+req.params.exptCode
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else if !error && response.statusCode == 404
				resp.send "Experiment code not found", 404
			else if !error && response.statusCode == 400
				resp.send json, 400
			else
				console.log 'got ajax error trying to retrieve curve stubs'
				console.log error
				console.log json
				console.log response
				resp.end 'error'
		)

exports.getCurveDetail = (req, resp) ->
	if global.specRunnerTestmode
		if req.params.id == "CURVE-ERROR"
			resp.send "Curve Detail not found", 404
		else
			curveCuratorTestData = require '../public/src/spec/testFixtures/curveCuratorTestFixtures.js'
			resp.end JSON.stringify curveCuratorTestData.curveDetail
	else
		baseurl = config.all.client.service.rapache.fullpath+"/curve/detail/?id="
		request(
			method: 'GET'
			url: baseurl+req.params.id
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				console.log JSON.stringify json
				resp.end JSON.stringify json
			else if !error && response.statusCode == 404
				resp.send "Curve Detail not found", 404
			else
				console.log 'got ajax error trying to retrieve curve detail'
				console.log error
				console.log json
				console.log response
				resp.send 'got ajax error trying to retrieve curve detail', 500
		)

exports.getCurveDetailCurveIds = (req, resp) ->
	if global.specRunnerTestmode
		curveCuratorTestData = require '../public/src/spec/testFixtures/curveCuratorTestFixtures.js'
		resp.end JSON.stringify curveCuratorTestData.curveDetail
	else
		baseurl = config.all.client.service.rapache.fullpath+"/curve/detail?"+req._parsedUrl.query
		console.log JSON.stringify req.body
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else if !error && response.statusCode == 500
				resp.send "Could not get curve details", 500
			else
				console.log 'got ajax error trying to get curve details'
				console.log error
				console.log json
				console.log response
				resp.send 'got ajax error trying to get curve details', 500
		)

exports.updateCurveUserFlag = (req, resp) ->
	if global.specRunnerTestmode
		curveCuratorTestData = require '../public/src/spec/testFixtures/curveCuratorTestFixtures.js'
		resp.end JSON.stringify curveCuratorTestData.curveDetail
	else
		baseurl = config.all.client.service.rapache.fullpath+"/curve/flag/user"
		console.log JSON.stringify req.body
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else if !error && response.statusCode == 500
				resp.send "Could not update curve user flag", 500
			else
				console.log 'got ajax error trying to update user flag'
				console.log error
				console.log json
				console.log response
				resp.send 'got ajax error trying to update user flag', 500
		)

exports.updateCurveDetail = (req, resp) ->
	req.connection.setTimeout 6000000
	if global.specRunnerTestmode
		curveCuratorTestData = require '../public/src/spec/testFixtures/curveCuratorTestFixtures.js'
		resp.end JSON.stringify curveCuratorTestData.curveDetail
	else
		baseurl = config.all.client.service.rapache.fullpath+"/curve/detail/"
		console.log JSON.stringify req.body
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify req.body
			json: true
			timeout: 6000000
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else if !error && response.statusCode == 500
				resp.send "Could not update curve", 500
			else
				console.log 'got ajax error trying to refit curve'
				console.log error
				console.log response
				resp.send 'got ajax error trying to refit curve', 500
		)

exports.updateCurveStub = (req, resp) ->
	if global.specRunnerTestmode
		response = req.body
		req.body.curveAttributes.flagUser = req.body.flagUser
		resp.end JSON.stringify req.body
	else
		baseurl = config.all.client.service.rapache.fullpath+"/curve/stub/"
		console.log JSON.stringify req.body
		request(
			method: 'POST'
			url: baseurl
			body: JSON.stringify req.body
			json: true
		, (error, response, json) =>
			if !error && response.statusCode == 200
				resp.end JSON.stringify json
			else if !error && response.statusCode == 500
				resp.send "Could not update curve", 500
			else
				console.log 'got ajax error trying to refit curve'
				console.log error
				console.log json
				console.log response
				resp.send 'got ajax error trying to refit curve', 500
		)

exports.curveCuratorIndex = (req, resp) ->
	global.specRunnerTestmode = if global.stubsMode then true else false
	scriptPaths = require './RequiredClientScripts.js'
	scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts)
	if config.all.client.require.login
		loginUserName = req.user.username
		loginUser = req.user
	else
		loginUserName = "nouser"
		loginUser =
			id: 0,
			username: "nouser",
			email: "nouser@nowhere.com",
			firstName: "no",
			lastName: "user"

	return resp.render 'CurveCurator',
		title: 'Curve Curator'
		scripts: scriptsToLoad
		AppLaunchParams:
			loginUserName: loginUserName
			loginUser: loginUser
			testMode: global.specRunnerTestmode
			moduleLaunchParams: if moduleLaunchParams? then moduleLaunchParams else null
			deployMode: global.deployMode

exports.renderCurve = (req, resp) ->
	redirectQuery = req._parsedUrl.query
	rapacheCall = config.all.client.service.rapache.fullpath + '/curve/render/dr/?' + redirectQuery
	if req.method == 'GET'
		req.pipe(request(rapacheCall)).pipe resp
	else
		req.pipe(request[req.method.toLowerCase()](
			url: rapacheCall
			json: req.body)).pipe resp
