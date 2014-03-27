
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
    var config;
    config = require('../../../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      if (username === "bob") {
        return callback(null, {
          id: "bob",
          username: "bob",
          email: "bob@nowwhere.com",
          firstName: "Bob",
          lastName: "Roberts"
        });
      } else {
        return callback("user not found", null);
      }
    } else {
      return callback(null, {
        id: 0,
        username: username,
        email: username + "@nowhere.com",
        firstName: "",
        lastName: username
      });
    }
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
    var projects;
    projects = exports.projects = [
      {
        code: "project1",
        name: "Project 1",
        ignored: false
      }, {
        code: "project2",
        name: "Project 2",
        ignored: false
      }
    ];
    return resp.end(JSON.stringify(projects));
  };

}).call(this);
