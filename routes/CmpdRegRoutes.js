(function() {
  var syncCmpdRegUser,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  exports.setupAPIRoutes = function(app) {
    return app.post('/api/cmpdReg', exports.postAssignedProperties);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/cmpdReg', loginRoutes.ensureAuthenticated, exports.cmpdRegIndex);
    app.get('/marvin4js-license.cxl', loginRoutes.ensureAuthenticated, exports.getMarvinJSLicense);
    app.get('/cmpdReg/scientists', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/parentAliasKinds', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/units', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/solutionUnits', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/stereoCategorys', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/fileTypes', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/projects', loginRoutes.ensureAuthenticated, exports.getAuthorizedCmpdRegProjects);
    app.get('/cmpdReg/vendors', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/physicalStates', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/operators', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/purityMeasuredBys', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
    app.get('/cmpdReg/structureimage/parent/[\\S]*', loginRoutes.ensureAuthenticated, exports.getStructureImage);
    app.get('/cmpdReg/metalots/corpName/[\\S]*', loginRoutes.ensureAuthenticated, exports.getMetaLot);
    app.get('/MultipleFilePicker/[\\S]*', loginRoutes.ensureAuthenticated, exports.getMultipleFilePicker);
    app.post('/cmpdReg/search/cmpds', loginRoutes.ensureAuthenticated, exports.searchCmpds);
    app.post('/cmpdReg/regsearches/parent', loginRoutes.ensureAuthenticated, exports.regSearch);
    app.post('/cmpdReg/filesave', loginRoutes.ensureAuthenticated, exports.fileSave);
    app.post('/cmpdReg/metalots', loginRoutes.ensureAuthenticated, exports.metaLots);
    app.post('/cmpdReg/salts', loginRoutes.ensureAuthenticated, exports.saveSalts);
    return app.post('/cmpdReg/isotopes', loginRoutes.ensureAuthenticated, exports.saveIsotopes);
  };

  exports.cmpdRegIndex = function(req, res) {
    var _, cmpdRegConfig, cmpdRegUser, config, grantedRoles, isAdmin, isChemist, loginUser, loginUserName, ref, ref1, ref2, ref3, scriptPaths, scriptsToLoad;
    scriptPaths = require('./RequiredClientScripts.js');
    config = require('../conf/compiled/conf.js');
    cmpdRegConfig = require('../public/src/modules/CmpdReg/src/client/custom/configuration.json');
    _ = require('underscore');
    grantedRoles = _.map(req.user.roles, function(role) {
      return role.roleEntry.roleName;
    });
    console.log(grantedRoles);
    isChemist = (((ref = config.all.client.roles.cmpdreg) != null ? ref.chemistRole : void 0) != null) && (ref1 = config.all.client.roles.cmpdreg.chemistRole, indexOf.call(grantedRoles, ref1) >= 0);
    isAdmin = (((ref2 = config.all.client.roles.cmpdreg) != null ? ref2.adminRole : void 0) != null) && (ref3 = config.all.client.roles.cmpdreg.adminRole, indexOf.call(grantedRoles, ref3) >= 0);
    global.specRunnerTestmode = global.stubsMode ? true : false;
    scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts);
    if (config.all.client.require.login) {
      loginUserName = req.user.username;
      loginUser = req.user;
      cmpdRegUser = {
        id: req.user.id,
        code: req.user.username,
        name: req.user.firstName + " " + req.user.lastName,
        isChemist: isChemist,
        isAdmin: isAdmin
      };
      syncCmpdRegUser(req, cmpdRegUser);
    } else {
      loginUserName = "nouser";
      loginUser = {
        id: 0,
        username: "nouser",
        email: "nouser@nowhere.com",
        firstName: "no",
        lastName: "user"
      };
      cmpdRegUser = {
        id: 0,
        code: "nouser",
        name: "no user",
        isChemist: true,
        isAdmin: true
      };
    }
    return res.render('CmpdReg', {
      title: "Compound Registration",
      scripts: scriptsToLoad,
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        cmpdRegUser: cmpdRegUser,
        testMode: false,
        moduleLaunchParams: typeof moduleLaunchParams !== "undefined" && moduleLaunchParams !== null ? moduleLaunchParams : null,
        deployMode: global.deployMode,
        cmpdRegConfig: cmpdRegConfig
      }
    });
  };

  syncCmpdRegUser = function(req, cmpdRegUser) {
    var _, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    _ = require("underscore");
    return exports.getScientists(req, function(scientistResponse) {
      var foundScientists, oldScientist;
      foundScientists = JSON.parse(scientistResponse);
      if ((_.findWhere(foundScientists, {
        code: cmpdRegUser.code
      })) != null) {
        console.debug('found scientist ' + cmpdRegUser.code);
        if ((_.findWhere(foundScientists, {
          code: cmpdRegUser.code,
          isAdmin: cmpdRegUser.isAdmin,
          isChemist: cmpdRegUser.isChemist,
          name: cmpdRegUser.name
        })) != null) {
          return console.debug('CmpdReg scientists are up-to-date');
        } else {
          oldScientist = _.findWhere(foundScientists, {
            code: cmpdRegUser.code
          });
          cmpdRegUser.id = oldScientist.id;
          cmpdRegUser.ignore = oldScientist.ignore;
          cmpdRegUser.version = oldScientist.version;
          console.debug('updating scientist with JSON: ' + JSON.stringify(cmpdRegUser));
          return exports.updateScientists([cmpdRegUser], function(updateScientistsResponse) {});
        }
      } else {
        console.debug('scientist ' + cmpdRegUser.code + ' not found.');
        console.debug('creating new scientist' + JSON.stringify(cmpdRegUser));
        return exports.saveScientists([cmpdRegUser], function(saveScientistsResponse) {});
      }
    });
  };

  exports.getBasicCmpdReg = function(req, resp) {
    var cmpdRegCall, config, endOfUrl, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in getBasicCmpdReg');
    console.log(req.originalUrl);
    endOfUrl = req.originalUrl.replace(/\/cmpdreg\//, "");
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/" + endOfUrl;
    console.log(cmpdRegCall);
    return req.pipe(request(cmpdRegCall)).pipe(resp);
  };

  exports.getAuthorizedCmpdRegProjects = function(req, resp) {
    return exports.getAuthorizedCmpdRegProjectsInternal(req, (function(_this) {
      return function(response) {
        resp.status("200");
        return resp.end(JSON.stringify(response));
      };
    })(this));
  };

  exports.getAuthorizedCmpdRegProjectsInternal = function(req, callback) {
    var _;
    _ = require("underscore");
    return exports.getACASProjects(req, function(statusCode, acasProjectsResponse) {
      var acasProjects;
      acasProjects = acasProjectsResponse;
      return exports.getProjects(req, function(cmpdRegProjectsResponse) {
        var allowedProjectCodes, allowedProjects, cmpdRegProjects;
        cmpdRegProjects = JSON.parse(cmpdRegProjectsResponse);
        allowedProjectCodes = _.pluck(acasProjects, 'code');
        allowedProjects = _.filter(cmpdRegProjects, function(cmpdRegProject) {
          var ref;
          return (ref = cmpdRegProject.code, indexOf.call(allowedProjectCodes, ref) >= 0);
        });
        return callback(allowedProjects);
      });
    });
  };

  exports.getACASProjects = function(req, callback) {
    var csUtilities;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (req.user == null) {
      req.user = {};
      req.user.username = req.params.username;
    }
    if (global.specRunnerTestmode) {
      return resp.end(JSON.stringify("testMode not implemented"));
    } else {
      return csUtilities.getProjectsInternal(req, callback);
    }
  };

  exports.getProjects = function(req, callback) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in getProjects');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/projects";
    return request({
      method: 'GET',
      url: cmpdRegCall,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          return callback(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to get CmpdReg projects');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.saveProjects = function(jsonBody, callback) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in saveProjects');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/projects/jsonArray";
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(jsonBody),
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          return callback(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to save CmpdReg projects');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.updateProjects = function(jsonBody, callback) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in updateProjects');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/projects/jsonArray";
    return request({
      method: 'PUT',
      url: cmpdRegCall,
      body: JSON.stringify(jsonBody),
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          return callback(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to update CmpdReg projects');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.getScientists = function(req, callback) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in getScientists');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/scientists";
    return request({
      method: 'GET',
      url: cmpdRegCall,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          return callback(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to get CmpdReg scientists');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.saveScientists = function(jsonBody, callback) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in saveScientists');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/scientists/jsonArray";
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(jsonBody),
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          return callback(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to save CmpdReg scientists');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.updateScientists = function(jsonBody, callback) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    console.log('in updateScientists');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + "/scientists/jsonArray";
    return request({
      method: 'PUT',
      url: cmpdRegCall,
      body: JSON.stringify(jsonBody),
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          return callback(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to update CmpdReg scientists');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.searchCmpds = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/search/cmpds';
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(req.body),
      json: true,
      timeout: 6000000
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          resp.setHeader('Content-Type', 'application/json');
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to search for compounds');
          console.log(error);
          console.log(json);
          console.log(response);
          return resp.end(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.getStructureImage = function(req, resp) {
    var cmpdRegCall, config, imagePath, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    imagePath = req.originalUrl.replace(/\/cmpdreg\/structureimage/, "");
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/structureimage' + imagePath;
    return req.pipe(request(cmpdRegCall)).pipe(resp);
  };

  exports.getMetaLot = function(req, resp) {
    var cmpdRegCall, config, endOfUrl, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    endOfUrl = req.originalUrl.replace(/\/cmpdreg\/metalots/, "");
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/metalots' + endOfUrl;
    console.log(cmpdRegCall);
    return req.pipe(request(cmpdRegCall)).pipe(resp);
  };

  exports.regSearch = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/regsearches/parent';
    console.log(cmpdRegCall);
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(req.body),
      json: true,
      timeout: 6000000
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          resp.setHeader('Content-Type', 'application/json');
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to do registration search');
          console.log(error);
          console.log(json);
          console.log(response);
          return resp.end(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.getMarvinJSLicense = function(req, resp) {
    var cmpdRegCall, config, licensePath, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath.replace('\/cmpdreg', "/");
    licensePath = cmpdRegCall + 'marvin4js-license.cxl';
    console.log(licensePath);
    return req.pipe(request(licensePath)).pipe(resp);
  };

  exports.getMultipleFilePicker = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + req.originalUrl;
    console.log(cmpdRegCall);
    return req.pipe(request(cmpdRegCall)).pipe(resp);
  };

  exports.fileSave = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/filesave';
    return req.pipe(request[req.method.toLowerCase()](cmpdRegCall)).pipe(resp);
  };

  exports.metaLots = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/metalots';
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(req.body),
      json: true,
      timeout: 6000000
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          resp.setHeader('Content-Type', 'application/json');
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to do metalot save');
          console.log(error);
          console.log(json);
          console.log(response);
          return resp.end(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.saveSalts = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/salts';
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(req.body),
      json: true,
      timeout: 6000000
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          resp.setHeader('Content-Type', 'application/json');
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to do save salts');
          console.log(error);
          console.log(json);
          console.log(response);
          return resp.end(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

  exports.saveIsotopes = function(req, resp) {
    var cmpdRegCall, config, request;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    cmpdRegCall = config.all.client.service.cmpdReg.persistence.basepath + '/isotopes';
    return request({
      method: 'POST',
      url: cmpdRegCall,
      body: JSON.stringify(req.body),
      json: true,
      timeout: 6000000
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          resp.setHeader('Content-Type', 'application/json');
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to do save isotopes');
          console.log(error);
          console.log(json);
          console.log(response);
          return resp.end(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

}).call(this);
