
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
    var request,
      _this = this;
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: 'http://host3.labsynch.com:8080/acas/resources/j_spring_security_check',
      form: {
        j_username: user,
        j_password: pass
      },
      json: false
    }, function(error, response, json) {
      if (!error && response.statusCode === 200) {
        return retFun(JSON.stringify(json));
      } else if (!error && response.statusCode === 302) {
        return retFun(JSON.stringify(response.headers.location));
      } else {
        console.log('got ajax error trying authenticate a user');
        console.log(error);
        console.log(json);
        return console.log(response);
      }
    });
  };

  exports.resetAuth = function(email, retFun) {
    var request,
      _this = this;
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: 'http://host3.labsynch.com:8080/acas/forgotpassword/update',
      form: {
        emailAddress: email
      },
      json: false
    }, function(error, response, json) {
      if (!error && response.statusCode === 200) {
        return retFun(JSON.stringify(json));
      } else {
        console.log('got ajax error trying authenticate a user');
        console.log(error);
        console.log(json);
        return console.log(response);
      }
    });
  };

  exports.changeAuth = function(user, passOld, passNew, passNewAgain, retFun) {
    var request,
      _this = this;
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: 'http://host3.labsynch.com:8080/acas/changepassword/update',
      form: {
        username: user,
        oldPassword: passOld,
        newPassword: passNew,
        newPasswordAgain: passNewAgain
      },
      json: false
    }, function(error, response, json) {
      console.log(response.statusCode);
      if (!error && response.statusCode === 200) {
        return retFun(JSON.stringify(json));
      } else {
        console.log('got ajax error trying authenticate a user');
        console.log(error);
        console.log(json);
        return console.log(response);
      }
    });
  };

  exports.getUser = function(username, callback) {
    var config, request,
      _this = this;
    config = require('../../../conf/compiled/conf.js');
    if (config.all.client.require.login) {
      request = require('request');
      return request({
        headers: {
          accept: 'application/json'
        },
        method: 'POST',
        url: 'http://host3.labsynch.com:8080/acas/authors/findbyname',
        json: '{"name":"guy@mcneilco.com"}'
      }, function(error, response, json) {
        if (!error && response.statusCode === 200) {
          return callback(null, {
            id: "bob",
            username: "bob",
            email: "bob@nowwhere.com",
            firstName: "Bob2",
            lastName: "Roberts1",
            role: "admin"
          });
        } else {
          return callback("user not found", null);
        }
      });
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
    return exports.findByUsername(username, function(err, user) {
      return exports.authCheck(username, password, function(results) {
        var error;
        if (results.indexOf("login_error") >= 0) {
          try {
            exports.logUsage("User failed login: ", "", username);
          } catch (_error) {
            error = _error;
            console.log("Exception trying to log:" + error);
          }
          return done(null, false, {
            message: "Invalid credentials"
          });
        } else {
          try {
            exports.logUsage("User logged in succesfully: ", "", username);
          } catch (_error) {
            error = _error;
            console.log("Exception trying to log:" + error);
          }
          if (user === null) {
            return exports.getUser(username, done);
          } else {
            return done(null, user);
          }
        }
      });
    });
  };

  exports.resetStrategy = function(username, done) {
    return exports.findByUsername(username, function(err, user) {
      return exports.resetAuth(username, function(results) {
        var error;
        if (results.indexOf("Your new password is sent to your email address") >= 0) {
          try {
            exports.logUsage("Can't find email or user name: ", "", username);
          } catch (_error) {
            error = _error;
            console.log("Exception trying to log:" + error);
          }
          return done(null, false, {
            message: "Invalid username or email"
          });
        } else {
          try {
            exports.logUsage("User password reset succesfully: ", "", username);
          } catch (_error) {
            error = _error;
            console.log("Exception trying to log:" + error);
          }
          return done(null, user);
        }
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
