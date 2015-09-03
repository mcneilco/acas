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
        baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + thing.lsType + "/" + thing.lsKind + "/" + thing.codeName + "?with=nestedfull";
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
        var completeThingUpdate, fileSaveCompleted, fileVals, filesToSave, fv, i, len, prefix, results1;
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
          results1 = [];
          for (i = 0, len = fileVals.length; i < len; i++) {
            fv = fileVals[i];
            console.log("updating file");
            results1.push(csUtilities.relocateEntityFile(fv, prefix, thing.codeName, fileSaveCompleted));
          }
          return results1;
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
        } else {
          baseurl += "?with=nestedfull";
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
    var completeThingUpdate, fileSaveCompleted, fileVals, filesToSave, fv, i, len, prefix, results1, thingToSave;
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
      results1 = [];
      for (i = 0, len = fileVals.length; i < len; i++) {
        fv = fileVals[i];
        if (fv.id == null) {
          results1.push(csUtilities.relocateEntityFile(fv, prefix, req.body.codeName, fileSaveCompleted));
        } else {
          results1.push(void 0);
        }
      }
      return results1;
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
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body.data,
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
            console.log(json);
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

  exports.getThingCodesFromNamesOrCodes = function(codeRequest, callback) {
    var baseurl, config, i, len, postBody, ref, req, request, res, response, results, url;
    console.log("got to getThingCodesFormNamesOrCodes");
    if (global.specRunnerTestmode) {
      results = [];
      ref = codeRequest.requests;
      for (i = 0, len = ref.length; i < len; i++) {
        req = ref[i];
        res = {
          requestName: req.requestName
        };
        if (req.requestName.indexOf("ambiguous") > -1) {
          res.referenceName = "";
          res.preferredName = "";
        } else if (req.requestName.indexOf("name") > -1) {
          res.referenceName = "GENE1111";
          res.preferredName = "1111";
        } else if (req.requestName.indexOf("1111") > -1) {
          res.referenceName = "GENE1111";
          res.preferredName = "1111";
        } else {
          res.referenceName = req.requestName;
          res.preferredName = req.requestName;
        }
        results.push(res);
      }
      response = {
        thingType: codeRequest.thingType,
        thingKind: codeRequest.thingKind,
        results: results
      };
      return callback(response);
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/getCodeNameFromNameRequest?";
      url = baseurl + ("thingType=" + codeRequest.thingType + "&thingKind=" + codeRequest.thingKind);
      postBody = {
        requests: codeRequest.requests
      };
      console.log(postBody);
      console.log(url);
      request = require('request');
      return request({
        method: 'POST',
        url: url,
        body: postBody,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          console.log(response.statusCode);
          console.log(json);
          if (!error && !json.error) {
            return callback({
              thingType: codeRequest.thingType,
              thingKind: codeRequest.thingKind,
              results: json.results
            });
          } else {
            console.log('got ajax error trying to lookup lsThing name');
            console.log(error);
            console.log(jsonthing);
            console.log(response);
            return callback(json);
          }
        };
      })(this));
    }
  };

}).call(this);
