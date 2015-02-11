(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/components/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericComponentsSearch);
  };

  exports.genericComponentsSearch = function(req, res) {
    var baseurl, componentBrowserServiceTestJSON, config, emptyResponse, serverUtilityFunctions;
    if (global.specRunnerTestmode) {
      componentBrowserServiceTestJSON = require('../public/javascripts/spec/testFixtures/ComponentBrowserServiceTestJSON.js');
      if (req.params.searchTerm === "no-match") {
        emptyResponse = [];
        return res.end(JSON.stringify(emptyResponse));
      } else {
        return res.end(JSON.stringify([componentBrowserServiceTestJSON.cationicBlockBatch]));
      }
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/search?lsType=batch&q=" + req.params.searchTerm;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, res);
    }
  };

}).call(this);
