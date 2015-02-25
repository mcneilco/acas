(function() {
  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.get('/api/things/:lsType/:lsKind', exports.thingsByTypeKind);
    app.get('/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName);
    app.get('/api/things/:lsType/:lsKind/:code', exports.thingByCodeName);
    app.post('/api/things/:lsType/:lsKind', exports.postThingParent);
    app.post('/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch);
    app.put('/api/things/:lsType/:lsKind/:code', exports.putThing);
    app.get('/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName);
    return app.post('/api/validateName/:lsKind', exports.validateName);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind);
    app.get('/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName);
    app.get('/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName);
    app.post('/api/things/:lsType/:lsKind', exports.postThingParent);
    app.post('/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch);
    app.put('/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing);
    app.get('/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName);
    return app.post('/api/validateName/:lsKind', loginRoutes.ensureAuthenticated, exports.validateName);
  };

  exports.thingsByTypeKind = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, thingServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingServiceTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingServiceTestJSON.batchList));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.thingByCodeName = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.thingParent));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind + "/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postThingParent = function(req, resp) {
    var baseurl, config, request, thingTestJSON;
    console.log("post thing parent");
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.thingParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind;
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 201) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to save lsThing');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.postThingBatch = function(req, resp) {
    var baseurl, config, request, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.thingBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind + "/?parentIdOrCodeName=" + req.params.parentCode;
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 201) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to save lsThing');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putThing = function(req, resp) {
    var baseurl, config, request, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingTestJSON.thingParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind + "/" + req.params.code;
      request = require('request');
      return request({
        method: 'PUT',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to update lsThing');
            console.log(error);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, thingServiceTestJSON;
    console.log("get batches by parent codeName");
    if (req.query.testMode || global.specRunnerTestmode) {
      thingServiceTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingServiceTestJSON.batchList));
    } else {
      if (req.params.parentCode === "undefined") {
        return resp.end(JSON.stringify([]));
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/" + req.params.lsKind + "/getbatches/" + req.params.parentCode;
        serverUtilityFunctions = require('./ServerUtilityFunctions.js');
        return serverUtilityFunctions.getFromACASServer(baseurl, resp);
      }
    }
  };

  exports.validateName = function(req, resp) {
    var baseurl, config, request, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(true));
    } else {
      console.log("validate name");
      console.log(req);
      console.log(JSON.stringify(req.body.requestName));
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/validatename?lsKind=" + req.params.lsKind;
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body.requestName,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          console.log(error);
          if (!error && response.statusCode === 200) {
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to save thing parent');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

}).call(this);
