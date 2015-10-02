(function() {
  var preferredCodeResponseToJSON;

  exports.setupRoutes = function(app, loginRoutes) {
    app.get('/excelApps/compoundInfo', loginRoutes.ensureAuthenticated, exports.compoundInfoIndex);
    return app.post('/excelApps/getPreferredIDAndProperties', loginRoutes.ensureAuthenticated, exports.getPreferredIDAndProperties);
  };

  exports.compoundInfoIndex = function(req, resp) {
    var config, loginUser, loginUserName;
    global.specRunnerTestmode = global.stubsMode ? true : false;
    config = require('../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      loginUserName = req.user.username;
      loginUser = req.user;
    } else {
      loginUserName = "nouser";
      loginUser = {
        id: 0,
        username: "nouser",
        email: "nouser@nowhere.com",
        firstName: "no",
        lastName: "user"
      };
    }
    return resp.render('CIExcelCompoundPropertiesApp', {
      title: 'Compound Info',
      AppLaunchParams: {
        loginUserName: loginUserName,
        loginUser: loginUser,
        testMode: global.specRunnerTestmode,
        deployMode: global.deployMode
      }
    });
  };

  exports.getPreferredIDAndProperties = function(req, resp) {
    var _, blankRequest, codeService, config, createOutObject, entities, entity, index, j, len, noneBlankRequest, outObject, propertiesService, requestData;
    _ = require('underscore');
    codeService = require('../routes/PreferredEntityCodeService.js');
    propertiesService = require('../routes/TestedEntityPropertiesServicesRoutes.js');
    config = require('../conf/compiled/conf.js');
    entities = req.body.entityIdStringLines.split('\n');
    outObject = [];
    createOutObject = (function(_this) {
      return function(entity, index) {
        var preferredIDAndPropertyObject;
        preferredIDAndPropertyObject = {
          index: index,
          preferredParentCode: "",
          preferredBatchCode: "",
          preferredCode: "",
          requestedName: entity
        };
        if (req.body.selectedProperties.parentNames != null) {
          req.body.selectedProperties.parentNames.forEach(function(selectedParentProperty) {
            return preferredIDAndPropertyObject[selectedParentProperty] = '';
          });
        }
        if (req.body.selectedProperties.batchNames != null) {
          req.body.selectedProperties.batchNames.forEach(function(selectedBatchProperty) {
            return preferredIDAndPropertyObject[selectedBatchProperty] = '';
          });
        }
        return outObject.push(preferredIDAndPropertyObject);
      };
    })(this);
    for (index = j = 0, len = entities.length; j < len; index = ++j) {
      entity = entities[index];
      createOutObject(entity, index);
    }
    blankRequest = _.where(outObject, {
      'requestedName': ''
    });
    noneBlankRequest = _.reject(outObject, function(prefs) {
      return prefs.requestedName === '';
    });
    requestData = {
      displayName: "Corporate Batch ID",
      entityIdStringLines: _.pluck(noneBlankRequest, 'requestedName').join("\n")
    };
    return codeService.referenceCodes(requestData, true, (function(_this) {
      return function(response) {
        var fillPreferred, k, len1, lines, preferredCodeLine, preferredCodes;
        lines = response.resultCSV.split("\n");
        preferredCodes = lines.slice(1, lines.length - 1);
        fillPreferred = function(preferredCodeLine, index) {
          return noneBlankRequest[index].preferredBatchCode = preferredCodeLine.split(",")[1];
        };
        for (index = k = 0, len1 = preferredCodes.length; k < len1; index = ++k) {
          preferredCodeLine = preferredCodes[index];
          fillPreferred(preferredCodeLine, index);
        }
        requestData = {
          displayName: "Corporate Parent ID",
          entityIdStringLines: _.pluck(noneBlankRequest, 'requestedName').join("\n")
        };
        return codeService.referenceCodes(requestData, true, function(response) {
          var entityIdStringLines, l, len2, missingPreferredCodes;
          lines = response.resultCSV.split("\n");
          preferredCodes = lines.slice(1, lines.length - 1);
          fillPreferred = function(preferredCodeLine, index) {
            if (noneBlankRequest[index].preferredBatchCode === "") {
              return noneBlankRequest[index].preferredParentCode = preferredCodeLine.split(",")[1];
            }
          };
          for (index = l = 0, len2 = preferredCodes.length; l < len2; index = ++l) {
            preferredCodeLine = preferredCodes[index];
            fillPreferred(preferredCodeLine, index);
          }
          outObject = noneBlankRequest.concat(blankRequest);
          outObject = _.map(outObject, function(pref) {
            if (pref.preferredBatchCode !== '') {
              pref.preferredCode = pref.preferredBatchCode;
            } else {
              if (pref.preferredParentCode !== '') {
                pref.preferredCode = pref.preferredParentCode;
              } else {
                pref.preferredCode = '';
              }
            }
            return pref;
          });
          missingPreferredCodes = _.where(outObject, {
            'preferredCode': ''
          });
          preferredCodes = _.reject(outObject, function(prefs) {
            return prefs.preferredCode === '';
          });
          entityIdStringLines = _.pluck(preferredCodes, 'preferredCode').join("\n");
          return exports.fillEntityProperties("Corporate Parent ID", entityIdStringLines, req.body.selectedProperties.parentNames, preferredCodes, function(preferredCodes) {
            var preferredBatchCodes, preferredParentCodes;
            preferredBatchCodes = _.reject(preferredCodes, function(prefs) {
              return prefs.preferredBatchCode === '';
            });
            preferredParentCodes = _.reject(preferredCodes, function(prefs) {
              return prefs.preferredParentCode === '';
            });
            entityIdStringLines = _.pluck(preferredBatchCodes, 'preferredBatchCode');
            return exports.fillEntityProperties("Corporate Batch ID", entityIdStringLines, req.body.selectedProperties.batchNames, preferredBatchCodes, function(preferredBatchCodes) {
              var arr, array, i, idKeys, keyNames, line, outCSV, prettyIDKeys, prettyNames;
              outObject = preferredBatchCodes.concat(preferredParentCodes.concat(missingPreferredCodes));
              outObject = _.sortBy(outObject, function(obj) {
                return obj.index;
              });
              array = typeof outObject !== 'object' ? JSON.parse(outObject) : outObject;
              outCSV = '';
              if (req.body.includeRequestedName === "true") {
                idKeys = ['requestedName', 'preferredCode'];
                prettyIDKeys = ['Requested Name', 'Preferred Code'];
              } else {
                idKeys = ['preferredCode'];
                prettyIDKeys = ['Preferred Code'];
              }
              if (req.body.selectedProperties.batchNames != null) {
                idKeys = idKeys.concat(req.body.selectedProperties.batchNames);
                prettyIDKeys = prettyIDKeys.concat(req.body.selectedProperties.batchPrettyNames);
              }
              if (req.body.selectedProperties.parentNames != null) {
                idKeys = idKeys.concat(req.body.selectedProperties.parentNames);
                prettyIDKeys = prettyIDKeys.concat(req.body.selectedProperties.parentPrettyNames);
              }
              keyNames = idKeys;
              prettyNames = prettyIDKeys;
              if (req.body.insertColumnHeaders === "true") {
                outCSV += prettyNames.join('\t') + '\n';
              }
              i = 0;
              while (i < array.length) {
                line = '';
                arr = _.pick(array[i], keyNames);
                for (index in arr) {
                  line += arr[index] + "\t";
                }
                line = line.slice(0, line.length - 1);
                outCSV += line + '\n';
                i++;
              }
              return resp.json(outCSV);
            });
          });
        });
      };
    })(this));
  };

  preferredCodeResponseToJSON = function(csv, shouldIndex, codeKind, additionalFieldsToAdd) {
    var _, index, lines, preferredCode, preferredCodes, splitLines, toArray;
    _ = require('underscore');
    toArray = function(preferredCode, index, additionalFieldsToAdd) {
      var out, prefs;
      out = {};
      prefs = preferredCode.split(",");
      out.requestedName = prefs[0];
      out[codeKind] = prefs[1];
      if (shouldIndex) {
        out.index = index;
      }
      out = _.extend(out, additionalFieldsToAdd);
      return out;
    };
    lines = csv.split("\n");
    preferredCodes = lines.slice(1, lines.length - 1);
    splitLines = (function() {
      var j, len, results;
      results = [];
      for (index = j = 0, len = preferredCodes.length; j < len; index = ++j) {
        preferredCode = preferredCodes[index];
        results.push(toArray(preferredCode, index, additionalFieldsToAdd));
      }
      return results;
    })();
    return splitLines;
  };

  exports.fillEntityProperties = function(displayName, entityIdStringLines, descriptorNames, outObject, callback) {
    var propertiesService;
    propertiesService = require('../routes/TestedEntityPropertiesServicesRoutes.js');
    if ((descriptorNames != null) && entityIdStringLines.length > 0 && entityIdStringLines !== "") {
      return propertiesService.entityProperties(displayName, entityIdStringLines, descriptorNames, "tsv", (function(_this) {
        return function(response) {
          var addRow, header, index, j, len, row, rows;
          addRow = function(row, header, rowIndex) {
            var addColumnValue, columnValue, columns, index, j, len, out, results;
            out = {};
            columns = row.split("\t");
            columns = columns.slice(1, row.length - 1);
            addColumnValue = function(columnValue, header, columnIndex) {
              var propName;
              propName = header[columnIndex];
              return outObject[rowIndex][propName] = columnValue;
            };
            results = [];
            for (index = j = 0, len = columns.length; j < len; index = ++j) {
              columnValue = columns[index];
              results.push(addColumnValue(columnValue, header, index));
            }
            return results;
          };
          rows = response.split("\n");
          header = rows[0].split("\t");
          header = header.slice(1, header.length);
          rows = rows.slice(1, rows.length - 1);
          for (index = j = 0, len = rows.length; j < len; index = ++j) {
            row = rows[index];
            addRow(row, header, index);
          }
          return callback(outObject);
        };
      })(this));
    } else {
      return callback(outObject);
    }
  };

}).call(this);
