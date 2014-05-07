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
    var config, request,
      _this = this;
    config = require('../../../conf/compiled/conf.js');
    console.log(config.all.client.require);
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: config.all.client.require.loginLink,
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
    var config, request,
      _this = this;
    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: config.all.client.require.resetLink,
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
    var config, request,
      _this = this;
    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      headers: {
        accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      },
      method: 'POST',
      url: config.all.client.require.changeLink,
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
    console.log("getting user");
    config = require('../../../conf/compiled/conf.js');
    if (config.all.client.require.login && !global.specRunnerTestmode) {
      console.log("getting user from server");
      request = require('request');
      return request({
        headers: {
          accept: 'application/json'
        },
        method: 'POST',
        url: config.all.client.require.getUserLink,
        json: {
          name: username
        }
      }, function(error, response, json) {
        if (!error && response.statusCode === 200 && json.id) {
          return callback(null, {
            id: json.id,
            username: json.userName,
            email: json.emailAddress,
            firstName: json.firstName,
            lastName: json.lastName,
            roles: json.authorRoles
          });
        } else {
          return callback("user not found", null);
        }
      });
    } else {
      if (username !== "starksofwesteros") {
        return callback(null, {
          id: 0,
          username: username,
          email: username + "@nowhere.com",
          firstName: username,
          lastName: username
        });
      } else {
        return callback("user not found", null);
      }
    }
  };

  exports.isUserAdmin = function(user) {
    var adminRoles, isAdmin, _;
    _ = require('underscore');
    adminRoles = _.filter(user.roles, function(role) {
      return role.roleEntry.roleName === 'admin';
    });
    return isAdmin = adminRoles.length > 0 ? true : false;
  };

  exports.findByUsername = function(username, fn) {
    return exports.getUser(username, fn);
  };

  exports.loginStrategy = function(username, password, done) {
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
        return exports.getUser(username, done);
      }
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
