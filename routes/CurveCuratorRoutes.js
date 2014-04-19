(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    var config;
    app.get('/api/curves/stubs/:exptCode', exports.getCurveStubs);
    app.get('/api/curve/detail/:id', exports.getCurveDetail);
    app.post('/api/curve/fit', exports.refitCurve);
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      return app.get('/curveCurator/*', loginRoutes.ensureAuthenticated, exports.curveCuratorIndex);
    } else {
      return app.get('/curveCurator/*', exports.curveCuratorIndex);
    }
  };

  exports.getCurveStubs = function(req, resp) {
    var baseurl, config, curveCuratorTestData, request;
    if (global.specRunnerTestmode) {
      curveCuratorTestData = require('../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js');
      return resp.end(JSON.stringify(curveCuratorTestData.curveCuratorThumbs));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "/experimentcode/curveids/?experimentcode=";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl + req.params.exptCode,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            console.log(JSON.stringify(json));
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to retrieve curve stubs');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.getCurveDetail = function(req, resp) {
    var baseurl, config, curveCuratorTestData, request;
    if (global.specRunnerTestmode) {
      curveCuratorTestData = require('../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js');
      return resp.end(JSON.stringify(curveCuratorTestData.curveDetail));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "/curve/detail/?id=";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl + req.params.id,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            console.log(JSON.stringify(json));
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to retrieve curve detail');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.refitCurve = function(req, resp) {
    var curveCuratorTestData;
    if (global.specRunnerTestmode) {
      curveCuratorTestData = require('../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js');
      return resp.end(JSON.stringify(curveCuratorTestData.curveDetail));
    } else {
      return console.log('not implemented yet');
    }
  };

  exports.curveCuratorIndex = function(req, resp) {
    var config, loginUser, loginUserName, scriptPaths, scriptsToLoad;
    global.specRunnerTestmode = global.stubsMode ? true : false;
    scriptPaths = require('./RequiredClientScripts.js');
    config = require('../conf/compiled/conf.js');
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
    return resp.render('CurveCurator', {
      title: 'Curve Curator',
      scripts: scriptsToLoad,
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: global.specRunnerTestmode,
        moduleLaunchParams: typeof moduleLaunchParams !== "undefined" && moduleLaunchParams !== null ? moduleLaunchParams : null,
        deployMode: global.deployMode
      }
    });
  };

}).call(this);
