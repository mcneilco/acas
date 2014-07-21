(function() {
  exports.setupAPIRoutes = function(app) {
    return app.get('/api/dataDict/:kind', exports.getDataDictValues);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/dataDict/:kind', loginRoutes.ensureAuthenticated, exports.getDataDictValues);
  };

  exports.getDataDictValues = function(req, resp) {
    var baseurl, config, dataDictServiceTestJSON, request;
    if (global.specRunnerTestmode) {
      dataDictServiceTestJSON = require('../public/javascripts/spec/testFixtures/dataDictServiceTestJSON.js');
      return resp.end(JSON.stringify(dataDictServiceTestJSON.dataDictValues[req.params.kind]));
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
