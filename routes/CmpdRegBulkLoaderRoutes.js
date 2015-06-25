(function() {
  var postAssignedProperties;

  exports.setupAPIRoutes = function(app) {
    return app.post('/api/cmpdRegBulkLoader', exports.postAssignedProperties);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderIndex);
    app.get('/api/cmpdRegBulkLoader/templates/:user', loginRoutes.ensureAuthenticated, exports.getCmpdRegBulkLoaderTemplates);
    app.get('/api/cmpdRegBulkLoader/getFilesToPurge', loginRoutes.ensureAuthenticated, exports.getFilesToPurge);
    app.post('/api/cmpdRegBulkLoader/readSDF', loginRoutes.ensureAuthenticated, exports.cmpdRegBulkLoaderReadSdf);
    app.post('/api/cmpdRegBulkLoader/saveTemplate', loginRoutes.ensureAuthenticated, exports.saveTemplate);
    app.post('/api/cmpdRegBulkLoader', loginRoutes.ensureAuthenticated, exports.postAssignedProperties);
    return app.post('/api/cmpdRegBulkLoader/purgeFile', loginRoutes.ensureAuthenticated, exports.purgeFile);
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
      baseurl = config.all.client.service.cmpdReg.persistence.fullpath + "bulkload/templates?userName=" + req.params.user;
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.getFilesToPurge = function(req, resp) {
    var cmpdRegBulkLoaderTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cmpdRegBulkLoaderTestJSON = require('../public/javascripts/spec/testFixtures/CmpdRegBulkLoaderServiceTestJSON.js');
      return resp.end(JSON.stringify(cmpdRegBulkLoaderTestJSON.filesToPurge));
    } else {
      return resp.end(JSON.stringify([]));
    }
  };

  exports.cmpdRegBulkLoaderReadSdf = function(req, resp) {
    var baseurl, cmpdRegBulkLoaderTestJSON, config, filePath, request, serverUtilityFunctions, uploadsPath;
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
      console.log(uploadsPath);
      filePath = uploadsPath + req.body.fileName;
      req.body.fileName = filePath;
      console.log(req.body);
      baseurl = config.all.client.service.cmpdReg.persistence.fullpath + "bulkload/getSdfProperties";
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(json);
          } else {
            console.log('got ajax error trying to read sdf');
            console.log(error);
            console.log(json);
            console.log(response);
            return resp.end(JSON.stringify("Error"));
          }
        };
      })(this));
    }
  };

  exports.saveTemplate = function(req, resp) {
    var baseurl, config, request;
    console.log("exports.save template");
    if (req.query.testMode || global.specRunnerTestmode) {
      return resp.end('<p>Please fix the following errors and use the "Back" button at the bottom of this screen to upload a new version of the file.</p>\n  <h4 style=\"color:red\">Errors: 1 </h4>\n                         <ul><li> We encountered an internal error. Check the logs at 2015-06-24 14:41:53 </li></ul>\n  <h4>Summary</h4><p>Information:</p>\n                               <ul>\n                               <li>No. of Unique Input Entities: 10</li><li>Requested Pool Size(s): 2</li><li>Replicate Size: 2</li><li>Unique Pools Generated: 45</li><li>Total Pools Generated: 90</li><li>Plates Available: 4</li><li>Rows Excluded: A, B, O, P</li><li>Columns Excluded: 1, 2, 23, 24</li><li>No. of Wells Per Plate: 240</li><li>No. of Total Wells: 960</li>\n                               </ul>');
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.cmpdReg.persistence.fullpath + "bulkload/templates/saveTemplate";
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(json);
          } else {
            console.log('got ajax error trying to save template');
            console.log(error);
            console.log(json);
            console.log(response);
            return resp.end(JSON.stringify("Error"));
          }
        };
      })(this));
    }
  };

  postAssignedProperties = function(req, resp) {
    var config, filePath, registerCompounds, saveTemplate, serverUtilityFunctions, uploadsPath;
    config = require('../conf/compiled/conf.js');
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    console.log("post assigned properties");
    registerCompounds = function(dataToSave, resp) {
      var baseurl, recordedBy, request;
      if (req.query.testMode || global.specRunnerTestmode) {
        console.log("register compounds");
        return resp.end(JSON.stringify("Registration Summary here"));
      } else {
        recordedBy = dataToSave.recordedBy;
        dataToSave.userName = recordedBy;
        delete dataToSave.recordedBy;
        console.log("info to register");
        console.log(dataToSave);
        baseurl = config.all.client.service.cmpdReg.persistence.fullpath + "bulkload/registerSdf";
        request = require('request');
        return request({
          method: 'POST',
          url: baseurl,
          body: dataToSave,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (!error && response.statusCode === 200) {
              console.log(json);
              return resp.json(json);
            } else {
              console.log('got ajax error trying to register compounds');
              console.log(error);
              console.log(json);
              return console.log(response);
            }
          };
        })(this));
      }
    };
    saveTemplate = function(templateInfo, resp) {
      var baseurl, mappings, request;
      console.log("save template");
      if (req.query.testMode || global.specRunnerTestmode) {
        return registerCompounds(templateInfo, resp);
      } else {
        mappings = templateInfo.mappings;
        delete templateInfo.mappings;
        console.log(templateInfo);
        baseurl = config.all.client.service.cmpdReg.persistence.fullpath + "bulkload/templates/saveTemplate";
        request = require('request');
        return request({
          method: 'POST',
          url: baseurl,
          body: templateInfo,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            var filePath, uploadsPath;
            if (!error && response.statusCode === 200) {
              templateInfo.mappings = JSON.parse(mappings);
              console.log("parsed JSON mappings");
              console.log(templateInfo);
              uploadsPath = serverUtilityFunctions.makeAbsolutePath(config.all.server.datafiles.relative_path);
              filePath = uploadsPath + "BulkLoaderTestSDF_1.sdf";
              req.body.filePath = filePath;
              return registerCompounds(templateInfo, resp);
            } else {
              console.log('got ajax error trying to save template');
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
      delete req.body.templateName;
      delete req.body.jsonTemplate;
      delete req.body.ignored;
      uploadsPath = serverUtilityFunctions.makeAbsolutePath(config.all.server.datafiles.relative_path);
      filePath = uploadsPath + "BulkLoaderTestSDF_1.sdf";
      req.body.filePath = filePath;
      req.body.mappings = JSON.parse(req.body.mappings);
      return registerCompounds(req.body, resp);
    }
  };

  exports.postAssignedProperties = function(req, resp) {
    return postAssignedProperties(req, resp);
  };

  exports.purgeFile = function(req, resp) {
    if (req.query.testMode || global.specRunnerTestmode) {
      return resp.end(JSON.stringify("Successful purge in stubsMode."));
    } else {
      return resp.end(JSON.stringify("purge file not implemented yet"));
    }
  };

}).call(this);
