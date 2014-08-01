(function() {
  exports.setupAPIRoutes = function(app) {
    app.get('/api/experiments/codename/:code', exports.experimentByCodename);
    app.get('/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename);
    app.get('/api/experiments/:id', exports.experimentById);
    app.post('/api/experiments', exports.postExperiment);
    app.put('/api/experiments/:id', exports.putExperiment);
    return app.get('/api/experimentStatusCodes', exports.getExperimentStatusCodes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename);
    app.get('/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename);
    app.get('/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById);
    app.post('/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment);
    app.put('/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment);
//    Commented out when pulling development into DNETRPLC-39
//    return app.get('/api/experimentStatusCodes', loginRoutes.ensureAuthenticated, exports.getExperimentStatusCodes);
    app.get('/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch);
    app.get('/api/experiments/edit/:experimentCodeName', loginRoutes.ensureAuthenticated, exports.editExperimentLookupAndRedirect);
    return app["delete"]('/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.deleteExperiment);
  };

  exports.experimentByCodename = function(request, response) {
    var baseurl, config, experimentServiceTestJSON, fullObjectFlag, serverUtilityFunctions;
    console.log(request.params.code);
    console.log(request.query.testMode);
    if ((request.query.testMode === true) || (global.specRunnerTestmode === true)) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return response.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments/codename/" + request.params.code;
      fullObjectFlag = "with=fullobject";
      if (request.query.fullObject) {
        baseurl += "?" + fullObjectFlag;
        return serverUtilityFunctions.getFromACASServer(baseurl, response);
      } else {
        return serverUtilityFunctions.getFromACASServer(baseurl, response);
      }
    }
  };

  exports.experimentsByProtocolCodename = function(request, response) {
    var baseurl, config, experimentServiceTestJSON, serverUtilityFunctions;
    console.log(request.params.code);
    console.log(request.query.testMode);
    if (request.query.testMode || global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return response.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments/protocolCodename/" + request.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, response);
    }
  };

  exports.experimentById = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, serverUtilityFunctions;
    console.log(req.params.id);
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments/" + req.params.id;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postExperiment = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, request;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments";
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 201) {
            console.log(JSON.stringify(json));
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to save new experiment');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putExperiment = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, putId, request;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../conf/compiled/conf.js');
      putId = req.body.id;
      baseurl = config.all.client.service.persistence.fullpath + "experiments/" + putId;
      request = require('request');
      return request({
        method: 'PUT',
        url: baseurl,
        body: req.body,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          console.log(response.statusCode);
          if (!error && response.statusCode === 200) {
            console.log(JSON.stringify(json));
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

  exports.getExperimentStatusCodes = function(req, resp) {
    var experimentServiceTestJSON;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.json(experimentServiceTestJSON.experimentStatusCodes);
    } else {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.json(experimentServiceTestJSON.experimentStatusCodes);
    }
  };

  exports.genericExperimentSearch = function(req, res) {
    var emptyResponse, experimentServiceTestJSON, json;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      if (req.params.searchTerm === "no-match") {
        emptyResponse = [];
        return res.end(JSON.stringify(emptyResponse));
      } else {
        return res.end(JSON.stringify([experimentServiceTestJSON.fullExperimentFromServer]));
      }
    } else {
      json = {
        message: "genericExperimentSearch not implemented yet"
      };
      return res.end(JSON.stringify(json));
    }
  };

  exports.editExperimentLookupAndRedirect = function(req, res) {
    var json;
    if (global.specRunnerTestmode) {
      json = {
        message: "got to edit experiment redirect"
      };
      return res.end(JSON.stringify(json));
    } else {
      json = {
        message: "genericExperimentSearch not implemented yet"
      };
      return res.end(JSON.stringify(json));
    }
  };

  exports.deleteExperiment = function(req, res) {
    var baseurl, config, experimentId, request;
    config = require('../conf/compiled/conf.js');
    experimentId = req.params.id;
    baseurl = config.all.client.service.persistence.fullpath + "experiments/" + experimentId;
    console.log("baseurl");
    console.log(baseurl);
    request = require('request');
    return request({
      method: 'DELETE',
      url: baseurl,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        console.log(response.statusCode);
        if (!error && response.statusCode === 200) {
          console.log(JSON.stringify(json));
          return res.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to save new experiment');
          console.log(error);
          return console.log(response);
        }
      };
    })(this));
  };

}).call(this);
