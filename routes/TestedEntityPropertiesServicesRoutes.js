(function() {
  exports.setupAPIRoutes = function(app) {
    return app.post('/api/testedEntities/properties', exports.testedEntityProperties);
  };

  exports.setupRoutes = function(app, loginRoutes) {};

  exports.testedEntityProperties = function(req, resp) {
    var csUtilities, ents, i, j, k, l, len, len1, m, out, prop, prop2, ref, ref1, ref2;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (global.specRunnerTestmode) {
      if (req.body.properties.indexOf('ERROR') > -1) {
        resp.statusCode = 500;
        resp.end("problem with propery request, check log");
      }
      ents = req.body.entityIdStringLines.split('\n');
      console.log(ents);
      out = "id,";
      ref = req.body.properties;
      for (k = 0, len = ref.length; k < len; k++) {
        prop = ref[k];
        out += prop + ",";
      }
      out = out.slice(0, -1) + '\n';
      for (i = l = 0, ref1 = ents.length - 2; 0 <= ref1 ? l <= ref1 : l >= ref1; i = 0 <= ref1 ? ++l : --l) {
        out += ents[i] + ",";
        j = 0;
        ref2 = req.body.properties;
        for (m = 0, len1 = ref2.length; m < len1; m++) {
          prop2 = ref2[m];
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
