(function() {
  var csUtilities, startApp;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  startApp = function() {
    var LocalStrategy, config, express, flash, fs, http, https, indexRoutes, loginRoutes, passport, path, sslOptions, testModeOverRide, user, util;
    config = require('./conf/compiled/conf.js');
    express = require('express');
    user = require('./routes/user');
    http = require('http');
    path = require('path');
    flash = require('connect-flash');
    passport = require('passport');
    util = require('util');
    LocalStrategy = require('passport-local').Strategy;
    global.deployMode = config.all.client.deployMode;
    global.stubsMode = false;
    testModeOverRide = process.argv[2];
    if (typeof testModeOverRide !== "undefined") {
      if (testModeOverRide === "stubsMode") {
        global.stubsMode = true;
        console.log("############ Starting in stubs mode");
      }
    }
    global.app = express();
    app.configure(function() {
      app.set('port', config.all.client.port);
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.use(express.favicon());
      app.use(express.logger('dev'));
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(express["static"](path.join(__dirname, 'public')));
      app.use(express.cookieParser());
      app.use(express.session({
        secret: 'acas needs login',
        cookie: {
          maxAge: 365 * 24 * 60 * 60 * 1000
        }
      }));
      app.use(flash());
      app.use(passport.initialize());
      app.use(passport.session());
      return app.use(app.router);
    });
    app.configure('development', function() {
      app.use(express.errorHandler());
      return console.log("node dev mode set");
    });
    passport.serializeUser(function(user, done) {
      return done(null, user.username);
    });
    passport.deserializeUser(function(username, done) {
      return csUtilities.findByUsername(username, function(err, user) {
        return done(err, user);
      });
    });
    passport.use(new LocalStrategy(csUtilities.loginStrategy));
    loginRoutes = require('./routes/loginRoutes');
    loginRoutes.setupRoutes(app, passport);
    indexRoutes = require('./routes/index.js');
    indexRoutes.setupRoutes(app, loginRoutes);

    /*TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES */
    if (!config.all.client.use.ssl) {
      http.createServer(app).listen(app.get('port'), function() {
        return console.log("Express server listening on port " + app.get('port'));
      });
    } else {
      console.log("------ Starting in SSL Mode");
      https = require('https');
      fs = require('fs');
      sslOptions = {
        key: fs.readFileSync(config.all.server.ssl.key.file.path),
        cert: fs.readFileSync(config.all.server.ssl.cert.file.path),
        ca: fs.readFileSync(config.all.server.ssl.cert.authority.file.path),
        passphrase: config.all.server.ssl.cert.passphrase
      };
      https.createServer(sslOptions, app).listen(app.get('port'), function() {
        return console.log("Express server listening on port " + app.get('port'));
      });
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
    }
    return csUtilities.logUsage("ACAS Node server started", "started", "");
  };

  startApp();

}).call(this);
