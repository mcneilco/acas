/* To install this Module

Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Containers From SDF", mainControllerClassName: "BulkLoadContainersFromSDFController"}
*/


(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/bulkLoadContainersFromSDF', loginRoutes.ensureAuthenticated, exports.bulkLoadContainersFromSDF);
  };

  exports.bulkLoadContainersFromSDF = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(6000000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDFStub.R", "bulkLoadContainersFromSDF", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDF.R", "bulkLoadContainersFromSDF", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
