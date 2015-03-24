(function() {
  var config, request, _;

  _ = require('underscore');

  request = require('request');

  exports.setupAPIRoutes = function(app, loginRoutes) {
    return app.get('/entity/edit/codeName/:code', exports.redirectToEditor);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/entity/edit/codeName/:code', loginRoutes.ensureAuthenticated, exports.redirectToEditor);
    return app.get('/api/labelsequences', loginRoutes.ensureAuthenticated, exports.getLabelSequences);
  };

  config = require('../conf/compiled/conf.js');

  exports.redirectToEditor = function(req, resp) {
    var controllerRedirectConf, controllerRedirectConfFile, prefix, prefixKeyIndex, queryPrefix;
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
          kind = response.body.lsKind;
          deepLink = controllerRedirectConf[queryPrefix][kind]["deepLink"];
          return resp.redirect("/" + deepLink + "/codeName/" + req.params.code);
        };
      })(this));
    } else {
      return resp.redirect("/#");
    }
  };

  exports.getLabelSequences = function(req, resp) {
    var baseurl, serverUtilityFunctions;
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    baseurl = config.all.client.service.persistence.fullpath + "/labelsequences";
    return serverUtilityFunctions.getFromACASServer(baseurl, resp);
  };

}).call(this);
