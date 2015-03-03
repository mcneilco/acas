(function() {
  var allModuleConfJSFiles, allModuleConfJSONFiles, baseurl, config, data, fileName, fs, glob, jsonfilestring, newFileName, request, typeKinds, typeOrKind, value, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref;

  fs = require('fs');

  glob = require('glob');

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

  for (_j = 0, _len1 = allModuleConfJSONFiles.length; _j < _len1; _j++) {
    fileName = allModuleConfJSONFiles[_j];
    data = require(fileName);
    for (_k = 0, _len2 = typeKinds.length; _k < _len2; _k++) {
      typeOrKind = typeKinds[_k];
      if (data.typeKindList[typeOrKind] != null) {
        _ref = data.typeKindList[typeOrKind];
        for (_l = 0, _len3 = _ref.length; _l < _len3; _l++) {
          value = _ref[_l];
          config = require('../conf/compiled/conf.js');
          baseurl = config.all.client.service.persistence.fullpath + "setup/" + typeOrKind;
          request = require('request');
          if ((value.kindName != null) && (value.typeName != null)) {
            console.log("trying to save typeName: " + value.typeName + " and kindName: " + value.kindName);
          } else if (value.typeName != null) {
            console.log("trying to save typeName: " + value.typeName);
          } else {
            console.log("trying to save " + typeOrKind);
          }
          request({
            method: 'POST',
            url: baseurl,
            body: JSON.stringify([value]),
            json: true,
            headers: {
              "Content-Type": 'application/json'
            }
          }, (function(_this) {
            return function(error, response, json) {
              if (!(!error && response.statusCode === 201)) {
                console.log('got ajax error trying to setup type/kind');
                console.log(error);
                return console.log(json);
              }
            };
          })(this));
        }
      }
    }
  }

}).call(this);
