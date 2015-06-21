(function() {
  var csUtilities, postThing, serverUtilityFunctions, updateThing;

  exports.setupAPIRoutes = function(app, loginRoutes) {
    app.get('/api/things/:lsType/:lsKind', exports.thingsByTypeKind);
    app.get('/api/things/:lsType/:lsKind/codename/:code', exports.thingByCodeName);
    app.get('/api/things/:lsType/:lsKind/:code', exports.thingByCodeName);
    app.post('/api/things/:lsType/:lsKind', exports.postThingParent);
    app.post('/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch);
    app.put('/api/things/:lsType/:lsKind/:code', exports.putThing);
    app.get('/api/batches/:lsKind/parentCodeName/:parentCode', exports.batchesByParentCodeName);
    app.post('/api/validateName/:componentOrAssembly', exports.validateName);
    return app.get('/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', exports.getAssemblies);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind);
    app.get('/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName);
    app.get('/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName);
    app.post('/api/things/:lsType/:lsKind', exports.postThingParent);
    app.post('/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch);
    app.put('/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing);
    app.get('/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName);
    app.post('/api/validateName/:componentOrAssembly', loginRoutes.ensureAuthenticated, exports.validateName);
    return app.get('/api/getAssembliesFromComponent/:lsType/:lsKind/:componentCode', loginRoutes.ensureAuthenticated, exports.getAssemblies);
  };

  exports.thingsByTypeKind = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, stubFlag, thingServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingServiceTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingServiceTestJSON.batchList));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind;
      stubFlag = "with=stub";
      if (req.query.stub) {
        baseurl += "?" + stubFlag;
      }
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  serverUtilityFunctions = require('./ServerUtilityFunctions.js');

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

  exports.thingByCodeName = function(req, resp) {
    var baseurl, config, nestedfull, nestedstub, prettyjson, stub, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.json(thingTestJSON.thingParent);
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind + "/" + req.params.code;
      if (req.query.nestedstub) {
        nestedstub = "with=nestedstub";
        baseurl += "?" + nestedstub;
      } else if (req.query.nestedfull) {
        nestedfull = "with=nestedfull";
        baseurl += "?" + nestedfull;
      } else if (req.query.prettyjson) {
        prettyjson = "with=prettyjson";
        baseurl += "?" + prettyjson;
      } else if (req.query.stub) {
        stub = "with=stub";
        baseurl += "?" + stub;
      }
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  updateThing = function(thing, testMode, callback) {
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    return serverUtilityFunctions.createLSTransaction(thing.recordedDate, "updated experiment", function(transaction) {
      var baseurl, config, request;
      thing = serverUtilityFunctions.insertTransactionIntoEntity(transaction.id, thing);
      if (testMode || global.specRunnerTestmode) {
        return callback(thing);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + thing.lsType + "/" + thing.lsKind + "/" + thing.code;
        request = require('request');
        return request({
          method: 'PUT',
          url: baseurl,
          body: thing,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (!error && response.statusCode === 200) {
              return callback(json);
            } else {
              console.log('got ajax error trying to update lsThing');
              console.log(error);
              return console.log(response);
            }
          };
        })(this));
      }
    });
  };

  postThing = function(isBatch, req, resp) {
    var thingToSave;
    console.log("post thing parent");
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    thingToSave = req.body;
    return serverUtilityFunctions.createLSTransaction(thingToSave.recordedDate, "new experiment", function(transaction) {
      var baseurl, checkFilesAndUpdate, config, request;
      thingToSave = serverUtilityFunctions.insertTransactionIntoEntity(transaction.id, thingToSave);
      if (req.query.testMode || global.specRunnerTestmode) {
        if (thingToSave.codeName == null) {
          if (isBatch) {
            thingToSave.codeName = "PT00002";
          } else {
            thingToSave.codeName = "PT00002-1";
          }
        }
      }
      checkFilesAndUpdate = function(thing) {
        var completeThingUpdate, fileSaveCompleted, fileVals, filesToSave, fv, prefix, _i, _len, _results;
        fileVals = serverUtilityFunctions.getFileValuesFromEntity(thing, false);
        filesToSave = fileVals.length;
        completeThingUpdate = function(thingToUpdate) {
          return updateThing(thingToUpdate, req.query.testMode, function(updatedThing) {
            return resp.json(updatedThing);
          });
        };
        fileSaveCompleted = function(passed) {
          if (!passed) {
            resp.statusCode = 500;
            return resp.end("file move failed");
          }
          if (--filesToSave === 0) {
            return completeThingUpdate(thing);
          }
        };
        if (filesToSave > 0) {
          prefix = serverUtilityFunctions.getPrefixFromEntityCode(thing.codeName);
          _results = [];
          for (_i = 0, _len = fileVals.length; _i < _len; _i++) {
            fv = fileVals[_i];
            console.log("updating file");
            _results.push(csUtilities.relocateEntityFile(fv, prefix, thing.codeName, fileSaveCompleted));
          }
          return _results;
        } else {
          return resp.json(thing);
        }
      };
      if (req.query.testMode || global.specRunnerTestmode) {
        return checkFilesAndUpdate(thingToSave);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind;
        if (isBatch) {
          baseurl += "/?parentIdOrCodeName=" + req.params.parentCode;
        }
        request = require('request');
        return request({
          method: 'POST',
          url: baseurl,
          body: thingToSave,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (!error && response.statusCode === 201) {
              return checkFilesAndUpdate(json);
            } else {
              console.log('got ajax error trying to save lsThing');
              console.log(error);
              console.log(json);
              return console.log(response);
            }
          };
        })(this));
      }
    });
  };

  exports.postThingParent = function(req, resp) {
    return postThing(false, req, resp);
  };

  exports.postThingBatch = function(req, resp) {
    return postThing(true, req, resp);
  };

  exports.putThing = function(req, resp) {
    var completeThingUpdate, fileSaveCompleted, fileVals, filesToSave, fv, prefix, thingToSave, _i, _len, _results;
    thingToSave = req.body;
    fileVals = serverUtilityFunctions.getFileValuesFromEntity(thingToSave, true);
    filesToSave = fileVals.length;
    completeThingUpdate = function() {
      return updateThing(thingToSave, req.query.testMode, function(updatedThing) {
        return resp.json(updatedThing);
      });
    };
    fileSaveCompleted = function(passed) {
      if (!passed) {
        resp.statusCode = 500;
        return resp.end("file move failed");
      }
      if (--filesToSave === 0) {
        return completeThingUpdate();
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
      return completeThingUpdate();
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var baseurl, config, nestedfull, nestedstub, prettyjson, stub, thingServiceTestJSON;
    console.log("get batches by parent codeName");
    if (req.query.testMode || global.specRunnerTestmode) {
      thingServiceTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.json(thingServiceTestJSON.batchList);
    } else {
      if (req.params.parentCode === "undefined") {
        return resp.json([]);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "lsthings/batch/" + req.params.lsKind + "/getbatches/" + req.params.parentCode;
        if (req.query.nestedstub) {
          nestedstub = "with=nestedstub";
          baseurl += "?" + nestedstub;
        } else if (req.query.nestedfull) {
          nestedfull = "with=nestedfull";
          baseurl += "?" + nestedfull;
        } else if (req.query.prettyjson) {
          prettyjson = "with=prettyjson";
          baseurl += "?" + prettyjson;
        } else if (req.query.stub) {
          stub = "with=stub";
          baseurl += "?" + stub;
        }
        return serverUtilityFunctions.getFromACASServer(baseurl, resp);
      }
    }
  };

  exports.validateName = function(req, resp) {
    var baseurl, config, request, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.json(true);
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/validate";
      if (req.params.componentOrAssembly === "component") {
        baseurl += "?uniqueName=true";
      } else {
        baseurl += "?uniqueName=true&uniqueInteractions=true&orderMatters=true&forwardAndReverseAreSame=true";
      }
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body.modelToSave,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 202) {
            return resp.json(json);
          } else if (response.statusCode === 409) {
            return resp.json("not unique name");
          } else {
            console.log('got ajax error trying to save thing parent');
            console.log(error);
            console.log(jsonthing);
            return console.log(response);
          }
        };
      })(this));
    }
  };

  exports.getAssemblies = function(req, resp) {
    var baseurl, config;
    if (req.query.testMode || global.specRunnerTestmode) {
      return resp.json([]);
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind + "/getcomposites/" + req.params.componentCode;
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.getThingCodesFormNamesOrCodes = function(request, callback) {
    var req, res, response, results, _i, _len, _ref;
    console.log("got to getThingCodesFormNamesOrCodes");
    if (global.specRunnerTestmode) {
      results = [];
      _ref = request.requests;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        req = _ref[_i];
        res = {
          requestName: req.requestName
        };
        if (req.requestName.indexOf("ambiguous") > -1) {
          res.preferredName = "";
        } else if (req.requestName.indexOf("name") > -1) {
          res.preferredName = "GENE1111";
        } else {
          res.preferredName = req.requestName;
        }
        results.push(res);
      }
      response = {
        thingType: "parent",
        thingKind: "gene",
        results: results
      };
      return callback(response);
    } else {
      return console.log("real function not implemented");
    }
  };

}).call(this);
