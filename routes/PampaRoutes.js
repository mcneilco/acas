/* To install this Module
1) Add these lines to app.coffee:
# PampaParser routes
pampaRoutes = require './routes/PampaRoutes.js'
app.post '/api/pampaParser', pampaRoutes.parsePampaData

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
		{isHeader: false, menuName: "Load PAMPA Experiment", mainControllerClassName: "PampaController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
	# For Pampa module
	'/javascripts/src/Pampa.js'

4) Add these lines to routes/index.coffee under specScripts = [
		# For Pampa Parser module
		'javascripts/spec/testFixtures/PampaTestJSON.js'
		'javascripts/spec/PampaSpec.js'
		'javascripts/spec/PampaServiceSpec.js'

5) add these lines to layout.jade
  // for pampa module
  include ../public/src/modules/DNSPampa/src/client/PampaView.html
*/


(function() {
  exports.parsePampaData = function(request, response) {
    var serverUtilityFunctions;

    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DNSPampa/src/server/PampaStub.R", "parsePampaData", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      logDnsUsage("Pampa parser service about to call R", "dryRunMode=" + request.body.dryRunMode, request.body.user);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DNSPampa/src/server/Pampa.R", "parsePampaData", function(rReturn) {
        response.end(rReturn);
        return logDnsUsage("Pampa parser service returned", "dryRunMode=" + request.body.dryRunMode, request.body.user);
      });
    }
  };

}).call(this);
