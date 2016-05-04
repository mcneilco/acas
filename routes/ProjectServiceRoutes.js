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

}).call(this);

(function() {
  exports.setupAPIRoutes = function(app, loginRoutes) {
    return app.get('/api/genericSearch/projects/:searchTerm', exports.genericProjectSearch);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/genericSearch/projects/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericProjectSearch);
  };

  exports.genericProjectSearch = function(req, resp) {
    var baseurl, config, searchParams, searchTerm, serverUtilityFunctions, userNameParam;
    console.log("generic project search");
    console.log(req.query.testMode);
    console.log(global.specRunnerTestmode);
    if (req.query.testMode === true || global.specRunnerTestmode === true) {
      return resp.end(JSON.stringify("Stubs mode not implemented yet"));
    } else {
      config = require('../conf/compiled/conf.js');
      console.log("search req");
      userNameParam = "userName=" + req.user.username;
      searchTerm = "q=" + req.params.searchTerm;
      searchParams = "";
      searchParams += userNameParam + "&";
      searchParams += searchTerm;
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/searchProjects?" + searchParams;
      console.log("generic project search baseurl");
      console.log(baseurl);
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

}).call(this);
