(function() {
  var asyncblock, exec, fs, startApp;

  global.logDnsUsage = function(action, data, username) {
    var config, form, req, request,
      _this = this;

    config = require('./public/src/conf/configurationNode.js');
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
    form = req.form();
    form.append('application', 'acas');
    form.append('action', action);
    form.append('application_data', data);
    return form.append('user_login', username);
  };

  fs = require('fs');

  asyncblock = require('asyncblock');

  exec = require('child_process').exec;

  asyncblock(function(flow) {
    var config, configLines, configTemplate, enableSpecRunner, hostName, jdbcParts, line, lineParts, name, setting, settings, _i, _len;

    global.deployMode = process.env.DNSDeployMode;
    exec("java -jar ../lib/dns-config-client.jar -m " + global.deployMode + " -c acas -d 2>/dev/null", flow.add());
    config = flow.wait();
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
    fs.writeFileSync("./public/src/conf/configurationNode.js", configTemplate);
    return startApp();
  });

  startApp = function() {
    var LocalStrategy, app, bulkLoadContainersFromSDFRoutes, bulkLoadSampleTransfersRoutes, config, curveCuratorRoutes, docForBatchesRoutes, experimentRoutes, express, flash, fullPKParserRoutes, genericDataParserRoutes, http, loginRoutes, metStabRoutes, microSolRoutes, pampaRoutes, passport, path, preferredBatchIdRoutes, projectServiceRoutes, protocolRoutes, routes, runPrimaryAnalysisRoutes, serverUtilityFunctions, user, util;

    config = require('./public/src/conf/configurationNode.js');
    express = require('express');
    user = require('./routes/user');
    http = require('http');
    path = require('path');
    flash = require('connect-flash');
    passport = require('passport');
    util = require('util');
    LocalStrategy = require('passport-local').Strategy;
    app = express();
    app.configure(function() {
      app.set('port', process.env.PORT || config.serverConfigurationParams.configuration.portNumber);
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
    loginRoutes = require('./routes/loginRoutes');
    app.configure('development', function() {
      return app.use(express.errorHandler());
    });
    routes = require('./routes');
    app.get('/', loginRoutes.ensureAuthenticated, routes.index);
    if (config.serverConfigurationParams.configuration.enableSpecRunner) {
      app.get('/SpecRunner', routes.specRunner);
      app.get('/LiveServiceSpecRunner', routes.liveServiceSpecRunner);
    }
    passport.serializeUser(function(user, done) {
      return done(null, user.username);
    });
    passport.deserializeUser(function(username, done) {
      return loginRoutes.findByUsername(username, function(err, user) {
        return done(err, user);
      });
    });
    passport.use(new LocalStrategy(loginRoutes.loginStrategy));
    app.get('/login', loginRoutes.loginPage);
    app.post('/login', passport.authenticate('local', {
      failureRedirect: '/login',
      failureFlash: true
    }), loginRoutes.loginPost);
    app.get('/logout', loginRoutes.logout);
    app.post('/api/userAuthentication', loginRoutes.authenticationService);
    app.get('/api/users/:username', loginRoutes.getUsers);
    preferredBatchIdRoutes = require('./routes/PreferredBatchIdService.js');
    app.post('/api/preferredBatchId', preferredBatchIdRoutes.preferredBatchId);
    app.post('/api/testRoute', preferredBatchIdRoutes.testRoute);
    protocolRoutes = require('./routes/ProtocolServiceRoutes.js');
    app.get('/api/protocols/codename/:code', protocolRoutes.protocolByCodename);
    app.get('/api/protocols/:id', protocolRoutes.protocolById);
    app.post('/api/protocols', protocolRoutes.postProtocol);
    app.put('/api/protocols', protocolRoutes.putProtocol);
    app.get('/api/protocollabels', protocolRoutes.protocolLabels);
    app.get('/api/protocolCodes', protocolRoutes.protocolCodeList);
    app.get('/api/protocolCodes/filter/:str', protocolRoutes.protocolCodeList);
    experimentRoutes = require('./routes/ExperimentServiceRoutes.js');
    app.get('/api/experiments/codename/:code', experimentRoutes.experimentByCodename);
    app.get('/api/experiments/:id', experimentRoutes.experimentById);
    app.post('/api/experiments', experimentRoutes.postExperiment);
    app.put('/api/experiments', experimentRoutes.putExperiment);
    projectServiceRoutes = require('./routes/ProjectServiceRoutes.js');
    app.get('/api/projects', projectServiceRoutes.getProjects);
    docForBatchesRoutes = require('./routes/DocForBatchesRoutes.js');
    app.get('/docForBatches/*', docForBatchesRoutes.docForBatchesIndex);
    app.get('/docForBatches', docForBatchesRoutes.docForBatchesIndex);
    app.get('/api/docForBatches/:id', docForBatchesRoutes.getDocForBatches);
    app.post('/api/docForBatches', docForBatchesRoutes.saveDocForBatches);
    genericDataParserRoutes = require('./routes/GenericDataParserRoutes.js');
    app.post('/api/genericDataParser', genericDataParserRoutes.parseGenericData);
    fullPKParserRoutes = require('./routes/FullPKParserRoutes.js');
    app.post('/api/fullPKParser', fullPKParserRoutes.parseFullPKData);
    microSolRoutes = require('./routes/MicroSolRoutes.js');
    app.post('/api/microSolParser', microSolRoutes.parseMicroSolData);
    pampaRoutes = require('./routes/PampaRoutes.js');
    app.post('/api/pampaParser', pampaRoutes.parsePampaData);
    metStabRoutes = require('./routes/MetStabRoutes.js');
    app.post('/api/metStabParser', metStabRoutes.parseMetStabData);
    bulkLoadContainersFromSDFRoutes = require('./routes/BulkLoadContainersFromSDFRoutes.js');
    app.post('/api/bulkLoadContainersFromSDF', bulkLoadContainersFromSDFRoutes.bulkLoadContainersFromSDF);
    bulkLoadSampleTransfersRoutes = require('./routes/BulkLoadSampleTransfersRoutes.js');
    app.post('/api/bulkLoadSampleTransfers', bulkLoadSampleTransfersRoutes.bulkLoadSampleTransfers);
    runPrimaryAnalysisRoutes = require('./routes/RunPrimaryAnalysisRoutes.js');
    app.get('/primaryScreenExperiment/*', runPrimaryAnalysisRoutes.primaryScreenExperimentIndex);
    app.get('/primaryScreenExperiment', runPrimaryAnalysisRoutes.primaryScreenExperimentIndex);
    app.post('/api/primaryAnalysis/runPrimaryAnalysis', runPrimaryAnalysisRoutes.runPrimaryAnalysis);
    curveCuratorRoutes = require('./routes/CurveCuratorRoutes.js');
    app.get('/curveCurator/*', curveCuratorRoutes.curveCuratorIndex);
    app.get('/api/curves/stub/:exptCode', curveCuratorRoutes.getCurveStubs);
    serverUtilityFunctions = require('./routes/ServerUtilityFunctions.js');
    app.post('/api/runRFunctionTest', serverUtilityFunctions.runRFunctionTest);
    http.createServer(app).listen(app.get('port'), function() {
      return console.log("Express server listening on port " + app.get('port'));
    });
    return logDnsUsage("ACAS Node server started", "started", "");
  };

  /* if not DNS
  global.deployMode = "Dev"
  startApp()
   end if not DNS
  */


}).call(this);
