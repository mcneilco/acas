(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/internalizationAgentParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.internalizationAgentParentByCodeName);
    app.post('/api/internalizationAgentParents', loginRoutes.ensureAuthenticated, exports.postInternalizationAgentParent);
    app.put('/api/internalizationAgentParents/:id', loginRoutes.ensureAuthenticated, exports.putInternalizationAgentParent);
    app.get('/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName);
    app.post('/api/internalizationAgentBatches', loginRoutes.ensureAuthenticated, exports.postInternalizationAgentBatch);
    return app.put('/api/internalizationAgentBatches/:id', loginRoutes.ensureAuthenticated, exports.putInternalizationAgentBatch);
  };

  exports.internalizationAgentParentByCodeName = function(req, resp) {
    var internalizationAgentTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js');
      return resp.end(JSON.stringify(internalizationAgentTestJSON.internalizationAgentParent));
    } else {
      return resp.end(JSON.stringify({
        error: "get parent by codename not implemented yet"
      }));
    }
  };

  exports.postInternalizationAgentParent = function(req, resp) {
    var internalizationAgentTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js');
      return resp.end(JSON.stringify(internalizationAgentTestJSON.internalizationAgentParent));
    } else {
      return resp.end(JSON.stringify({
        error: "post internalizationAgent parent not implemented yet"
      }));
    }
  };

  exports.putInternalizationAgentParent = function(req, resp) {
    var internalizationAgentTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js');
      return resp.end(JSON.stringify(internalizationAgentTestJSON.internalizationAgentParent));
    } else {
      return resp.end(JSON.stringify({
        error: "put internalizationAgent parent not implemented yet"
      }));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var internalizationAgentServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentServiceTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentServiceTestJSON.js');
      console.log("batches by parent codeName test mode");
      return resp.end(JSON.stringify(internalizationAgentServiceTestJSON.batchList));
    } else {
      return resp.end(JSON.stringify({
        error: "get batches by parent codeName not implemented yet"
      }));
    }
  };

  exports.batchesByCodeName = function(req, resp) {
    var internalizationAgentTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js');
      return resp.end(JSON.stringify(internalizationAgentTestJSON.internalizationAgentBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "get batch by codeName not implemented yet"
      }));
    }
  };

  exports.postInternalizationAgentBatch = function(req, resp) {
    var internalizationAgentTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js');
      return resp.end(JSON.stringify(internalizationAgentTestJSON.internalizationAgentBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "post batch not implemented yet"
      }));
    }
  };

  exports.putInternalizationAgentBatch = function(req, resp) {
    var internalizationAgentTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      internalizationAgentTestJSON = require('../public/javascripts/spec/testFixtures/InternalizationAgentTestJSON.js');
      return resp.end(JSON.stringify(internalizationAgentTestJSON.internalizationAgentBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "put batch not implemented yet"
      }));
    }
  };

}).call(this);
