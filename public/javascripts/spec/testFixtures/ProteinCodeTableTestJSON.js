(function() {
  (function(exports) {
    return exports.codetableValues = [
      {
        type: "protein",
        kind: "type",
        codes: [
          {
            code: "mab",
            name: "mAb",
            ignored: false
          }, {
            code: "fab",
            name: "fAb",
            ignored: false
          }, {
            code: "centyrin",
            name: "Centyrin",
            ignored: false
          }, {
            code: "other",
            name: "Other",
            ignored: false
          }
        ]
      }, {
        type: "protein",
        kind: "target",
        codes: [
          {
            code: "egfr",
            name: "EGFR",
            ignored: false
          }, {
            code: "psma",
            name: "PSMA",
            ignored: false
          }, {
            code: "transferrin",
            name: "Transferrin",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.proteinCodeTableTestJSON = window.proteinCodeTableTestJSON || {} : exports));

}).call(this);
