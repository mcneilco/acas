(function() {
  var configuredEntityTypes, formatCSVRequestAsReqArray, formatReqArratAsCSV, _;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/entitymeta/configuredEntityTypes/:asCodes?', exports.getConfiguredEntityTypesRoute);
    return app.post('/api/entitymeta/preferredCodes', exports.preferredCodesRoute);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/entitymeta/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypesRoute);
    return app.post('/api/entitymeta/preferredCodes', loginRoutes.ensureAuthenticated, exports.preferredCodesRoute);
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
    var codes, et;
    console.log("asCodes: " + asCodes);
    if (asCodes) {
      codes = (function() {
        var _i, _len, _ref, _results;
        _ref = configuredEntityTypes.entityTypes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          et = _ref[_i];
          _results.push({
            code: et.type + " " + et.kind,
            name: et.displayName,
            ignored: false
          });
        }
        return _results;
      })();
      return callback(codes);
    } else {
      return callback(configuredEntityTypes.entityTypes);
    }
  };

  exports.preferredCodesRoute = function(req, resp) {
    var requestData;
    requestData = {
      type: req.body.type,
      kind: req.body.kind,
      entityIdStringLines: req.body.entityIdStringLines
    };
    return exports.preferredCodes(requestData, function(json) {
      return resp.json(json);
    });
  };

  exports.preferredCodes = function(requestData, callback) {
    var csUtilities, entityType, preferredBatchService, preferredThingService, reqHashes;
    console.log(global.specRunnerTestmode);
    if (requestData.type === "compound") {
      reqHashes = formatCSVRequestAsReqArray(requestData.entityIdStringLines);
      if (requestData.kind === "batch name") {
        preferredBatchService = require("./PreferredBatchIdService.js");
        preferredBatchService.getPreferredCompoundBatchIDs(reqHashes, function(json) {
          var prefResp;
          prefResp = JSON.parse(json);
          return callback({
            type: requestData.type,
            kind: requestData.kind,
            resultCSV: formatReqArratAsCSV(prefResp.results)
          });
        });
        return;
      } else if (requestData.kind === "parent name") {
        console.log("looking up compound parents");
        csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
        csUtilities.getPreferredParentIds(reqHashes, function(prefResp) {
          return callback({
            type: requestData.type,
            kind: requestData.kind,
            resultCSV: formatReqArratAsCSV(prefResp)
          });
        });
        return;
      }
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
          requests: formatCSVRequestAsReqArray(requestData.entityIdStringLines)
        };
        preferredThingService.getThingCodesFromNamesOrCodes(reqHashes, function(codeResponse) {
          var out, outStr, res;
          out = (function() {
            var _i, _len, _ref, _results;
            _ref = codeResponse.results;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              res = _ref[_i];
              _results.push(res.requestName + "," + res.preferredName);
            }
            return _results;
          })();
          outStr = "Requested Name,Preferred Code\n" + out.join('\n');
          return callback({
            type: codeResponse.thingType,
            kind: codeResponse.thingKind,
            resultCSV: outStr
          });
        });
        return;
      }
    }
    resp.statusCode = 500;
    return resp.end("problem with preferred Code request: code type and kind are unknown to system");
  };

  formatCSVRequestAsReqArray = function(csvReq) {
    var req, requests, _i, _len, _ref;
    requests = [];
    _ref = csvReq.split('\n');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      req = _ref[_i];
      if (req !== "") {
        requests.push({
          requestName: req
        });
      }
    }
    return requests;
  };

  formatReqArratAsCSV = function(prefResp) {
    var outStr, pref, preferreds, _i, _len;
    preferreds = prefResp;
    outStr = "Requested Name,Preferred Code\n";
    for (_i = 0, _len = preferreds.length; _i < _len; _i++) {
      pref = preferreds[_i];
      outStr += pref.requestName + ',' + pref.preferredName + '\n';
    }
    return outStr;
  };

}).call(this);
