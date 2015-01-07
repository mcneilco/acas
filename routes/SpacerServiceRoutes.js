(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/spacerParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.spacerParentByCodeName);
    app.post('/api/spacerParents', loginRoutes.ensureAuthenticated, exports.postSpacerParent);
    app.put('/api/spacerParents/:id', loginRoutes.ensureAuthenticated, exports.putSpacerParent);
    app.get('/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName);
    app.post('/api/spacerBatches', loginRoutes.ensureAuthenticated, exports.postSpacerBatch);
    return app.put('/api/spacerBatches/:id', loginRoutes.ensureAuthenticated, exports.putSpacerBatch);
  };

  exports.spacerParentByCodeName = function(req, resp) {
    var spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerParent));
    } else {
      return resp.end(JSON.stringify({
        error: "get parent by codename not implemented yet"
      }));
    }
  };

  exports.postSpacerParent = function(req, resp) {
    var spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerParent));
    } else {
      return resp.end(JSON.stringify({
        error: "post spacer parent not implemented yet"
      }));
    }
  };

  exports.putSpacerParent = function(req, resp) {
    var spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerParent));
    } else {
      return resp.end(JSON.stringify({
        error: "put spacer parent not implemented yet"
      }));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var spacerServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerServiceTestJSON = require('../public/javascripts/spec/testFixtures/SpacerServiceTestJSON.js');
      console.log("batches by parent codeName test mode");
      return resp.end(JSON.stringify(spacerServiceTestJSON.batchList));
    } else {
      return resp.end(JSON.stringify({
        error: "get batches by parent codeName not implemented yet"
      }));
    }
  };

  exports.batchesByCodeName = function(req, resp) {
    var spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "get batch by codeName not implemented yet"
      }));
    }
  };

  exports.postSpacerBatch = function(req, resp) {
    var spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "post batch not implemented yet"
      }));
    }
  };

  exports.putSpacerBatch = function(req, resp) {
    var spacerTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      spacerTestJSON = require('../public/javascripts/spec/testFixtures/SpacerTestJSON.js');
      return resp.end(JSON.stringify(spacerTestJSON.spacerBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "put batch not implemented yet"
      }));
    }
  };

}).call(this);
