
/*
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
 */

(function() {
  var checkBatch_TestMode, fs, serverUtilityFunctions;

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
    var _, adminRoles, isAdmin;
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

  exports.getProjects = function(req, resp) {
    var config, request, url;
    config = require('../../../conf/compiled/conf.js');
    url = config.all.client.service.persistence.fullpath + "authorization/projects?find=ByUserName&userName=" + req.user.username + "&format=codeTable";
    request = require('request');
    return request({
      method: 'GET',
      url: url,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return resp.json(json);
        } else {
          console.log('got ajax error trying get acas project codes');
          console.log(error);
          console.log(json);
          console.log(response);
          resp.status(response.statusCode);
          return resp.json(json);
        }
      };
    })(this));
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
    if (fileValue.comments !== void 0 && fileValue.comments !== null) {
      newPath = absEntityFolder + fileValue.comments;
    } else {
      newPath = absEntityFolder + fileValue.fileValue;
    }
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
              var stream;
              if (err != null) {
                console.log("Can't find or create : " + absEntityFolder);
                return callback(false);
              } else if (fileValue.comments !== void 0 && fileValue.comments !== null) {
                console.log("fileValue has comments");
                console.log(oldPath);
                console.log(newPath);
                stream = fs.createReadStream(oldPath).pipe(fs.createWriteStream(newPath));
                stream.on('error', function(err) {
                  console.log("error copying file to new location");
                  return callback(false);
                });
                return stream.on('close', function() {
                  fileValue.fileValue = relEntityFolder + fileValue.comments;
                  return callback(true);
                });
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

  exports.getDownloadUrl = function(fileValue) {
    var config;
    config = require('../../../conf/compiled/conf.js');
    return config.all.client.datafiles.downloadurl.prefix + fileValue;
  };

  exports.getTestedEntityProperties = function(propertyList, entityList, callback) {
    var ents, i, j, k, l, len, len1, m, out, prop, prop2, ref;
    if (propertyList.indexOf('ERROR') > -1) {
      callback(null);
      return;
    }
    ents = entityList.split('\n');
    out = "id,";
    for (k = 0, len = propertyList.length; k < len; k++) {
      prop = propertyList[k];
      out += prop + ",";
    }
    out = out.slice(0, -1) + '\n';
    for (i = l = 0, ref = ents.length - 2; 0 <= ref ? l <= ref : l >= ref; i = 0 <= ref ? ++l : --l) {
      out += ents[i] + ",";
      j = 0;
      for (m = 0, len1 = propertyList.length; m < len1; m++) {
        prop2 = propertyList[m];
        if (ents[i].indexOf('ERROR') < 0) {
          out += i + j++;
        } else {
          out += "";
        }
        out += ',';
      }
      out = out.slice(0, -1) + '\n';
    }
    return callback(out);
  };

  exports.getExternalReferenceCodes = function(displayName, requests, callback) {
    if (displayName === "Corporate Batch ID") {
      console.log("looking up compound batches");
      return exports.getPreferredBatchIds(requests, function(response) {
        return callback(response);
      });
    } else if (displayName === "Corporate Parent ID") {
      console.log("looking up compound parents");
      return exports.getPreferredParentIds(requests, function(response) {
        return callback(response);
      });
    } else {
      callback.statusCode = 500;
      return callback.end("problem with external preferred Code request: code type and kind are unknown to system");
    }
  };

  exports.getExternalBestLabel = function(displayName, requests, callback) {
    if (displayName === "Corporate Batch ID") {
      console.log("looking up compound batches");
      return exports.getBatchBestLabels(requests, function(response) {
        return callback(response);
      });
    } else if (displayName === "Corporate Parent ID") {
      console.log("looking up compound parents");
      return exports.getParentBestLabels(requests, function(response) {
        console.log(JSON.stringify(response));
        return callback(response);
      });
    } else {
      callback.statusCode = 500;
      return callback.end("problem with external best label request: displayName is unknown to system");
    }
  };

  exports.getPreferredBatchIds = function(requests, callback) {
    var config, k, len, req, request, res, response, results;
    if (global.specRunnerTestmode) {
      results = [];
      for (k = 0, len = requests.length; k < len; k++) {
        req = requests[k];
        res = {
          requestName: req.requestName
        };
        if (req.requestName.indexOf("999999999") > -1) {
          res.preferredName = "";
        } else if (req.requestName.indexOf("673874") > -1) {
          res.preferredName = "DNS000001234::7";
        } else {
          res.preferredName = checkBatch_TestMode(req.requestName);
        }
        results.push(res);
      }
      response = results;
      return callback(response);
    } else {
      config = require('../../../conf/compiled/conf.js');
      request = require('request');
      console.log("search term: " + requests[0]);
      return request({
        method: 'POST',
        url: config.all.server.service.external.preferred.batchid.url,
        json: true,
        body: requests
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return callback(json);
          } else {
            console.log(error);
            console.log(response);
            console.log(json);
            return callback(null);
          }
        };
      })(this));
    }
  };

  exports.getPreferredParentIds = function(requests, callback) {
    var config, k, len, req, request, res, response, results;
    if (global.specRunnerTestmode) {
      results = [];
      for (k = 0, len = requests.length; k < len; k++) {
        req = requests[k];
        res = {
          requestName: req.requestName
        };
        if (req.requestName.indexOf("999999999") > -1) {
          res.preferredName = "";
        } else if (req.requestName.indexOf("673874") > -1) {
          res.preferredName = "DNS000001234";
        } else if (req.requestName.indexOf("compoundName") > -1) {
          res.preferredName = "CMPD000001234";
        } else {
          res.preferredName = req.requestName;
        }
        results.push(res);
      }
      response = results;
      return callback(response);
    } else {
      config = require('../../../conf/compiled/conf.js');
      request = require('request');
      return request({
        method: 'POST',
        url: config.all.server.service.external.preferred.batchid.url + "/parent",
        json: true,
        body: requests
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return callback(json);
          } else {
            console.log(error);
            console.log(response);
            console.log(json);
            return callback(null);
          }
        };
      })(this));
    }
  };

  exports.getBatchBestLabels = function(requests, callback) {
    var config, k, len, req, request, res, response, results;
    if (global.specRunnerTestmode) {
      results = [];
      for (k = 0, len = requests.length; k < len; k++) {
        req = requests[k];
        res = {
          requestName: req.requestName
        };
        if (req.requestName.indexOf("1111") > -1) {
          res.preferredName = "1111";
        } else if (req.requestName.indexOf("1234") > -1) {
          res.preferredName = "1234::7";
        } else {
          res.preferredName = req.requestName;
        }
        results.push(res);
      }
      response = results;
      return callback(response);
    } else {
      config = require('../../../conf/compiled/conf.js');
      request = require('request');
      return request({
        method: 'POST',
        url: config.all.server.service.external.preferred.batchid.url,
        json: true,
        body: requests
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return callback(json);
          } else {
            console.log(error);
            console.log(response);
            console.log(json);
            return callback(null);
          }
        };
      })(this));
    }
  };

  exports.getParentBestLabels = function(requests, callback) {
    var config, k, len, req, request, res, response, results;
    if (global.specRunnerTestmode) {
      results = [];
      for (k = 0, len = requests.length; k < len; k++) {
        req = requests[k];
        res = {
          requestName: req.requestName
        };
        if (req.requestName.indexOf("1111") > -1) {
          res.preferredName = "1111";
        } else if (req.requestName.indexOf("1234") > -1) {
          res.preferredName = "1234";
        } else if (req.requestName.indexOf("CMPD000001234") > -1) {
          res.preferredName = "1234";
        } else {
          res.preferredName = req.requestName;
        }
        results.push(res);
      }
      response = results;
      return callback(response);
    } else {
      config = require('../../../conf/compiled/conf.js');
      request = require('request');
      return request({
        method: 'POST',
        url: config.all.server.service.external.preferred.batchid.url + "/parent",
        json: true,
        body: requests
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return callback(json);
          } else {
            console.log(error);
            console.log(response);
            console.log(json);
            return callback(null);
          }
        };
      })(this));
    }
  };

  checkBatch_TestMode = function(requestName) {
    var idComps, pref, respId;
    idComps = requestName.split("_");
    pref = idComps[0];
    respId = "";
    switch (pref) {
      case "norm":
        respId = batchName.requestName;
        break;
      case "none":
        respId = "";
        break;
      case "alias":
        respId = "norm_" + idComps[1] + "A";
        break;
      default:
        respId = requestName;
    }
    return respId;
  };

}).call(this);
