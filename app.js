(function() {
  var csUtilities, startApp;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  startApp = function() {
    var LocalStrategy, child, config, express, flash, forever, fs, http, https, indexRoutes, loginRoutes, options, passport, path, sslOptions, testModeOverRide, upload, user, util;
    config = require('./conf/compiled/conf.js');
    express = require('express');
    user = require('./routes/user');
    http = require('http');
    path = require('path');
    upload = require('./node_modules_customized/jquery-file-upload-middleware');
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
    upload.configure({
      uploadDir: __dirname + '/privateUploads',
      ssl: config.all.client.use.ssl,
      uploadUrl: "/dataFiles"
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
      app.use('/uploads', upload.fileHandler());
      app.use(express.json());
      app.use(express.urlencoded());
      app.use(express.methodOverride());
      app.use(express["static"](path.join(__dirname, 'public')));
      return app.use(app.router);
    });
    upload.on("error", function(e) {
      return console.log("fileUpload: ", e.message);
    });
    upload.on("end", function(fileInfo) {
      return app.emit("file-uploaded", fileInfo);
    });
    loginRoutes.setupRoutes(app, passport);
    indexRoutes = require('./routes/index.js');
    indexRoutes.setupRoutes(app, loginRoutes);

  	routeSet_1 = require("./routes/BulkLoadContainersFromSDFRoutes.js");
	routeSet_1.setupRoutes(app, loginRoutes);
	routeSet_2 = require("./routes/BulkLoadSampleTransfersRoutes.js");
	routeSet_2.setupRoutes(app, loginRoutes);
	routeSet_3 = require("./routes/CodeTableServiceRoutes.js");
	routeSet_3.setupRoutes(app, loginRoutes);
	routeSet_4 = require("./routes/CurveCuratorRoutes.js");
	routeSet_4.setupRoutes(app, loginRoutes);
	routeSet_5 = require("./routes/DocForBatchesRoutes.js");
	routeSet_5.setupRoutes(app, loginRoutes);
	routeSet_6 = require("./routes/DoseResponseFitRoutes.js");
	routeSet_6.setupRoutes(app, loginRoutes);
	routeSet_7 = require("./routes/ExperimentBrowserRoutes.js");
	routeSet_7.setupRoutes(app, loginRoutes);
	routeSet_8 = require("./routes/ExperimentServiceRoutes.js");
	routeSet_8.setupRoutes(app, loginRoutes);
	routeSet_9 = require("./routes/FileServices.js");
	routeSet_9.setupRoutes(app, loginRoutes);
	routeSet_10 = require("./routes/GeneDataQueriesRoutes.js");
	routeSet_10.setupRoutes(app, loginRoutes);
	routeSet_11 = require("./routes/GenericDataParserRoutes.js");
	routeSet_11.setupRoutes(app, loginRoutes);
	routeSet_12 = require("./routes/PreferredBatchIdService.js");
	routeSet_12.setupRoutes(app, loginRoutes);
	routeSet_13 = require("./routes/PrimaryScreenRoutes.js");
	routeSet_13.setupRoutes(app, loginRoutes);
	routeSet_14 = require("./routes/ProjectServiceRoutes.js");
	routeSet_14.setupRoutes(app, loginRoutes);
	routeSet_15 = require("./routes/ProtocolServiceRoutes.js");
	routeSet_15.setupRoutes(app, loginRoutes);
	routeSet_16 = require("./routes/RunPrimaryAnalysisRoutes.js");
	routeSet_16.setupRoutes(app, loginRoutes);
	routeSet_17 = require("./routes/ServerUtilityFunctions.js");
	routeSet_17.setupRoutes(app, loginRoutes);

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
      options: options
    });
    child.on("exit", function() {
      return console.log("app_api.js has exited after 3 restarts");
    });
    child.start();
    return csUtilities.logUsage("ACAS Node server started", "started", "");
  };

  startApp();

}).call(this);
