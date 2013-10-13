(function() {
  var csUtilities, prepareRooConfig;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  global.deployMode = "Dev";

  csUtilities.prepareConfigFile(function() {
    csUtilities.logUsage("Configuration file generated", "deployMode: " + deployMode, "");
    return prepareRooConfig();
  });

  prepareRooConfig = function() {
    var attr, config, configOut, fs, value, _ref;

    config = require('./public/src/conf/configurationNode.js');
    fs = require('fs');
    configOut = "";
    _ref = config.serverConfigurationParams.configuration;
    for (attr in _ref) {
      value = _ref[attr];
      configOut += attr + "=" + value + "\n";
    }
    return fs.writeFile("./public/src/conf/acas_roo.properties", configOut);
  };

}).call(this);
