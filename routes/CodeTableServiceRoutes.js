(function() {
  exports.setupAPIRoutes = function(app) {
    return app.get('/api/dataDict/:kind', exports.getDataDictValues);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/dataDict/:kind', loginRoutes.ensureAuthenticated, exports.getDataDictValues);
  };

  exports.getDataDictValues = function(req, resp) {
    var baseurl, codeTableServiceTestJSON, config, i, request, _i, _len, _ref, _results;
    if (global.specRunnerTestmode) {
      codeTableServiceTestJSON = require('../public/javascripts/spec/testFixtures/CodeTableJSON.js');
      _ref = codeTableServiceTestJSON.codes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (i[req.params.kind]) {
          console.log("success");
          _results.push(resp.end(JSON.stringify(i[req.params.kind])));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "api/v1/ddictvalues/bytype/" + req.params.kind + "/codetable";
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
