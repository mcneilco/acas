(function() {
  (function(exports) {
    return exports.codetableValues = [
      {
        type: "assay",
        kind: "activity",
        codes: [
          {
            code: "luminescence",
            name: "Luminescence",
            ignored: false
          }, {
            code: "fluorescence",
            name: "Fluorescence",
            ignored: false
          }
        ]
      }, {
        type: "assay",
        kind: "molecular target",
        codes: [
          {
            code: "target x",
            name: "Target X",
            ignored: false
          }, {
            code: "target y",
            name: "Target Y",
            ignored: false
          }
        ]
      }, {
        type: "target",
        kind: "origin",
        codes: [
          {
            code: "human",
            name: "Human",
            ignored: false
          }, {
            code: "chimpanzee",
            name: "Chimpanzee",
            ignored: false
          }
        ]
      }, {
        type: "assay",
        kind: "type",
        codes: [
          {
            code: "cellular assay",
            name: "Cellular Assay",
            ignored: false
          }
        ]
      }, {
        type: "assay",
        kind: "technology",
        codes: [
          {
            code: "wizard triple luminescence",
            name: "Wizard Triple Luminescence",
            ignored: false
          }
        ]
      }, {
        type: "reagent",
        kind: "cell line",
        codes: [
          {
            code: "cell line x",
            name: "Cell Line X",
            ignored: false
          }, {
            code: "cell line y",
            name: "Cell Line Y",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.primaryScreenProtocolCodeTableTestJSON = window.primaryScreenProtocolCodeTableTestJSON || {} : exports));

}).call(this);
