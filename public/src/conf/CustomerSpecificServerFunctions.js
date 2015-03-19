
/*
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
 */

(function() {
  var fs, serverUtilityFunctions;

  serverUtilityFunctions = require('../../../routes/ServerUtilityFunctions.js');

  fs = require('fs');

  exports.logUsage = function(action, data, username) {
    console.log("would have logged: " + action + " with data: " + data + " and user: " + username);
    return global.logger.writeToLog("info", "logUsage", action, data, username, null);
  };

  exports.getConfServiceVars = function(sysEnv, callback) {
    var conf;
    conf = {};
    return callback(conf);
  };

  exports.authCheck = function(user, pass, retFun) {
    var config, request;
    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: config.all.server.roologin.loginLink,
      form: {
        j_username: user,
        j_password: pass
      },
      json: false
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return retFun(JSON.stringify(json));
        } else if (!error && response.statusCode === 302) {
          return retFun(JSON.stringify(response.headers.location));
        } else {
          console.log('got connection error trying authenticate a user');
          console.log(error);
          console.log(json);
          console.log(response);
          return retFun("connection_error " + error);
        }
      };
    })(this));
  };

  exports.resetAuth = function(email, retFun) {
    var config, request;
    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: config.all.server.roologin.resetLink,
      form: {
        emailAddress: email
      },
      json: false
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return retFun(JSON.stringify(json));
        } else {
          console.log('got ajax error trying authenticate a user');
          console.log(error);
          console.log(json);
          console.log(response);
          return retFun("connection_error " + error);
        }
      };
    })(this));
  };

  exports.changeAuth = function(user, passOld, passNew, passNewAgain, retFun) {
    var config, request;
    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: config.all.server.roologin.changeLink,
      form: {
        username: user,
        oldPassword: passOld,
        newPassword: passNew,
        newPasswordAgain: passNewAgain
      },
      json: false
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return retFun(JSON.stringify(json));
        } else {
          console.log('got ajax error trying authenticate a user');
          console.log(error);
          console.log(json);
          console.log(response);
          return retFun("connection_error " + error);
        }
      };
    })(this));
  };

  exports.getUser = function(username, callback) {
    var config, request;
    config = require('../../../conf/compiled/conf.js');
    if (config.all.server.roologin.getUserLink && !global.specRunnerTestmode) {
      request = require('request');
      return request({
        headers: {
          accept: 'application/json'
        },
        method: 'POST',
        url: config.all.server.roologin.getUserLink,
        json: {
          name: username
        }
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200 && json.id) {
            return callback(null, {
              id: json.id,
              username: json.userName,
              email: json.emailAddress,
              firstName: json.firstName,
              lastName: json.lastName,
              roles: json.authorRoles
            });
          } else {
            return callback("user not found", null);
          }
        };
      })(this));
    } else {
      if (username !== "starksofwesteros") {
        return callback(null, {
          id: 0,
          username: username,
          email: username + "@nowhere.com",
          firstName: username,
          lastName: username
        });
      } else {
        return callback("user not found", null);
      }
    }
  };

  exports.isUserAdmin = function(user) {
    var adminRoles, isAdmin, _;
    _ = require('underscore');
    adminRoles = _.filter(user.roles, function(role) {
      return role.roleEntry.roleName === 'admin';
    });
    return isAdmin = adminRoles.length > 0 ? true : false;
  };

  exports.findByUsername = function(username, fn) {
    return exports.getUser(username, fn);
  };

  exports.loginStrategy = function(username, password, done) {
    return exports.authCheck(username, password, function(results) {
      var error;
      if (results.indexOf("login_error") >= 0) {
        try {
          exports.logUsage("User failed login: ", "", username);
        } catch (_error) {
          error = _error;
          console.log("Exception trying to log:" + error);
        }
        return done(null, false, {
          message: "Invalid credentials"
        });
      } else if (results.indexOf("connection_error") >= 0) {
        try {
          exports.logUsage("Connection to authentication service failed: ", "", username);
        } catch (_error) {
          error = _error;
          console.log("Exception trying to log:" + error);
        }
        return done(null, false, {
          message: "Cannot connect to authentication service. Please contact an administrator"
        });
      } else {
        try {
          exports.logUsage("User logged in succesfully: ", "", username);
        } catch (_error) {
          error = _error;
          console.log("Exception trying to log:" + error);
        }
        return exports.getUser(username, done);
      }
    });
  };

  exports.getProjects = function(resp) {
    var projects;
    projects = exports.projects = [
      {
        code: "project1",
        name: "Project 1",
        ignored: false
      }, {
        code: "project2",
        name: "Project 2",
        ignored: false
      }
    ];
    return resp.end(JSON.stringify(projects));
  };

  exports.makeServiceRequestHeaders = function(user) {
    var headers, username;
    username = user != null ? user.username : "testmode";
    return headers = {
      "From": username
    };
  };

  exports.getCustomerMolecularTargetCodes = function(resp) {
    var molecTargetTestJSON;
    molecTargetTestJSON = require('../../javascripts/spec/testFixtures/PrimaryScreenProtocolServiceTestJSON.js');
    return resp.end(JSON.stringify(molecTargetTestJSON.customerMolecularTargetCodeTable));
  };

  exports.validateCloneAndGetTarget = function(req, resp) {
    var psProtocolServiceTestJSON;
    psProtocolServiceTestJSON = require('../../javascripts/spec/testFixtures/PrimaryScreenProtocolServiceTestJSON.js');
    return resp.json(psProtocolServiceTestJSON.successfulCloneValidation);
  };

  exports.getAuthors = function(resp) {
    var baseurl, config;
    config = require('../../../conf/compiled/conf.js');
    serverUtilityFunctions = require('../../../routes/ServerUtilityFunctions.js');
    baseurl = config.all.client.service.persistence.fullpath + "authors/codeTable";
    return serverUtilityFunctions.getFromACASServer(baseurl, resp);
  };

  exports.relocateEntityFile = function(fileValue, entityCodePrefix, entityCode, callback) {
    var absEntitiesFolder, absEntityFolder, config, entitiesFolder, newPath, oldPath, relEntitiesFolder, relEntityFolder, uploadsPath;
    config = require('../../../conf/compiled/conf.js');
    uploadsPath = serverUtilityFunctions.makeAbsolutePath(config.all.server.datafiles.relative_path);
    oldPath = uploadsPath + fileValue.fileValue;
    relEntitiesFolder = serverUtilityFunctions.getRelativeFolderPathForPrefix(entityCodePrefix);
    if (relEntitiesFolder === null) {
      callback(false);
      return;
    }
    relEntityFolder = relEntitiesFolder + entityCode + "/";
    absEntitiesFolder = uploadsPath + relEntitiesFolder;
    absEntityFolder = uploadsPath + relEntityFolder;
    newPath = absEntityFolder + fileValue.fileValue;
    entitiesFolder = uploadsPath + "entities/";
    return serverUtilityFunctions.ensureExists(entitiesFolder, 0x1e4, function(err) {
      if (err != null) {
        console.log("Can't find or create entities folder: " + entitiesFolder);
        return callback(false);
      } else {
        return serverUtilityFunctions.ensureExists(absEntitiesFolder, 0x1e4, function(err) {
          if (err != null) {
            console.log("Can't find or create : " + absEntitiesFolder);
            return callback(false);
          } else {
            return serverUtilityFunctions.ensureExists(absEntityFolder, 0x1e4, function(err) {
              if (err != null) {
                console.log("Can't find or create : " + absEntityFolder);
                return callback(false);
              } else {
                return fs.rename(oldPath, newPath, function(err) {
                  if (err != null) {
                    console.log(err);
                    return callback(false);
                  } else {
                    fileValue.comments = fileValue.fileValue;
                    fileValue.fileValue = relEntityFolder + fileValue.fileValue;
                    return callback(true);
                  }
                });
              }
            });
          }
        });
      }
    });
  };

}).call(this);
