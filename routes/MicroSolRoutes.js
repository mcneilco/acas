/* To install this Module
1) Add these lines to app.coffee:
# MicroSolParser routes
microSolRoutes = require './routes/MicroSolRoutes.js'
app.post '/api/microSolParser', microSolRoutes.parseMicroSolData

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
		{isHeader: false, menuName: "Load Micro Solubility Experiment", mainControllerClassName: "MicroSolController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
	# For MicroSol module
	'/javascripts/src/MicroSol.js'

4) Add these lines to routes/index.coffee under specScripts = [
		# For MicroSol Parser module
		'javascripts/spec/testFixtures/MicroSolTestJSON.js'
		'javascripts/spec/MicroSolSpec.js'
		'javascripts/spec/MicroSolServiceSpec.js'

5) add these lines to layout.jade
  // for microSol module
  include ../public/src/modules/DNSMicroSol/src/client/MicroSolView.html
*/


(function() {
  exports.parseMicroSolData = function(request, response) {
    var serverUtilityFunctions;

    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DNSMicroSol/src/server/MicroSolStub.R", "parseMicroSolData", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DNSMicroSol/src/server/MicroSol.R", "parseMicroSolData", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
