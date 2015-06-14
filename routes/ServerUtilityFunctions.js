(function() {
  var basicRScriptPreValidation, controllerRedirect, _;

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

  exports.runRFunction = function(request, rScript, rFunction, returnFunction, preValidationFunction) {
    return exports.runRFunctionOutsideRequest(request.body.user, request.body, rScript, rFunction, returnFunction, preValidationFunction);
  };

  exports.runRFunctionOutsideRequest = function(username, argumentsJSON, rScript, rFunction, returnFunction, preValidationFunction) {
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
    csUtilities.logUsage("About to call R function: " + rFunction, JSON.stringify(argumentsJSON), username);
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
    exec = require('child_process').exec;
    Tempfile = require('temporary/lib/file');
    rCommandFile = new Tempfile;
    requestJSONFile = new Tempfile;
    stdoutFile = new Tempfile;
    return requestJSONFile.writeFile(JSON.stringify(argumentsJSON), (function(_this) {
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
                var message, result;
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
                  return csUtilities.logUsage("Returned R execution error R function: " + rFunction, JSON.stringify(result.errorMessages), username);
                } else {
                  returnFunction.call(_this, stdoutFileText);
                  try {
                    if (stdoutFileText.indexOf('"hasError":true' > -1)) {
                      return csUtilities.logUsage("Returned success from R function with trapped errors: " + rFunction, stdoutFileText, username);
                    } else {
                      return csUtilities.logUsage("Returned success from R function: " + rFunction, "NA", username);
                    }
                  } catch (_error) {
                    error = _error;
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

  exports.setupRoutes = function(app) {
    return app.post('/api/runRFunctionTest', exports.runRFunctionTest);
  };

  exports.runRFunctionTest = function(request, response) {
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    return exports.runRFunction(request, "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R", "runRFunctionTest", function(rReturn) {
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
    var acasPath, d, dotMatches, numDotDots, _i;
    acasPath = process.env.PWD;
    dotMatches = relativePath.match(/\.\.\//g);
    if (dotMatches != null) {
      numDotDots = relativePath.match(/\.\.\//g).length;
      relativePath = relativePath.replace(/\.\.\//g, '');
      for (d = _i = 1; 1 <= numDotDots ? _i <= numDotDots : _i >= numDotDots; d = 1 <= numDotDots ? ++_i : --_i) {
        acasPath = acasPath.replace(/[^\/]+\/?$/, '');
      }
    } else {
      acasPath += '/';
    }
    console.log(acasPath + relativePath + '/');
    return acasPath + relativePath + '/';
  };

  exports.getFileValuesFromEntity = function(thing, ignoreSaved) {
    var fvs, state, v, vals, _i, _j, _len, _len1, _ref;
    fvs = [];
    _ref = thing.lsStates;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      state = _ref[_i];
      vals = state.lsValues;
      for (_j = 0, _len1 = vals.length; _j < _len1; _j++) {
        v = vals[_j];
        if (v.lsType === 'fileValue' && !v.ignored && v.fileValue !== "" && v.fileValue !== void 0) {
          if (!(ignoreSaved && (v.id != null))) {
            fvs.push(v);
          }
        }
      }
    }
    return fvs;
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
    var pref, redir, _ref;
    _ref = controllerRedirect.controllerRedirectConf;
    for (pref in _ref) {
      redir = _ref[pref];
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
    var lab, state, val, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    entity.lsTransaction = transactionid;
    if (entity.lsLabels != null) {
      _ref = entity.lsLabels;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        lab = _ref[_i];
        lab.lsTransaction = transactionid;
      }
    }
    if (entity.lsStates != null) {
      _ref1 = entity.lsStates;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        state = _ref1[_j];
        state.lsTransaction = transactionid;
        _ref2 = state.lsValues;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          val = _ref2[_k];
          val.lsTransaction = transactionid;
        }
      }
    }
    return entity;
  };

}).call(this);
