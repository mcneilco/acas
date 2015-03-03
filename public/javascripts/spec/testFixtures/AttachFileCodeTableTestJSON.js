(function() {
  (function(exports) {
    return exports.codetableValues = [
      {
        type: "analytical method",
        kind: "file type",
        codes: [
          {
            code: "hplc",
            name: "HPLC",
            ignored: false
          }, {
            code: "nmr",
            name: "NMR",
            ignored: false
          }, {
            code: "gpc",
            name: "GPC",
            ignored: false
          }, {
            code: "ms",
            name: "MS",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.attachFileCodeTableTestJSON = window.attachFileCodeTableTestJSON || {} : exports));

}).call(this);
