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
    app.get('/cmpdReg/projects', loginRoutes.ensureAuthenticated, exports.getBasicCmpdReg);
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
    return app.post('/cmpdReg/metalots', loginRoutes.ensureAuthenticated, exports.metaLots);
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
      syncCmpdRegUser(cmpdRegUser);
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

  syncCmpdRegUser = function(cmpdRegUser) {
    var config, getScientists, getUsersUrl, request, scientists;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    getUsersUrl = config.all.client.service.cmpdReg.persistence.basepath + '/scientists';
    getScientists = function(getUsersUrl, resp) {
      return request({
        method: 'GET',
        url: getUsersUrl,
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
    scientists = (getScientists(getUsersUrl)).json;
    console.log('scientists:');
    return console.log(scientists);
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
          console.log('got ajax error trying to search for compounds');
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
          console.log('got ajax error trying to search for compounds');
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

}).call(this);
