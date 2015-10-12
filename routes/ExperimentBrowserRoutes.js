
/* To install this Module
Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Experiment Browser", mainControllerClassName: "ExperimentBrowserController"}
 */

(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/experimentsForProtocol/:protocolCode', loginRoutes.ensureAuthenticated, exports.experimentsForProtocol);
  };

  exports.experimentsForProtocol = function(req, resp) {
    var baseurl, config, fixturesData, request;
    fixturesData = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
    config = require('./compiled/conf.js');
    baseurl = config.all.client.service.persistence.fullpath + ("experiments/protocol/" + req.params.protocolCode);
    console.log("baseurl");
    console.log(baseurl);
    request = require('request');
    return request({
      method: 'GET',
      url: baseurl,
      body: req.body,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error) {
          console.log(JSON.stringify(json));
          resp.setHeader('Content-Type', 'application/json');
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to save new experiment');
          console.log(error);
          console.log(json);
          console.log(response);
          return resp.end(JSON.stringify({
            error: "something went wrong :("
          }));
        }
      };
    })(this));
  };

}).call(this);
