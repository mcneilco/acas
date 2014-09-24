(function() {
  (function(exports) {
    return exports.dataDictValues = [
      {
        type: "experimentMetadata",
        kind: "algorithm well flags",
        codes: [
          {
            code: "outlier",
            name: "Outlier",
            ignored: false
          }, {
            code: "high",
            name: "Value too high",
            ignored: true
          }, {
            code: "low",
            name: "Value too low",
            ignored: true
          }, {
            code: "crashout",
            name: "Compound crashed out",
            ignored: false
          }
        ],
        "user well flags": [
          {
            code: "outlier",
            name: "Outlier",
            ignored: false
          }, {
            code: "high",
            name: "Value too high",
            ignored: true
          }, {
            code: "low",
            name: "Value to low",
            ignored: true
          }, {
            code: "crashout",
            name: "Compound crashed out",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.dataDictServiceTestJSON = window.dataDictServiceTestJSON || {} : exports));

}).call(this);
