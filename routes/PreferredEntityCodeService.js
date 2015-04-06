(function() {
  var configuredEntityTypes;

  exports.setupAPIRoutes = function(app) {
    app.get('/api/entitymeta/configuredEntityTypes', exports.getConfiguredEntityTypes);
    return app.post('/api/entitymeta/preferredCodes', exports.preferredCodes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/api/entitymeta/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypes);
    return app.post('/api/entitymeta/preferredCodes', loginRoutes.ensureAuthenticated, exports.preferredCodes);
  };

  configuredEntityTypes = require('../conf/ConfiguredEntityTypes.js');

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
    var name, out, outStr;
    if (global.specRunnerTestmode) {
      if (req.body.type.indexOf('ERROR') > -1) {
        resp.statusCode = 500;
        resp.end("problem with propery request, check log");
        return;
      }
      out = (function() {
        var _i, _len, _ref, _results;
        _ref = req.body.entityIdStringLines.split('\n');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i];
          _results.push(name + "," + (name.indexOf('ERROR') < 0 ? name : ""));
        }
        return _results;
      })();
      outStr = "Requested Name,Preferred Code\n" + out.join('\n');
      return resp.json({
        resultCSV: outStr
      });
    } else {
      return console.log("preferredCodes not implemented");
    }
  };

}).call(this);
