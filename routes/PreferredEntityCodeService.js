(function() {
  var _, configuredEntityTypes, formatCSVRequestAsReqArray, formatReqArratAsCSV, formatReqArratAsJSON,
    hasProp = {}.hasOwnProperty;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute);
    app.get('/api/entitymeta/configuredEntityTypes/displayName/:displayName', exports.getSpecificEntityTypeRoute);
    app.post('/api/entitymeta/referenceCodes/:csv?', exports.referenceCodesRoute);
    app.post('/api/entitymeta/pickBestLabels', exports.pickBestLabelsRoute);
    return app.post('/api/entitymeta/searchForEntities', exports.searchForEntitiesRoute);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/entitymeta/configuredEntityTypes/:asCodes?', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute);
    app.get('/api/entitymeta/ConfiguredEntityTypes/displayName/:displayName', loginRoutes.ensureAuthenticated, exports.getSpecificEntityTypeRoute);
    app.post('/api/entitymeta/referenceCodes/:csv?', loginRoutes.ensureAuthenticated, exports.referenceCodesRoute);
    app.post('/api/entitymeta/pickBestLabels', loginRoutes.ensureAuthenticated, exports.pickBestLabelsRoute);
    return app.post('/api/entitymeta/searchForEntities', loginRoutes.ensureAuthenticated, exports.searchForEntitiesRoute);
  };

  configuredEntityTypes = require('../conf/ConfiguredEntityTypes.js');

  _ = require('underscore');

  exports.getConfiguredEntityTypesRoute = function(req, resp) {
    var asCodes;
    if (req.params.asCodes != null) {
      asCodes = true;
    } else {
      asCodes = false;
    }
    return exports.getConfiguredEntityTypes(asCodes, function(json) {
      return resp.json(json);
    });
  };

  exports.getConfiguredEntityTypes = function(asCodes, callback) {
    var codes, et, name;
    console.log("asCodes: " + asCodes);
    if (asCodes) {
      codes = (function() {
        var ref, results;
        ref = configuredEntityTypes.entityTypes;
        results = [];
        for (name in ref) {
          if (!hasProp.call(ref, name)) continue;
          et = ref[name];
          results.push({
            code: et.type + " " + et.kind,
            name: name,
            ignored: false
          });
        }
        return results;
      })();
      return callback(codes);
    } else {
      return callback(configuredEntityTypes.entityTypes);
    }
  };

  exports.getSpecificEntityTypeRoute = function(req, resp) {
    var displayName;
    displayName = req.params.displayName;
    return exports.getSpecificEntityType(displayName, function(json) {
      return resp.json(json);
    });
  };

  exports.getSpecificEntityType = function(displayName, callback) {
    return callback(configuredEntityTypes.entityTypes[displayName]);
  };

  exports.referenceCodesRoute = function(req, resp) {
    var csv, requestData;
    requestData = {
      displayName: req.body.displayName
    };
    if (req.params.csv === "csv") {
      csv = true;
      requestData.entityIdStringLines = req.body.entityIdStringLines;
    } else {
      csv = false;
      requestData.requests = req.body.requests;
    }
    return exports.referenceCodes(requestData, csv, function(json) {
      return resp.json(json);
    });
  };

  exports.referenceCodes = function(requestData, csv, callback) {
    var csUtilities, entityType, preferredThingService, reqHashes, reqList;
    console.log(global.specRunnerTestmode);
    console.log("csv is " + csv);
    console.log("request Data is " + JSON.stringify(requestData));
    exports.getSpecificEntityType(requestData.displayName, function(json) {
      requestData.type = json.type;
      requestData.kind = json.kind;
      return requestData.sourceExternal = json.sourceExternal;
    });
    if (csv) {
      reqList = formatCSVRequestAsReqArray(requestData.entityIdStringLines);
    } else {
      reqList = requestData.requests;
    }
    if (requestData.sourceExternal) {
      console.log("looking up external entity");
      csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
      csUtilities.getExternalReferenceCodes(requestData.displayName, reqList, function(prefResp) {
        if (csv) {
          return callback({
            displayName: requestData.displayName,
            resultCSV: formatReqArratAsCSV(prefResp)
          });
        } else {
          return callback({
            displayName: requestData.displayName,
            results: formatReqArratAsJSON(prefResp, "preferredName")
          });
        }
      });
    } else {
      entityType = _.where(configuredEntityTypes.entityTypes, {
        type: requestData.type,
        kind: requestData.kind
      });
      if (entityType.length === 1 && entityType[0].codeOrigin === "ACAS LSThing") {
        preferredThingService = require("./ThingServiceRoutes.js");
        reqHashes = {
          thingType: entityType[0].type,
          thingKind: entityType[0].kind,
          requests: reqList
        };
        preferredThingService.getThingCodesFromNamesOrCodes(reqHashes, function(codeResponse) {
          var out, outStr, res;
          if (csv) {
            out = (function() {
              var i, len, ref, results;
              ref = codeResponse.results;
              results = [];
              for (i = 0, len = ref.length; i < len; i++) {
                res = ref[i];
                results.push(res.requestName + "," + res.referenceName);
              }
              return results;
            })();
            outStr = "Requested Name,Reference Code\n" + out.join('\n');
            return callback({
              displayName: requestData.displayName,
              resultCSV: outStr
            });
          } else {
            return callback({
              displayName: requestData.displayName,
              results: formatReqArratAsJSON(codeResponse.results, "referenceName")
            });
          }
        });
        return;
      }
      callback.statusCode = 500;
      return callback.end("problem with internal preferred Code request: code type and kind are unknown to system");
    }
  };

  exports.pickBestLabelsRoute = function(req, resp) {
    var requestData;
    requestData = {
      displayName: req.body.displayName,
      referenceCodes: req.body.referenceCodes
    };
    return exports.referenceCodes(requestData, function(json) {
      return resp.json(json);
    });
  };

  exports.pickBestLabels = function(requestData, callback) {};

  exports.searchForEntitiesRoute = function(req, resp) {
    var requestData;
    requestData = {
      requestTexts: req.body.requestTexts
    };
    return exports.searchForEntities(requestData, function(json) {
      return resp.json(json);
    });
  };

  exports.searchForEntities = function(requestData, callback) {};

  formatCSVRequestAsReqArray = function(csvReq) {
    var i, len, ref, req, requests;
    requests = [];
    ref = csvReq.split('\n');
    for (i = 0, len = ref.length; i < len; i++) {
      req = ref[i];
      if (req !== "") {
        requests.push({
          requestName: req
        });
      }
    }
    return requests;
  };

  formatReqArratAsCSV = function(prefResp) {
    var i, len, outStr, pref, preferreds;
    preferreds = prefResp;
    outStr = "Requested Name,Reference Code\n";
    for (i = 0, len = preferreds.length; i < len; i++) {
      pref = preferreds[i];
      outStr += pref.requestName + ',' + pref.preferredName + '\n';
    }
    return outStr;
  };

  formatReqArratAsJSON = function(prefResp, referenceCodeLocation) {
    var i, len, out, pref;
    out = [];
    for (i = 0, len = prefResp.length; i < len; i++) {
      pref = prefResp[i];
      out.push({
        requestName: pref.requestName,
        referenceCode: pref[referenceCodeLocation]
      });
    }
    return out;
  };

}).call(this);
