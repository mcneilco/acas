(function() {
  var configuredEntityTypes, formatCSVRequestAsReqArray, formatReqArratAsCSV, _;

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
            resultCSV: formatReqArratAsCSV(prefResp.results)
          });
        });
        return;
      } else if (req.body.kind === "parent name") {
        console.log("looking up compound parents");
        csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
        csUtilities.getPreferredParentIds(reqHashes, function(prefResp) {
          return resp.json({
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
        preferredThingService.getThingCodesFormNamesOrCodes(reqHashes, function(codeResponse) {
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
          return resp.json({
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
      requests.push({
        requestName: req
      });
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
