(function() {
  (function(exports) {
    exports.nextLabelSequenceRequest = {
      labelTypeAndKind: "id_codeName",
      thingTypeAndKind: "document_experiment",
      numberOfLabels: 1
    };
    return exports.nextLabelSequenceResponse = {
      digits: 8,
      groupDigits: false,
      id: 2,
      ignored: false,
      labelPrefix: "EXPT",
      labelSeparator: "-",
      labelTypeAndKind: "id_codeName",
      latestNumber: 1,
      modifiedDate: 1430326747601,
      thingTypeAndKind: "document_experiment",
      version: 635
    };
  })((typeof process === "undefined" || !process.versions ? window.labelServiceTestJSON = window.labelServiceTestJSON || {} : exports));

}).call(this);
