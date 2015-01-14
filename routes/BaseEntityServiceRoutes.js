(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors);
  };

  exports.getAuthors = function(req, resp) {
    var baseEntityServiceTestJSON, csUtilities;
    console.log("getting authors");
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      baseEntityServiceTestJSON = require('../public/javascripts/spec/testFixtures/BaseEntityServiceTestJSON.js');
      return resp.end(JSON.stringify(baseEntityServiceTestJSON.authorsList));
    } else {
      csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
      return csUtilities.getAuthors(resp);
    }
  };

}).call(this);
