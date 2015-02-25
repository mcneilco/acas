(function() {
  exports.setupAPIRoutes = function(app) {
    app.get('/api/protocols/codename/:code', exports.protocolByCodename);
    app.get('/api/protocols/:id', exports.protocolById);
    app.post('/api/protocols', exports.postProtocol);
    return app.put('/api/protocols/:id', exports.putProtocol);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/protocols/codename/:code', loginRoutes.ensureAuthenticated, exports.protocolByCodename);
    app.get('/api/protocols/:id', loginRoutes.ensureAuthenticated, exports.protocolById);
    app.post('/api/protocols', loginRoutes.ensureAuthenticated, exports.postProtocol);
    app.put('/api/protocols/:id', loginRoutes.ensureAuthenticated, exports.putProtocol);
    app.get('/api/protocollabels', loginRoutes.ensureAuthenticated, exports.lsLabels);
    app.get('/api/protocolCodes', loginRoutes.ensureAuthenticated, exports.protocolCodeList);
    app.get('/api/protocolKindCodes', loginRoutes.ensureAuthenticated, exports.protocolKindCodeList);
    app.get('/api/protocols/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericProtocolSearch);
    return app["delete"]('/api/protocols/browser/:id', loginRoutes.ensureAuthenticated, exports.deleteProtocol);
  };

  exports.protocolByCodename = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, serverUtilityFunctions;
    console.log(req.params.code);
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(protocolServiceTestJSON.stubSavedProtocol));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocols/codename/" + req.params.code;
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
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocols/" + req.params.id;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.postProtocol = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, request;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullSavedProtocol));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocols";
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
            console.log('got ajax error trying to save new protocol');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.putProtocol = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, putId, request;
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(protocolServiceTestJSON.fullSavedProtocol));
    } else {
      config = require('../conf/compiled/conf.js');
      putId = req.body.id;
      baseurl = config.all.client.service.persistence.fullpath + "protocols/" + putId;
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
            console.log('got ajax error trying to save new protocol');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.lsLabels = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, serverUtilityFunctions;
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.end(JSON.stringify(protocolServiceTestJSON.lsLabels));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocollabels";
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.protocolCodeList = function(req, resp) {
    var baseurl, config, filterString, labels, protocolServiceTestJSON, request, shouldFilterByKind, shouldFilterByName, translateToCodes;
    if (req.query.protocolName != null) {
      shouldFilterByName = true;
      filterString = req.query.protocolName.toUpperCase();
    } else if (req.query.protocolKind != null) {
      shouldFilterByKind = true;
      filterString = req.query.protocolKind;
    } else {
      shouldFilterByName = false;
      shouldFilterByKind = false;
    }
    translateToCodes = function(labels) {
      var label, match, protCodes, _i, _len;
      protCodes = [];
      for (_i = 0, _len = labels.length; _i < _len; _i++) {
        label = labels[_i];
        if (shouldFilterByName) {
          match = label.labelText.toUpperCase().indexOf(filterString) > -1;
        } else if (shouldFilterByKind) {
          if (label.protocol.lsKind === "default") {
            match = label.protocol.lsKind.indexOf(filterString) > -1;
          } else {
            match = label.protocol.lsKind.toUpperCase().indexOf(filterString) > -1;
          }
        } else {
          match = true;
        }
        if (!label.ignored && !label.protocol.ignored && label.lsType === "name" && match) {
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
      labels = protocolServiceTestJSON.lsLabels;
      return resp.json(translateToCodes(labels));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocols/codetable";
      if (shouldFilterByName) {
        baseurl += "/?protocolName=" + filterString;
      } else if (shouldFilterByKind) {
        baseurl += "?lskind=" + filterString;
      }
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
            console.log('got ajax error trying to get protocol labels');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.protocolKindCodeList = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, request, translateToCodes;
    translateToCodes = function(kinds) {
      var kind, kindCodes, _i, _len;
      kindCodes = [];
      for (_i = 0, _len = kinds.length; _i < _len; _i++) {
        kind = kinds[_i];
        kindCodes.push({
          code: kind.kindName,
          name: kind.kindName,
          ignored: false
        });
      }
      return kindCodes;
    };
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      return resp.json(translateToCodes(protocolServiceTestJSON.protocolKinds));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocolkinds";
      request = require('request');
      return request({
        method: 'GET',
        url: baseurl,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 200) {
            return resp.json(translateToCodes(json));
          } else {
            console.log('got ajax error trying to get protocol labels');
            console.log(error);
            console.log(json);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.genericProtocolSearch = function(req, res) {
    var baseurl, config, emptyResponse, protocolServiceTestJSON, serverUtilityFunctions;
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      if (req.params.searchTerm === "no-match") {
        emptyResponse = [];
        return res.end(JSON.stringify(emptyResponse));
      } else {
        return res.end(JSON.stringify([protocolServiceTestJSON.fullSavedProtocol, protocolServiceTestJSON.fullDeletedProtocol]));
      }
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocols/search?q=" + req.params.searchTerm;
      console.log("baseurl");
      console.log(baseurl);
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, res);
    }
  };

  exports.deleteProtocol = function(req, res) {
    var baseurl, config, protocolID, request;
    config = require('../conf/compiled/conf.js');
    protocolID = req.params.id;
    baseurl = config.all.client.service.persistence.fullpath + "protocols/browser/" + protocolID;
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
          console.log('got ajax error trying to delete protocol');
          console.log(error);
          return console.log(response);
        }
      };
    })(this));
  };

}).call(this);
