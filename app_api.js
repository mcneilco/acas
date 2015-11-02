(function() {
  var csUtilities, startApp;

  global.logger = require("./routes/Logger");

  require('./src/ConsoleLogWinstonOverride');

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

  	routeSet_1 = require("./routes/AdminPanelRoutes.js");
	if (routeSet_1.setupAPIRoutes) {
		routeSet_1.setupAPIRoutes(app); }
	routeSet_2 = require("./routes/BaseEntityServiceRoutes.js");
	if (routeSet_2.setupAPIRoutes) {
		routeSet_2.setupAPIRoutes(app); }
	routeSet_3 = require("./routes/BulkLoadContainersFromSDFRoutes.js");
	if (routeSet_3.setupAPIRoutes) {
		routeSet_3.setupAPIRoutes(app); }
	routeSet_4 = require("./routes/BulkLoadSampleTransfersRoutes.js");
	if (routeSet_4.setupAPIRoutes) {
		routeSet_4.setupAPIRoutes(app); }
	routeSet_5 = require("./routes/CmpdRegBulkLoaderRoutes.js");
	if (routeSet_5.setupAPIRoutes) {
		routeSet_5.setupAPIRoutes(app); }
	routeSet_6 = require("./routes/CodeTableServiceRoutes.js");
	if (routeSet_6.setupAPIRoutes) {
		routeSet_6.setupAPIRoutes(app); }
	routeSet_7 = require("./routes/ControllerRedirectRoutes.js");
	if (routeSet_7.setupAPIRoutes) {
		routeSet_7.setupAPIRoutes(app); }
	routeSet_8 = require("./routes/CurveCuratorRoutes.js");
	if (routeSet_8.setupAPIRoutes) {
		routeSet_8.setupAPIRoutes(app); }
	routeSet_9 = require("./routes/DocForBatchesRoutes.js");
	if (routeSet_9.setupAPIRoutes) {
		routeSet_9.setupAPIRoutes(app); }
	routeSet_10 = require("./routes/DoseResponseFitRoutes.js");
	if (routeSet_10.setupAPIRoutes) {
		routeSet_10.setupAPIRoutes(app); }
	routeSet_11 = require("./routes/ExperimentBrowserRoutes.js");
	if (routeSet_11.setupAPIRoutes) {
		routeSet_11.setupAPIRoutes(app); }
	routeSet_12 = require("./routes/ExperimentServiceRoutes.js");
	if (routeSet_12.setupAPIRoutes) {
		routeSet_12.setupAPIRoutes(app); }
	routeSet_13 = require("./routes/FileServices.js");
	if (routeSet_13.setupAPIRoutes) {
		routeSet_13.setupAPIRoutes(app); }
	routeSet_14 = require("./routes/GeneDataQueriesRoutes.js");
	if (routeSet_14.setupAPIRoutes) {
		routeSet_14.setupAPIRoutes(app); }
	routeSet_15 = require("./routes/GenericDataParserRoutes.js");
	if (routeSet_15.setupAPIRoutes) {
		routeSet_15.setupAPIRoutes(app); }
	routeSet_16 = require("./routes/LabelServiceRoutes.js");
	if (routeSet_16.setupAPIRoutes) {
		routeSet_16.setupAPIRoutes(app); }
	routeSet_17 = require("./routes/Logger.js");
	if (routeSet_17.setupAPIRoutes) {
		routeSet_17.setupAPIRoutes(app); }
	routeSet_18 = require("./routes/LoggingRoutes.js");
	if (routeSet_18.setupAPIRoutes) {
		routeSet_18.setupAPIRoutes(app); }
	routeSet_19 = require("./routes/PreferredBatchIdService.js");
	if (routeSet_19.setupAPIRoutes) {
		routeSet_19.setupAPIRoutes(app); }
	routeSet_20 = require("./routes/PreferredEntityCodeService.js");
	if (routeSet_20.setupAPIRoutes) {
		routeSet_20.setupAPIRoutes(app); }
	routeSet_21 = require("./routes/PrimaryScreenProtocolRoutes.js");
	if (routeSet_21.setupAPIRoutes) {
		routeSet_21.setupAPIRoutes(app); }
	routeSet_22 = require("./routes/PrimaryScreenRoutes.js");
	if (routeSet_22.setupAPIRoutes) {
		routeSet_22.setupAPIRoutes(app); }
	routeSet_23 = require("./routes/ProjectServiceRoutes.js");
	if (routeSet_23.setupAPIRoutes) {
		routeSet_23.setupAPIRoutes(app); }
	routeSet_24 = require("./routes/ProtocolServiceRoutes.js");
	if (routeSet_24.setupAPIRoutes) {
		routeSet_24.setupAPIRoutes(app); }
	routeSet_25 = require("./routes/RunPrimaryAnalysisRoutes.js");
	if (routeSet_25.setupAPIRoutes) {
		routeSet_25.setupAPIRoutes(app); }
	routeSet_26 = require("./routes/ServerUtilityFunctions.js");
	if (routeSet_26.setupAPIRoutes) {
		routeSet_26.setupAPIRoutes(app); }
	routeSet_27 = require("./routes/SetupRoutes.js");
	if (routeSet_27.setupAPIRoutes) {
		routeSet_27.setupAPIRoutes(app); }
	routeSet_28 = require("./routes/TestedEntityPropertiesServicesRoutes.js");
	if (routeSet_28.setupAPIRoutes) {
		routeSet_28.setupAPIRoutes(app); }
	routeSet_29 = require("./routes/ThingServiceRoutes.js");
	if (routeSet_29.setupAPIRoutes) {
		routeSet_29.setupAPIRoutes(app); }
	routeSet_30 = require("./routes/ValidateCloneNameService.js");
	if (routeSet_30.setupAPIRoutes) {
		routeSet_30.setupAPIRoutes(app); }

    http.createServer(app).listen(app.get('port'), function() {
      return console.log("ACAS API server listening on port " + app.get('port'));
    });
    return csUtilities.logUsage("ACAS API server started", "started", "");
  };

  startApp();

}).call(this);
