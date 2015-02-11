(function() {
  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.get('/api/linkerSmallMoleculeParents/codename/:code', exports.linkerSmallMoleculeParentByCodeName);
    app.get('/api/linkerSmallMoleculeParents/:code', exports.linkerSmallMoleculeParentByCodeName);
    app.post('/api/linkerSmallMoleculeParents', exports.postLinkerSmallMoleculeParent);
    app.put('/api/linkerSmallMoleculeParents/:id', exports.putLinkerSmallMoleculeParent);
    app.get('/api/linkerSmallMoleculeBatches/codename/:code', exports.linkerSmallMoleculeBatchesByCodeName);
    app.post('/api/linkerSmallMoleculeBatches/:parentCode', exports.postLinkerSmallMoleculeBatch);
    return app.put('/api/linkerSmallMoleculeBatches/:id', exports.putLinkerSmallMoleculeBatch);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/linkerSmallMoleculeParents/codename/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeParentByCodeName);
    app.get('/api/linkerSmallMoleculeParents/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeParentByCodeName);
    app.post('/api/linkerSmallMoleculeParents', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeParent);
    app.put('/api/linkerSmallMoleculeParents/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeParent);
    app.get('/api/linkerSmallMoleculeBatches/codename/:code', loginRoutes.ensureAuthenticated, exports.linkerSmallMoleculeBatchesByCodeName);
    app.post('/api/linkerSmallMoleculeBatches/:parentCode', loginRoutes.ensureAuthenticated, exports.postLinkerSmallMoleculeBatch);
    return app.put('/api/linkerSmallMoleculeBatches/:id', loginRoutes.ensureAuthenticated, exports.putLinkerSmallMoleculeBatch);
  };

  exports.linkerSmallMoleculeParentByCodeName = function(req, resp) {
    var baseurl, config, linkerSmallMoleculeTestJSON, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/linker small molecule/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postLinkerSmallMoleculeParent = function(req, resp) {
    var baseurl, config, linkerSmallMoleculeTestJSON, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/linker small molecule";
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
            console.log('got ajax error trying to save linker small molecule parent');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putLinkerSmallMoleculeParent = function(req, resp) {
    var baseurl, config, linkerSmallMoleculeTestJSON, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeParent));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/parent/linker small molecule/" + req.params.code;
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
            console.log('got ajax error trying to update linker small molecule parent');
            console.log(error);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.linkerSmallMoleculeBatchesByCodeName = function(req, resp) {
    var baseurl, config, linkerSmallMoleculeTestJSON, serverUtilityFunctions;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/linker small molecule/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postLinkerSmallMoleculeBatch = function(req, resp) {
    var baseurl, config, linkerSmallMoleculeTestJSON, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/linker small molecule/?parentIdOrCodeName=" + req.params.parentCode;
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
            console.log('got ajax error trying to save new linker small molecule batch');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putLinkerSmallMoleculeBatch = function(req, resp) {
    var baseurl, config, linkerSmallMoleculeTestJSON, request;
    if (req.query.testMode || global.specRunnerTestmode) {
      linkerSmallMoleculeTestJSON = require('../public/javascripts/spec/testFixtures/LinkerSmallMoleculeTestJSON.js');
      return resp.end(JSON.stringify(linkerSmallMoleculeTestJSON.linkerSmallMoleculeBatch));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/linker small molecule/" + req.params.code;
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
