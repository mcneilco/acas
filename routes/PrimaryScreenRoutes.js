(function() {
  exports.setupAPIRoutes = function(app) {
    app.get('/api/transformationCodes', exports.getTransformationCodes);
    return app.get('/api/normalizationCodes', exports.getNormalizationCodes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/transformationCodes', loginRoutes.ensureAuthenticated, exports.getTransformationCodes);
    return app.get('/api/normalizationCodes', loginRoutes.ensureAuthenticated, exports.getNormalizationCodes);
  };

  exports.getTransformationCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.transformationCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.transformationCodes);
    }
  };

  exports.getNormalizationCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.normalizationCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.normalizationCodes);
    }
  };

}).call(this);
