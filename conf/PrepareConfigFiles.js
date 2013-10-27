(function() {
  var csUtilities, flat, fs, properties, sysEnv, underscoreDeepExtend, writeClientJSONFormat, writeJSONFormat, writePropertiesFormat, _;

  csUtilities = require("../public/src/conf/CustomerSpecificServerFunctions.js");

  properties = require("properties");

  _ = require("underscore");

  underscoreDeepExtend = require("underscoreDeepExtend");

  _.mixin({
    deepExtend: underscoreDeepExtend(_)
  });

  fs = require('fs');

  flat = require('flat');

  global.deployMode = "Dev";

  sysEnv = process.env;

  global.deployMode = "Dev";

  csUtilities.getConfServiceVars(sysEnv, function(confVars) {
    var configDir, options, substitutions;

    substitutions = {
      env: sysEnv,
      conf: confVars
    };
    options = {
      path: true,
      namespaces: true,
      sections: true,
      variables: true,
      include: true,
      vars: substitutions
    };
    configDir = "./";
    return properties.parse(configDir + "config.properties", options, function(error, conf) {
      if (error != null) {
        return console.log("Problem parsing config.properties: " + error);
      } else {
        return properties.parse(configDir + "config_advanced.properties", options, function(error, confAdv) {
          var allConf;

          if (typeof errors !== "undefined" && errors !== null) {
            return console.log("Problem parsing config_advanced.properties: " + error);
          } else {
            allConf = _.deepExtend(confAdv, conf);
            writeJSONFormat(allConf);
            writeClientJSONFormat(allConf);
            return writePropertiesFormat(allConf);
          }
        });
      }
    });
  });

  writeJSONFormat = function(conf) {
    return fs.writeFile("./compiled/conf.js", "exports.all=" + JSON.stringify(conf) + ";");
  };

  writeClientJSONFormat = function(conf) {
    return fs.writeFile("../public/src/conf/conf.js", "window.conf=" + JSON.stringify(conf.client) + ";");
  };

  writePropertiesFormat = function(conf) {
    var attr, configOut, flatConf, value;

    fs = require('fs');
    flatConf = flat.flatten(conf);
    configOut = "";
    for (attr in flatConf) {
      value = flatConf[attr];
      configOut += attr + "=" + value + "\n";
    }
    return fs.writeFile("./compiled/conf.properties", configOut);
  };

}).call(this);
