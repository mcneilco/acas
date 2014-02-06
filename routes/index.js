(function() {
  var scriptPaths;

  scriptPaths = require('./RequiredClientScripts.js');

  exports.setupRoutes = function(app, loginRoutes) {
    var config;
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      app.get('/', loginRoutes.ensureAuthenticated, exports.index);
      app.get('/:moduleName/codeName/:code', loginRoutes.ensureAuthenticated, exports.autoLaunchWithCode);
    } else {

    }
    app.get('/:moduleName/codeName/:code', exports.autoLaunchWithCode);
    app.get('/', exports.index);
    if (config.all.server.enableSpecRunner) {
      app.get('/SpecRunner', exports.specRunner);
      return app.get('/LiveServiceSpecRunner', exports.liveServiceSpecRunner);
    }
  };

  exports.autoLaunchWithCode = function(req, res) {
    var moduleLaunchParams;
    moduleLaunchParams = {
      moduleName: req.params.moduleName,
      code: req.params.code
    };
    return exports.index(req, res, moduleLaunchParams);
  };

  exports.index = function(req, res, moduleLaunchParams) {
    var config, loginUser, loginUserName, scriptsToLoad;
    config = require('../conf/compiled/conf.js');
    global.specRunnerTestmode = true;
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
        deployMode: global.deployMode
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

  exports.liveServiceSpecRunner = function(req, res) {
    "use strict";
    var scriptsToLoad, specScripts;
    global.specRunnerTestmode = false;
    specScripts = ['javascripts/spec/ProjectsServiceSpec.js', 'javascripts/spec/ProtocolServiceSpec.js', 'javascripts/spec/PreferredBatchIdServiceSpec.js'];
    scriptsToLoad = requiredScripts.concat(scriptPaths.jasmineScripts, specScripts);
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
