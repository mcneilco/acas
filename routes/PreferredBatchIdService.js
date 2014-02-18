
/* To install this Module
1) Add these lines to app.coffee:
preferredBatchIdRoutes = require './public/src/modules/02_serverAPI/src/server/routes/PreferredBatchIdService.js'
preferredBatchIdRoutes.setupRoutes(app)
 */

(function() {
  var checkBatch_TestMode;

  exports.setupRoutes = function(app) {
    app.post('/api/preferredBatchId', exports.preferredBatchId);
    return app.post('/api/testRoute', exports.testRoute);
  };

  exports.preferredBatchId = function(req, resp) {
    var config, each, request, requests, serverUtilityFunctions, serviceType, _;
    _ = require("underscore");
    each = require("each");
    request = require('request');
    config = require('../conf/compiled/conf.js');
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    serviceType = config.all.client.service.external.preferred.batchid.type;
    requests = req.body.requests;
    if (serviceType === "SeuratCmpdReg" && !global.specRunnerTestmode) {
      req.body.user = "";
      return serverUtilityFunctions.runRFunction(req, "public/src/modules/ServerAPI/src/server/SeuratBatchCheck.R", "seuratBatchCodeCheck", function(rReturn) {
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
            json: false
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
