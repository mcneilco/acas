
/*
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Sample Transfer Log", mainControllerClassName: "BulkLoadSampleTransfersController"}
 */

(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/bulkLoadSampleTransfers', loginRoutes.ensureAuthenticated, exports.bulkLoadSampleTransfers);
  };

  exports.bulkLoadSampleTransfers = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(6000000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/BulkLoadSampleTransfers/src/server/BulkLoadSampleTransfersStub.R", "bulkLoadSampleTransfers", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/BulkLoadSampleTransfers/src/server/BulkLoadSampleTransfers.R", "bulkLoadSampleTransfers", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
