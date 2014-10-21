(function() {
  var _;

  _ = require("underscore");

  exports.setupAPIRoutes = function(app) {
    return app.get('/api/dataDict/:type/:kind', exports.getDataDictValues);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/dataDict/:type/:kind', loginRoutes.ensureAuthenticated, exports.getDataDictValues);
  };

  exports.getDataDictValues = function(req, resp) {
    var baseurl, codeTableServiceTestJSON, config, correctCodeTable, request;
    if (global.specRunnerTestmode) {
      codeTableServiceTestJSON = require('../public/javascripts/spec/testFixtures/CodeTableJSON.js');
      correctCodeTable = _.findWhere(codeTableServiceTestJSON.codes, {
        type: req.params.type,
        kind: req.params.kind
      });
      return resp.end(JSON.stringify(correctCodeTable['codes']));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "api/v1/ddictvalues/all/" + req.params.type + "/" + req.params.kind + "/codetable";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(json);
          } else {
            console.log('got ajax error trying to get protocol labels');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

}).call(this);
