
/* To install this Module
1) Add these lines to app.coffee:
 * RunPrimaryAnalysisRoutes routes
runPrimaryAnalysisRoutes = require './routes/RunPrimaryAnalysisRoutes.js'
app.post '/api/primaryAnalysis/runPrimaryAnalysis', runPrimaryAnalysisRoutes.runPrimaryAnalysis

2) Add to index.coffee
 under applicationScripts:
  	 *Primary Screen module
	'javascripts/src/PrimaryScreenExperiment.js'

  under specScripts
 *Primary Screen module
'javascripts/spec/RunPrimaryScreenAnalysisServiceSpec.js'
'javascripts/spec/PrimaryScreenExperimentSpec.js'

3) in layout.jade
  // for PrimaryScreen module
 include ../public/src/modules/PrimaryScreen/src/client/PrimaryScreenExperiment.html
  // for serverAPI module
  include ../public/src/modules/serverAPI/src/client/Experiment.html
 */

(function() {
  exports.setupRoutes = function(app) {
    return app.post('/api/primaryAnalysis/runPrimaryAnalysis', exports.runPrimaryAnalysis);
  };

  exports.runPrimaryAnalysis = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(1800000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    console.log(request.body);
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/PrimaryScreen/src/server/PrimaryAnalysisStub.R", "runPrimaryAnalysis", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R", "runPrimaryAnalysis", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
