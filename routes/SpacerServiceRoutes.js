(function() {
  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.get('/api/spacerParents/codename/:code', exports.spacerParentByCodeName);
    app.get('/api/spacerParents/:code', exports.spacerParentByCodeName);
    app.post('/api/spacerParents', exports.postSpacerParent);
    app.put('/api/spacerParents/:id', exports.putSpacerParent);
    app.get('/api/spacerBatches/codename/:code', exports.spacerBatchesByCodeName);
    app.post('/api/spacerBatches/:parentCode', exports.postSpacerBatch);
    return app.put('/api/spacerBatches/:id', exports.putSpacerBatch);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/spacerParents/codename/:code', loginRoutes.ensureAuthenticated, exports.spacerParentByCodeName);
    app.get('/api/spacerParents/:code', loginRoutes.ensureAuthenticated, exports.spacerParentByCodeName);
    app.post('/api/spacerParents', loginRoutes.ensureAuthenticated, exports.postSpacerParent);
    app.put('/api/spacerParents/:id', loginRoutes.ensureAuthenticated, exports.putSpacerParent);
    app.get('/api/spacerBatches/codename/:code', loginRoutes.ensureAuthenticated, exports.spacerBatchesByCodeName);
    app.post('/api/spacerBatches/:parentCode', loginRoutes.ensureAuthenticated, exports.postSpacerBatch);
    return app.put('/api/spacerBatches/:id', loginRoutes.ensureAuthenticated, exports.putSpacerBatch);
  };

  exports.spacerParentByCodeName = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerParent));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/spacer/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postSpacerParent = function(req, resp) {
    var baseurl, config, request, spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/spacer";
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
            console.log('got ajax error trying to save spacer parent');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putSpacerParent = function(req, resp) {
    var baseurl, config, request, spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/spacer/" + req.params.code;
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
            console.log('got ajax error trying to update spacer parent');
            console.log(error);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, spacerServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerServiceTestJSON = require('../public/javascripts/spec/testFixtures/SpacerServiceTestJSON.js');
      return resp.end(JSON.stringify(spacerServiceTestJSON.batchList));
    } else {
      if (req.params.parentCode === "undefined") {
        return resp.end(JSON.stringify([]));
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/" + req.params.kind + "/getbatches/" + req.params.parentCode;
        serverUtilityFunctions = require('./ServerUtilityFunctions.js');
        return serverUtilityFunctions.getFromACASServer(baseurl, resp);
      }
    }
  };

  exports.spacerBatchesByCodeName = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/spacer/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postSpacerBatch = function(req, resp) {
    var baseurl, config, request, spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/spacer/?parentIdOrCodeName=" + req.params.parentCode;
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
            console.log('got ajax error trying to save new spacer batch');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putSpacerBatch = function(req, resp) {
    var baseurl, config, request, spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/spacer/" + req.params.code;
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
            console.log('got ajax error trying to save new experiment');
            console.log(error);
            return console.log(response);
          }
        };
      })(this));
    }
  };

}).call(this);
