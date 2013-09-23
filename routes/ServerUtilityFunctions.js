(function() {
  var basicRScriptPreValidation;

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
    var Tempfile, child, command, csUtilities, exec, preValErrors, rCommand, rCommandFile, requestJSONFile;

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
    requestJSONFile.writeFileSync(JSON.stringify(request.body));
    rCommand = 'tryCatch({ ';
    rCommand += '	out <- capture.output(require("rjson")); ';
    rCommand += '	out <- capture.output(source("' + rScript + '")); ';
    rCommand += '	out <- capture.output(request <- fromJSON(file=' + JSON.stringify(requestJSONFile.path) + '));';
    rCommand += '	out <- capture.output(returnValues <- ' + rFunction + '(request));';
    rCommand += '	cat(toJSON(returnValues));';
    rCommand += '},error = function(ex) {cat(paste("R Execution Error:",ex));})';
    rCommandFile.writeFileSync(rCommand);
    command = "Rscript " + rCommandFile.path + " 2> /dev/null";
    return child = exec(command, function(error, stdout, stderr) {
      var message, result;

      console.log("stderr: " + stderr);
      console.log("stdout: " + stdout);
      if (stdout.indexOf("R Execution Error") === 0) {
        message = {
          errorLevel: "error",
          message: stdout
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
        returnFunction.call(this, stdout);
        try {
          if (stdout.indexOf('"hasError":true' > -1)) {
            return csUtilities.logUsage("Returned success from R function with trapped errors: " + rFunction, stdout, request.body.user);
          } else {
            return csUtilities.logUsage("Returned success from R function: " + rFunction, "NA", request.body.user);
          }
        } catch (_error) {
          error = _error;
          return console.log(error);
        }
      }
    });
  };

  /* To allow following test routes to work, install this Module
  1) Add these lines to app.coffee:
  # ServerUtility function testing routes
  serverUtilityFunctions = require './routes/serverUtilityFunctions.js'
  app.post '/api/runRFunctionTest', serverUtilityFunctions.runRFunctionTest
  */


  exports.runRFunctionTest = function(request, response) {
    var serverUtilityFunctions;

    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    response.writeHead(200, {
      'Content-Type': 'application/json'
    });
    return serverUtilityFunctions.runRFunction(request, "public/src/modules/serverAPI/src/server/RunRFunctionTestStub.R", "runRFunctionTest", function(rReturn) {
      return response.end(rReturn);
    });
  };

  exports.getFromACASServer = function(baseurl, resp) {
    var request,
      _this = this;

    request = require('request');
    return request({
      method: 'GET',
      url: baseurl,
      json: true
    }, function(error, response, json) {
      if (!error && response.statusCode === 200) {
        return resp.end(JSON.stringify(json));
      } else {
        console.log('got ajax error trying to save new experiment');
        console.log(error);
        console.log(json);
        return console.log(response);
      }
    });
  };

}).call(this);
