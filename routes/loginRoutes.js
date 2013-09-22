/* To install this module add
  to app.coffee
# login routes
passport.serializeUser (user, done) ->
	done null, user.username
passport.deserializeUser (username, done) ->
	loginRoutes.findByUsername username, (err, user) ->
		done err, user
passport.use new LocalStrategy loginRoutes.loginStrategy

app.get '/login', loginRoutes.loginPage
app.post '/login',
	passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }),
	loginRoutes.loginPost
app.get '/logout', loginRoutes.logout
app.post '/api/userAuthentication', loginRoutes.authenticationService
app.get '/api/users/:username', loginRoutes.getUsers
*/


(function() {
  var dnsAuthCheck, dnsGetUser, users;

  users = [
    {
      id: 1,
      username: "bob",
      password: "secret",
      email: "bob@example.com",
      firstName: "Bob",
      lastName: "Roberts"
    }, {
      id: 2,
      username: "jmcneil",
      password: "birthday",
      email: "jmcneil@example.com",
      firstName: "John",
      lastName: "McNeil"
    }, {
      id: 3,
      username: "ldap-query",
      password: "Est@P7uRi5SyR+",
      email: "",
      firstName: "ldap-query",
      lastName: ""
    }
  ];

  exports.findById = function(id, fn) {
    var idx;

    idx = id - 1;
    if (users[idx]) {
      return fn(null, users[idx]);
    } else {
      return fn(new Error("User " + id + " does not exist"));
    }
  };

  exports.findByUsername = function(username, fn) {
    var config, i, len, user;

    config = require('../public/src/conf/configurationNode.js');
    if (global.specRunnerTestmode || config.serverConfigurationParams.configuration.userAuthenticationType === "Demo") {
      i = 0;
      len = users.length;
      while (i < len) {
        user = users[i];
        if (user.username === username) {
          return fn(null, user);
        }
        i++;
      }
    } else if (config.serverConfigurationParams.configuration.userAuthenticationType === "DNS") {
      return dnsGetUser(username, fn);
    }
    return fn(null, null);
  };

  exports.loginStrategy = function(username, password, done) {
    var config, serverUtilityFunctions;

    config = require('../public/src/conf/configurationNode.js');
    serverUtilityFunctions = require('./ServerUtilityFunctions.js');
    return process.nextTick(function() {
      return exports.findByUsername(username, function(err, user) {
        if (config.serverConfigurationParams.configuration.userAuthenticationType === "Demo") {
          if (err) {
            return done(err);
          }
          if (!user) {
            return done(null, false, {
              message: "Unknown user " + username
            });
          }
          if (user.password !== password) {
            return done(null, false, {
              message: "Invalid password"
            });
          }
          return done(null, user);
        } else if (config.serverConfigurationParams.configuration.userAuthenticationType === "DNS") {
          return dnsAuthCheck(username, password, function(results) {
            var error;

            if (results.indexOf("Success") >= 0) {
              try {
                serverUtilityFunctions.logUsage("User logged in succesfully: ", "", username);
              } catch (_error) {
                error = _error;
                console.log("Exception trying to log:" + error);
              }
              return done(null, user);
            } else {
              try {
                serverUtilityFunctions.logUsage("User failed login: ", "", username);
              } catch (_error) {
                error = _error;
                console.log("Exception trying to log:" + error);
              }
              return done(null, false, {
                message: "Invalid credentials"
              });
            }
          });
        }
      });
    });
  };

  exports.loginPage = function(req, res) {
    var error, errorMsg, user;

    user = null;
    if (req.user != null) {
      user = req.user;
    }
    errorMsg = "";
    error = req.flash('error');
    if (error.length > 0) {
      errorMsg = error[0];
    }
    return res.render('login', {
      title: "ACAS Login",
      scripts: [],
      user: user,
      message: errorMsg
    });
  };

  exports.loginPost = function(req, res) {
    return res.redirect('/');
  };

  exports.logout = function(req, res) {
    req.logout();
    return res.redirect('/');
  };

  exports.ensureAuthenticated = function(req, res, next) {
    if (req.isAuthenticated()) {
      return next();
    }
    return res.redirect('/login');
  };

  /* Does not seem to be used
  exports.authenticationService = (req, resp) ->
  	config = require '../public/src/conf/configurationNode.js'
  	callback = (results) ->
  		if results.indexOf("Success")>=0
  			resp.json
  				status: "Success"
  		else
  			resp.json
  				status: "Fail"
  
  	if global.specRunnerTestmode
  		callback("Success")
  	else
  		if config.serverConfigurationParams.configuration.userAuthenticationType == "Demo"
  			callback("Success")
  		else if config.serverConfigurationParams.configuration.userAuthenticationType == "DNS"
  			dnsAuthCheck req.body.user, req.body.password, callback
  */


  dnsAuthCheck = function(user, pass, retFun) {
    var config, request,
      _this = this;

    config = require('../public/src/conf/configurationNode.js');
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

  dnsGetUser = function(username, callback) {
    var config, request,
      _this = this;

    config = require('../public/src/conf/configurationNode.js');
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

  exports.getUsers = function(req, resp) {
    var callback;

    callback = function(err, user) {
      if (user === null) {
        return resp.send(204);
      } else {
        delete user.password;
        return resp.json(user);
      }
    };
    return exports.findByUsername(req.params.username, callback);
  };

}).call(this);
