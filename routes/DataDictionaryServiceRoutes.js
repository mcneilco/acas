(function() {
  exports.setupAPIRoutes = function(app) {
    return app.get('/api/dataDict/:kind', exports.getDataDictValues);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/dataDict/:kind', loginRoutes.ensureAuthenticated, exports.getDataDictValues);
  };

  exports.getDataDictValues = function(req, resp) {
    var dataDictServiceTestJSON;
    if (global.specRunnerTestmode) {
      dataDictServiceTestJSON = require('../public/javascripts/spec/testFixtures/dataDictServiceTestJSON.js');
      return resp.end(JSON.stringify(dataDictServiceTestJSON.dataDictValues));
    } else {
      dataDictServiceTestJSON = require('../public/javascripts/spec/testFixtures/dataDictServiceTestJSON.js');
      return resp.end(JSON.stringify(dataDictServiceTestJSON.dataDictValues));
    }
  };

}).call(this);
