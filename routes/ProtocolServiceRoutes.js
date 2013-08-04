/* To install this Module
1) Add these lines to app.coffee under # serverAPI routes:
protocolRoutes = require './routes/ProtocolServiceRoutes.js'
app.get '/api/protocols/codename/:code', protocolRoutes.protocolByCodename
app.get '/api/protocols/:id', protocolRoutes.protocolById
app.post '/api/protocols', protocolRoutes.postProtocol
app.put '/api/protocols', protocolRoutes.putProtocol
app.get '/api/protocollabels', protocolRoutes.protocolLabels
app.get '/api/protocolCodeList', protocolRoutes.protocolCodeList
app.get '/api/protocolCodeList/:filter', protocolRoutes.protocolCodeList
*/


(function() {
  exports.protocolByCodename = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, serverUtilityFunctions;

    console.log(req.params.code);
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(protocolServiceTestJSON.stubSavedProtocol));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "protocols/codename/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.protocolById = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, serverUtilityFunctions;

    console.log(req.params.id);
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(protocolServiceTestJSON.fullSavedProtocol));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "protocols/" + req.params.id;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postProtocol = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, request,
      _this = this;

    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullSavedProtocol));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "protocols";
      request = require('request');
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

  exports.putProtocol = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, request,
      _this = this;

    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullSavedProtocol));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "protocols";
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

  exports.protocolLabels = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, serverUtilityFunctions;

    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(protocolServiceTestJSON.protocolLabels));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "protocollabels";
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.protocolCodeList = function(req, resp) {
    var baseurl, config, filterString, labels, protocolServiceTestJSON, request, shouldFilter, translateToCodes,
      _this = this;

    console.log(req.params);
    if (req.params.str != null) {
      shouldFilter = true;
      filterString = req.params.str;
    }
    translateToCodes = function(labels) {
      var label, match, protCodes, _i, _len;

      protCodes = [];
      for (_i = 0, _len = labels.length; _i < _len; _i++) {
        label = labels[_i];
        if (shouldFilter) {
          match = label.labelText.toUpperCase().indexOf(filterString.toUpperCase()) > -1;
        } else {
          match = true;
        }
        if (!label.ignored && label.lsType === "name" && match) {
          protCodes.push({
            code: label.protocol.codeName,
            name: label.labelText,
            ignored: label.ignored
          });
        }
      }
      return protCodes;
    };
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      labels = protocolServiceTestJSON.protocolLabels;
      return resp.json(translateToCodes(labels));
    } else {
      config = require('../public/src/conf/configurationNode.js');
      baseurl = config.serverConfigurationParams.configuration.serverPath + "protocollabels";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl,
        json: true
      }, function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return resp.json(translateToCodes(json));
        } else {
          console.log('got ajax error trying to get protocol labels');
          console.log(error);
          console.log(json);
          return console.log(response);
        }
      });
    }
  };

}).call(this);
