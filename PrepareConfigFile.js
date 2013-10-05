(function() {
  var csUtilities;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  global.deployMode = "Dev";

  csUtilities.prepareConfigFile(function() {
    return csUtilities.logUsage("Configuration file generated", "deployMode: " + deployMode, "");
  });

}).call(this);
