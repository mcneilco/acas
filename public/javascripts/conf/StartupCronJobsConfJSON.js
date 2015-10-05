(function() {
  exports.jobsToStart = [
    {
      schedule: "0-59/2 * * * * *",
      scriptType: "R",
      scriptFile: "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
      functionName: "runRFunctionTest",
      scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv", "dryRun": "true", "user": "jmcneil" }',
      active: true
    }, {
      schedule: "0-59/2 * * * * *",
      scriptType: "R",
      scriptFile: "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
      functionName: "runRFunctionTest",
      scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/SampleTransfers_good.csv", "dryRun": "true", "user": "jmcneil" }',
      active: false
    }, {
      schedule: "0-59/3 * * * * *",
      scriptType: "R",
      scriptFile: "public/src/modules/ServerAPI/src/server/RunRFunctionTestStub.R",
      functionName: "runRFunctionTest",
      scriptJSONData: '{"fileToParse": "public/src/modules/BulkLoadSampleTransfers/spec/specFiles/KilroyTransfers_good.csv", "dryRun": "true", "user": "kilroy" }',
      active: true
    }
  ];

}).call(this);
