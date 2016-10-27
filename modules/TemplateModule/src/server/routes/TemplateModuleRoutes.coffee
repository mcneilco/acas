exports.setupAPIRoutes = (app) ->
	app.get '/api/reagentReg/hazardCatagories', exports.gethazardCatagories
	app.get '/api/reagentReg/reagents/codename', exports.getReagentByCodename

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/reagentReg/hazardCatagories', loginRoutes.ensureAuthenticated, exports.gethazardCatagories
	app.get '/api/reagentReg/reagents/codename', loginRoutes.ensureAuthenticated, exports.getReagentByCodename

exports.gethazardCatagories = (req, resp) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		ReagentRegtestJSON = require '../public/javascripts/spec/testFixtures/ReagentRegtestJSON.js'
		resp.end JSON.stringify ReagentRegtestJSON.hazardCategories
	else
		console.log "hazard categories route not implented"

exports.getReagentByCodename = (req, resp) ->
	csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'
	if global.specRunnerTestmode
		ReagentRegtestJSON = require '../public/javascripts/spec/testFixtures/ReagentRegtestJSON.js'
		resp.end JSON.stringify ReagentRegtestJSON.savedReagent
	else
		console.log "hazard categories route not implented"
