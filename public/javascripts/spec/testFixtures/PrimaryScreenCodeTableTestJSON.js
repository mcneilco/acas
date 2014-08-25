(function() {
  (function(exports) {
    return exports.dataDictValues = [
      {
        "instrumentReaderCodes": [
          {
            code: "flipr",
            name: "FLIPR",
            ignored: false
          }
        ]
      }, {
        "signalDirectionCodes": [
          {
            code: "increasing signal (highest = 100%)",
            name: "Increasing Signal (highest = 100%)",
            ignored: false
          }
        ]
      }, {
        "aggregateBy1Codes": [
          {
            code: "compound batch concentration",
            name: "Compound Batch Concentration",
            ignored: false
          }
        ]
      }, {
        "aggregateBy2Codes": [
          {
            code: "median",
            name: "Median",
            ignored: false
          }, {
            code: "mean",
            name: "Mean",
            ignored: false
          }
        ]
      }, {
        "transformationCodes": [
          {
            code: "% efficacy",
            name: "% Efficacy",
            ignored: false
          }, {
            code: "sd",
            name: "SD",
            ignored: false
          }, {
            code: "null",
            name: "Not Set",
            ignored: false
          }
        ]
      }, {
        "normalizationCodes": [
          {
            code: "plate order only",
            name: "Plate Order Only",
            ignored: false
          }, {
            code: "plate order and row",
            name: "Plate Order And Row",
            ignored: false
          }, {
            code: "plate order and tip",
            name: "Plate Order And Tip",
            ignored: false
          }, {
            code: "none",
            name: "None",
            ignored: false
          }
        ]
      }, {
        "readNameCodes": [
          {
            code: "luminescence",
            name: "Luminescence",
            ignored: false
          }, {
            code: "none",
            name: "None",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.primaryScreenCodeTableTestJSON = window.primaryScreenCodeTableTestJSON || {} : exports));

}).call(this);
