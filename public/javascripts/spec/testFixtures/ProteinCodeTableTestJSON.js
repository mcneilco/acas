(function() {
  (function(exports) {
    return exports.dataDictValues = [
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
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.proteinCodeTableTestJSON = window.proteinCodeTableTestJSON || {} : exports));

}).call(this);
