(function() {
  var csUtilities, startApp;

  global.logger = require("./routes/Logger");

  require('./src/ConsoleLogWinstonOverride');

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  startApp = function() {
    var LocalStrategy, child, config, express, flash, forever, fs, http, https, indexRoutes, loginRoutes, options, passport, path, sslOptions, testModeOverRide, user, util;
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
    passport.serializeUser(function(user, done) {
      var userToSerialize;
      userToSerialize = {
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        roles: user.roles
      };
      return done(null, userToSerialize);
    });
    passport.deserializeUser(function(user, done) {
      return done(null, user);
    });
    passport.use(new LocalStrategy(csUtilities.loginStrategy));
    loginRoutes = require('./routes/loginRoutes');
    global.app = express();
    app.configure(function() {
      app.set('port', config.all.client.port);
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.use(express.favicon());
      app.use(express.logger('dev'));
      app.use(express.cookieParser());
      app.use(express.session({
        secret: 'acas needs login',
        cookie: {
          maxAge: 365 * 24 * 60 * 60 * 1000
        }
      }));
      app.use(flash());
      app.use(passport.initialize());
      app.use(passport.session({
        pauseStream: true
      }));
      app.use(express.json());
      app.use(express.urlencoded());
      app.use(express.methodOverride());
      app.use(express["static"](path.join(__dirname, 'public')));
      return app.use(app.router);
    });
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
    options = stubsMode ? ["stubsMode"] : [];
    forever = require("forever-monitor");
    child = new forever.Monitor("app_api.js", {
      max: 3,
      silent: false,
      options: options,
      args: ['--color']
    });
    child.on("exit", function() {
      return console.log("app_api.js has exited after 3 restarts");
    });
    child.start();
    child.on('exit:code', function(code) {
      console.error('stopping child process with code ');
      process.exit(0);
    });
    process.once('SIGTERM', function() {
      child.stop(0);
    });
    process.once('SIGINT', function() {
      child.stop(0);
    });
    process.once('exit', function() {
      console.log('clean exit of app');
    });
    process.on('uncaughtException', function(err) {
      console.error('Caught exception: ' + err.stack);
    });
    return csUtilities.logUsage("ACAS Node server started", "started", "");
  };

  startApp();

}).call(this);