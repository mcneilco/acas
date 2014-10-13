csUtilities = require '../public/src/conf/CustomerSpecificServerFunctions.js'

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/DNS/codes/v1/Codes/SB_Variant_Construct', loginRoutes.ensureAuthenticated, exports.getMolecularTargetCodes

exports.getMolecularTargetCodes = (req, resp) ->
	if global.specRunnerTestmode
		molecTargetTestJSON = require '../public/javascripts/spec/testFixtures/PrimaryScreenProtocolServiceTestJSON.js'
		console.log molecTargetTestJSON
		resp.end JSON.stringify molecTargetTestJSON.customerMolecularTargetCodeTable
	else
		csUtilities.getDNSCodes(resp, config.all.server.service.external.requestmanager.queueItemTypes.url, req.user)


