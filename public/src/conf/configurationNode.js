(function() {

	(function(exports) {

		exports.serverConfigurationParams = {};
		exports.serverConfigurationParams.configuration = {};
		exports.serverConfigurationParams.configuration.serverName = "http://localhost";
		exports.serverConfigurationParams.configuration.serverAddress = "localhost";
		exports.serverConfigurationParams.configuration.portNumber = 3000;
		exports.serverConfigurationParams.configuration.fileServiceURL = "http://localhost:8888";
		exports.serverConfigurationParams.configuration.serverRelativeFilePath = "serverOnlyModules/blueimp-file-upload-node/public/files/";
		exports.serverConfigurationParams.configuration.driver = "oracle.jdbc.driver.OracleDriver";
		exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/ojdbc6.jar";
		exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:oracle://";
		exports.serverConfigurationParams.configuration.databasePort = ":5432/compound";
		exports.serverConfigurationParams.configuration.username = "acas_dev";
		exports.serverConfigurationParams.configuration.password = "acas_dev_password";
		exports.serverConfigurationParams.configuration.serverPath = "http://suse.labsynch.com:8080/acas/";
		exports.serverConfigurationParams.configuration.enableSpecRunner = true;
		exports.serverConfigurationParams.configuration.requireLogin = false;
// For preferred ID service
		exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://localhost:3000/api/preferredBatchId";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "LabSynchCmpdReg";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://suse.labsynch.com:8080/cmpdreg/metalots/corpName/";

// For Login
		exports.serverConfigurationParams.configuration.userAuthenticationType = "Demo";
		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "";
		exports.serverConfigurationParams.configuration.userInformationServiceURL = "";

// For Projects
		exports.serverConfigurationParams.configuration.projectsType = "ACAS";
		exports.serverConfigurationParams.configuration.projectsServiceURL = "";

// For racas
		exports.serverConfigurationParams.configuration.appName = "ACAS";
		exports.serverConfigurationParams.configuration.db_driver = "JDBC('oracle.jdbc.driver.OracleDriver', 'public/src/modules/GenericDataParser/src/server/ojdbc6.jar')";
		exports.serverConfigurationParams.configuration.db_user = "acas_dev";
		exports.serverConfigurationParams.configuration.db_password = "acas_dev_password";
		exports.serverConfigurationParams.configuration.db_name = "osl";
		exports.serverConfigurationParams.configuration.db_host = "ora.labsynch.com";
		exports.serverConfigurationParams.configuration.db_port = "1521";
		exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
		exports.serverConfigurationParams.configuration.db_driver_package = "require(RJDBC)";
		exports.serverConfigurationParams.configuration.logDir = "/opt/node_apps/log";
// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://suse.labsynch.com/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://suse.labsynch.com:3838";

// For generic data parser
		exports.serverConfigurationParams.configuration.projectService = "";
		exports.serverConfigurationParams.configuration.fileServiceType = "blueimp";
		exports.serverConfigurationParams.configuration.externalFileService = "";
		exports.serverConfigurationParams.configuration.stateGroupsScript = "public/src/conf/genericDataParserConfiguration.R";
		exports.serverConfigurationParams.configuration.includeProject = "FALSE";
		exports.serverConfigurationParams.configuration.reportRegistrationURL = "";
		exports.serverConfigurationParams.configuration.allowProtocolCreationWithFormats = "Generic,Dose Response,Custom Example";
		exports.serverConfigurationParams.configuration.nameValidationService = "http://localhost:3000/api/users";
		exports.serverConfigurationParams.configuration.resultViewerProtocolPrefix = "http://suse.labsynch.com:9080/seurat/runseurat?cmd=newjob&AssayName=";
		exports.serverConfigurationParams.configuration.resultViewerExperimentPrefix = "&AssayProtocol=";
		exports.serverConfigurationParams.configuration.deleteFilesOnReload = "false";
		exports.serverConfigurationParams.configuration.useCustomReportRegistration = "false"



	})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
