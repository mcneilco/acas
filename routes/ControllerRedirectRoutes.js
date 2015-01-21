(function() {
  var config, request, _;

  _ = require('underscore');

  request = require('request');

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/entity/edit/codeName/:code', loginRoutes.ensureAuthenticated, exports.redirectToEditor);
  };

  config = require('../conf/compiled/conf.js');

  exports.redirectToEditor = function(req, resp) {
    var controllerRedirectConf, controllerRedirectConfFile, isStub, prefix, prefixKeyIndex, queryPrefix;
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      controllerRedirectConfFile = require('../conf/ControllerRedirectConf.js');
      controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf;
      queryPrefix = null;
      prefixKeyIndex = 0;
      while (queryPrefix === null && prefixKeyIndex < (Object.keys(controllerRedirectConf)).length) {
        prefix = Object.keys(controllerRedirectConf)[prefixKeyIndex];
        if (req.params.code.indexOf(prefix) > -1) {
          queryPrefix = prefix;
        } else {
          prefixKeyIndex += 1;
        }
      }
      if (queryPrefix !== null) {
        isStub = controllerRedirectConf[queryPrefix]["stub"];
        return request({
          json: true,
          url: "http://localhost:" + config.all.server.nodeapi.port + "/api/" + controllerRedirectConf[queryPrefix]["entityName"] + "/codename/" + req.params.code
        }, (function(_this) {
          return function(error, response, body) {
            var deepLink, kind, stub;
            if (isStub) {
              stub = response.body[0];
              kind = stub.lsKind;
            } else {
              kind = response.body.lsKind;
            }
            deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"];
            return resp.redirect("/" + deepLink + "/codeName/" + req.params.code);
          };
        })(this));
      } else {
        return resp.redirect("/#");
      }
    } else {
      controllerRedirectConfFile = require('../conf/ControllerRedirectConf.js');
      controllerRedirectConf = controllerRedirectConfFile.controllerRedirectConf;
      queryPrefix = null;
      prefixKeyIndex = 0;
      while (queryPrefix === null && prefixKeyIndex < (Object.keys(controllerRedirectConf)).length) {
        prefix = Object.keys(controllerRedirectConf)[prefixKeyIndex];
        if (req.params.code.indexOf(prefix) > -1) {
          queryPrefix = prefix;
        } else {
          prefixKeyIndex += 1;
        }
      }
      if (queryPrefix !== null) {
        return request({
          json: true,
          url: config.all.server.nodeapi.path + "/api/" + controllerRedirectConf[queryPrefix]["entityName"] + "/codename/" + req.params.code
        }, (function(_this) {
          return function(error, response, body) {
            var deepLink, kind;
            console.log(error);
            console.log(response);
            console.log(body);
            kind = response.body[0].lsKind;
            deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"];
            return resp.redirect("/" + deepLink + "/codeName/" + req.params.code);
          };
        })(this));
      } else {
        return resp.redirect("/#");
      }
    }
  };

}).call(this);
