(function() {
  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.get('/api/cationicBlockParents/codename/:code', exports.cationicBlockParentByCodeName);
    app.get('/api/cationicBlockParents/:code', exports.cationicBlockParentByCodeName);
    app.post('/api/cationicBlockParents', exports.postCationicBlockParent);
    app.put('/api/cationicBlockParents/:id', exports.putCationicBlockParent);
    app.get('/api/batches/:kind/parentCodeName/:parentCode', exports.batchesByParentCodeName);
    app.get('/api/cationicBlockBatches/codename/:code', exports.cationicBlockBatchesByCodeName);
    app.post('/api/cationicBlockBatches/:parentCode', exports.postCationicBlockBatch);
    app.put('/api/cationicBlockBatches/:id', exports.putCationicBlockBatch);
    return app.post('/api/validateName', exports.validateName);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/cationicBlockParents/codename/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName);
    app.get('/api/cationicBlockParents/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockParentByCodeName);
    app.post('/api/cationicBlockParents', loginRoutes.ensureAuthenticated, exports.postCationicBlockParent);
    app.put('/api/cationicBlockParents/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockParent);
    app.get('/api/batches/:kind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName);
    app.get('/api/cationicBlockBatches/codename/:code', loginRoutes.ensureAuthenticated, exports.cationicBlockBatchesByCodeName);
    app.post('/api/cationicBlockBatches/:parentCode', loginRoutes.ensureAuthenticated, exports.postCationicBlockBatch);
    app.put('/api/cationicBlockBatches/:id', loginRoutes.ensureAuthenticated, exports.putCationicBlockBatch);
    return app.post('/api/validateName/:lsKind', loginRoutes.ensureAuthenticated, exports.validateName);
  };

  exports.validateName = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
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
            console.log('got ajax error trying to save cationic block parent');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
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
    var baseurl, cationicBlockTestJSON, config, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/cationic block";
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
            console.log('got ajax error trying to save cationic block parent');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putCationicBlockParent = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/cationic block/" + req.params.code;
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
            console.log('got ajax error trying to update cationic block parent');
            console.log(error);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var baseurl, cationicBlockServiceTestJSON, config, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockServiceTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockServiceTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockServiceTestJSON.batchList));
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
    var baseurl, cationicBlockTestJSON, config, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/cationic block/?parentIdOrCodeName=" + req.params.parentCode;
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
            console.log('got ajax error trying to save new cationic block batch');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putCationicBlockBatch = function(req, resp) {
    var baseurl, cationicBlockTestJSON, config, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      cationicBlockTestJSON = require('../public/javascripts/spec/testFixtures/CationicBlockTestJSON.js');
      return resp.end(JSON.stringify(cationicBlockTestJSON.cationicBlockBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/cationic block/" + req.params.code;
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
