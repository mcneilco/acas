(function() {

	(function(exports) {

		exports.serverConfigurationParams = {};
		exports.serverConfigurationParams.configuration = {}
		exports.serverConfigurationParams.configuration.serverName = "http://localhost"
		exports.serverConfigurationParams.configuration.portNumber = 3000
		exports.serverConfigurationParams.configuration.fileServiceURL = "http://localhost:8888"
		exports.serverConfigurationParams.configuration.serverAddress = "host3.labsynch.com"
		exports.serverConfigurationParams.configuration.driver = "org.postgresql.Driver"
		exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/postgresql-9.1-901.jdbc3.jar"
		exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:postgresql://"
		exports.serverConfigurationParams.configuration.databasePort = ":5432/compound"
		exports.serverConfigurationParams.configuration.username = "labseer"
		exports.serverConfigurationParams.configuration.password = "labseer"
		exports.serverConfigurationParams.configuration.serverPath = "http://host3.labsynch.com:8080/acas/"
		exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://localhost:3000/api/preferredBatchId"

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
		exports.serverConfigurationParams.configuration.db_driver = "JDBC('org.postgresql.Driver', 'public/src/modules/GenericDataParser/src/server/postgresql-9.1-901.jdbc3.jar')";
		exports.serverConfigurationParams.configuration.db_user = "labseer";
		exports.serverConfigurationParams.configuration.db_password = "labseer";
		exports.serverConfigurationParams.configuration.db_name = "compound";
		exports.serverConfigurationParams.configuration.db_host = "host3.labsynch.com";
		exports.serverConfigurationParams.configuration.db_port = "5432";
		exports.serverConfigurationParams.configuration.stringsAsFactors = "FALSE";
		exports.serverConfigurationParams.configuration.db_driver_package = "require(RJDBC)";

// For R curve curation
		exports.serverConfigurationParams.configuration.rapache = "http://suse.labsynch.com/r-services-api";
		exports.serverConfigurationParams.configuration.rshiny = "http://suse.labsynch.com:3838";

// For generic data parser
		exports.serverConfigurationParams.configuration.projectService = "http://dsanpimapp01:8080/DNS/core/v1/DNSCode/Project.json";
//		exports.serverConfigurationParams.configuration.fileServiceType = "DNS";
		exports.serverConfigurationParams.configuration.fileServiceType = "blueimp";
		exports.serverConfigurationParams.configuration.externalFileService = "http://dsandimapp01:8080/DNS/core/v1/DNSFile"


	})((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);
