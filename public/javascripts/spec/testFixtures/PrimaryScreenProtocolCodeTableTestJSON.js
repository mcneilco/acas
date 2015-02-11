(function() {
  (function(exports) {
    return exports.codetableValues = [
      {
        type: "protocol metadata",
        kind: "assay stage",
        codes: [
          {
            code: "assay development",
            name: "Assay Development",
            ignored: false
          }
        ]
      }, {
        type: "protocol metadata",
        kind: "assay activity",
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
        type: "protocol metadata",
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
        type: "protocol metadata",
        kind: "target origin",
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
        type: "protocol metadata",
        kind: "assay type",
        codes: [
          {
            code: "cellular assay",
            name: "Cellular Assay",
            ignored: false
          }
        ]
      }, {
        type: "protocol metadata",
        kind: "assay technology",
        codes: [
          {
            code: "wizard triple luminescence",
            name: "Wizard Triple Luminescence",
            ignored: false
          }
        ]
      }, {
        type: "protocol metadata",
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
