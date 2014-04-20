(function() {
  var applicationScripts, requiredScripts;

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/curveCurator/*', loginRoutes.ensureAuthenticated, exports.curveCuratorIndex);
    return app.get('/api/curves/stub/:exptCode', loginRoutes.ensureAuthenticated, exports.getCurveStubs);
  };

  requiredScripts = ['/src/lib/jquery.min.js', '/src/lib/json2.js', '/src/lib/underscore.js', '/src/lib/backbone-min.js', '/src/lib/bootstrap/bootstrap.min.js', '/src/lib/bootstrap/bootstrap-tooltip.js', '/src/lib/jqueryFileUpload/js/vendor/jquery.ui.widget.js', '/src/lib/jqueryFileUpload/js/jquery.iframe-transport.js', '/src/lib/bootstrap/bootstrap.min.js', '/src/lib/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js'];

  applicationScripts = ['/src/conf/conf.js', '/javascripts/src/CurveCurator.js', '/javascripts/src/CurveCuratorAppController.js'];

  exports.getCurveStubs = function(req, resp) {
    var baseurl, config, curveCuratorTestData, request;
    if (global.specRunnerTestmode) {
      console.log(req.params);
      curveCuratorTestData = require('../public/javascripts/spec/testFixtures/curveCuratorTestFixtures.js');
      return resp.end(JSON.stringify(curveCuratorTestData.curveStubs));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.rapache.fullpath + "/experimentcode/curvids/?experimentcode=";
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
            console.log('got ajax error trying to save new experiment');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.curveCuratorIndex = function(request, response) {
    var scriptsToLoad;
    global.specRunnerTestmode = false;
    scriptsToLoad = requiredScripts.concat(applicationScripts);
    return response.render('CurveCurator', {
      title: 'Curve Curator',
      scripts: scriptsToLoad,
      appParams: {
        exampleParam: null
      }
    });
  };

}).call(this);
