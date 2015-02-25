(function() {
  (function(exports) {
    return exports.codes = [
      {
        code: "fluorescence",
        name: "Fluorescence",
        id: 1,
        displayOrder: 1,
        ignored: false
      }, {
        code: "biochemical",
        name: "Biochemical",
        id: 2,
        displayOrder: 2,
        ignored: false
      }, {
        code: "ko",
        name: "Well Knocked Out",
        id: 3,
        displayOrder: 3,
        ignored: true
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.codeTableServiceTestJSON = window.codeTableServiceTestJSON || {} : exports));

}).call(this);
