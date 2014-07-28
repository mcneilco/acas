(function() {
  var allCodeTableFiles, allCodeTableKeys, allCodeTables, allCodeTablesFileName, allFiles, codeTable, codeTablesFile, data, fileName, fs, glob, jsonallcodetablesstring, jsonfilestring, newFileName, _i, _j, _k, _len, _len1, _len2, _ref, _ref1,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  glob = require('glob');

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

  allCodeTableKeys = [];

  for (_j = 0, _len1 = allCodeTableFiles.length; _j < _len1; _j++) {
    fileName = allCodeTableFiles[_j];
    codeTablesFile = require(fileName);
    _ref = codeTablesFile['dataDictValues'];
    for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
      codeTable = _ref[_k];
      if ((_ref1 = Object.keys(codeTable)[0], __indexOf.call(allCodeTableKeys, _ref1) >= 0)) {
        console.log("Error: code table for " + Object.keys(codeTable)[0] + " already stored");
        process.exit(-1);
      } else {
        allCodeTables.push(codeTable);
        Array.prototype.push.apply(allCodeTableKeys, Object.keys(codeTable));
      }
    }
  }

  jsonallcodetablesstring = JSON.stringify(allCodeTables);

  allCodeTablesFileName = "../public/javascripts/spec/testFixtures/CodeTableJSON.js";

  jsonallcodetablesstring = "exports.codes = " + jsonallcodetablesstring;

  fs.writeFileSync(allCodeTablesFileName, jsonallcodetablesstring);

}).call(this);
