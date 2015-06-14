(function() {
  (function(exports) {
    return exports.unsavedCronEntry = [
      {
        cronCode: "CRON123456789",
        schedule: "0-59/10 * * * * *",
        scriptType: "R",
        scriptPath: "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
        scriptJSONData: '{fileToParse: "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv", dryRun: true, }',
        user: 'jmcneil',
        lastStarted: null,
        duration: null,
        lastResultJSON: null,
        active: true,
        ignored: false
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.cronScriptRunnerTestJSON = window.cronScriptRunnerTestJSON || {} : exports));

}).call(this);
