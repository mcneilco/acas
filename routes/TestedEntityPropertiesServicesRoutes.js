(function() {
  exports.setupAPIRoutes = function(app) {
    return app.post('/api/testedEntities/properties', exports.testedEntityProperties);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.post('/api/testedEntities/properties', loginRoutes.ensureAuthenticated, exports.testedEntityProperties);
  };

  exports.testedEntityProperties = function(req, resp) {
    var csUtilities, ents, i, j, out, prop, prop2, _i, _j, _k, _len, _len1, _ref, _ref1, _ref2;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (global.specRunnerTestmode) {
      if (req.body.properties.indexOf('ERROR') > -1) {
        resp.statusCode = 500;
        resp.end("problem with propery request, check log");
      }
      ents = req.body.entityIdStringLines.split('\n');
      console.log(ents);
      out = "id,";
      _ref = req.body.properties;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        out += prop + ",";
      }
      out = out.slice(0, -1) + '\n';
      for (i = _j = 0, _ref1 = ents.length - 2; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        out += ents[i] + ",";
        j = 0;
        _ref2 = req.body.properties;
        for (_k = 0, _len1 = _ref2.length; _k < _len1; _k++) {
          prop2 = _ref2[_k];
          if (ents[i].indexOf('ERROR') < 0) {
            out += i + j++;
          } else {
            out += "";
          }
          out += ',';
        }
        out = out.slice(0, -1) + '\n';
      }
      return resp.json({
        resultCSV: out
      });
    } else {
      return csUtilities.getTestedEntityProperties(req.body.properties, req.body.entityIdStringLines, function(properties) {
        if (properties != null) {
          return resp.json({
            resultCSV: properties
          });
        } else {
          resp.statusCode = 500;
          return resp.end("problem with propery request, check log");
        }
      });
    }
  };

}).call(this);
