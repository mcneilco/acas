(function() {
  (function(exports) {
    return exports.dataDictValues = [
      {
        type: "experiment",
        kind: "status",
        codes: [
          {
            code: "created",
            name: "Created",
            ignored: false
          }, {
            code: "started",
            name: "Started",
            ignored: false
          }, {
            code: "complete",
            name: "Complete",
            ignored: false
          }, {
            code: "finalized",
            name: "Finalized",
            ignored: false
          }, {
            code: "rejected",
            name: "Rejected",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.experimentCodeTableTestJSON = window.experimentCodeTableTestJSON || {} : exports));

}).call(this);
