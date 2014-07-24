(function() {
  exports.setupAPIRoutes = function(app) {
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/instrumentReaderCodes', exports.getInstrumentReaderCodes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/signalDirectionCodes', exports.getSignalDirectionCodes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy1Codes', exports.getAggregateBy1Codes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy2Codes', exports.getAggregateBy2Codes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/transformationCodes', exports.getTransformationCodes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/normalizationCodes', exports.getNormalizationCodes);
    return app.get('/api/primaryAnalysis/runPrimaryAnalysis/readNameCodes', exports.getReadNameCodes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.post('/api/primaryAnalysis/runPrimaryAnalysis', loginRoutes.ensureAuthenticated, exports.runPrimaryAnalysis);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/instrumentReaderCodes', loginRoutes.ensureAuthenticated, exports.getInstrumentReaderCodes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/signalDirectionCodes', loginRoutes.ensureAuthenticated, exports.getSignalDirectionCodes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy1Codes', loginRoutes.ensureAuthenticated, exports.getAggregateBy1Codes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/aggregateBy2Codes', loginRoutes.ensureAuthenticated, exports.getAggregateBy2Codes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/transformationCodes', loginRoutes.ensureAuthenticated, exports.getTransformationCodes);
    app.get('/api/primaryAnalysis/runPrimaryAnalysis/normalizationCodes', loginRoutes.ensureAuthenticated, exports.getNormalizationCodes);
    return app.get('/api/primaryAnalysis/runPrimaryAnalysis/readNameCodes', loginRoutes.ensureAuthenticated, exports.getReadNameCodes);
  };

  exports.runPrimaryAnalysis = function(request, response) {
    var serverUtilityFunctions;
    request.connection.setTimeout(1800000);
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    console.log(request.body);
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    if (global.specRunnerTestmode) {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/PrimaryScreen/src/server/PrimaryAnalysisStub.R", "runPrimaryAnalysis", function(rReturn) {
        return response.end(rReturn);
      });
    } else {
      return serverUtilityFunctions.runRFunction(request, "public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R", "runPrimaryAnalysis", function(rReturn) {
        return response.end(rReturn);
      });
    }
  };

  exports.getInstrumentReaderCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.instrumentReaderCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.instrumentReaderCodes);
    }
  };

  exports.getSignalDirectionCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.signalDirectionCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.signalDirectionCodes);
    }
  };

  exports.getAggregateBy1Codes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.aggregateBy1Codes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.aggregateBy1Codes);
    }
  };

  exports.getAggregateBy2Codes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.aggregateBy2Codes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.aggregateBy2Codes);
    }
  };

  exports.getTransformationCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.transformationCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.transformationCodes);
    }
  };

  exports.getNormalizationCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.normalizationCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.normalizationCodes);
    }
  };

  exports.getReadNameCodes = function(req, resp) {
    var primaryScreenTestJSON;
    if (global.specRunnerTestmode) {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.readNameCodes);
    } else {
      primaryScreenTestJSON = require('../public/javascripts/spec/testFixtures/PrimaryScreenTestJSON.js');
      return resp.json(primaryScreenTestJSON.readNameCodes);
    }
  };

}).call(this);
