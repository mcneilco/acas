(function() {
  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/cationicBlockParents/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName);
    app.post('/api/cationicBlockParents', loginRoutes.ensureAuthenticated, exports.postCationicBlockParent);
    app.put('/api/cationicBlockParents/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockParent);
    app.get('/api/batches/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName);
    app.get('/api/cationicBlockBatches/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockBatchesByCodeName);
    app.post('/api/cationicBlockBatches', loginRoutes.ensureAuthenticated, exports.postCationicBlockBatch);
    return app.put('/api/cationicBlockBatches/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockBatch);
  };

  exports.cationicBlockParentByCodeName = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/cationic block/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postCationicBlockParent = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      console.log('post cbp in test mode');
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/cationic block/";
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.putCationicBlockParent = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/cationic block/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var baseurl, cationicBlockServiceTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockServiceTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js');
      console.log("batches by parent codeName test mode");
      return resp.end(JSON.stringify(cationicBlockServiceTestJSON.batchList));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/cationic block/getbatches/" + req.params.parentCode;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.cationicBlockBatchesByCodeName = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/cationic block/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postCationicBlockBatch = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/cationic block/";
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.putCationicBlockBatch = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/cationic block/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

}).call(this);
