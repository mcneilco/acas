(function() {

        (function(exports) {

                exports.serverConfigurationParams = {};
                exports.serverConfigurationParams.configuration = {};
                exports.serverConfigurationParams.configuration.serverName = "http://acas-d";
                exports.serverConfigurationParams.configuration.portNumber = 3000;
                exports.serverConfigurationParams.configuration.fileServiceURL = "http://acas-d:8888";
				exports.serverConfigurationParams.configuration.serverRelativeFilePath = "serverOnlyModules/blueimp-file-upload-node/public/files/";
                exports.serverConfigurationParams.configuration.serverAddress = "acas-d";
                exports.serverConfigurationParams.configuration.driver = "oracle.jdbc.driver.OracleDriver";
                exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/ojdbc6.jar";
                exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:oracle:thin:@";
                exports.serverConfigurationParams.configuration.databasePort = ":1521:oradev";
                exports.serverConfigurationParams.configuration.username = "ACAS";
                exports.serverConfigurationParams.configuration.password = "2Ydudu8$pD";
                exports.serverConfigurationParams.configuration.serverPath = "http://acas-d:8080/acas/";
// For preferred ID service
                exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://acas-d:3000/api/preferredBatchId";
                exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "SingleBatchNameQueryString";
                exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://dsanpimapp01:8080/DNS/core/v1/synonyms/preferred/";

// For Login
//                exports.serverConfigurationParams.configuration.userAuthenticationType = "Demo";
//                exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "";
				exports.serverConfigurationParams.configuration.userAuthenticationType = "DNS";
				exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "http://imapp01:8080/DNS/persons/v1/Persons/authenticate";

// For Projects
//		exports.serverConfigurationParams.configuration.projectsType = "ACAS";
//		exports.serverConfigurationParams.configuration.projectsServiceURL = "http://tbd";
				exports.serverConfigurationParams.configuration.projectsType = "DNS";
				exports.serverConfigurationParams.configuration.projectsServiceURL = "http://dsanpimapp01:8080/DNS/core/v1/DNSCode/Project.json";

// For racas
                exports.serverConfigurationParams.configuration.appName = "ACAS";
                exports.serverConfigurationParams.configuration.db_driver = "Oracle()";
                exports.serverConfigurationParams.configuration.db_user = "ACAS";
                exports.serverConfigurationParams.configuration.db_password = "2Ydudu8$pD";
                exports.serverConfigurationParams.configuration.db_name = "ORADEV";
                exports.serverConfigurationParams.configuration.db_host = "***REMOVED***";
                exports.serverConfigurationParams.configuration.db_port = "1521";
                exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
                exports.serverConfigurationParams.configuration.db_driver_package = "require(ROracle)";

// For R curve curation
				exports.serverConfigurationParams.configuration.rapache = "http://acas-d/r-services-api";
				exports.serverConfigurationParams.configuration.rshiny = "http://acas-d:3838";

// For generic data parser
				exports.serverConfigurationParams.configuration.projectService = "http://acas-d:3000/api/projects";
		       exports.serverConfigurationParams.configuration.fileServiceType = "DNS";
//		       exports.serverConfigurationParams.configuration.fileServiceType = "blueimp";
		       exports.serverConfigurationParams.configuration.externalFileService = "http://dsandimapp01:8080/DNS/core/v1/DNSFile";
		       exports.serverConfigurationParams.configuration.stateGroupsScript = "public/src/conf/genericDataParserConfiguration.R";
		       exports.serverConfigurationParams.configuration.includeProject = "TRUE";
		       exports.serverConfigurationParams.configuration.reportRegistrationURL = "http://dsandimapp01:8080/DNS/core/v1/DNSAnnotation";
		       exports.serverConfigurationParams.configuration.allowProtocolCreationWithFormats = ""
		       
        })((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
