exports.setupAPIRoutes = (app) ->
	app.get '/api/dataDict/:kind', exports.getDataDictValues

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/dataDict/:kind', loginRoutes.ensureAuthenticated, exports.getDataDictValues

exports.getDataDictValues = (req, resp) ->
	if global.specRunnerTestmode
		dataDictServiceTestJSON = require '../public/javascripts/spec/testFixtures/dataDictServiceTestJSON.js'
		resp.end JSON.stringify dataDictServiceTestJSON.dataDictValues[req.params.kind]
	else
		console.log 'not implemented yet'
