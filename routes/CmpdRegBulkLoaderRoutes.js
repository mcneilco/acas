(function() {
  var postAssignedProperties;

  exports.setupAPIRoutes = function(app) {
    return app.post('/api/cmpdRegBulkLoader', exports.postAssignedProperties);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex);
    app.get('/api/cmpdRegBulkLoader/templates/:user', loginRoutes.ensureAuthenticated, exports.getCmpdRegBulkLoaderTemplates);
    app.post('/api/cmpdRegBulkLoader/readSDF', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderReadSdf);
    return app.post('/api/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.postAssignedProperties);
  };

  exports.cmpdRegBulkLoaderIndex = function(req, res) {
    var config, loginUser, loginUserName, scriptPaths, scriptsToLoad;
    scriptPaths = require('./RequiredClientScripts.js');
    config = require('../conf/compiled/conf.js');
    global.specRunnerTestmode = global.stubsMode ? true : false;
    scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.applicationScripts);
    if (config.all.client.require.login) {
      loginUserName = req.user.username;
      loginUser = req.user;
    } else {
      loginUserName = "nouser";
      loginUser = {
        id: 0,
        username: "nouser",
        email: "nouser@nowhere.com",
        firstName: "no",
        lastName: "user"
      };
    }
    return res.render('CmpdRegBulkLoader', {
      title: "Compound Registration Bulk Loader",
      scripts: scriptsToLoad,
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: false,
        moduleLaunchParams: typeof moduleLaunchParams !== "undefined" && moduleLaunchParams !== null ? moduleLaunchParams : null,
        deployMode: global.deployMode
      }
    });
  };

  exports.getCmpdRegBulkLoaderTemplates = function(req, resp) {
    var baseurl, cmpdRegBulkLoaderTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cmpdRegBulkLoaderTestJSON = require('../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js');
      return resp.end(JSON.stringify(cmpdRegBulkLoaderTestJSON.templates));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "bulkload/templates?userName=" + req.params.user;
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.cmpdRegBulkLoaderReadSdf = function(req, resp) {
    var cmpdRegBulkLoaderTestJSON, config, filePath, serverUtilityFunctions, uploadsPath;
    console.log("cmpdRegBulkLoaderReadSdf");
    if (req.query.testMode || global.specRunnerTestmode) {
      cmpdRegBulkLoaderTestJSON = require('../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js');
      console.log(req.body);
      if (req.body.templateName === "Template 1") {
        if (req.body.numRecords < 300) {
          return resp.end(JSON.stringify(cmpdRegBulkLoaderTestJSON.propertiesList));
        } else {
          return resp.end(JSON.stringify(cmpdRegBulkLoaderTestJSON.propertiesList2));
        }
      } else {
        return resp.end(JSON.stringify(cmpdRegBulkLoaderTestJSON.propertiesList3));
      }
    } else {
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      config = require('../conf/compiled/conf.js');
      uploadsPath = serverUtilityFunctions.makeAbsolutePath(config.all.server.datafiles.relative_path);
      filePath = uploadsPath + req.body.fileName;
      req.body.fileName = filePath;
      console.log(req.body);
      return resp.end(JSON.stringify("read sdf route not implemented yet"));
    }
  };

  postAssignedProperties = function(req, resp) {
    var registerCompounds, saveTemplate;
    console.log("post assigned properties");
    registerCompounds = function(templateInfo, resp) {
      if (req.query.testMode || global.specRunnerTestmode) {
        console.log("register compounds");
        return resp.end(JSON.stringify("Registration Summary here"));
      } else {
        return resp.end(JSON.stringify("read sdf route not implemented yet"));
      }
    };
    saveTemplate = function(templateInfo, resp) {
      var baseurl, config, request;
      console.log("save template");
      if (req.query.testMode || global.specRunnerTestmode) {
        return registerCompounds(templateInfo, resp);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "bulkload/templates/saveTemplate";
        request = require('request');
        return request({
          method: 'POST',
          url: baseurl,
          body: templateInfo,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (!error && response.statusCode === 201) {
              return registerCompounds(templateInfo, resp);
            } else {
              console.log('got ajax error trying to save lsThing');
              console.log(error);
              console.log(json);
              return console.log(response);
            }
          };
        })(this));
      }
    };
    if (req.body.templateName !== "") {
      return saveTemplate(req.body, resp);
    } else {
      return registerCompounds(req.body, resp);
    }
  };

  exports.postAssignedProperties = function(req, resp) {
    return postAssignedProperties(req, resp);
  };

}).call(this);
