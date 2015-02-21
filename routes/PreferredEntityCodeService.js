(function() {
  var configuredEntityTypes;

  exports.setupAPIRoutes = function(app) {
    return app.get('/api/configuredEntityTypes', exports.getConfiguredEntityTypes);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/configuredEntityTypes', loginRoutes.ensureAuthenticated, exports.getConfiguredEntityTypes);
  };

  configuredEntityTypes = require('../conf/ConfiguredEntityTypes.js');

  exports.getConfiguredEntityTypes = function(req, resp) {
    var codes, et;
    console.log(req.query);
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

}).call(this);
