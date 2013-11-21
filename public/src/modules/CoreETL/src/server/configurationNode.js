(function() {

	(function(exports) {

		exports.serverConfigurationParams = {};
		exports.serverConfigurationParams.configuration = {};
		exports.serverConfigurationParams.configuration.serverName = "http://localhost";
		exports.serverConfigurationParams.configuration.portNumber = 3000;
		exports.serverConfigurationParams.configuration.fileServiceURL = "http://localhost:8888";
		exports.serverConfigurationParams.configuration.serverRelativeFilePath = "serverOnlyModules/blueimp-file-upload-node/public/files/";


//        exports.serverConfigurationParams.configuration.serverName = "http://acas-d"
//        exports.serverConfigurationParams.configuration.portNumber = 3000
//        exports.serverConfigurationParams.configuration.fileServiceURL = "http://acas-d:8888"
//        exports.serverConfigurationParams.configuration.serverAddress = "acas-d"
		exports.serverConfigurationParams.configuration.driver = "oracle.jdbc.driver.OracleDriver"
		exports.serverConfigurationParams.configuration.driverLocation = "/opt/node_apps/acas/public/src/modules/GenericDataParser/src/server/ojdbc6.jar"
		exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:oracle:thin:@"
		exports.serverConfigurationParams.configuration.databasePort = ":1521:oraprod"
		exports.serverConfigurationParams.configuration.username = "seurat"
		exports.serverConfigurationParams.configuration.password = "seurat"
		exports.serverConfigurationParams.configuration.serverPath = "http://acas-d:8080/acas/"
// For preferred ID service
//        exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://acas-d:3000/api/preferredBatchId"
		exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://localhost:3000/api/preferredBatchId"
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "SingleBatchNameQueryString";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://imapp01-d:8080/DNS/core/v1/synonyms/preferred/";

// For Login
//		exports.serverConfigurationParams.configuration.userAuthenticationType = "Demo";
//		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "";
		exports.serverConfigurationParams.configuration.userAuthenticationType = "DNS";
		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "http://imapp01-d:8080/DNS/persons/v1/Persons/authenticate";
		exports.serverConfigurationParams.configuration.userInformationServiceURL = "http://imapp01-d:8080/DNS/persons/v1/Persons/";

// For Projects
//		exports.serverConfigurationParams.configuration.projectsType = "ACAS";
//		exports.serverConfigurationParams.configuration.projectsServiceURL = "http://tbd";
		exports.serverConfigurationParams.configuration.projectsType = "DNS";
		exports.serverConfigurationParams.configuration.projectsServiceURL = "http://imapp01-d:8080/DNS/codes/v1/Codes/Project.json";

// For core ETL work
		exports.serverConfigurationParams.configuration.appName = "ACAS";
		exports.serverConfigurationParams.configuration.db_driver = "JDBC('oracle.jdbc.driver.OracleDriver', '/opt/node_apps/acas/public/src/modules/GenericDataParser/src/server/ojdbc6.jar')";
		exports.serverConfigurationParams.configuration.db_user = "seurat";
		exports.serverConfigurationParams.configuration.db_password = "seurat";
		exports.serverConfigurationParams.configuration.db_name = "ORAPROD";
		exports.serverConfigurationParams.configuration.db_host = "dsanpora03.dart.corp";
		exports.serverConfigurationParams.configuration.db_port = "1521";
		exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
		exports.serverConfigurationParams.configuration.db_driver_package = "require(RJDBC)";
//// For racas
//		exports.serverConfigurationParams.configuration.appName = "ACAS";
//		exports.serverConfigurationParams.configuration.db_driver = "JDBC('oracle.jdbc.driver.OracleDriver', 'public/src/modules/GenericDataParser/src/server/ojdbc6.jar')";
//		exports.serverConfigurationParams.configuration.db_user = "ACAS";
//		exports.serverConfigurationParams.configuration.db_password = "2Ydudu8$pD";
//		exports.serverConfigurationParams.configuration.db_name = "ORADEV";
//		exports.serverConfigurationParams.configuration.db_host = "***REMOVED***";
//		exports.serverConfigurationParams.configuration.db_port = "1521";
//		exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
//		exports.serverConfigurationParams.configuration.db_driver_package = "require(RJDBC)";
// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://acas-d/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://acas-d:3838"

// For generic data parser


		})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
