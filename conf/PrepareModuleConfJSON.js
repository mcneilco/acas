(function() {
  var allFiles, data, fileName, fs, glob, jsonfilestring, newFileName, _, _i, _len;

  fs = require('fs');

  glob = require('glob');

  _ = require("underscore");

  allFiles = glob.sync("../public/javascripts/conf/*.js");

  for (_i = 0, _len = allFiles.length; _i < _len; _i++) {
    fileName = allFiles[_i];
    data = require(fileName);
    jsonfilestring = JSON.stringify(data);
    newFileName = fileName.replace(".js", ".json");
    fs.writeFileSync(newFileName, jsonfilestring);
  }

}).call(this);
