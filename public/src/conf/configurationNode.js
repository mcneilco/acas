(function() {

	(function(exports) {

		exports.serverConfigurationParams = {};
		exports.serverConfigurationParams.configuration = {};
		exports.serverConfigurationParams.configuration.serverName = "http://localhost";
		exports.serverConfigurationParams.configuration.portNumber = 3000;
		exports.serverConfigurationParams.configuration.fileServiceURL = "http://localhost:8888";
		exports.serverConfigurationParams.configuration.serverAddress = "ora.labsynch.com";
		exports.serverConfigurationParams.configuration.driver = "oracle.jdbc.driver.OracleDriver";
		exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/ojdbc6.jar";
		exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:oracle:thin:@";
		exports.serverConfigurationParams.configuration.databasePort = ":1521:osl";
		exports.serverConfigurationParams.configuration.username = "acas_dev";
		exports.serverConfigurationParams.configuration.password = "acas_dev_password";
		exports.serverConfigurationParams.configuration.serverPath = "http://suse.labsynch.com:8080/acas/";

// For preferred ID service
		exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://localhost:3000/api/preferredBatchId";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "LabSynchCmpdReg";
		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://host3.labsynch.com:8080/cmpdreg/metalots/corpName/";
//		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "SingleBatchNameQueryString";
//		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://dsanpimapp01:8080/DNS/core/v1/synonyms/preferred/";
//		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "Seurat";
//		exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "";

// For Login
		exports.serverConfigurationParams.configuration.userAuthenticationType = "Demo";
		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "";
//		exports.serverConfigurationParams.configuration.userAuthenticationType = "DNS";
//		exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "http://imapp01:8080/DNS/persons/v1/Persons/authenticate";

// For Projects
		exports.serverConfigurationParams.configuration.projectsType = "DNS";
		exports.serverConfigurationParams.configuration.projectsServiceURL = "http://dsanpimapp01:8080/DNS/core/v1/DNSCode/Project.json";

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

// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://suse.labsynch.com/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://suse.labsynch.com:3838";
		
// For generic data parser
		exports.serverConfigurationParams.configuration.projectService = "http://suse.labsynch.com:8080/a/project/service";
		exports.serverConfigurationParams.configuration.fileServiceType = "blueimp";
		exports.serverConfigurationParams.configuration.fileService = "http://suse.labsynch.com:8080/a/file/service"


	})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
