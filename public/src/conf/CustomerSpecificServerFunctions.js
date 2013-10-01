/*
  DNS-specific implementations of required server functions

  All functions are required with unchanged signatures
*/


(function() {
  exports.logUsage = function(action, data, username) {
    var config, error, form, req, request,
      _this = this;

    config = require('./configurationNode.js');
    request = require('request');
    req = request.post(config.serverConfigurationParams.configuration.loggingService, function(error, response) {
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

  exports.prepareConfigFile = function(callback) {
    var asyncblock, exec, fs;

    fs = require('fs');
    asyncblock = require('asyncblock');
    exec = require('child_process').exec;
    return asyncblock(function(flow) {
      var config, configLines, configTemplate, enableSpecRunner, hostName, jdbcParts, line, lineParts, name, setting, settings, _i, _len;

      global.deployMode = process.env.DNSDeployMode;
      exec("java -jar ../lib/dns-config-client.jar -m " + global.deployMode + " -c acas -d 2>/dev/null", flow.add());
      config = flow.wait();
      if (config.indexOf("It=works") > -1) {
        console.log("Can't contact DNS config service. If you are doing local dev, check your VPN.");
        process.exit(1);
      }
      config = config.replace(/\\/g, "");
      configLines = config.split("\n");
      settings = {};
      for (_i = 0, _len = configLines.length; _i < _len; _i++) {
        line = configLines[_i];
        lineParts = line.split("=");
        if (lineParts[1] !== void 0) {
          settings[lineParts[0]] = lineParts[1];
        }
      }
      configTemplate = fs.readFileSync("./public/src/conf/configurationNode_Template.js").toString();
      for (name in settings) {
        setting = settings[name];
        configTemplate = configTemplate.replace(RegExp(name, "g"), setting);
      }
      jdbcParts = settings["acas.jdbc.url"].split(":");
      configTemplate = configTemplate.replace(/acas.api.db.location/g, jdbcParts[0] + ":" + jdbcParts[1] + ":" + jdbcParts[2] + ":@");
      configTemplate = configTemplate.replace(/acas.api.db.host/g, jdbcParts[3].replace("@", ""));
      configTemplate = configTemplate.replace(/acas.api.db.port/g, jdbcParts[4]);
      configTemplate = configTemplate.replace(/acas.api.db.name/g, jdbcParts[5]);
      enableSpecRunner = true;
      switch (global.deployMode) {
        case "Dev":
          hostName = "acas-d";
          break;
        case "Test":
          hostName = "acas-t";
          break;
        case "Stage":
          hostName = "acas-s";
          break;
        case "Prod":
          hostName = "acas";
          enableSpecRunner = false;
      }
      configTemplate = configTemplate.replace(RegExp("acas.api.hostname", "g"), hostName);
      configTemplate = configTemplate.replace(/acas.api.enableSpecRunner/g, enableSpecRunner);
      configTemplate = configTemplate.replace(/acas.env.logDir/g, process.env.DNSLogDirectory);
      fs.writeFileSync("./public/src/conf/configurationNode.js", configTemplate);
      return callback();
    });
  };

  exports.authCheck = function(user, pass, retFun) {
    var config, request,
      _this = this;

    config = require('./configurationNode.js');
    request = require('request');
    return request({
      method: 'POST',
      url: config.serverConfigurationParams.configuration.userAuthenticationServiceURL,
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

    config = require('./configurationNode.js');
    request = require('request');
    return request({
      method: 'GET',
      url: config.serverConfigurationParams.configuration.userInformationServiceURL + username,
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
              exports.logUsage("User logged in succesfully: ", "NA", username);
            } catch (_error) {
              error = _error;
              console.log("Exception trying to log:" + error);
            }
            return done(null, user);
          } else {
            try {
              exports.logUsage("User failed login: ", "NA", username);
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

}).call(this);
