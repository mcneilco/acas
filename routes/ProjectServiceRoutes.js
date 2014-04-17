/* To install this Module
1) Add these lines to app.coffee
	#Components routes
	projectServiceRoutes = require './public/src/modules/01_Components/src/server/routes/ProjectServiceRoutes.js'
	projectServiceRoutes.setupRoutes(app)
*/


(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/projects', loginRoutes.ensureAuthenticated, exports.getProjects);
  };

  exports.getProjects = function(req, resp) {
    var csUtilities, projectServiceTestJSON;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (global.specRunnerTestmode) {
      projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
      return resp.end(JSON.stringify(projectServiceTestJSON.projects));
    } else {
      return csUtilities.getProjects(resp);
    }
  };

}).call(this);
