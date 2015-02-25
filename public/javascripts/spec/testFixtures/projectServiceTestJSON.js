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
      }, {
        code: "proj3ct4",
        name: "proj3ct four",
        ignored: true
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.projectServiceTestJSON = window.projectServiceTestJSON || {} : exports));

}).call(this);
