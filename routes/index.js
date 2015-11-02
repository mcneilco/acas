(function() {
  var scriptPaths;

  scriptPaths = require('./RequiredClientScripts.js');

  exports.setupRoutes = function(app, loginRoutes) {
    var config;
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      app.get('/', loginRoutes.ensureAuthenticated, exports.index);
      app.get('/:moduleName/codeName/:code', loginRoutes.ensureAuthenticated, exports.autoLaunchWithCode);
      app.get('/entity/copy/:moduleName/:code', loginRoutes.ensureAuthenticated, exports.copyAndLaunchWithCode);
      app.get('/:moduleName/createFrom/:code', loginRoutes.ensureAuthenticated, exports.autoLaunchCreateFromOtherEntity);
    } else {

    }
    app.get('/:moduleName/codeName/:code', exports.autoLaunchWithCode);
    app.get('/', exports.index);
    if (config.all.server.enableSpecRunner) {
      app.get('/SpecRunner', loginRoutes.ensureAuthenticated, exports.specRunner);
      app.get('/LiveServiceSpecRunner', loginRoutes.ensureAuthenticated, exports.liveServiceSpecRunner);
      return app.get('/CIExcelCompoundPropertiesAppSpecRunner', loginRoutes.ensureAuthenticated, exports.ciExcelCompoundPropertiesAppSpecRunner);
    }
  };

  exports.autoLaunchWithCode = function(req, res) {
    var moduleLaunchParams;
    console.log("autoLaunchWithCode");
    console.log(req.params);
    moduleLaunchParams = {
      moduleName: req.params.moduleName,
      code: req.params.code,
      copy: false,
      createFromOtherEntity: false
    };
    return exports.index(req, res, moduleLaunchParams);
  };

  exports.copyAndLaunchWithCode = function(req, res) {
    var moduleLaunchParams;
    moduleLaunchParams = {
      moduleName: req.params.moduleName,
      code: req.params.code,
      copy: true,
      createFromOtherEntity: false
    };
    return exports.index(req, res, moduleLaunchParams);
  };

  exports.autoLaunchCreateFromOtherEntity = function(req, res) {
    var moduleLaunchParams;
    moduleLaunchParams = {
      moduleName: req.params.moduleName,
      code: req.params.code,
      copy: false,
      createFromOtherEntity: true
    };
    return exports.index(req, res, moduleLaunchParams);
  };

  exports.index = function(req, res, moduleLaunchParams) {
    var config, loginUser, loginUserName, scriptsToLoad;
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
    return res.render('index', {
      title: "ACAS Home",
      scripts: scriptsToLoad,
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: false,
        moduleLaunchParams: moduleLaunchParams != null ? moduleLaunchParams : null,
        deployMode: global.deployMode,
        loggingToMongo: config.all.logging.usemongo
      }
    });
  };

  exports.specRunner = function(req, res) {
    "use strict";
    var scriptsToLoad;
    global.specRunnerTestmode = true;
    scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.jasmineScripts, scriptPaths.specScripts);
    scriptsToLoad = scriptsToLoad.concat(scriptPaths.applicationScripts);
    return res.render('SpecRunner', {
      title: 'SeuratAddOns SpecRunner',
      scripts: scriptsToLoad,
      appParams: {
        loginUserName: 'jmcneil',
        loginUser: {
          id: 2,
          username: "jmcneil",
          email: "jmcneil@example.com",
          firstName: "John",
          lastName: "McNeil"
        },
        testMode: true,
        liveServiceTest: false,
        deployMode: global.deployMode
      }
    });
  };

  exports.ciExcelCompoundPropertiesAppSpecRunner = function(req, res) {
    "use strict";
    global.specRunnerTestmode = true;
    return res.render('CIExcelCompoundPropertiesAppSpecRunner', {
      title: 'SeuratAddOns SpecRunner'
    });
  };

  exports.liveServiceSpecRunner = function(req, res) {
    "use strict";
    var scriptsToLoad, specScripts;
    global.specRunnerTestmode = false;
    specScripts = ['javascripts/spec/ProjectsServiceSpec.js', 'javascripts/spec/ProtocolServiceSpec.js', 'javascripts/spec/PreferredBatchIdServiceSpec.js'];
    scriptsToLoad = scriptPaths.requiredScripts.concat(scriptPaths.jasmineScripts, specScripts);
    scriptsToLoad = scriptsToLoad.concat(scriptPaths.applicationScripts);
    return res.render('LiveServiceSpecRunner', {
      title: 'SeuratAddOns LiveServiceSpecRunner',
      scripts: scriptsToLoad,
      appParams: {
        loginUserName: 'jmcneil',
        loginUser: {
          id: 2,
          username: "jmcneil",
          email: "jmcneil@example.com",
          firstName: "John",
          lastName: "McNeil"
        },
        testMode: false,
        liveServiceTest: true
      }
    });
  };

}).call(this);
