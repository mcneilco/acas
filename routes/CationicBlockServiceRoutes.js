(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/cationicBlockParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName);
    app.post('/api/cationicBlockParents', loginRoutes.ensureAuthenticated, exports.postCationicBlockParent);
    app.put('/api/cationicBlockParents/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockParent);
    app.get('/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName);
    app.post('/api/cationicBlockBatches', loginRoutes.ensureAuthenticated, exports.postCationicBlockBatch);
    return app.put('/api/cationicBlockBatches/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockBatch);
  };

  exports.cationicBlockParentByCodeName = function(req, resp) {
    var cationicBlockTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/cationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      return resp.end(JSON.stringify({
        error: "get parent by codename not implemented yet"
      }));
    }
  };

  exports.postCationicBlockParent = function(req, resp) {
    var cationicBlockTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      console.log('post cbp in test mode');
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      return resp.end(JSON.stringify({
        error: "post cationic block parent not implemented yet"
      }));
    }
  };

  exports.putCationicBlockParent = function(req, resp) {
    var cationicBlockTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      return resp.end(JSON.stringify({
        error: "put cationic block parent not implemented yet"
      }));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var cationicBlockServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockServiceTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js');
      console.log("batches by parent codeName test mode");
      return resp.end(JSON.stringify(cationicBlockServiceTestJSON.batchList));
    } else {
      return resp.end(JSON.stringify({
        error: "get batches by parent codeName not implemented yet"
      }));
    }
  };

  exports.batchesByCodeName = function(req, resp) {
    var cationicBlockTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "get batch by codeName not implemented yet"
      }));
    }
  };

  exports.postCationicBlockBatch = function(req, resp) {
    var cationicBlockTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "post batch not implemented yet"
      }));
    }
  };

  exports.putCationicBlockBatch = function(req, resp) {
    var cationicBlockTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "put batch not implemented yet"
      }));
    }
  };

}).call(this);
