(function() {
  var _;

  _ = require("underscore");

  exports.setupAPIRoutes = function(app) {
    app.get('/api/codetables/:type/:kind', exports.getCodeTableValues);
    app.get('/api/codetables', exports.getAllCodeTableValues);
    app.post('/api/codetables', exports.postCodeTable);
    return app.put('/api/codetables/:id', exports.putCodeTable);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/codetables/:type/:kind', loginRoutes.ensureAuthenticated, exports.getCodeTableValues);
    app.get('/api/codetables', loginRoutes.ensureAuthenticated, exports.getAllCodeTableValues);
    app.post('/api/codetables', loginRoutes.ensureAuthenticated, exports.postCodeTable);
    return app.put('/api/codetables/:id', loginRoutes.ensureAuthenticated, exports.putCodeTable);
  };

  exports.getAllCodeTableValues = function(req, resp) {
    var baseurl, codeTableServiceTestJSON, config, request;
    if (global.specRunnerTestmode) {
      codeTableServiceTestJSON = require('../public/javascripts/spec/testFixtures/codeTableServiceTestJSON.js');
      return resp.end(JSON.stringify(codeTableServiceTestJSON['codes']));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = "" + config.all.client.service.persistence.fullpath + "ddictvalues?format=codetable";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(json);
          } else {
            console.log('got ajax error trying to get all code table entries');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.getCodeTableValues = function(req, resp) {
    var baseurl, config, correctCodeTable, fullCodeTableJSON, request;
    if (global.specRunnerTestmode) {
      fullCodeTableJSON = require('../public/javascripts/spec/testFixtures/CodeTableJSON.js');
      correctCodeTable = _.findWhere(fullCodeTableJSON.codes, {
        type: req.params.type,
        kind: req.params.kind
      });
      return resp.end(JSON.stringify(correctCodeTable['codes']));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = "" + config.all.client.service.persistence.fullpath + "ddictvalues/all/" + req.params.type + "/" + req.params.kind + "/codetable";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(json);
          } else {
            console.log('got ajax error trying to get code table entries');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.postCodeTable = function(req, resp) {
    var baseurl, codeTablePostTestJSON, config, request;
    if (global.specRunnerTestmode) {
      codeTablePostTestJSON = require('../public/javascripts/spec/testFixtures/codeTablePostTestJSON.js');
      return resp.end(JSON.stringify(codeTablePostTestJSON.codeEntry));
    } else {
      console.log("attempting to post new code table value");
      config = require('../conf/compiled/conf.js');
      baseurl = "" + config.all.client.service.persistence.fullpath + "ddictvalues/codetable";
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
            console.log('got ajax error trying to save new code table');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putCodeTable = function(req, resp) {
    var baseurl, codeTablePostTestJSON, config, putId, request;
    if (global.specRunnerTestmode) {
      codeTablePostTestJSON = require('../public/javascripts/spec/testFixtures/codeTablePutTestJSON.js');
      return resp.end(JSON.stringify(codeTablePostTestJSON.codeEntry));
    } else {
      config = require('../conf/compiled/conf.js');
      putId = req.body.id;
      baseurl = "" + config.all.client.service.persistence.fullpath + "ddictvalues/codetable/" + putId;
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
            return resp.end(JSON.stringify(json));
          } else {
            console.log('got ajax error trying to update code table');
            console.log(error);
            return console.log(response);
          }
        };
      })(this));
    }
  };

}).call(this);
