(function() {
  var allModuleConfJSFiles, allModulesTypesAndKinds, async, compiledModuleConfsFileName, compiledTypesAndKinds, confJSONFilesToCompile, config, data, fileName, fs, glob, jsonfilestring, moduleData, newFileName, request, selectedConfJSONFiles, typeKinds, typeOrKind, value, values, _, _i, _j, _k, _l, _len, _len1, _len2, _len3;

  fs = require('fs');

  glob = require('glob');

  _ = require("underscore");

  allModuleConfJSFiles = glob.sync("../public/javascripts/conf/*.js");

  for (_i = 0, _len = allModuleConfJSFiles.length; _i < _len; _i++) {
    fileName = allModuleConfJSFiles[_i];
    data = require(fileName);
    jsonfilestring = JSON.stringify(data);
    newFileName = fileName.replace("conf", "conf/confJSON/moduleJSON");
    newFileName = newFileName.replace(".js", ".json");
    fs.writeFileSync(newFileName, jsonfilestring);
  }

  typeKinds = ["codetables", "containertypes", "containerkinds", "ddicttypes", "ddictkinds", "experimenttypes", "experimentkinds", "interactiontypes", "interactionkinds", "labeltypes", "labelkinds", "labelsequences", "operatortypes", "operatorkinds", "protocoltypes", "protocolkinds", "statetypes", "statekinds", "thingtypes", "thingkinds", "unittypes", "unitkinds", "valuetypes", "valuekinds"];

  selectedConfJSONFiles = process.argv[2];

  if (selectedConfJSONFiles != null) {
    confJSONFilesToCompile = glob.sync(process.argv[2]);
    if (confJSONFilesToCompile.length === 0) {
      console.log("This file does not exist");
      console.log("Check the file path. The file should be in /public/javascripts/conf/confJSON/moduleJSON");
      process.exit(-1);
    }
  } else {
    confJSONFilesToCompile = glob.sync("../public/javascripts/conf/confJSON/moduleJSON/*.json");
  }

  allModulesTypesAndKinds = {};

  for (_j = 0, _len1 = confJSONFilesToCompile.length; _j < _len1; _j++) {
    fileName = confJSONFilesToCompile[_j];
    moduleData = require(fileName);
    for (_k = 0, _len2 = typeKinds.length; _k < _len2; _k++) {
      typeOrKind = typeKinds[_k];
      if (moduleData.typeKindList[typeOrKind] != null) {
        values = moduleData.typeKindList[typeOrKind];
        if (allModulesTypesAndKinds[typeOrKind] != null) {
          compiledTypesAndKinds = allModulesTypesAndKinds[typeOrKind];
          for (_l = 0, _len3 = values.length; _l < _len3; _l++) {
            value = values[_l];
            if (_.findWhere(compiledTypesAndKinds, value) === void 0) {
              compiledTypesAndKinds.push(value);
            }
          }
          delete allModulesTypesAndKinds[typeOrKind];
          allModulesTypesAndKinds[typeOrKind] = compiledTypesAndKinds;
        } else {
          allModulesTypesAndKinds[typeOrKind] = values;
        }
      }
    }
  }

  jsonfilestring = JSON.stringify(allModulesTypesAndKinds);

  compiledModuleConfsFileName = "../public/javascripts/conf/confJSON/CompiledModuleConfJSONs.json";

  fs.writeFileSync(compiledModuleConfsFileName, jsonfilestring);

  async = require('async');

  request = require('request');

  data = require('../public/javascripts/conf/confJSON/CompiledModuleConfJSONs.json');

  config = require('../conf/compiled/conf.js');

  async.forEachSeries(typeKinds, (function(typeOrKind, callback) {
    var baseurl;
    baseurl = config.all.client.service.persistence.fullpath + "setup/" + typeOrKind;
    if (data[typeOrKind] != null) {
      console.log("trying to save " + typeOrKind);
      return request({
        method: 'POST',
        url: baseurl,
        body: JSON.stringify(data[typeOrKind]),
        json: true,
        headers: {
          "Content-Type": 'application/json'
        }
      }, (function(_this) {
        return function(error, response, json) {
          if (!error && response.statusCode === 201) {
            console.log("successfully added " + typeOrKind);
          } else {
            console.log('got ajax error trying to setup type/kind ' + typeOrKind);
            console.log(error);
            console.log(json);
          }
          return callback();
        };
      })(this));
    } else {
      console.log("no " + typeOrKind + " to save");
      return callback();
    }
  }), function(err) {
    return console.log("done adding types and kinds");
  });

}).call(this);
