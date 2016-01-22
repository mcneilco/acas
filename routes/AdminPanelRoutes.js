
/* To install this Module
1) Add these lines to app.coffee:
	 * GenericDataParser routes
	genericDataParserRoutes = require './public/src/modules/GenericDataParser/src/server/routes/GenericDataParserRoutes.js'
	genericDataParserRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load From Generic Format", mainControllerClassName: "GenericDataParserController"}
 */

(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/adminPanel', loginRoutes.ensureAuthenticated, exports.parseAdminPanel);
  };

  exports.parseAdminPanel = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(6000000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/EchoPlateFile/src/server/AdminPanelStub.R", "parseAdminPanel", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/EchoPlateFile/src/server/adminPanel.R", "external.parseCreateFiles", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
