(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/primaryAnalysis/runPrimaryAnalysis', loginRoutes.ensureAuthenticated, exports.runPrimaryAnalysis);
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
