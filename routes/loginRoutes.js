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

  to index.coffee under specScripts:
		#For Login module
		'javascripts/spec/AuthenticationServiceSpec.js'
*/


(function() {
  var users;

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
    } else {
      console.log("no authorization service configured");
    }
    if (config.serverConfigurationParams.configuration.userAuthenticationType !== "Demo") {
      return fn(null, null);
    } else {
      return fn(null, {
        username: username
      });
    }
  };

  exports.loginStrategy = function(username, password, done) {
    var config;
    config = require('../public/src/conf/configurationNode.js');
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
        } else {
          return console.log("no authentication service configured");
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

  exports.authenticationService = function(req, resp) {
    var callback, config;
    config = require('../public/src/conf/configurationNode.js');
    callback = function(results) {
      if (results.indexOf("Success") >= 0) {
        return resp.json({
          status: "Success"
        });
      } else {
        return resp.json({
          status: "Fail"
        });
      }
    };
    if (global.specRunnerTestmode) {
      return callback("Success");
    } else {
      if (config.serverConfigurationParams.configuration.userAuthenticationType === "Demo") {
        return callback("Success");
      } else {
        return console.log("no authentication service configured");
      }
    }
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
