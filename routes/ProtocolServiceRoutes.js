(function() {
  var csUtilities, postProtocol, serverUtilityFunctions, updateProt;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/protocols/codename/:code', exports.protocolByCodename);
    app.get('/api/protocols/:id', exports.protocolById);
    app.post('/api/protocols', exports.postProtocol);
    app.put('/api/protocols/:id', exports.putProtocol);
    app.get('/api/protocollabels', exports.lsLabels);
    app.get('/api/protocolCodes', exports.protocolCodeList);
    app.get('/api/protocolKindCodes', exports.protocolKindCodeList);
    return app["delete"]('/api/protocols/browser/:id', exports.deleteProtocol);
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

  serverUtilityFunctions = require('./ServerUtilityFunctions.js');

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

  exports.protocolByCodename = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON, stubSavedProtocol;
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      stubSavedProtocol = JSON.parse(JSON.stringify(protocolServiceTestJSON.stubSavedProtocol));
      if (req.params.code.indexOf("screening") > -1) {
        stubSavedProtocol.lsKind = "Bio Activity";
      } else {
        stubSavedProtocol.lsKind = "default";
      }
      return resp.end(JSON.stringify(stubSavedProtocol));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "protocols/codename/" + req.params.code;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.protocolById = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON;
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

  updateProt = function(prot, testMode, callback) {
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    return serverUtilityFunctions.createLSTransaction(prot.recordedDate, "updated protocol", function(transaction) {
      var baseurl, config, request;
      prot = serverUtilityFunctions.insertTransactionIntoEntity(transaction.id, prot);
      if (testMode || global.specRunnerTestmode) {
        return callback(prot);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "protocols/" + prot.id;
        request = require('request');
        return request({
          method: 'PUT',
          url: baseurl,
          body: prot,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (response.statusCode === 409) {
              console.log('got ajax error trying to update protocol - not unique name');
              if (response.body[0].message === "not unique protocol name") {
                return callback(JSON.stringify(response.body[0].message));
              }
            } else if (!error && response.statusCode === 200) {
              return callback(json);
            } else {
              console.log('got ajax error trying to update protocol');
              console.log(error);
              console.log(response);
              return callback(JSON.stringify("saveFailed"));
            }
          };
        })(this));
      }
    });
  };

  postProtocol = function(req, resp) {
    var protToSave;
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    protToSave = req.body;
    return serverUtilityFunctions.createLSTransaction(protToSave.recordedDate, "new protocol", function(transaction) {
      var baseurl, checkFilesAndUpdate, config, request;
      protToSave = serverUtilityFunctions.insertTransactionIntoEntity(transaction.id, protToSave);
      if (req.query.testMode || global.specRunnerTestmode) {
        if (protToSave.codeName == null) {
          protToSave.codeName = "PROT-00000001";
        }
      }
      checkFilesAndUpdate = function(prot) {
        var completeProtUpdate, fileSaveCompleted, fileVals, filesToSave, fv, prefix, _i, _len, _results;
        fileVals = serverUtilityFunctions.getFileValuesFromEntity(prot, false);
        filesToSave = fileVals.length;
        completeProtUpdate = function(protToUpdate) {
          return updateProt(protToUpdate, req.query.testMode, function(updatedProt) {
            return resp.json(updatedProt);
          });
        };
        fileSaveCompleted = function(passed) {
          if (!passed) {
            resp.statusCode = 500;
            return resp.end("file move failed");
          }
          if (--filesToSave === 0) {
            return completeProtUpdate(prot);
          }
        };
        if (filesToSave > 0) {
          prefix = serverUtilityFunctions.getPrefixFromEntityCode(prot.codeName);
          _results = [];
          for (_i = 0, _len = fileVals.length; _i < _len; _i++) {
            fv = fileVals[_i];
            _results.push(csUtilities.relocateEntityFile(fv, prefix, prot.codeName, fileSaveCompleted));
          }
          return _results;
        } else {
          return resp.json(prot);
        }
      };
      if (req.query.testMode || global.specRunnerTestmode) {
        return checkFilesAndUpdate(protToSave);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "protocols";
        request = require('request');
        return request({
          method: 'POST',
          url: baseurl,
          body: protToSave,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (!error && response.statusCode === 201) {
              return checkFilesAndUpdate(json);
            } else {
              console.log('got ajax error trying to save new protocol');
              console.log(error);
              console.log(response.statusCode);
              console.log(response);
              if (response.body[0].message === "not unique protocol name") {
                return resp.end(JSON.stringify(response.body[0].message));
              } else {
                return resp.end(JSON.stringify("saveFailed"));
              }
            }
          };
        })(this));
      }
    });
  };

  exports.postProtocol = function(req, resp) {
    return postProtocol(req, resp);
  };

  exports.putProtocol = function(req, resp) {
    var completeProtUpdate, fileSaveCompleted, fileVals, filesToSave, fv, prefix, protToSave, _i, _len, _results;
    protToSave = req.body;
    fileVals = serverUtilityFunctions.getFileValuesFromEntity(protToSave, true);
    filesToSave = fileVals.length;
    completeProtUpdate = function() {
      return updateProt(protToSave, req.query.testMode, function(updatedProt) {
        return resp.json(updatedProt);
      });
    };
    fileSaveCompleted = function(passed) {
      if (!passed) {
        resp.statusCode = 500;
        return resp.end("file move failed");
      }
      if (--filesToSave === 0) {
        return completeProtUpdate();
      }
    };
    if (filesToSave > 0) {
      prefix = serverUtilityFunctions.getPrefixFromEntityCode(req.body.codeName);
      _results = [];
      for (_i = 0, _len = fileVals.length; _i < _len; _i++) {
        fv = fileVals[_i];
        if (fv.id == null) {
          _results.push(csUtilities.relocateEntityFile(fv, prefix, req.body.codeName, fileSaveCompleted));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    } else {
      return completeProtUpdate();
    }
  };

  exports.lsLabels = function(req, resp) {
    var baseurl, config, protocolServiceTestJSON;
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
    var baseurl, config, emptyResponse, protocolServiceTestJSON;
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
    var baseurl, config, deletedProtocol, protocolID, protocolServiceTestJSON, request;
    if (global.specRunnerTestmode) {
      protocolServiceTestJSON = require('../public/javascripts/spec/testFixtures/ProtocolServiceTestJSON.js');
      deletedProtocol = JSON.parse(JSON.stringify(protocolServiceTestJSON.fullDeletedProtocol));
      return res.end(JSON.stringify(deletedProtocol));
    } else {
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
    }
  };

}).call(this);
