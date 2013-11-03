/*
  DNS-specific implementations of required server functions

  All functions are required with unchanged signatures
*/


(function() {
  var dnsFormatProjectResponse;

  exports.logUsage = function(action, data, username) {
    var config, error, form, req, request,
      _this = this;

    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    req = request.post(config.all.server.service.external.logging.url, function(error, response) {
      if (!error && response.statusCode === 200) {
        return console.log("logged: " + action + " with data: " + data + " and user: " + username);
      } else {
        console.log("got error trying log action: " + action + " with data: " + data);
        console.log(error);
        return console.log(response);
      }
    });
    if (username == null) {
      username = "NA";
    }
    if (data === "") {
      data = "NA";
    }
    try {
      form = req.form();
      form.append('application', 'acas');
      form.append('action', action);
      form.append('application_data', data);
      return form.append('user_login', username);
    } catch (_error) {
      error = _error;
      return console.log(error);
    }
  };

  exports.getConfServiceVars = function(sysEnv, callback) {
    var asyncblock, exec, os, properties;

    properties = require("properties");
    asyncblock = require('asyncblock');
    exec = require('child_process').exec;
    os = require('os');
    if (typeof sysEnv.DNSDeployMode === "undefined") {
      sysEnv.DNSDeployMode = "Dev";
    }
    if (typeof sysEnv.DNSLogDirectory === "undefined") {
      sysEnv.DNSLogDirectory = "/tmp";
    }
    return asyncblock(function(flow) {
      var config, options;

      global.deployMode = sysEnv.DNSDeployMode;
      exec("java -jar ../../lib/dns-config-client.jar -m " + deployMode + " -c acas -d 2>/dev/null", flow.add());
      config = flow.wait();
      if (config.indexOf("It=works") > -1) {
        console.log("Can't contact DNS config service. If you are doing local dev, check your VPN.");
        process.exit(1);
      }
      config = config.replace(/\\/g, "");
      options = {
        namespaces: true
      };
      return properties.parse(config, options, function(error, dnsconf) {
        var jdbcParts;

        if (error != null) {
          return console.log("Parsing DNS conf service output failed: " + error);
        } else {
          if (global.deployMode === "Prod") {
            dnsconf.enableSpecRunner = false;
          } else {
            dnsconf.enableSpecRunner = true;
          }
          switch (global.deployMode) {
            case "Dev":
              dnsconf.hostname = "acas-d.dart.corp";
              break;
            case "Test":
              dnsconf.hostname = "acas-t.dart.corp";
              break;
            case "Stage":
              dnsconf.hostname = "acas-s.dart.corp";
              break;
            case "Prod":
              dnsconf.hostname = "acas.dart.corp";
              dnsconf.enableSpecRunner = false;
          }
          jdbcParts = dnsconf.acas.jdbc.url.split(":");
          dnsconf.acas.api.db = {};
          dnsconf.acas.api.db.location = jdbcParts[0] + ":" + jdbcParts[1] + ":" + jdbcParts[2] + ":@";
          dnsconf.acas.api.db.host = jdbcParts[3].replace("@", "");
          dnsconf.acas.api.db.port = jdbcParts[4];
          dnsconf.acas.api.db.name = jdbcParts[5];
          return callback(dnsconf);
        }
      });
    });
  };

  exports.authCheck = function(user, pass, retFun) {
    var config, request,
      _this = this;

    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      method: 'POST',
      url: config.all.server.service.external.user.authentication.url,
      form: {
        username: user,
        password: pass
      },
      json: true
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

  exports.getUser = function(username, callback) {
    var config, request,
      _this = this;

    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      method: 'GET',
      url: config.all.server.service.external.user.information.url + username,
      json: true
    }, function(error, response, json) {
      if (!error && response.statusCode === 200) {
        return callback(null, {
          id: json.DNSPerson.id,
          username: json.DNSPerson.id,
          email: json.DNSPerson.email,
          firstName: json.DNSPerson.firstName,
          lastName: json.DNSPerson.lastName
        });
      } else {
        console.log('got ajax error trying get user information');
        console.log(error);
        console.log(json);
        console.log(response);
        return callback(null, null);
      }
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
    var config, request,
      _this = this;

    config = require('../../../conf/compiled/conf.js');
    request = require('request');
    return request({
      method: 'GET',
      url: config.all.server.service.external.project.url,
      json: true
    }, function(error, response, json) {
      if (!error && response.statusCode === 200) {
        console.log(JSON.stringify(json));
        console.log(JSON.stringify(dnsFormatProjectResponse(json)));
        return resp.json(dnsFormatProjectResponse(json));
      } else {
        console.log('got ajax error trying get project list');
        console.log(error);
        console.log(json);
        return console.log(response);
      }
    });
  };

  dnsFormatProjectResponse = function(json) {
    var projects, _;

    _ = require('underscore');
    projects = [];
    _.each(json, function(proj) {
      var p;

      p = proj.DNSCode;
      return projects.push({
        code: p.code,
        name: p.name,
        ignored: !p.active
      });
    });
    return projects;
  };

}).call(this);
