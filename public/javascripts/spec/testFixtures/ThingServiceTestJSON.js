(function() {
  (function(exports) {
    return exports.authorsList = [
      {
        code: "bob",
        codeName: null,
        displayOrder: null,
        id: 1,
        ignored: false,
        name: "Bob Roberts"
      }, {
        code: "john",
        codeName: null,
        displayOrder: null,
        id: 2,
        ignored: false,
        name: "John Smith"
      }, {
        code: "jane",
        codeName: null,
        displayOrder: null,
        id: 3,
        ignored: false,
        name: "Jane Doe"
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.thingServiceTestJSON = window.thingServiceTestJSON || {} : exports));

}).call(this);
