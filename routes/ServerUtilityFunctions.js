(function() {
  var _, basicRScriptPreValidation, controllerRedirect;

  _ = require('underscore');

  basicRScriptPreValidation = function(payload) {
    var result;
    result = {
      hasError: false,
      hasWarning: false,
      errorMessages: [],
      transactionId: null,
      experimentId: null,
      results: null
    };
    if (payload.user == null) {
      result.hasError = true;
      result.errorMessages.push({
        errorLevel: "error",
        message: "Username is required"
      });
    }
    return result;
  };

  exports.runRFunction_HIDDEN = function(request, rScript, rFunction, returnFunction, preValidationFunction) {
    var Tempfile, config, csUtilities, exec, preValErrors, rCommandFile, rScriptCommand, requestJSONFile, serverUtilityFunctions, stdoutFile;
    config = require('../conf/compiled/conf.js');
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    rScriptCommand = config.all.server.rscript;
    if (config.all.server.rscript != null) {
      rScriptCommand = config.all.server.rscript;
    } else {
      rScriptCommand = "Rscript";
    }
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    csUtilities.logUsage("About to call R function: " + rFunction, JSON.stringify(request.body), request.body.user);
    if (preValidationFunction != null) {
      preValErrors = preValidationFunction.call(this, request.body);
    } else {
      preValErrors = basicRScriptPreValidation(request.body);
    }
    if (preValErrors.hasError) {
      console.log(preValErrors);
      returnFunction.call(this, JSON.stringify(preValErrors));
      return;
    }
    exec = require('child_process').exec;
    Tempfile = require('temporary/lib/file');
    rCommandFile = new Tempfile;
    requestJSONFile = new Tempfile;
    stdoutFile = new Tempfile;
    return requestJSONFile.writeFile(JSON.stringify(request.body), (function(_this) {
      return function() {
        var rCommand;
        rCommand = 'tryCatch({ ';
        rCommand += '	out <- capture.output(.libPaths("r_libs")); ';
        rCommand += '	out <- capture.output(require("rjson")); ';
        rCommand += '	out <- capture.output(source("' + rScript + '")); ';
        rCommand += '	out <- capture.output(request <- fromJSON(file=' + JSON.stringify(requestJSONFile.path) + '));';
        rCommand += '	out <- capture.output(returnValues <- ' + rFunction + '(request));';
        rCommand += '	cat(toJSON(returnValues));';
        rCommand += '},error = function(ex) {cat(paste("R Execution Error:",ex));})';
        return rCommandFile.writeFile(rCommand, function() {
          var child, command;
          console.log(rCommand);
          console.log(stdoutFile.path);
          command = rScriptCommand + " " + rCommandFile.path + " > " + stdoutFile.path + " 2> /dev/null";
          return child = exec(command, function(error, stdout, stderr) {
            console.log("stderr: " + stderr);
            console.log("stdout: " + stdout);
            return stdoutFile.readFile({
              encoding: 'utf8'
            }, (function(_this) {
              return function(err, stdoutFileText) {
                var error1, message, result;
                if (stdoutFileText.indexOf("R Execution Error") === 0) {
                  message = {
                    errorLevel: "error",
                    message: stdoutFileText
                  };
                  result = {
                    hasError: true,
                    hasWarning: false,
                    errorMessages: [message],
                    transactionId: null,
                    experimentId: null,
                    results: null
                  };
                  returnFunction.call(JSON.stringify(result));
                  return csUtilities.logUsage("Returned R execution error R function: " + rFunction, JSON.stringify(result.errorMessages), request.body.user);
                } else {
                  returnFunction.call(_this, stdoutFileText);
                  try {
                    if (stdoutFileText.indexOf('"hasError":true' > -1)) {
                      return csUtilities.logUsage("Returned success from R function with trapped errors: " + rFunction, stdoutFileText, request.body.user);
                    } else {
                      return csUtilities.logUsage("Returned success from R function: " + rFunction, "NA", request.body.user);
                    }
                  } catch (error1) {
                    error = error1;
                    return console.log(error);
                  }
                }
              };
            })(this));
          });
        });
      };
    })(this));
  };

  exports.runRFunction = function(req, rScript, rFunction, returnFunction, preValidationFunction) {
    var testMode;
    testMode = req.query.testMode;
    return exports.runRFunctionOutsideRequest(req.body.user, req.body, rScript, rFunction, returnFunction, preValidationFunction, testMode);
  };

  exports.runRFunctionOutsideRequest = function(username, argumentsJSON, rScript, rFunction, returnFunction, preValidationFunction, testMode) {
    var config, csUtilities, preValErrors, request, requestBody, runRFunctionServiceTestJSON;
    request = require('request');
    config = require('../conf/compiled/conf.js');
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    csUtilities.logUsage("About to call RApache function: " + rFunction, JSON.stringify(argumentsJSON), username);
    if (preValidationFunction != null) {
      preValErrors = preValidationFunction.call(this, argumentsJSON);
    } else {
      preValErrors = basicRScriptPreValidation(argumentsJSON);
    }
    if (preValErrors.hasError) {
      console.log(preValErrors);
      returnFunction.call(this, JSON.stringify(preValErrors));
      return;
    }
    requestBody = {
      rScript: rScript,
      rFunction: rFunction,
      request: JSON.stringify(argumentsJSON)
    };
    if (testMode || global.specRunnerTestmode) {
      runRFunctionServiceTestJSON = require('../public/javascripts/spec/testFixtures/runRFunctionServiceTestJSON.js');
      console.log('test');
      console.log(JSON.stringify(runRFunctionServiceTestJSON.runRFunctionResponse.hasError));
      return returnFunction.call(this, JSON.stringify(runRFunctionServiceTestJSON.runRFunctionResponse));
    } else {
      return request.post({
        timeout: 6000000,
        url: config.all.client.service.rapache.fullpath + "runfunction",
        json: true,
        body: JSON.stringify(requestBody)
      }, (function(_this) {
        return function(error, response, body) {
          var error1, message, messageText, result;
          _this.serverError = error;
          _this.responseJSON = body;
          if (((_this.responseJSON != null) && (_this.responseJSON["RExecutionError"] != null)) || (_this.serverError != null)) {
            if ((_this.responseJSON != null) && (_this.responseJSON["RExecutionError"] != null)) {
              messageText = _this.responseJSON["RExecutionError"];
            } else {
              messageText = _this.serverError;
            }
            message = {
              errorLevel: "error",
              message: messageText
            };
            result = {
              hasError: true,
              hasWarning: false,
              errorMessages: [message],
              transactionId: null,
              experimentId: null
            };
            returnFunction.call(_this, JSON.stringify(result));
            return csUtilities.logUsage("Returned R execution error R function: " + rFunction, JSON.stringify(result.errorMessages), username);
          } else {
            returnFunction.call(_this, JSON.stringify(_this.responseJSON));
            try {
              if (_this.responseJSON.hasError) {
                return csUtilities.logUsage("Returned success from R function with trapped errors: " + rFunction, JSON.stringify(_this.responseJSON), username);
              } else {
                return csUtilities.logUsage("Returned success from R function: " + rFunction, "NA", username);
              }
            } catch (error1) {
              error = error1;
              return console.log(error);
            }
          }
        };
      })(this));
    }
  };

  exports.runRScript = function(rScript) {
    var child, command, config, exec, rScriptCommand, serverUtilityFunctions;
    config = require('../conf/compiled/conf.js');
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    rScriptCommand = config.all.server.rscript;
    if (config.all.server.rscript != null) {
      rScriptCommand = config.all.server.rscript;
    } else {
      rScriptCommand = "Rscript";
    }
    exec = require('child_process').exec;
    command = "export R_LIBS=r_libs && " + rScriptCommand + " " + rScript + " 2> /dev/null";
    console.log("About to call R script using command: " + command);
    return child = exec(command, function(error, stdout, stderr) {
      console.log("stderr: " + stderr);
      return console.log("stdout: " + stdout);
    });
  };


  /* To allow following test routes to work, install this Module
  	 * ServerUtility function testing routes
  	serverUtilityFunctions = require './public/src/modules/02_serverAPI/src/server/routes/ServerUtilityFunctions.js'
  	serverUtilityFunctions.setupRoutes(app)
   */

  exports.setupRoutes = function(app) {
    app.post('/api/runRFunctionTest', exports.runRFunctionTest);
    return app.post('/api/runRApacheFunctionTest', exports.runRApacheFunctionTest);
  };

  exports.runRFunctionTest = function(request, response) {
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    return exports.runRFunction(request, "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R", "runRFunctionTest", function(rReturn) {
      return response.end(rReturn);
    });
  };

  exports.runRApacheFunctionTest = function(request, response) {
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    return exports.runRApacheFunction(request, "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R", "runRFunctionTest", function(rReturn) {
      console.log(rReturn);
      return response.end(rReturn);
    });
  };

  exports.getFromACASServer = function(baseurl, resp) {
    var request;
    request = require('request');
    return request({
      method: 'GET',
      url: baseurl,
      json: true
    }, (function(_this) {
      return function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return resp.end(JSON.stringify(json));
        } else {
          console.log('got ajax error');
          console.log(error);
          console.log(json);
          return console.log(response);
        }
      };
    })(this));
  };

  exports.ensureExists = function(path, mask, cb) {
    var fs;
    fs = require('fs');
    fs.mkdir(path, mask, function(err) {
      if (err) {
        if (err.code === "EEXIST") {
          cb(null);
        } else {
          cb(err);
        }
      } else {
        console.log("Created new directory: " + path);
        cb(null);
      }
    });
  };

  exports.makeAbsolutePath = function(relativePath) {
    var acasPath, d, dotMatches, i, numDotDots, ref;
    acasPath = process.env.PWD;
    dotMatches = relativePath.match(/\.\.\//g);
    if (dotMatches != null) {
      numDotDots = relativePath.match(/\.\.\//g).length;
      relativePath = relativePath.replace(/\.\.\//g, '');
      for (d = i = 1, ref = numDotDots; 1 <= ref ? i <= ref : i >= ref; d = 1 <= ref ? ++i : --i) {
        acasPath = acasPath.replace(/[^\/]+\/?$/, '');
      }
    } else {
      acasPath += '/';
    }
    console.log(acasPath + relativePath + '/');
    return acasPath + relativePath + '/';
  };

  exports.getFileValuesFromEntity = function(thing, ignoreSaved) {
    var fvs, i, j, len, len1, ref, state, v, vals;
    fvs = [];
    ref = thing.lsStates;
    for (i = 0, len = ref.length; i < len; i++) {
      state = ref[i];
      vals = state.lsValues;
      for (j = 0, len1 = vals.length; j < len1; j++) {
        v = vals[j];
        if (v.lsType === 'fileValue' && !v.ignored && v.fileValue !== "" && v.fileValue !== void 0) {
          if (!(ignoreSaved && (v.id != null))) {
            fvs.push(v);
          }
        }
      }
    }
    return fvs;
  };

  exports.getFileValuesFromCollection = function(collection, ignoreSaved) {
    var fvs, i, j, len, len1, ref, state, v, vals;
    fvs = [];
    if (collection.lsStates == null) {
      collection = JSON.parse(collection);
    }
    ref = collection.lsStates;
    for (i = 0, len = ref.length; i < len; i++) {
      state = ref[i];
      vals = state.lsValues;
      for (j = 0, len1 = vals.length; j < len1; j++) {
        v = vals[j];
        if (v.lsType === 'fileValue' && !v.ignored && v.fileValue !== "" && v.fileValue !== void 0) {
          if (!(ignoreSaved && (v.id != null))) {
            fvs.push(v);
          }
        }
      }
    }
    if (fvs.length > 0) {
      return fvs;
    } else {
      return null;
    }
  };

  controllerRedirect = require('../conf/ControllerRedirectConf.js');

  exports.getRelativeFolderPathForPrefix = function(prefix) {
    var entityDef;
    if (controllerRedirect.controllerRedirectConf[prefix] != null) {
      entityDef = controllerRedirect.controllerRedirectConf[prefix];
      return entityDef.relatedFilesRelativePath + "/";
    } else {
      return null;
    }
  };

  exports.getPrefixFromEntityCode = function(code) {
    var pref, redir, ref;
    ref = controllerRedirect.controllerRedirectConf;
    for (pref in ref) {
      redir = ref[pref];
      if (code.indexOf(pref) > -1) {
        return pref;
      }
    }
    return null;
  };

  exports.createLSTransaction = function(date, comments, callback) {
    var config, request;
    if (global.specRunnerTestmode) {
      console.log("create lsTransaction stubsMode");
      return callback({
        comments: "test transaction",
        date: 1427414400000,
        id: 1234,
        version: 0
      });
    } else {
      config = require('../conf/compiled/conf.js');
      request = require('request');
      return request({
        method: 'POST',
        url: config.all.client.service.persistence.fullpath + "lstransactions",
        json: true,
        body: {
          recordedDate: date,
          comments: comments
        }
      }, function(error, response, json) {
        if (!error && response.statusCode === 201) {
          return callback(json);
        } else {
          console.log('got connection error trying to create an lsTransaction');
          console.log(error);
          console.log(json);
          console.log(response);
          return callback(null);
        }
      });
    }
  };

  exports.insertTransactionIntoEntity = function(transactionid, entity) {
    var i, j, k, lab, len, len1, len2, ref, ref1, ref2, state, val;
    entity.lsTransaction = transactionid;
    if (entity.lsLabels != null) {
      ref = entity.lsLabels;
      for (i = 0, len = ref.length; i < len; i++) {
        lab = ref[i];
        lab.lsTransaction = transactionid;
      }
    }
    if (entity.lsStates != null) {
      ref1 = entity.lsStates;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        state = ref1[j];
        state.lsTransaction = transactionid;
        ref2 = state.lsValues;
        for (k = 0, len2 = ref2.length; k < len2; k++) {
          val = ref2[k];
          val.lsTransaction = transactionid;
        }
      }
    }
    return entity;
  };

}).call(this);
