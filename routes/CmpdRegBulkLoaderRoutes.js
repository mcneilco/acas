(function() {
  exports.setupAPIRoutes = function(app) {
    return app.post('/api/cmpdRegBulkLoader', exports.postAssignedProperties);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex);
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

  exports.cmpdRegBulkLoaderReadSdf = function(req, resp) {
    var cmpdRegBulkLoaderTestJSON, config, filePath, serverUtilityFunctions, uploadsPath;
    console.log("cmpdRegBulkLoaderReadSdf");
    if (req.query.testMode || global.specRunnerTestmode) {
      cmpdRegBulkLoaderTestJSON = require('../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js');
      console.log(req.body);
      console.log(req.body.numRecords);
      console.log(req.body.fileName);
      if (req.body.template === "Template 1") {
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

  exports.postAssignedProperties = function(req, resp) {
    console.log("postAssignedProperties");
    if (req.query.testMode || global.specRunnerTestmode) {
      console.log(req.body.properties);
      return resp.end(JSON.stringify("Registration Summary here"));
    } else {
      return resp.end(JSON.stringify("read sdf route not implemented yet"));
    }
  };

}).call(this);
