(function() {
  var csUtilities, startApp;

  csUtilities = require("./public/src/conf/CustomerSpecificServerFunctions.js");

  startApp = function() {
    var config, express, http, loginRoutes, path, testModeOverRide, user;
    config = require('./conf/compiled/conf.js');
    express = require('express');
    user = require('./routes/user');
    http = require('http');
    path = require('path');
    global.deployMode = config.all.client.deployMode;
    global.stubsMode = false;
    testModeOverRide = process.argv[2];
    if (typeof testModeOverRide !== "undefined") {
      if (testModeOverRide === "stubsMode") {
        global.stubsMode = true;
        global.specRunnerTestmode = true;
        console.log("############ Starting API in stubs mode");
      }
    }
    global.app = express();
    app.configure(function() {
      app.set('port', config.all.server.nodeapi.port);
      app.use(express.favicon());
      app.use(express.logger('dev'));
      app.use(express.json());
      app.use(express.urlencoded());
      app.use(express.methodOverride());
      app.use(express["static"](path.join(__dirname, 'public')));
      return app.use(app.router);
    });
    loginRoutes = require('./routes/loginRoutes');
    loginRoutes.setupAPIRoutes(app);

    /*TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES */
    http.createServer(app).listen(app.get('port'), function() {
      return console.log("ACAS API server listening on port " + app.get('port'));
    });
    return csUtilities.logUsage("ACAS API server started", "started", "");
  };

  startApp();

}).call(this);
