(function() {
  exports.setupRoutes = function(app) {
    return app.post('/api/doseResponseCurveFit', exports.fitDoseResponse);
  };

  exports.fitDoseResponse = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/CurveAnalysis/src/server/DoseResponseCurveFitStub.R", "fitDoseResponse", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/CurveAnalysis/src/server/DoseResponseCurveFit.R", "fitDoseResponse", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
