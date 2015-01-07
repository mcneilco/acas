(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/proteinParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.proteinParentByCodeName);
    app.post('/api/proteinParents', loginRoutes.ensureAuthenticated, exports.postProteinParent);
    app.put('/api/proteinParents/:id', loginRoutes.ensureAuthenticated, exports.putProteinParent);
    app.get('/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName);
    app.post('/api/proteinBatches', loginRoutes.ensureAuthenticated, exports.postProteinBatch);
    return app.put('/api/proteinBatches/:id', loginRoutes.ensureAuthenticated, exports.putProteinBatch);
  };

  exports.proteinParentByCodeName = function(req, resp) {
    var proteinTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinTestJSON = require('../public/javascripts/spec/testFixtures/ProteinTestJSON.js');
      return resp.end(JSON.stringify(proteinTestJSON.proteinParent));
    } else {
      return resp.end(JSON.stringify({
        error: "get parent by codename not implemented yet"
      }));
    }
  };

  exports.postProteinParent = function(req, resp) {
    var proteinTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinTestJSON = require('../public/javascripts/spec/testFixtures/ProteinTestJSON.js');
      return resp.end(JSON.stringify(proteinTestJSON.proteinParent));
    } else {
      return resp.end(JSON.stringify({
        error: "post protein parent not implemented yet"
      }));
    }
  };

  exports.putProteinParent = function(req, resp) {
    var proteinTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinTestJSON = require('../public/javascripts/spec/testFixtures/ProteinTestJSON.js');
      return resp.end(JSON.stringify(proteinTestJSON.proteinParent));
    } else {
      return resp.end(JSON.stringify({
        error: "put protein parent not implemented yet"
      }));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var proteinServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProteinServiceTestJSON.js');
      console.log("batches by parent codeName test mode");
      return resp.end(JSON.stringify(proteinServiceTestJSON.batchList));
    } else {
      return resp.end(JSON.stringify({
        error: "get batches by parent codeName not implemented yet"
      }));
    }
  };

  exports.batchesByCodeName = function(req, resp) {
    var proteinTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinTestJSON = require('../public/javascripts/spec/testFixtures/ProteinTestJSON.js');
      return resp.end(JSON.stringify(proteinTestJSON.proteinBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "get batch by codeName not implemented yet"
      }));
    }
  };

  exports.postProteinBatch = function(req, resp) {
    var proteinTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinTestJSON = require('../public/javascripts/spec/testFixtures/ProteinTestJSON.js');
      return resp.end(JSON.stringify(proteinTestJSON.proteinBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "post batch not implemented yet"
      }));
    }
  };

  exports.putProteinBatch = function(req, resp) {
    var proteinTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      proteinTestJSON = require('../public/javascripts/spec/testFixtures/ProteinTestJSON.js');
      return resp.end(JSON.stringify(proteinTestJSON.proteinBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "put batch not implemented yet"
      }));
    }
  };

}).call(this);
