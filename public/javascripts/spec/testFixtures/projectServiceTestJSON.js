(function() {
  (function(exports) {
    return exports.projects = [
      {
        code: "project1",
        name: "Project 1",
        ignored: false
      }, {
        code: "project2",
        name: "Project 2",
        ignored: false
      }, {
        code: "proj3ct3",
        name: "proj3ct three",
        ignored: true
      }, {
        code: "project3",
        name: "Project 3",
        ignored: false
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.curveCuratorTestJSON = window.curveCuratorTestJSON || {} : exports));

}).call(this);
