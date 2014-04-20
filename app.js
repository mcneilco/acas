(function() {
  var csUtilities, startApp;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  startApp = function() {
    var LocalStrategy, config, express, flash, http, indexRoutes, loginRoutes, passport, path, testModeOverRide, user, util;
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
  	routeSet_1 = require("./routes/BulkLoadContainersFromSDFRoutes.js");
	routeSet_1.setupRoutes(app, loginRoutes);
	routeSet_2 = require("./routes/BulkLoadSampleTransfersRoutes.js");
	routeSet_2.setupRoutes(app, loginRoutes);
	routeSet_3 = require("./routes/CurveCuratorRoutes.js");
	routeSet_3.setupRoutes(app, loginRoutes);
	routeSet_4 = require("./routes/DocForBatchesRoutes.js");
	routeSet_4.setupRoutes(app, loginRoutes);
	routeSet_5 = require("./routes/DoseResponseFitRoutes.js");
	routeSet_5.setupRoutes(app, loginRoutes);
	routeSet_6 = require("./routes/ExperimentBrowserRoutes.js");
	routeSet_6.setupRoutes(app, loginRoutes);
	routeSet_7 = require("./routes/ExperimentServiceRoutes.js");
	routeSet_7.setupRoutes(app, loginRoutes);
	routeSet_8 = require("./routes/GeneDataQueriesRoutes.js");
	routeSet_8.setupRoutes(app, loginRoutes);
	routeSet_9 = require("./routes/GenericDataParserRoutes.js");
	routeSet_9.setupRoutes(app, loginRoutes);
	routeSet_10 = require("./routes/PreferredBatchIdService.js");
	routeSet_10.setupRoutes(app, loginRoutes);
	routeSet_11 = require("./routes/ProjectServiceRoutes.js");
	routeSet_11.setupRoutes(app, loginRoutes);
	routeSet_12 = require("./routes/ProtocolServiceRoutes.js");
	routeSet_12.setupRoutes(app, loginRoutes);
	routeSet_13 = require("./routes/RunPrimaryAnalysisRoutes.js");
	routeSet_13.setupRoutes(app, loginRoutes);
	routeSet_14 = require("./routes/ServerUtilityFunctions.js");
	routeSet_14.setupRoutes(app, loginRoutes);


    http.createServer(app).listen(app.get('port'), function() {
      return console.log("Express server listening on port " + app.get('port'));
    });
    return csUtilities.logUsage("ACAS Node server started", "started", "");
  };

  startApp();

}).call(this);
