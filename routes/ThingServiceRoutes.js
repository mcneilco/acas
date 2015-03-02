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
    return app.post('/api/validateName/:lsKind', exports.validateName);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/things/:lsType/:lsKind', loginRoutes.ensureAuthenticated, exports.thingsByTypeKind);
    app.get('/api/things/:lsType/:lsKind/codename/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName);
    app.get('/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.thingByCodeName);
    app.post('/api/things/:lsType/:lsKind', exports.postThingParent);
    app.post('/api/things/:lsType/:lsKind/:parentCode', exports.postThingBatch);
    app.put('/api/things/:lsType/:lsKind/:code', loginRoutes.ensureAuthenticated, exports.putThing);
    app.get('/api/batches/:lsKind/parentCodeName/:parentCode', loginRoutes.ensureAuthenticated, exports.batchesByParentCodeName);
    return app.post('/api/validateName/:lsKind', loginRoutes.ensureAuthenticated, exports.validateName);
  };

  exports.thingsByTypeKind = function(req, resp) {
    var baseurl, config, serverUtilityFunctions, thingServiceTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingServiceTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.end(JSON.stringify(thingServiceTestJSON.batchList));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  serverUtilityFunctions = require('./ServerUtilityFunctions.js');

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

  exports.thingByCodeName = function(req, resp) {
    var baseurl, config, thingTestJSON;
    if (req.query.testMode || global.specRunnerTestmode) {
      thingTestJSON = require('../public/javascripts/spec/testFixtures/ThingServiceTestJSON.js');
      return resp.json(thingTestJSON.thingParent);
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + req.params.lsType + "/" + req.params.lsKind + "/" + req.params.code;
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  updateThing = function(thing, testMode, callback) {
    var baseurl, config, request;
    if (testMode || global.specRunnerTestmode) {
      return callback(thing);
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/" + thing.lsType + "/" + thing.lsKind + "/" + thing.code;
      console.log(baseurl);
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
  };

  postThing = function(isBatch, req, resp) {
    var baseurl, checkFilesAndUpdate, config, request, thingToSave;
    console.log("post thing parent");
    thingToSave = req.body;
    if (req.query.testMode || global.specRunnerTestmode) {
      if (thingToSave.codeName == null) {
        if (isBatch) {
          thingToSave.codeName = "PT00002";
        } else {
          thingToSave.codeName = "PT00002-1";
        }
      }
    } else {

    }
    checkFilesAndUpdate = function(thing) {
      var completeThingUpdate, fileSaveCompleted, fileVals, filesToSave, fv, prefix, _i, _len, _results;
      fileVals = serverUtilityFunctions.getFileValesFromThing(thing);
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
        prefix = serverUtilityFunctions.getPrefixFromThingCode(thing.codeName);
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
    fileVals = serverUtilityFunctions.getFileValesFromThing(thingToSave);
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
      prefix = serverUtilityFunctions.getPrefixFromThingCode(req.params.code);
      _results = [];
      for (_i = 0, _len = fileVals.length; _i < _len; _i++) {
        fv = fileVals[_i];
        _results.push(csUtilities.relocateEntityFile(fv, prefix, req.params.code, fileSaveCompleted));
      }
      return _results;
    } else {
      return completeThingUpdate();
    }
  };

  exports.batchesByParentCodeName = function(req, resp) {
    var baseurl, config, thingServiceTestJSON;
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
      console.log("validate name");
      console.log(req);
      console.log(JSON.stringify(req.body.requestName));
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "lsthings/validatename?lsKind=" + req.params.lsKind;
      request = require('request');
      return request({
        method: 'POST',
        url: baseurl,
        body: req.body.requestName,
        json: true
      }, (function(_this) {
        return function(error, response, json) {
          console.log(error);
          if (!error && response.statusCode === 200) {
            return resp.json(json);
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

}).call(this);
