### To install this Module
1) Add these lines to app.coffee:
# MetStabParser routes
metStabRoutes = require './routes/MetStabRoutes.js'
app.post '/api/metStabParser', metStabRoutes.parseMetStabData

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
		{isHeader: false, menuName: "Load Met. Stab. Experiment", mainControllerClassName: "MetStabController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
	# For MetStab module
	'/javascripts/src/MetStab.js'

4) Add these lines to routes/index.coffee under specScripts = [
		# For MetStab Parser module
		'javascripts/spec/testFixtures/MetStabTestJSON.js'
		'javascripts/spec/MetStabSpec.js'
		'javascripts/spec/MetStabServiceSpec.js'

5) add these lines to layout.jade
  // for metStab module
  include ../public/src/modules/DNSMetStab/src/client/MetStabView.html
###

exports.parseMetStabData = (request, response)  ->
	request.connection.setTimeout 600000
	serverUtilityFunctions = require './ServerUtilityFunctions.js'

	response.writeHead(200, {'Content-Type': 'application/json'});
	if global.specRunnerTestmode
		console.log "test mode: "+global.specRunnerTestmode
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/DNSMetStab/src/server/MetStabStub.R",
			"parseMetStabData",
		(rReturn) ->
			response.end rReturn
		)
	else
		logDnsUsage "MetStab parser service about to call R", "dryRunMode="+request.body.dryRunMode, request.body.user
		serverUtilityFunctions.runRFunction(
			request,
			"public/src/modules/DNSMetStab/src/server/MetStab.R",
			"parseMetStabData",
		(rReturn) ->
			response.end rReturn
			logDnsUsage "MetStab parser service returned", "dryRunMode="+request.body.dryRunMode, request.body.user
		)




