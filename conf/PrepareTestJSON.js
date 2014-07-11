(function() {
  var allFiles, data, fileName, fs, glob, jsonfilestring, newFileName, _i, _len;

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

}).call(this);
