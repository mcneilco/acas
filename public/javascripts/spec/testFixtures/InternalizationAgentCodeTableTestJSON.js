(function() {
  (function(exports) {
    return exports.codetableValues = [
      {
        type: "internalization agent",
        kind: "conjugation type",
        codes: [
          {
            code: "conjugated",
            name: "Conjugated",
            ignored: false
          }, {
            code: "unconjugated",
            name: "Unconjugated",
            ignored: false
          }
        ]
      }, {
        type: "internalization agent",
        kind: "conjugation site",
        codes: [
          {
            code: "cys",
            name: "Cys",
            ignored: false
          }, {
            code: "lys",
            name: "Lys",
            ignored: false
          }, {
            code: "thiobridge",
            name: "ThioBridge",
            ignored: false
          }
        ]
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.internalizationAgentCodeTableTestJSON = window.internalizationAgentCodeTableTestJSON || {} : exports));

}).call(this);
