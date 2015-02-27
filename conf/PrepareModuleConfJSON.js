(function() {
  var allModuleConfJSFiles, allModuleConfJSONFiles, data, fileName, fs, glob, jsonfilestring, newFileName, typeKinds, _, _i, _len;

  fs = require('fs');

  glob = require('glob');

  _ = require("underscore");

  console.log("here");

  allModuleConfJSFiles = glob.sync("../public/javascripts/conf/*.js");

  for (_i = 0, _len = allModuleConfJSFiles.length; _i < _len; _i++) {
    fileName = allModuleConfJSFiles[_i];
    data = require(fileName);
    jsonfilestring = JSON.stringify(data);
    newFileName = fileName.replace("conf", "conf/confJSON");
    newFileName = newFileName.replace(".js", ".json");
    fs.writeFileSync(newFileName, jsonfilestring);
  }

  typeKinds = ["codetables", "containerkinds", "containertypes", "ddictkinds", "ddicttypes", "experimentkinds", "experimenttypes", "interactionkinds", "interactiontypes", "labelkinds", "labelsequences", "labeltypes", "operatorkinds", "operatortypes", "protocolkinds", "protocoltypes", "statekinds", "statetypes", "thingkinds", "thingtypes", "unitkinds", "unittypes", "valuekinds", "valuetypes"];

  allModuleConfJSONFiles = glob.sync("../public/javascripts/conf/confJSON/*.json");

}).call(this);
