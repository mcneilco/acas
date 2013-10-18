/* To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
experimentRoutes = require './routes/ExperimentServiceRoutes.js'
app.get '/api/experiments/codename/:code', experimentRoutes.experimentByCodename
app.get '/api/experiments/protocolCodename/:code', experimentRoutes.experimentByProtocolCodename
app.get '/api/experiments/:id', experimentRoutes.experimentById
app.post '/api/experiments', experimentRoutes.postExperiment
app.put '/api/experiments', experimentRoutes.putExperiment
*/


(function() {
  exports.experimentByCodename = function(request, response) {
    var baseurl, config, experimentServiceTestJSON, serverUtilityFunctions;

    console.log(request.params.code);
    console.log(request.query.testMode);
    if (request.query.testMode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return response.end(JSON.stringify(experimentServiceTestJSON.stubSavedExperiment));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "experiments/codename/" + request.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, response);
    }
  };

  exports.experimentByProtocolCodename = function(request, response) {
    var baseurl, config, experimentServiceTestJSON, serverUtilityFunctions;

    console.log(request.params.code);
    console.log(request.query.testMode);
    if (request.query.testMode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return response.end(JSON.stringify(experimentServiceTestJSON.stubSavedExperiment));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "experiments/protocolCodename/" + request.params.code;
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
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "experiments/" + req.params.id;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postExperiment = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, request,
      _this = this;

    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "experiments";
      request = require('request');
      console.log(req.body);
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body,
        json: true
      }, function(error, response, json) {
        if (!error && response.statusCode === 201) {
          console.log(JSON.stringify(json));
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to save new experiment');
          console.log(error);
          console.log(json);
          return console.log(response);
        }
      });
    }
  };

  exports.putExperiment = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, request,
      _this = this;

    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "experiments/" + req.params.id;
      request = require('request');
      return request({
        method: 'PUT',
        url: baseurl,
        body: req.body,
        json: true
      }, function(error, response, json) {
        if (!error && response.statusCode === 201) {
          console.log(JSON.stringify(json));
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error trying to save new experiment');
          console.log(error);
          console.log(json);
          return console.log(response);
        }
      });
    }
  };

}).call(this);
