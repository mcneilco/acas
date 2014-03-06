(function() {
  var csUtilities, startApp;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  startApp = function() {
    var LocalStrategy, bulkLoadContainersFromSDFRoutes, bulkLoadSampleTransfersRoutes, config, curveCuratorRoutes, docForBatchesRoutes, experimentRoutes, express, flash, genericDataParserRoutes, http, indexRoutes, loginRoutes, passport, path, preferredBatchIdRoutes, projectServiceRoutes, protocolRoutes, runPrimaryAnalysisRoutes, serverUtilityFunctions, user, util;
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
    preferredBatchIdRoutes = require('./routes/PreferredBatchIdService.js');
    preferredBatchIdRoutes.setupRoutes(app);
    serverUtilityFunctions = require('./routes/ServerUtilityFunctions.js');
    serverUtilityFunctions.setupRoutes(app);
    protocolRoutes = require('./routes/ProtocolServiceRoutes.js');
    protocolRoutes.setupRoutes(app);
    experimentRoutes = require('./routes/ExperimentServiceRoutes.js');
    experimentRoutes.setupRoutes(app);
    projectServiceRoutes = require('./routes/ProjectServiceRoutes.js');
    projectServiceRoutes.setupRoutes(app);
    docForBatchesRoutes = require('./routes/DocForBatchesRoutes.js');
    docForBatchesRoutes.setupRoutes(app);
    genericDataParserRoutes = require('./routes/GenericDataParserRoutes.js');
    genericDataParserRoutes.setupRoutes(app);
    bulkLoadContainersFromSDFRoutes = require('./routes/BulkLoadContainersFromSDFRoutes.js');
    bulkLoadContainersFromSDFRoutes.setupRoutes(app);
    bulkLoadSampleTransfersRoutes = require('./routes/BulkLoadSampleTransfersRoutes.js');
    bulkLoadSampleTransfersRoutes.setupRoutes(app);
    runPrimaryAnalysisRoutes = require('./routes/RunPrimaryAnalysisRoutes.js');
    runPrimaryAnalysisRoutes.setupRoutes(app);
    curveCuratorRoutes = require('./routes/CurveCuratorRoutes.js');
    curveCuratorRoutes.setupRoutes(app);
    http.createServer(app).listen(app.get('port'), function() {
      return console.log("Express server listening on port " + app.get('port'));
    });
    return csUtilities.logUsage("ACAS Node server started", "started", "");
  };

  startApp();

}).call(this);
