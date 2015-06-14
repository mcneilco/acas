(function() {
  (function(exports) {
    return exports.savedCronEntry = {
      schedule: "0-59/10 * * * * *",
      scriptType: "R",
      scriptFile: "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
      functionName: "runRFunctionTest",
      scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv", "dryRun": "true", "user": "jmcneil" }',
      active: true,
      ignored: false,
      user: 'jmcneil',
      cronCode: "CRON123456789",
      lastStartTime: null,
      lastDuration: null,
      lastResultJSON: null,
      numberOfExcutions: null
    };
  })((typeof process === "undefined" || !process.versions ? window.cronScriptRunnerTestJSON = window.cronScriptRunnerTestJSON || {} : exports));

}).call(this);
