/* To install this Module
1) add to app.coffee
# BulkLoadSampleTransfers routes
	bulkLoadSampleTransfersRoutes = require './public/src/modules/BulkLoadSampleTransfers/src/server/routes/BulkLoadSampleTransfersRoutes.js'
	bulkLoadSampleTransfersRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Sample Transfer Log", mainControllerClassName: "BulkLoadSampleTransfersController"}
*/


(function() {
  exports.setupRoutes = function(app) {
    return app.post('/api/bulkLoadSampleTransfers', exports.bulkLoadSampleTransfers);
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
