(function() {
  var allCodeTableFiles, allCodeTableTypesAndKinds, allCodeTables, allCodeTablesFileName, allFiles, codeTable, codeTableFile, currentTypeAndKind, data, fileName, fs, glob, jsonallcodetablesstring, jsonfilestring, kind, newFileName, type, _, _i, _j, _k, _len, _len1, _len2, _ref;

  fs = require('fs');

  glob = require('glob');

  _ = require("underscore");

  allFiles = glob.sync("../public/javascripts/spec/testFixtures/*.js");

  for (_i = 0, _len = allFiles.length; _i < _len; _i++) {
    fileName = allFiles[_i];
    data = require(fileName);
    jsonfilestring = JSON.stringify(data);
    newFileName = fileName.replace("testFixtures", "TestJSON");
    newFileName = newFileName.replace(".js", ".json");
    fs.writeFileSync(newFileName, jsonfilestring);
  }

  allCodeTableFiles = glob.sync("../public/javascripts/spec/testFixtures/*CodeTableTestJSON.js");

  allCodeTables = [];

  allCodeTableTypesAndKinds = [];

  currentTypeAndKind = {};

  for (_j = 0, _len1 = allCodeTableFiles.length; _j < _len1; _j++) {
    fileName = allCodeTableFiles[_j];
    codeTableFile = require(fileName);
    _ref = codeTableFile['dataDictValues'];
    for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
      codeTable = _ref[_k];
      type = codeTable['type'];
      kind = codeTable['kind'];
      currentTypeAndKind['type'] = type;
      currentTypeAndKind['kind'] = kind;
      if (_.findWhere(allCodeTableTypesAndKinds, currentTypeAndKind) === void 0) {
        allCodeTableTypesAndKinds.push.apply(allCodeTableTypesAndKinds, [
          {
            type: codeTable['type'],
            kind: codeTable['kind']
          }
        ]);
        allCodeTables.push(codeTable);
      } else {
        console.log("Error: code table for type: " + type + "and kind: " + kind + " already stored");
        process.exit(-1);
      }
    }
  }

  jsonallcodetablesstring = JSON.stringify(allCodeTables);

  allCodeTablesFileName = "../public/javascripts/spec/testFixtures/CodeTableJSON.js";

  jsonallcodetablesstring = "exports.codes = " + jsonallcodetablesstring;

  fs.writeFileSync(allCodeTablesFileName, jsonallcodetablesstring);

}).call(this);
