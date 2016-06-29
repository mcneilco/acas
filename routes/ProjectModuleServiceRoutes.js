(function() {
  var deleteAuthorRoles, getOrCreateProjectRoleKindAndName, postAuthorRoles, saveLsroles, saveRolekinds;

  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.get('/api/genericSearch/projects/:searchTerm', exports.genericProjectSearch);
    app.get('/api/projects/getByRoleTypeKindAndName/:roleType/:roleKind/:roleName', exports.getProjectByRoleTypeKindAndName);
    app.post('/api/projects/createRoleKindAndName', exports.createProjectRoleKindAndName);
    return app.post('/api/projects/updateProjectRoles', exports.updateProjectRoles);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/genericSearch/projects/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericProjectSearch);
    app.get('/api/projects/getByRoleTypeKindAndName/:roleType/:roleKind/:roleName', loginRoutes.ensureAuthenticated, exports.getProjectByRoleTypeKindAndName);
    app.post('/api/projects/createRoleKindAndName', loginRoutes.ensureAuthenticated, exports.createProjectRoleKindAndName);
    return app.post('/api/projects/updateProjectRoles', loginRoutes.ensureAuthenticated, exports.updateProjectRoles);
  };

  exports.genericProjectSearch = function(req, resp) {
    var baseurl, config, projectTestJSON, searchParams, searchTerm, serverUtilityFunctions, userNameParam;
    console.log("generic project search");
    console.log(req.query.testMode);
    console.log(global.specRunnerTestmode);
    if (req.query.testMode === true || global.specRunnerTestmode === true) {
      projectTestJSON = require('../public/javascripts/spec/testFixtures/ProjectTestJSON.js');
      return resp.end(JSON.stringify[projectTestJSON.project]);
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

  exports.getProjectByRoleTypeKindAndName = function(req, resp) {
    var baseurl, config, projectTestJSON, roleKind, roleName, roleType, serverUtilityFunctions;
    if (req.query.testMode === true || global.specRunnerTestmode === true) {
      projectTestJSON = require('../public/javascripts/spec/testFixtures/ProjectTestJSON.js');
      return resp.end(JSON.stringify[projectTestJSON.projectUsers]);
    } else {
      config = require('../conf/compiled/conf.js');
      roleType = req.params.roleType;
      roleKind = req.params.roleKind;
      roleName = req.params.roleName;
      baseurl = config.all.client.service.persistence.fullpath + ("authors/findByRoleTypeKindAndName?roleType=" + roleType + "&roleKind=" + roleKind + "&roleName=" + roleName);
      if ((req.query.format != null) && req.query.format.toLowerCase() === "codetable") {
        baseurl += "&format=codetable";
      }
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.createProjectRoleKindAndName = function(req, resp) {
    return getOrCreateProjectRoleKindAndName(req.body.rolekind, req.body.lsroles, req.query.testMode, function(err, response) {
      if (err != null) {
        resp.statusCode = 500;
        return resp.end(err);
      } else {
        return resp.json(response);
      }
    });
  };

  getOrCreateProjectRoleKindAndName = function(rolekind, lsroles, testMode, callback) {
    var projectTestJSON;
    if (testMode === true || global.specRunnerTestmode === true) {
      projectTestJSON = require('../public/javascripts/spec/testFixtures/ProjectTestJSON.js');
      return callback(null, JSON.stringify[projectTestJSON.projectUsers]);
    } else {
      return saveRolekinds(rolekind, function(err1) {
        if (err1 != null) {
          callback(err1);
        }
        return saveLsroles(lsroles, function(err2, response) {
          if (err2 != null) {
            return callback(err2);
          } else {
            return callback(null, response);
          }
        });
      });
    }
  };

  saveRolekinds = function(rolekind, callback) {
    var config, request, rolekindUrl;
    config = require('../conf/compiled/conf.js');
    rolekindUrl = config.all.client.service.persistence.fullpath + "setup/rolekinds";
    console.log("rolekind");
    console.log(rolekind);
    request = require('request');
    return request({
      method: 'POST',
      url: rolekindUrl,
      body: JSON.stringify(rolekind),
      json: true,
      headers: {
        "Content-Type": 'application/json'
      }
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 201) {
          console.log("successfully added project role kind");
          return callback(null);
        } else {
          console.log("error saving project role kind");
          console.log(response.statusCode);
          console.log(response.json);
          return callback("saveFailed for project rolekind");
        }
      };
    })(this));
  };

  saveLsroles = function(lsroles, callback) {
    var config, lsrolesUrl, request;
    config = require('../conf/compiled/conf.js');
    lsrolesUrl = config.all.client.service.persistence.fullpath + "setup/lsroles";
    console.log("lsroles");
    console.log(lsroles);
    request = require('request');
    return request({
      method: 'POST',
      url: lsrolesUrl,
      body: JSON.stringify(lsroles),
      json: true,
      headers: {
        "Content-Type": 'application/json'
      }
    }, (function(_this) {
      return function(error2, response2, json2) {
        if (!error2 && response2.statusCode === 201) {
          console.log("successfully added lsroles");
          return callback(null, json2);
        } else {
          console.log("error saving project role names");
          console.log(error2);
          console.log(response2);
          console.log(response2.statusCode);
          return callback("saveFailed for project lsrole");
        }
      };
    })(this));
  };

  exports.updateProjectRoles = function(req, resp) {
    var _, config, projectTestJSON, request;
    if (req.query.testMode === true || global.specRunnerTestmode === true) {
      projectTestJSON = require('../public/javascripts/spec/testFixtures/ProjectTestJSON.js');
      return resp.end(JSON.stringify[projectTestJSON.project]);
    } else {
      config = require('../conf/compiled/conf.js');
      request = require('request');
      _ = require('../public/src/lib/underscore.js');
      console.log("req.body.authorRolesToDelete");
      console.log(req.body.authorRolesToDelete);
      return deleteAuthorRoles(req.body.authorRolesToDelete, (function(_this) {
        return function(err) {
          if (err != null) {
            resp.statusCode = 500;
            return resp.end(err);
          } else {
            console.log("req.body.newAuthorRoles");
            console.log(req.body.newAuthorRoles);
            return postAuthorRoles(req.body.newAuthorRoles, function(err2) {
              if (err2 != null) {
                resp.statusCode = 500;
                return resp.end(err2);
              } else {
                console.log("post author roles success");
                return resp.end(JSON.stringify('saved author roles successfully'));
              }
            });
          }
        };
      })(this));
    }
  };

  deleteAuthorRoles = function(authorRoles, callback) {
    var baseurl, config, request;
    config = require('../conf/compiled/conf.js');
    baseurl = config.all.client.service.persistence.fullpath + "authorroles/deleteRoles";
    console.log(baseurl);
    request = require('request');
    return request({
      method: 'POST',
      url: baseurl,
      body: authorRoles,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        console.log(response.statusCode);
        if (!error && response.statusCode === 200) {
          console.log("successfully deleted author roles");
          return callback(null);
        } else {
          console.log('got ajax error trying to delete author roles');
          console.log(error);
          return callback("saveFailed for deleting author roles" + error);
        }
      };
    })(this));
  };

  postAuthorRoles = function(authorRoles, callback) {
    var baseurl, config, request;
    config = require('../conf/compiled/conf.js');
    baseurl = config.all.client.service.persistence.fullpath + "authorroles/saveRoles";
    request = require('request');
    return request({
      method: 'POST',
      url: baseurl,
      body: authorRoles,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 201) {
          return callback(null);
        } else {
          return callback("saveFailed posting new author roles");
        }
      };
    })(this));
  };

}).call(this);
