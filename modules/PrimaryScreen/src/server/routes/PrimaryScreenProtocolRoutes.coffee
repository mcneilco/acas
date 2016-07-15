csUtilities = require '../src/javascripts/ServerAPI/CustomerSpecificServerFunctions.js'

exports.setupAPIRoutes = (app) ->
	app.get '/api/customerMolecularTargetCodeTable', exports.getCustomerMolecularTargetCodes

exports.setupRoutes = (app, loginRoutes) ->
	app.get '/api/customerMolecularTargetCodeTable', loginRoutes.ensureAuthenticated, exports.getCustomerMolecularTargetCodes

exports.getCustomerMolecularTargetCodes = (req, resp) ->
	if global.specRunnerTestmode
		molecTargetTestJSON = require '../public/javascripts/spec/PrimaryScreen/testFixtures/PrimaryScreenProtocolServiceTestJSON.js'
		resp.end JSON.stringify molecTargetTestJSON.customerMolecularTargetCodeTable
	else
		csUtilities.getCustomerMolecularTargetCodes resp



