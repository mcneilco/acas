(function() {
  var csUtilities;

  exports.setupAPIRoutes = function(app) {
    return app.get('/api/cloneValidation/:name', exports.cloneValidation);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/cloneValidation/:name', loginRoutes.ensureAuthenticated, exports.cloneValidation);
  };

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

  exports.cloneValidation = function(req, resp) {
    var psProtocolServiceTestJSON;
    console.log("clone validation");
    console.log(req.params.name);
    if (global.specRunnerTestmode) {
      psProtocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenProtocolServiceTestJSON.js');
      if (req.params.name === "fake") {
        return resp.json([]);
      } else {
        return resp.json(psProtocolServiceTestJSON.successfulCloneValidation);
      }
    } else {
      return csUtilities.validateCloneAndGetTarget(req, resp);
    }
  };

}).call(this);
