(function() {
  var _, allCodeTableFiles, allCodeTableTypesAndKinds, allCodeTables, allCodeTablesFileName, allFiles, codeTable, codeTableFile, currentTypeAndKind, data, fileName, fs, glob, i, j, jsonallcodetablesstring, jsonfilestring, k, kind, len, len1, len2, newFileName, ref, type;

  fs = require('fs');

  glob = require('glob');

  _ = require("underscore");

  allFiles = glob.sync("../public/javascripts/spec/testFixtures/*.js");

  for (i = 0, len = allFiles.length; i < len; i++) {
    fileName = allFiles[i];
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

  for (j = 0, len1 = allCodeTableFiles.length; j < len1; j++) {
    fileName = allCodeTableFiles[j];
    codeTableFile = require(fileName);
    ref = codeTableFile['codetableValues'];
    for (k = 0, len2 = ref.length; k < len2; k++) {
      codeTable = ref[k];
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
