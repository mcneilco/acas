(function() {
  (function(exports) {
    exports.runRFunctionRequest = {
      rScript: "public/src/modules/ServerAPI/spec/serviceTests/runRApacheFunction.R",
      rFunction: "testFunction",
      request: "{\"smartMode\":true,\"inactiveThresholdMode\":true,\"inactiveThreshold\":20,\"inverseAgonistMode\":false,\"max\":{\"limitType\":\"none\"},\"min\":{\"limitType\":\"none\"},\"slope\":{\"limitType\":\"none\"}}"
    };
    return exports.runRFunctionResponse = {
      hasError: false,
      results: {
        dryRun: true,
        htmlSummary: true
      },
      hasWarning: true
    };
  })((typeof process === "undefined" || !process.versions ? window.runRFunctionServiceTestJSON = window.runRFunctionServiceTestJSON || {} : exports));

}).call(this);
