/*
  Master ACAS -specific implementations of required server functions

  All functions are required with unchanged signatures
*/


(function() {
  exports.logUsage = function(action, data, username) {
    return console.log("would have logged: " + action + " with data: " + data + " and user: " + username);
  };

  exports.getConfServiceVars = function(sysEnv, callback) {
    var conf;
    conf = {};
    return callback(conf);
  };

  exports.authCheck = function(user, pass, retFun) {
    return retFun("Success");
  };

  exports.getUser = function(username, callback) {
    return callback(null, {
      id: "bob",
      username: "bob",
      email: "bob@nowwhere.com",
      firstName: "Bob",
      lastName: "Bob"
    });
  };

  exports.findByUsername = function(username, fn) {
    return exports.getUser(username, fn);
  };

  exports.loginStrategy = function(username, password, done) {
    return process.nextTick(function() {
      return exports.findByUsername(username, function(err, user) {
        return exports.authCheck(username, password, function(results) {
          var error;
          if (results.indexOf("Success") >= 0) {
            try {
              exports.logUsage("User logged in succesfully: ", "", username);
            } catch (_error) {
              error = _error;
              console.log("Exception trying to log:" + error);
            }
            return done(null, user);
          } else {
            try {
              exports.logUsage("User failed login: ", "", username);
            } catch (_error) {
              error = _error;
              console.log("Exception trying to log:" + error);
            }
            return done(null, false, {
              message: "Invalid credentials"
            });
          }
        });
      });
    });
  };

  exports.getProjects = function(resp) {
    var projectServiceTestJSON;
    projectServiceTestJSON = require('../public/javascripts/spec/testFixtures/projectServiceTestJSON.js');
    return resp.end(JSON.stringify(projectServiceTestJSON.projects));
  };

}).call(this);
