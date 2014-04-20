/* To install this Module
1) Add these lines to app.coffee:
	# GenericDataParser routes
	genericDataParserRoutes = require './public/src/modules/GenericDataParser/src/server/routes/GenericDataParserRoutes.js'
	genericDataParserRoutes.setupRoutes(app)

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Load From Generic Format", mainControllerClassName: "GenericDataParserController"}
*/


(function() {
  exports.setupRoutes = function(app) {
    return app.post('/api/genericDataParser', exports.parseGenericData);
  };

  exports.parseGenericData = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/GenericDataParser/src/server/GenericDataParserStub.R", "parseGenericData", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/GenericDataParser/src/server/generic_data_parser.R", "parseGenericData", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

}).call(this);
