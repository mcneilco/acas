(function() {
  exports.setupAPIRoutes = function(app) {
    return app.get('/api/projects/:username', exports.getProjects);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/projects', loginRoutes.ensureAuthenticated, exports.getProjects);
  };

  exports.getProjects = function(req, resp) {
    var csUtilities, projectServiceTestJSON;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    console.log(req.params);
    if (req.user == null) {
      console.log("No user!");
      req.user = {};
      req.user.username = req.params.username;
    }
    if (global.specRunnerTestmode) {
      projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
      return resp.end(JSON.stringify(projectServiceTestJSON.projects));
    } else {
      return csUtilities.getProjects(req, resp);
    }
  };

}).call(this);
