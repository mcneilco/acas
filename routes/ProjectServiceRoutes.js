/* To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
#Components routes
projectServiceRoutes = require './routes/ProjectServiceRoutes.js'
app.get '/api/projects', projectServiceRoutes.getProjects
*/


(function() {
  exports.getProjects = function(req, resp) {
    var config, projectServiceTestJSON;

    config = require('../public/src/conf/configurationNode.js');
    if (global.specRunnerTestmode) {
      projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
      return resp.end(JSON.stringify(projectServiceTestJSON.projects));
    } else {
      console.log("calling live projects service");
      if (config.serverConfigurationParams.configuration.projectsType === "ACAS") {
        projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
        return resp.end(JSON.stringify(projectServiceTestJSON.projects));
      } else {
        projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
        return resp.end(JSON.stringify(projectServiceTestJSON.projects));
      }
    }
  };

}).call(this);
