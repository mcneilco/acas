(function() {

	(function(exports) {

		exports.serverConfigurationParams = {};
		exports.serverConfigurationParams.configuration = {};
		exports.serverConfigurationParams.configuration.serverName = "http://acas-t";
		exports.serverConfigurationParams.configuration.serverAddress = "acas-t";
		exports.serverConfigurationParams.configuration.portNumber = 48203;
		exports.serverConfigurationParams.configuration.fileServiceURL = "http://acas-t:8888";
		exports.serverConfigurationParams.configuration.serverRelativeFilePath = "serverOnlyModules/blueimp-file-upload-node/public/files/";
		exports.serverConfigurationParams.configuration.driver = "oracle.jdbc.driver.OracleDriver";
		exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/ojdbc6.jar";
		exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:oracle:thin:@";
		exports.serverConfigurationParams.configuration.databasePort = ":1521:oratest";
		exports.serverConfigurationParams.configuration.username = "ACAS";
		exports.serverConfigurationParams.configuration.password = "2Ydudu8$pT";
		exports.serverConfigurationParams.configuration.serverPath = "http://acas-t:8080/acas/";
// For preferred ID service
		exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://acas-d:3000/api/preferredBatchId";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "SingleBatchNameQueryString";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://imapp01-t:8080/DNS/core/v1/synonyms/preferred/";

// For Login
		exports.serverConfigurationParams.configuration.userAuthenticationType = "DNS";
		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "http://imapp01-t:8080/DNS/persons/v1/Persons/authenticate";
		exports.serverConfigurationParams.configuration.userInformationServiceURL = "http://imapp01-t:8080/DNS/persons/v1/Persons/";

// For Projects
		exports.serverConfigurationParams.configuration.projectsType = "DNS";
		exports.serverConfigurationParams.configuration.projectsServiceURL = "http://imapp01-t:8080/DNS/codes/v1/Codes/Project.json";

// For racas
		exports.serverConfigurationParams.configuration.appName = "ACAS";
		exports.serverConfigurationParams.configuration.db_driver = "Oracle()";
		exports.serverConfigurationParams.configuration.db_user = "ACAS";
		exports.serverConfigurationParams.configuration.db_password = "2Ydudu8$pT";
		exports.serverConfigurationParams.configuration.db_name = "ORATEST";
		exports.serverConfigurationParams.configuration.db_host = "***REMOVED***";
		exports.serverConfigurationParams.configuration.db_port = "1521";
		exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
		exports.serverConfigurationParams.configuration.db_driver_package = "require(ROracle)";

// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://acas-t/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://acas-t:3838";

// For generic data parser
		exports.serverConfigurationParams.configuration.projectService = "http://acas-t:3000/api/projects";
		exports.serverConfigurationParams.configuration.fileServiceType = "DNS";
		exports.serverConfigurationParams.configuration.externalFileService = "http://dsantimapp01:8080/DNS/core/v1/DNSFile";
		exports.serverConfigurationParams.configuration.stateGroupsScript = "public/src/conf/genericDataParserConfiguration.R";
		exports.serverConfigurationParams.configuration.includeProject = "TRUE";
		exports.serverConfigurationParams.configuration.reportRegistrationURL = "http://dsantimapp01:8080/DNS/core/v1/DNSAnnotation";
		exports.serverConfigurationParams.configuration.allowProtocolCreationWithFormats = "";
		exports.serverConfigurationParams.configuration.nameValidationService = "http://acas-t:3000/api/users"



		})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
