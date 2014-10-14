(function() {
  var csUtilities;

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

  exports.setupAPIRoutes = function(app) {
    return app.get('/api/customerMolecularTargetCodeTable', exports.getCustomerMolecularTargetCodes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/customerMolecularTargetCodeTable', loginRoutes.ensureAuthenticated, exports.getCustomerMolecularTargetCodes);
  };

  exports.getCustomerMolecularTargetCodes = function(req, resp) {
    var molecTargetTestJSON;
    if (global.specRunnerTestmode) {
      molecTargetTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(molecTargetTestJSON.customerMolecularTargetCodeTable));
    } else {
      return csUtilities.getCustomerMolecularTargetCodes(resp);
    }
  };

}).call(this);
