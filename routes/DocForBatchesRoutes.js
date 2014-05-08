
/* To install this Module
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Annotate Batches with File", mainControllerClassName: "DocForBatchesController"}
 */

(function() {
  var fixturesData;

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/docForBatches/*', loginRoutes.ensureAuthenticated, exports.docForBatchesIndex);
    app.get('/docForBatches', loginRoutes.ensureAuthenticated, exports.docForBatchesIndex);
    app.get('/api/docForBatches/:id', loginRoutes.ensureAuthenticated, exports.getDocForBatches);
    return app.post('/api/docForBatches', loginRoutes.ensureAuthenticated, exports.saveDocForBatches);
  };

  fixturesData = require('../public/src/modules/DocForBatches/spec/testFixtures/testJSON.js');

  exports.getDocForBatches = function(request, response) {
    if (request.params.id === "1") {
      return response.end(JSON.stringify(fixturesData.docForBatches));
    } else {
      return response.end(JSON.stringify(fixturesData.docForBatchesWithURl));
    }
  };

  exports.saveDocForBatches = function(request, response) {
    var serverUtilityFunctions;
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DocForBatches/src/server/DocForBatches_Stub.R", "saveDocForBatches", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/DocForBatches/src/server/DocForBatches.R", "saveDocForBatches", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
