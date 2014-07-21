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

  	routeSet_1 = require("./routes/BulkLoadContainersFromSDFRoutes.js");
	if (routeSet_1.setupAPIRoutes) {
		routeSet_1.setupAPIRoutes(app); }
	routeSet_2 = require("./routes/BulkLoadSampleTransfersRoutes.js");
	if (routeSet_2.setupAPIRoutes) {
		routeSet_2.setupAPIRoutes(app); }
	routeSet_3 = require("./routes/CurveCuratorRoutes.js");
	if (routeSet_3.setupAPIRoutes) {
		routeSet_3.setupAPIRoutes(app); }
	routeSet_4 = require("./routes/DocForBatchesRoutes.js");
	if (routeSet_4.setupAPIRoutes) {
		routeSet_4.setupAPIRoutes(app); }
	routeSet_5 = require("./routes/DoseResponseFitRoutes.js");
	if (routeSet_5.setupAPIRoutes) {
		routeSet_5.setupAPIRoutes(app); }
	routeSet_6 = require("./routes/ExperimentBrowserRoutes.js");
	if (routeSet_6.setupAPIRoutes) {
		routeSet_6.setupAPIRoutes(app); }
	routeSet_7 = require("./routes/ExperimentServiceRoutes.js");
	if (routeSet_7.setupAPIRoutes) {
		routeSet_7.setupAPIRoutes(app); }
	routeSet_8 = require("./routes/FileServices.js");
	if (routeSet_8.setupAPIRoutes) {
		routeSet_8.setupAPIRoutes(app); }
	routeSet_9 = require("./routes/GeneDataQueriesRoutes.js");
	if (routeSet_9.setupAPIRoutes) {
		routeSet_9.setupAPIRoutes(app); }
	routeSet_10 = require("./routes/GenericDataParserRoutes.js");
	if (routeSet_10.setupAPIRoutes) {
		routeSet_10.setupAPIRoutes(app); }
	routeSet_11 = require("./routes/PreferredBatchIdService.js");
	if (routeSet_11.setupAPIRoutes) {
		routeSet_11.setupAPIRoutes(app); }
	routeSet_12 = require("./routes/PrimaryScreenRoutes.js");
	if (routeSet_12.setupAPIRoutes) {
		routeSet_12.setupAPIRoutes(app); }
	routeSet_13 = require("./routes/ProjectServiceRoutes.js");
	if (routeSet_13.setupAPIRoutes) {
		routeSet_13.setupAPIRoutes(app); }
	routeSet_14 = require("./routes/ProtocolServiceRoutes.js");
	if (routeSet_14.setupAPIRoutes) {
		routeSet_14.setupAPIRoutes(app); }
	routeSet_15 = require("./routes/RunPrimaryAnalysisRoutes.js");
	if (routeSet_15.setupAPIRoutes) {
		routeSet_15.setupAPIRoutes(app); }
	routeSet_16 = require("./routes/ServerUtilityFunctions.js");
	if (routeSet_16.setupAPIRoutes) {
		routeSet_16.setupAPIRoutes(app); }

    http.createServer(app).listen(app.get('port'), function() {
      return console.log("ACAS API server listening on port " + app.get('port'));
    });
    return csUtilities.logUsage("ACAS API server started", "started", "");
  };

  startApp();

}).call(this);
