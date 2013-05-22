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
		exports.serverConfigurationParams.configuration.username = "seurat";
		exports.serverConfigurationParams.configuration.password = "seurat";
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


// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://suse.labsynch.com/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://suse.labsynch.com:3838"

	})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
