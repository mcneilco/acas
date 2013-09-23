/* To install this Module
1) Add these lines to app.coffee:
# FullPKParser routes
	fullPKParserRoutes = require './routes/FullPKParserRoutes.js'
	app.post '/api/fullPKParser', fullPKParserRoutes.parseFullPKData

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
		{isHeader: false, menuName: "Load Full PK Experiment", mainControllerClassName: "FullPKParserController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
	# For FullPK module
	'/javascripts/src/FullPK.js'

4) Add these lines to routes/index.coffee under specScripts = [
		# For Full PK Parser module
		'javascripts/spec/testFixtures/FullPKTestJSON.js'
		'javascripts/spec/FullPKSpec.js'
		'javascripts/spec/FullPKParserServiceSpec.js'

5) add these lines to layout.jade
  // for fullPK module
  include ../public/src/modules/FullPK/src/client/FullPKView.html
*/


(function() {
  exports.parseFullPKData = function(request, response) {
    var serverUtilityFunctions;

    request.connection.setTimeout(600000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      console.log("test mode: " + global.specRunnerTestmode);
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/FullPK/src/server/fullPKStub.R", "parseFullPKData", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/FullPK/src/server/fullPK.R", "parseFullPKData", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

  app.post('/api/fullPKParser', exports.parseFullPKData);

}).call(this);
