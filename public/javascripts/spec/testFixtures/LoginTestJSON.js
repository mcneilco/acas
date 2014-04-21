(function() {
  (function(exports) {
    return exports.sampleLoginUser = {
      id: 4,
      username: "jam",
      email: "john@mcneilco.com",
      firstName: "John",
      lastName: "McNeil",
      roles: [
        {
          id: 3,
          roleEntry: {
            id: 2,
            roleDescription: "admin role",
            roleName: "admin",
            version: 0
          },
          version: 0
        }, {
          id: 4,
          roleEntry: {
            id: 1,
            roleDescription: "user role",
            roleName: "user",
            version: 0
          },
          version: 0
        }
      ]
    };
  })((typeof process === "undefined" || !process.versions ? window.loginTestJSON = window.loginTestJSON || {} : exports));

}).call(this);
