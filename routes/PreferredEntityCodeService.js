(function() {
  var _, configuredEntityTypes, formatCSVRequestAsReqArray, formatReqArratAsCSV;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/entitymeta/configuredEntityTypes', exports.getConfiguredEntityTypes);
    return app.post('/api/entitymeta/preferredCodes', exports.preferredCodes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/entitymeta/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypes);
    return app.post('/api/entitymeta/preferredCodes', loginRoutes.ensureAuthenticated, exports.preferredCodes);
  };

  configuredEntityTypes = require('../conf/ConfiguredEntityTypes.js');

  _ = require('underscore');

  exports.getConfiguredEntityTypes = function(req, resp) {
    var codes, et;
    if (req.query.asCodes != null) {
      codes = (function() {
        var i, len, ref, results;
        ref = configuredEntityTypes.entityTypes;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          et = ref[i];
          results.push({
            code: et.type + " " + et.kind,
            name: et.displayName,
            ignored: false
          });
        }
        return results;
      })();
      return resp.json(codes);
    } else {
      return resp.json(configuredEntityTypes.entityTypes);
    }
  };

  exports.preferredCodes = function(req, resp) {
    var csUtilities, entityType, preferredBatchService, preferredThingService, reqHashes;
    if (req.body.type === "compound") {
      reqHashes = formatCSVRequestAsReqArray(req.body.entityIdStringLines);
      if (req.body.kind === "batch name") {
        preferredBatchService = require("./PreferredBatchIdService.js");
        preferredBatchService.getPreferredCompoundBatchIDs(reqHashes, function(json) {
          var prefResp;
          prefResp = JSON.parse(json);
          return resp.json({
            type: req.body.type,
            kind: req.body.kind,
            resultCSV: formatReqArratAsCSV(prefResp.results)
          });
        });
        return;
      } else if (req.body.kind === "parent name") {
        console.log("looking up compound parents");
        csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
        csUtilities.getPreferredParentIds(reqHashes, function(prefResp) {
          return resp.json({
            type: req.body.type,
            kind: req.body.kind,
            resultCSV: formatReqArratAsCSV(prefResp)
          });
        });
        return;
      }
    } else {
      entityType = _.where(configuredEntityTypes.entityTypes, {
        type: req.body.type,
        kind: req.body.kind
      });
      if (entityType.length === 1 && entityType[0].codeOrigin === "ACAS LSThing") {
        preferredThingService = require("./ThingServiceRoutes.js");
        reqHashes = {
          thingType: entityType[0].type,
          thingKind: entityType[0].kind,
          requests: formatCSVRequestAsReqArray(req.body.entityIdStringLines)
        };
        preferredThingService.getThingCodesFromNamesOrCodes(reqHashes, function(codeResponse) {
          var out, outStr, res;
          out = (function() {
            var i, len, ref, results;
            ref = codeResponse.results;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              res = ref[i];
              results.push(res.requestName + "," + res.preferredName);
            }
            return results;
          })();
          outStr = "Requested Name,Preferred Code\n" + out.join('\n');
          return resp.json({
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
    outStr = "Requested Name,Preferred Code\n";
    for (i = 0, len = preferreds.length; i < len; i++) {
      pref = preferreds[i];
      outStr += pref.requestName + ',' + pref.preferredName + '\n';
    }
    return outStr;
  };

}).call(this);
