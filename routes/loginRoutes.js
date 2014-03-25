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
  var csUtilities;

  exports.setupRoutes = function(app, passport) {
    app.get('/login', exports.loginPage);
    app.post('/login', passport.authenticate('local', {
      failureRedirect: '/login',
      failureFlash: true
    }), exports.loginPost);
    app.get('/logout', exports.logout);
    app.post('/api/userAuthentication', exports.authenticationService);
    return app.get('/api/users/:username', exports.getUsers);
  };

  csUtilities = require('../public/src/conf/CustomerSpecificServerFunctions.js');

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
    console.log(req);
    return res.redirect(req.session.returnTo);
  };

  exports.logout = function(req, res) {
    req.logout();
    return res.redirect('/');
  };

  exports.ensureAuthenticated = function(req, res, next) {
    if (req.isAuthenticated()) {
      return next();
    }
    req.session.returnTo = req.url;
    return res.redirect('/login');
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
    return csUtilities.getUser(req.params.username, callback);
  };

  exports.authenticationService = function(req, resp) {
    var callback;
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
      return csUtilities.authCheck(req.body.user, req.body.password, callback);
    }
  };

}).call(this);
