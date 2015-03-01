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
                  return csUtilities.logUsage("Returned R execution error R function: " + rFunction, JSON.stringify(result.errorMessages), request.body.user);
                } else {
                  returnFunction.call(_this, stdoutFileText);
                  try {
                    if (stdoutFileText.indexOf('"hasError":true' > -1)) {
                      return csUtilities.logUsage("Returned success from R function with trapped errors: " + rFunction, stdoutFileText, request.body.user);
                    } else {
                      return csUtilities.logUsage("Returned success from R function: " + rFunction, "NA", request.body.user);
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
          console.log('got ajax error trying to save new experiment');
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

  exports.getFileValesFromThing = function(thing) {
    var fvs, v, vals, _i, _len;
    vals = thing.lsStates[0].lsValues;
    fvs = [];
    for (_i = 0, _len = vals.length; _i < _len; _i++) {
      v = vals[_i];
      if (v.lsType === 'fileValue' && !v.ignored) {
        fvs.push(v);
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

  exports.getPrefixFromThingCode = function(code) {
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

}).call(this);
