(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/linkerSmallMoleculeParents/codeName/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeParentByCodeName);
    app.post('/api/linkerSmallMoleculeParents', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeParent);
    app.put('/api/linkerSmallMoleculeParents/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeParent);
    app.get('/api/batches/codeName/:code', loginRoutes.ensureAuthenticated, exports.batchesByCodeName);
    app.post('/api/linkerSmallMoleculeBatches', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeBatch);
    return app.put('/api/linkerSmallMoleculeBatches/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeBatch);
  };

  exports.linkerSmallMoleculeParentByCodeName = function(req, resp) {
    var linkerSmallMoleculeTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent));
    } else {
      return resp.end(JSON.stringify({
        error: "get parent by codename not implemented yet"
      }));
    }
  };

  exports.postLinkerSmallMoleculeParent = function(req, resp) {
    var linkerSmallMoleculeTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent));
    } else {
      return resp.end(JSON.stringify({
        error: "post linker small molecule parent not implemented yet"
      }));
    }
  };

  exports.putLinkerSmallMoleculeParent = function(req, resp) {
    var linkerSmallMoleculeTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent));
    } else {
      return resp.end(JSON.stringify({
        error: "put linker small molecule parent not implemented yet"
      }));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var linkerSmallMoleculeServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeServiceTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeServiceTestJSON.js');
      console.log("batches by parent codeName test mode");
      return resp.end(JSON.stringify(linkerSmallMoleculeServiceTestJSON.batchList));
    } else {
      return resp.end(JSON.stringify({
        error: "get batches by parent codeName not implemented yet"
      }));
    }
  };

  exports.batchesByCodeName = function(req, resp) {
    var linkerSmallMoleculeTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "get batch by codeName not implemented yet"
      }));
    }
  };

  exports.postLinkerSmallMoleculeBatch = function(req, resp) {
    var linkerSmallMoleculeTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "post batch not implemented yet"
      }));
    }
  };

  exports.putLinkerSmallMoleculeBatch = function(req, resp) {
    var linkerSmallMoleculeTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch));
    } else {
      return resp.end(JSON.stringify({
        error: "put batch not implemented yet"
      }));
    }
  };

}).call(this);
