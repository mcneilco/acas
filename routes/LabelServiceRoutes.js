(function() {
  exports.setupAPIRoutes = function(app) {
    return app.post('/api/getNextLabelSequence', exports.getNextLabelSequence);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/getNextLabelSequence', loginRoutes.ensureAuthenticated, exports.getNextLabelSequence);
  };

  exports.getNextLabelSequence = function(req, resp) {
    var baseurl, config, labelServiceTestJSON, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      labelServiceTestJSON = require('../public/javascripts/spec/testFixtures/LabelServiceTestJSON.js');
      return resp.json(labelServiceTestJSON.nextLabelSequenceResponse);
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "labelsequences/getLabels";
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(json);
          } else {
            console.log('got ajax error trying to get next label sequence');
            console.log(error);
            console.log(json);
            console.log(response);
            return resp.end(JSON.stringify("getNextLabelSequenceFailed"));
          }
        };
      })(this));
    }
  };

}).call(this);
