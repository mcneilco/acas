/* To install this Module
1) Add these lines to app.coffee:
# BulkLoadSampleTransfers routes
bulkLoadSampleTransfersRoutes = require './routes/BulkLoadSampleTransfersRoutes.js'
app.post '/api/bulkLoadSampleTransfers', bulkLoadSampleTransfersRoutes.bulkLoadSampleTransfers

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load Sample Transfer Log", mainControllerClassName: "BulkLoadSampleTransfersController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
# For BulkLoadSampleTransfers module
'javascripts/src/BulkLoadSampleTransfers.js'
*/


(function() {
  exports.bulkLoadSampleTransfers = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(600000);
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
