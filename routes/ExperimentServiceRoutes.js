(function() {
  var csUtilities, postExperiment, serverUtilityFunctions, updateExpt;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/experiments/codename/:code', exports.experimentByCodename);
    app.get('/api/experiments/experimentName/:name', exports.experimentByName);
    app.get('/api/experiments/protocolCodename/:code', exports.experimentsByProtocolCodename);
    app.get('/api/experiments/:id', exports.experimentById);
    app.post('/api/experiments', exports.postExperiment);
    app.put('/api/experiments/:id', exports.putExperiment);
    app.get('/api/experiments/resultViewerURL/:code', exports.resultViewerURLByExperimentCodename);
    return app["delete"]('/api/experiments/:id', exports.deleteExperiment);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/experiments/codename/:code', loginRoutes.ensureAuthenticated, exports.experimentByCodename);
    app.get('/api/experiments/experimentName/:name', loginRoutes.ensureAuthenticated, exports.experimentByName);
    app.get('/api/experiments/protocolCodename/:code', loginRoutes.ensureAuthenticated, exports.experimentsByProtocolCodename);
    app.get('/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.experimentById);
    app.post('/api/experiments', loginRoutes.ensureAuthenticated, exports.postExperiment);
    app.put('/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.putExperiment);
    app.get('/api/experiments/genericSearch/:searchTerm', loginRoutes.ensureAuthenticated, exports.genericExperimentSearch);
    app["delete"]('/api/experiments/:id', loginRoutes.ensureAuthenticated, exports.deleteExperiment);
    app.get('/api/experiments/resultViewerURL/:code', loginRoutes.ensureAuthenticated, exports.resultViewerURLByExperimentCodename);
    return app.get('/api/experiments/values/:id', loginRoutes.ensureAuthenticated, exports.experimentValueById);
  };

  serverUtilityFunctions = require('./ServerUtilityFunctions.js');

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

  exports.experimentByCodename = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON, expt, fullObjectFlag;
    console.log(req.params.code);
    console.log(req.query.testMode);
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      expt = JSON.parse(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer));
      if (req.params.code.indexOf("screening") > -1) {
        expt.lsKind = "Bio Activity";
      } else {
        expt.lsKind = "default";
      }
      return resp.json(expt);
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments/codename/" + req.params.code;
      fullObjectFlag = "with=fullobject";
      if (req.query.fullObject) {
        baseurl += "?" + fullObjectFlag;
        return serverUtilityFunctions.getFromACASServer(baseurl, resp);
      } else {
        return serverUtilityFunctions.getFromACASServer(baseurl, resp);
      }
    }
  };

  exports.experimentByName = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON;
    console.log("exports.experiment by name");
    if ((req.query.testMode === true) || (global.specRunnerTestmode === true)) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify([experimentServiceTestJSON.fullExperimentFromServer]));
    } else {
      config = require('../conf/compiled/conf.js');
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments?findByName&name=" + req.params.name;
      console.log(baseurl);
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

  exports.experimentsByProtocolCodename = function(request, response) {
    var baseurl, config, experimentServiceTestJSON;
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
    var baseurl, config, experimentServiceTestJSON;
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

  updateExpt = function(expt, testMode, callback) {
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    return serverUtilityFunctions.createLSTransaction(expt.recordedDate, "updated experiment", function(transaction) {
      var baseurl, config, request;
      expt = serverUtilityFunctions.insertTransactionIntoEntity(transaction.id, expt);
      if (testMode || global.specRunnerTestmode) {
        return callback(expt);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "experiments/" + expt.id;
        request = require('request');
        return request({
          method: 'PUT',
          url: baseurl,
          body: expt,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (response.statusCode === 409) {
              console.log('got ajax error trying to update experiment - not unique name');
              if (response.body[0].message === "not unique experiment name") {
                return callback(JSON.stringify(response.body[0].message));
              }
            } else if (!error && response.statusCode === 200) {
              return callback(json);
            } else {
              console.log('got ajax error trying to update experiment');
              console.log(error);
              return console.log(response);
            }
          };
        })(this));
      }
    });
  };

  postExperiment = function(req, resp) {
    var exptToSave;
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    exptToSave = req.body;
    return serverUtilityFunctions.createLSTransaction(exptToSave.recordedDate, "new experiment", function(transaction) {
      var baseurl, checkFilesAndUpdate, config, request;
      exptToSave = serverUtilityFunctions.insertTransactionIntoEntity(transaction.id, exptToSave);
      if (req.query.testMode || global.specRunnerTestmode) {
        if (exptToSave.codeName == null) {
          exptToSave.codeName = "EXPT-00000001";
        }
      }
      checkFilesAndUpdate = function(expt) {
        var completeExptUpdate, fileSaveCompleted, fileVals, filesToSave, fv, prefix, _i, _len, _results;
        fileVals = serverUtilityFunctions.getFileValuesFromEntity(expt, false);
        filesToSave = fileVals.length;
        completeExptUpdate = function(exptToUpdate) {
          return updateExpt(exptToUpdate, req.query.testMode, function(updatedExpt) {
            return resp.json(updatedExpt);
          });
        };
        fileSaveCompleted = function(passed) {
          if (!passed) {
            resp.statusCode = 500;
            return resp.end("file move failed");
          }
          if (--filesToSave === 0) {
            return completeExptUpdate(expt);
          }
        };
        if (filesToSave > 0) {
          prefix = serverUtilityFunctions.getPrefixFromEntityCode(expt.codeName);
          _results = [];
          for (_i = 0, _len = fileVals.length; _i < _len; _i++) {
            fv = fileVals[_i];
            _results.push(csUtilities.relocateEntityFile(fv, prefix, expt.codeName, fileSaveCompleted));
          }
          return _results;
        } else {
          return resp.json(expt);
        }
      };
      if (req.query.testMode || global.specRunnerTestmode) {
        return checkFilesAndUpdate(exptToSave);
      } else {
        config = require('../conf/compiled/conf.js');
        baseurl = config.all.client.service.persistence.fullpath + "experiments";
        request = require('request');
        return request({
          method: 'POST',
          url: baseurl,
          body: exptToSave,
          json: true
        }, (function(_this) {
          return function(error, response, json) {
            if (!error && response.statusCode === 201) {
              return checkFilesAndUpdate(json);
            } else {
              console.log('got ajax error trying to save experiment - not unique name');
              if (response.body[0].message === "not unique experiment name") {
                return resp.end(JSON.stringify(response.body[0].message));
              }
            }
          };
        })(this));
      }
    });
  };

  exports.postExperiment = function(req, resp) {
    return postExperiment(req, resp);
  };

  exports.putExperiment = function(req, resp) {
    var completeExptUpdate, exptToSave, fileSaveCompleted, fileVals, filesToSave, fv, prefix, _i, _len, _results;
    exptToSave = req.body;
    fileVals = serverUtilityFunctions.getFileValuesFromEntity(exptToSave, true);
    filesToSave = fileVals.length;
    completeExptUpdate = function() {
      return updateExpt(exptToSave, req.query.testMode, function(updatedExpt) {
        return resp.json(updatedExpt);
      });
    };
    fileSaveCompleted = function(passed) {
      if (!passed) {
        resp.statusCode = 500;
        return resp.end("file move failed");
      }
      if (--filesToSave === 0) {
        return completeExptUpdate();
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
      return completeExptUpdate();
    }
  };

  exports.genericExperimentSearch = function(req, res) {
    var baseurl, config, emptyResponse, experimentServiceTestJSON;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      if (req.params.searchTerm === "no-match") {
        emptyResponse = [];
        return res.end(JSON.stringify(emptyResponse));
      } else {
        return res.end(JSON.stringify([experimentServiceTestJSON.fullExperimentFromServer, experimentServiceTestJSON.fullDeletedExperiment]));
      }
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "experiments/search?q=" + req.params.searchTerm;
      console.log("baseurl");
      console.log(baseurl);
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, res);
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
    var baseurl, config, deletedExperiment, experimentId, experimentServiceTestJSON, request;
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      deletedExperiment = JSON.parse(JSON.stringify(experimentServiceTestJSON.fullDeletedExperiment));
      return res.end(JSON.stringify(deletedExperiment));
    } else {
      config = require('../conf/compiled/conf.js');
      experimentId = req.params.id;
      baseurl = config.all.client.service.persistence.fullpath + "experiments/browser/" + experimentId;
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
    }
  };

  exports.resultViewerURLByExperimentCodename = function(request, resp) {
    var baseurl, config, experimentServiceTestJSON, resultViewerURL, _;
    console.log(__dirname);
    _ = require('../public/src/lib/underscore.js');
    if ((request.query.testMode === true) || (global.specRunnerTestmode === true)) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.resultViewerURLByExperimentCodeName));
    } else {
      config = require('../conf/compiled/conf.js');
      if (config.all.client.service.result && config.all.client.service.result.viewer && (config.all.client.service.result.viewer.experimentPrefix != null) && (config.all.client.service.result.viewer.protocolPrefix != null) && (config.all.client.service.result.viewer.experimentNameColumn != null)) {
        resultViewerURL = [
          {
            resultViewerURL: ""
          }
        ];
        serverUtilityFunctions = require('./ServerUtilityFunctions.js');
        baseurl = config.all.client.service.persistence.fullpath + "experiments/codename/" + request.params.code;
        request = require('request');
        return request({
          method: 'GET',
          url: baseurl,
          json: true
        }, (function(_this) {
          return function(error, response, experiment) {
            if (!error && response.statusCode === 200) {
              if (experiment.length === 0) {
                resp.statusCode = 404;
                return resp.json(resultViewerURL);
              } else {
                baseurl = config.all.client.service.persistence.fullpath + "protocols/" + experiment.protocol.id;
                request = require('request');
                return request({
                  method: 'GET',
                  url: baseurl,
                  json: true
                }, function(error, response, protocol) {
                  var experimentName, preferredExperimentLabel, preferredExperimentLabelText, preferredProtocolLabel, preferredProtocolLabelText;
                  if (response.statusCode === 404) {
                    resp.statusCode = 404;
                    return resp.json(resultViewerURL);
                  } else {
                    if (!error && response.statusCode === 200) {
                      preferredExperimentLabel = _.filter(experiment.lsLabels, function(lab) {
                        return lab.preferred && lab.ignored === false;
                      });
                      preferredExperimentLabelText = preferredExperimentLabel[0].labelText;
                      if (config.all.client.service.result.viewer.experimentNameColumn === "EXPERIMENT_NAME") {
                        experimentName = experiment.codeName + "::" + preferredExperimentLabelText;
                      } else {
                        experimentName = preferredExperimentLabelText;
                      }
                      preferredProtocolLabel = _.filter(protocol.lsLabels, function(lab) {
                        return lab.preferred && lab.ignored === false;
                      });
                      preferredProtocolLabelText = preferredProtocolLabel[0].labelText;
                      return resp.json({
                        resultViewerURL: config.all.client.service.result.viewer.protocolPrefix + encodeURIComponent(preferredProtocolLabelText) + config.all.client.service.result.viewer.experimentPrefix + encodeURIComponent(experimentName)
                      });
                    } else {
                      console.log('got ajax error trying to save new experiment');
                      console.log(error);
                      console.log(json);
                      return console.log(response);
                    }
                  }
                });
              }
            } else {
              console.log('got ajax error trying to save new experiment');
              console.log(error);
              console.log(json);
              return console.log(response);
            }
          };
        })(this));
      } else {
        resp.statusCode = 500;
        return resp.end("configuration client.service.result.viewer.protocolPrefix and experimentPrefix and experimentNameColumn must exist");
      }
    }
  };

  exports.experimentValueById = function(req, resp) {
    var baseurl, config, experimentServiceTestJSON;
    console.log(req.params.id);
    if (global.specRunnerTestmode) {
      experimentServiceTestJSON = require('../public/javascripts/spec/testFixtures/ExperimentServiceTestJSON.js');
      return resp.end(JSON.stringify(experimentServiceTestJSON.fullExperimentFromServer.lsStates[1]));
    } else {
      config = require('../conf/compiled/conf.js');
      baseurl = config.all.client.service.persistence.fullpath + "experimentvalues/" + req.params.id;
      serverUtilityFunctions = require('./ServerUtilityFunctions.js');
      return serverUtilityFunctions.getFromACASServer(baseurl, resp);
    }
  };

}).call(this);
