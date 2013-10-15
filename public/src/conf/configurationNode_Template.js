(function() {

	(function(exports) {

		exports.serverConfigurationParams = {};
		exports.serverConfigurationParams.configuration = {};
		exports.serverConfigurationParams.configuration.serverName = "http://acas.api.hostname";
		exports.serverConfigurationParams.configuration.serverAddress = "acas.api.hostname";
		exports.serverConfigurationParams.configuration.portNumber = acas.node.port;
		exports.serverConfigurationParams.configuration.fileServiceURL = "http://acas.api.hostname:8888";
		exports.serverConfigurationParams.configuration.serverRelativeFilePath = "serverOnlyModules/blueimp-file-upload-node/public/files/";
		exports.serverConfigurationParams.configuration.driver = "acas.jdbc.driverClassName";
		exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/ojdbc6.jar";
		exports.serverConfigurationParams.configuration.databaseLocation = "acas.api.db.location";
		exports.serverConfigurationParams.configuration.databasePort = ":acas.api.db.port:acas.api.db.name";
		exports.serverConfigurationParams.configuration.username = "acas.jdbc.username";
		exports.serverConfigurationParams.configuration.password = "acas.jdbc.password";
		exports.serverConfigurationParams.configuration.serverPath = "http://acas.api.hostname:8080/acas/";
		exports.serverConfigurationParams.configuration.enableSpecRunner = acas.api.enableSpecRunner;
// For preferred ID service
		exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://acas.api.hostname:acas.node.port/api/preferredBatchId";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "SingleBatchNameQueryString";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "acas.api.externalPreferredBatchIdServiceURL";

// For Login
		exports.serverConfigurationParams.configuration.userAuthenticationType = "DNS";
		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "acas.api.userAuthenticationServiceURL";
		exports.serverConfigurationParams.configuration.userInformationServiceURL = "acas.api.personsServiceURL";

// For Projects
		exports.serverConfigurationParams.configuration.projectsType = "DNS";
		exports.serverConfigurationParams.configuration.projectsServiceURL = "acas.api.projectsServiceURL";

// For racas
		exports.serverConfigurationParams.configuration.appName = "acas.jdbc.username";
		exports.serverConfigurationParams.configuration.db_driver = "Oracle()";
		exports.serverConfigurationParams.configuration.db_user = "acas.jdbc.username";
		exports.serverConfigurationParams.configuration.db_password = "acas.jdbc.password";
		exports.serverConfigurationParams.configuration.db_name = "acas.api.db.name";
		exports.serverConfigurationParams.configuration.db_host = "acas.api.db.host";
		exports.serverConfigurationParams.configuration.db_port = "acas.api.db.port";
		exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
		exports.serverConfigurationParams.configuration.db_driver_package = "require(ROracle)";
		exports.serverConfigurationParams.configuration.logDir = "acas.env.logDir";
// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://acas.api.hostname/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://acas.api.hostname:3838";

// For generic data parser
		exports.serverConfigurationParams.configuration.projectService = "http://acas.api.hostname:acas.node.port/api/projects";
		exports.serverConfigurationParams.configuration.fileServiceType = "custom";
		exports.serverConfigurationParams.configuration.externalFileService = "acas.api.externalFileServiceURL";
		exports.serverConfigurationParams.configuration.stateGroupsScript = "public/src/conf/genericDataParserConfiguration.R";
		exports.serverConfigurationParams.configuration.includeProject = "TRUE";
		exports.serverConfigurationParams.configuration.reportRegistrationURL = "acas.api.reportRegistrationServiceURL";
		exports.serverConfigurationParams.configuration.allowProtocolCreationWithFormats = "";
		exports.serverConfigurationParams.configuration.nameValidationService = "http://acas.api.hostname:acas.node.port/api/users"
		exports.serverConfigurationParams.configuration.loggingService = "acas.api.usageLoggingServiceURL"
		exports.serverConfigurationParams.configuration.resultViewerProtocolPrefix = "acas.api.resultViewerProtocolPrefix";
		exports.serverConfigurationParams.configuration.resultViewerExperimentPrefix = "acas.api.resultViewerExperimentPrefix";
		exports.serverConfigurationParams.configuration.deleteFilesOnReload = "true";
		exports.serverConfigurationParams.configuration.useCustomReportRegistration = "true"


	})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
