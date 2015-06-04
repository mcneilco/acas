(function() {
  (function(exports) {
    exports.nextLabelSequenceRequest = {
      labelTypeAndKind: "id_codeName",
      thingTypeAndKind: "document_experiment",
      numberOfLabels: 1
    };
    return exports.nextLabelSequenceResponse = [
      {
        autoLabel: "EXPT-00000001"
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.labelServiceTestJSON = window.labelServiceTestJSON || {} : exports));

}).call(this);
