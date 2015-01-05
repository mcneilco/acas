(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/things/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodename);
    app.get('/api/things/:id', loginRoutes.ensureAuthenticated, exports.thingById);
    app.post('/api/things', loginRoutes.ensureAuthenticated, exports.postThing);
    app.put('/api/things/:id', loginRoutes.ensureAuthenticated, exports.putThing);
    app["delete"]('/api/things/:id', loginRoutes.ensureAuthenticated, exports.deleteThing);
    return app.get('/api/authors', loginRoutes.ensureAuthenticated, exports.getAuthors);
  };

  exports.thingByCodename = function(req, resp) {
    var thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.siRNA));
    } else {
      return resp.end(JSON.stringify({
        error: "get thing by codename not implemented yet"
      }));
    }
  };

  exports.thingById = function(req, resp) {
    var thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.siRNA));
    } else {
      return resp.end(JSON.stringify({
        error: "get thing by id not implemented yet"
      }));
    }
  };

  exports.postThing = function(req, resp) {
    var thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.siRNA));
    } else {
      return resp.end(JSON.stringify({
        error: "post thing not implemented yet"
      }));
    }
  };

  exports.putThing = function(req, resp) {
    var thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.siRNA));
    } else {
      return resp.end(JSON.stringify({
        error: "put thing not implemented yet"
      }));
    }
  };

  exports.deleteThing = function(req, resp) {
    if (req.query.testMode || global.specRunnerTestmode) {
      return resp.end(JSON.stringify({
        message: "deleted thing"
      }));
    } else {
      return resp.end(JSON.stringify({
        error: "delete thing not implemented yet"
      }));
    }
  };

  exports.getAuthors = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, thingServiceTestJSON;
    console.log("getting authors");
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      thingServiceTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingServiceTestJSON.authorsList));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "authors/codeTable";
      console.log(baseurl);
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

}).call(this);
