(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/setup/:typeOrKind', exports.setupTypeOrKind);
  };

  exports.setupTypeOrKind = function(req, resp) {
    var baseurl, config, request;
    console.log("setupTypeOrKind");
    if (req.query.testMode || global.specRunnerTestmode) {
      return resp.end(JSON.stringify("set up type or kind"));
    } else {
      config = require('./compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "setup/" + req.params.typeOrKind;
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 201) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to setup type/kind');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

}).call(this);
