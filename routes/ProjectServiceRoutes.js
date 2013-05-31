/* To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
#Components routes
projectServiceRoutes = require './routes/ProjectServiceRoutes.js'
app.get '/api/projects', projectServiceRoutes.getProjects
*/


(function() {
  var dnsFormatProjectResponse, dnsGetProjects;

  exports.getProjects = function(req, resp) {
    var projectServiceTestJSON;

    if (global.specRunnerTestmode) {
      projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
      return resp.end(JSON.stringify(projectServiceTestJSON.projects));
    } else {
      console.log("calling live projects service");
      return dnsGetProjects(resp);
    }
  };

  dnsGetProjects = function(resp) {
    var config, request,
      _this = this;

    config = require('../public/src/conf/configurationNode.js');
    request = require('request');
    return request({
      method: 'GET',
      url: config.serverConfigurationParams.configuration.projectsServiceURL,
      json: true
    }, function(error, response, json) {
      if (!error && response.statusCode === 200) {
        console.log(JSON.stringify(json));
        console.log(JSON.stringify(dnsFormatProjectResponse(json)));
        return resp.json(dnsFormatProjectResponse(json));
      } else {
        console.log('got ajax error trying get project list');
        console.log(error);
        console.log(json);
        return console.log(response);
      }
    });
  };

  dnsFormatProjectResponse = function(json) {
    var projects, _;

    _ = require('underscore');
    projects = [];
    _.each(json, function(proj) {
      var p;

      p = proj.DNSCode;
      return projects.push({
        code: p.code,
        name: p.name,
        ignored: !p.active
      });
    });
    return projects;
  };

}).call(this);
