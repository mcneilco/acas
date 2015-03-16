(function() {
  var checkBatch_TestMode,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  exports.setupAPIRoutes = function(app) {
    return app.post('/api/preferredBatchId', exports.preferredBatchId);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.post('/api/preferredBatchId', loginRoutes.ensureAuthenticated, exports.preferredBatchId);
    return app.post('/api/testRoute', loginRoutes.ensureAuthenticated, exports.testRoute);
  };

  exports.preferredBatchId = function(req, resp) {
    var config, csUtilities, each, errorMessage, possibleServiceTypes, request, requests, serverUtilityFunctions, serviceType, _;
    _ = require("underscore");
    each = require("each");
    request = require('request');
    config = require('../conf/compiled/conf.js');
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    serviceType = config.all.client.service.external.preferred.batchid.type;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    possibleServiceTypes = ['SeuratCmpdReg', 'GeneCodeCheckByR', 'AcasCmpdReg', 'LabSynchCmpdReg', 'SingleBatchNameQueryString'];
    requests = req.body.requests;
    if (__indexOf.call(possibleServiceTypes, serviceType) < 0) {
      errorMessage = "client.service.external.preferred.batchid.type '" + serviceType + "' is not in possible service types " + possibleServiceTypes;
      console.log(errorMessage);
      resp.end(errorMessage);
    }
    if (serviceType === "SeuratCmpdReg" && !global.specRunnerTestmode) {
      req.body.user = "";
      return serverUtilityFunctions.runRFunction(req, "public/src/modules/ServerAPI/src/server/SeuratBatchCheck.R", "seuratBatchCodeCheck", function(rReturn) {
        return resp.end(rReturn);
      });
    } else if (serviceType === "AcasCmpdReg" && !global.specRunnerTestmode) {
      req.body.user = "";
      return serverUtilityFunctions.runRFunction(req, "public/src/modules/ServerAPI/src/server/AcasCmpdRegBatchCheck.R", "acasCmpdRegBatchCheck", function(rReturn) {
        return resp.end(rReturn);
      });
    } else if (serviceType === "GeneCodeCheckByR" && !global.specRunnerTestmode) {
      req.body.user = "";
      return serverUtilityFunctions.runRFunction(req, "public/src/modules/ServerAPI/src/server/AcasGeneBatchCheck.R", "acasGeneCodeCheck", function(rReturn) {
        return resp.end(rReturn);
      });
    } else {
      return each(requests).parallel(1).on("item", function(batchName, next) {
        var baseurl;
        if (global.specRunnerTestmode) {
          console.log("running fake batch check");
          checkBatch_TestMode(batchName);
          return next();
        } else if (serviceType === "LabSynchCmpdReg") {
          console.log("running LabSynchCmpdReg batch check");
          baseurl = config.all.server.service.external.preferred.batchid.url;
          return request({
            method: 'GET',
            url: baseurl + batchName.requestName,
            json: true
          }, (function(_this) {
            return function(error, response, json) {
              if (!error && response.statusCode === 200) {
                if (json.lot != null) {
                  if (json.lot.corpName != null) {
                    batchName.preferredName = batchName.requestName;
                  }
                } else {
                  batchName.preferredName = "";
                }
              } else {
                console.log('got ajax error trying to validate batch name');
              }
              return next();
            };
          })(this));
        } else if (serviceType === "SingleBatchNameQueryString") {
          console.log("running SingleBatchNameQueryString batch check");
          baseurl = config.all.server.service.external.preferred.batchid.url;
          return request({
            method: 'GET',
            url: baseurl + batchName.requestName + ".csv",
            json: false,
            headers: csUtilities.makeServiceRequestHeaders(req.user)
          }, (function(_this) {
            return function(error, response, body) {
              if (!error && response.statusCode === 200) {
                console.log(body);
                batchName.preferredName = body;
              } else if (!error && response.statusCode === 204) {
                batchName.preferredName = "";
              } else {
                console.log('got ajax error trying to validate batch name');
              }
              return next();
            };
          })(this));
        }
      }).on("error", function(err, errors) {
        console.log(err.message);
        return _.each(errors, function(error) {
          return console.log("  " + error.message);
        });
      }).on("end", function() {
        var answer;
        answer = {
          error: false,
          errorMessages: [],
          results: requests
        };
        console.log(JSON.stringify(answer));
        return resp.json(answer);
      });
    }
  };

  checkBatch_TestMode = function(batchName) {
    var idComps, pref, respId;
    idComps = batchName.requestName.split("_");
    pref = idComps[0];
    respId = "";
    switch (pref) {
      case "norm":
        respId = batchName.requestName;
        break;
      case "none":
        respId = "";
        break;
      case "alias":
        respId = "norm_" + idComps[1] + "A";
        break;
      default:
        respId = batchName.requestName;
    }
    return batchName.preferredName = respId;
  };

  exports.testRoute = function(req, resp) {
    console.log(req.body);
    return resp.json({
      hello: "world"
    });
  };

}).call(this);
