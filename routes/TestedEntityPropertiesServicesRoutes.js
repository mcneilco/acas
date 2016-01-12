(function() {
  exports.setupAPIRoutes = function(app) {
    app.post('/api/testedEntities/properties', exports.testedEntityPropertiesRoute);
    app.get('/api/:entityType/:entityKind/property/descriptors', exports.entityPropertyDescriptors);
    app.post('/api/:entityType/:entityKind/properties/:format?', exports.entityPropertiesRoute);
    return app.post('/api/entityMeta/properties/:format?', exports.entityPropertiesRoute);
  };

  exports.setupRoutes = function(app, loginRoutes) {
    app.post('/api/testedEntities/properties', loginRoutes.ensureAuthenticated, exports.testedEntityProperties);
    app.get('/api/:entityType/:entityKind/property/descriptors', loginRoutes.ensureAuthenticated, exports.entityPropertyDescriptors);
    return app.post('/api/:entityType/:entityKind/properties/:format?', loginRoutes.ensureAuthenticated, exports.entityPropertiesRoute);
  };

  exports.entityPropertiesRoute = function(req, resp) {
    return exports.entityProperties(req.body.displayName, req.body.entityCodeList, req.body.propertyNameList, req.params.format, function(json) {
      if (json.indexOf('problem with property request') > -1) {
        return resp.statusCode = 500;
      } else {
        return resp.json(json);
      }
    });
  };

  exports.entityProperties = function(displayName, entityCodeList, propertyNameList, format, callback) {
    var csUtilities, entityCode, entityResponse, index, k, l, len, len1, propertyName, response, withHeader;
    if (format == null) {
      format = "json";
    }
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (global.specRunnerTestmode) {
      if (JSON.stringify(propertyNameList).indexOf('ERROR') > -1) {
        callback("problem with property request, check log");
      }
      response = [];
      for (index = k = 0, len = entityCodeList.length; k < len; index = ++k) {
        entityCode = entityCodeList[index];
        entityResponse = {};
        entityResponse.id = entityCode;
        for (l = 0, len1 = propertyNameList.length; l < len1; l++) {
          propertyName = propertyNameList[l];
          if (entityCode.indexOf("ERROR")) {
            entityResponse[propertyName] = "";
          } else {

          }
          entityResponse[propertyName] = 1;
        }
        response.push(entityResponse);
      }
      if (format === "csv") {
        response = exports.objectToCSV(response, withHeader = true);
      }
      return callback(response);
    } else {
      return csUtilities.getExternalEntityProperties(displayName, entityCodeList, propertyNameList, format, (function(_this) {
        return function(response) {
          if (response != null) {
            return callback(response);
          } else {
            return callback("problem with property request, check log");
          }
        };
      })(this));
    }
  };

  exports.objectToCSV = function(objArray, withHeader) {
    var array, i, index, line, str;
    array = typeof objArray !== 'object' ? JSON.parse(objArray) : objArray;
    str = '';
    if (withHeader) {
      str += Object.keys(array[0]).join(',') + '\n';
    }
    i = 0;
    while (i < array.length) {
      line = '';
      for (index in array[i]) {
        if (line !== '') {
          line += ',';
        }
        line += array[i][index];
      }
      str += line + '\n';
      i++;
    }
    return str;
  };

  exports.testedEntityPropertiesRoute = function(req, resp) {
    return exports.getEntityProperties(req.body.properties, req.body.entityIdStringLines, function(json) {
      if (JSON.stringify(json).indexOf('problem with property request') > -1) {
        resp.statusCode = 500;
        return resp.end("problem with property request, check log");
      } else {
        return resp.json(json);
      }
    });
  };

  exports.getEntityProperties = function(properties, entityIdStringLines, callback) {
    var csUtilities, ents, i, j, k, l, len, len1, m, out, prop, prop2, ref;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (global.specRunnerTestmode) {
      if (properties.indexOf('ERROR') > -1) {
        callback("problem with property request, check log");
      }
      ents = entityIdStringLines.split('\n');
      out = "id,";
      for (k = 0, len = properties.length; k < len; k++) {
        prop = properties[k];
        out += prop + ",";
      }
      out = out.slice(0, -1) + '\n';
      for (i = l = 0, ref = ents.length - 2; 0 <= ref ? l <= ref : l >= ref; i = 0 <= ref ? ++l : --l) {
        out += ents[i] + ",";
        j = 0;
        for (m = 0, len1 = properties.length; m < len1; m++) {
          prop2 = properties[m];
          if (ents[i].indexOf('ERROR') < 0) {
            out += i + j++;
          } else {
            out += "";
          }
          out += ',';
        }
        out = out.slice(0, -1) + '\n';
      }
      return callback({
        resultCSV: out
      });
    } else {
      return csUtilities.getTestedEntityProperties(properties, entityIdStringLines, function(properties) {
        if (properties != null) {
          return callback({
            resultCSV: properties
          });
        } else {
          return callback("problem with property request, check log");
        }
      });
    }
  };

  exports.entityPropertyDescriptors = function(req, resp) {
    var csUtilities, entityDescriptorServiceTestJSON;
    csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');
    if (global.specRunnerTestmode) {
      entityDescriptorServiceTestJSON = require("../public/javascripts/spec/testFixtures/EntityPropertyDescriptorsServiceTestJSON.js");
      return resp.json(entityDescriptorServiceTestJSON.propertyDescriptors[req.params.entityType][req.params.entityKind]);
    } else {
      return csUtilities.getEntityPropertyDescriptors(req.params.entityType, req.params.entityKind, function(descriptorsJSON) {
        return resp.json(JSON.parse(descriptorsJSON));
      });
    }
  };

}).call(this);
