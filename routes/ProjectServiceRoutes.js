(function() {
  exports.setupAPIRoutes = function(app) {
    app.get('/api/projects/:username', exports.getProjects);
    return app.get('/api/projects/getAllProjects/stubs', exports.getProjectStubs);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/projects', loginRoutes.ensureAuthenticated, exports.getProjects);
    return app.get('/api/projects/getAllProjects/stubs', loginRoutes.ensureAuthenticated, exports.getProjectStubs);
  };

  exports.getProjects = function(req, resp) {
    var csUtilities, projectServiceTestJSON;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (req.user == null) {
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

  exports.getProjectStubs = function(req, resp) {
    var csUtilities, projectServiceTestJSON;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (req.user == null) {
      req.user = {};
      req.user.username = req.params.username;
    }
    if (global.specRunnerTestmode) {
      projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
      return resp.end(JSON.stringify(projectServiceTestJSON.projectStubs));
    } else {
      return csUtilities.getProjectStubs(req, resp);
    }
  };

}).call(this);
