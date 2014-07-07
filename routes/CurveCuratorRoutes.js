(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/curves/stubs/:exptCode', loginRoutes.ensureAuthenticated, exports.getCurveStubs);
    app.get('/api/curve/detail/:id', loginRoutes.ensureAuthenticated, exports.getCurveDetail);
    app.put('/api/curve/detail/:id', loginRoutes.ensureAuthenticated, exports.updateCurve);
    return app.get('/curveCurator/*', loginRoutes.ensureAuthenticated, exports.curveCuratorIndex);
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
      console.log(baseurl + req.params.exptCode);
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
            console.log(response);
            return resp.end('error');
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
            console.log(response);
            return resp.end('error');
          }
        };
      })(this));
    }
  };

  exports.updateCurveUserFlag = function(req, resp) {
    var baseurl, config, curveCuratorTestData, request;
    if (global.specRunnerTestmode) {
      curveCuratorTestData = require('../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js');
      return resp.end(JSON.stringify(curveCuratorTestData.curveDetail));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "/curve/flag/user";
      request = require('request');
      console.log(JSON.stringify(req.body));
      return request({
        method: 'POST',
        url: baseurl,
        body: JSON.stringify(req.body),
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to update user flag');
            console.log(error);
            console.log(json);
            console.log(response);
            return resp.end(json);
          }
        };
      })(this));
    }
  };

  exports.updateCurve = function(req, resp) {
    var baseurl, config, curveCuratorTestData, request;
    if (global.specRunnerTestmode) {
      curveCuratorTestData = require('../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js');
      return resp.end(JSON.stringify(curveCuratorTestData.curveDetail));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "/curve/detail/";
      request = require('request');
      console.log(JSON.stringify(req.body));
      return request({
        method: 'POST',
        url: baseurl,
        body: JSON.stringify(req.body),
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to refit curve');
            console.log(error);
            console.log(json);
            console.log(response);
            return resp.end(json);
          }
        };
      })(this));
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
