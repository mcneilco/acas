(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors);
  };

  exports.getAuthors = function(req, resp) {
    var baseEntityServiceTestJSON, baseurl, config, serverUtilityFunctions;
    console.log("getting authors");
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      baseEntityServiceTestJSON = require('../public/javascripts/spec/testFixtures/BaseEntityServiceTestJSON.js');
      return resp.end(JSON.stringify(baseEntityServiceTestJSON.authorsList));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "api/v1/authors/codeTable";
      console.log(baseurl);
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

}).call(this);
