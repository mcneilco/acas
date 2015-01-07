(function() {
  (function(exports) {
    return exports.dataDictValues = [
      {
        type: "rna",
        kind: "target transcript",
        codes: [
          {
            code: "egfr",
            name: "EGFR",
            ignored: false
          }, {
            code: "kras",
            name: "KRAS",
            ignored: false
          }, {
            code: "pan-ar",
            name: "Pan-AR",
            ignored: false
          }, {
            code: "ar-sv",
            name: "AR-SV",
            ignored: false
          }
        ]
      }, {
        type: "rna",
        kind: "modification",
        codes: [
          {
            code: "u",
            name: "u",
            ignored: false
          }, {
            code: "ffm",
            name: "ffm",
            ignored: false
          }, {
            code: "ffm1sm",
            name: "ffm1sm",
            ignored: false
          }, {
            code: "ffm4sm",
            name: "ffm4sm",
            ignored: false
          }, {
            code: "mfm1sm",
            name: "mfm1sm",
            ignored: false
          }, {
            code: "mfm4sm",
            name: "mfm4sm",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.rnaCodeTableTestJSON = window.rnaCodeTableTestJSON || {} : exports));

}).call(this);
