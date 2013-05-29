(function() {

        (function(exports) {

                exports.serverConfigurationParams = {};
                exports.serverConfigurationParams.configuration = {};
                exports.serverConfigurationParams.configuration.serverName = "http://acas-d.dart.corp"
                exports.serverConfigurationParams.configuration.portNumber = 3000
                exports.serverConfigurationParams.configuration.fileServiceURL = "http://acas-d.dart.corp:8888"
                exports.serverConfigurationParams.configuration.serverAddress = "acas-d.dart.corp"
                exports.serverConfigurationParams.configuration.driver = "oracle.jdbc.driver.OracleDriver"
                exports.serverConfigurationParams.configuration.driverLocation = "public/src/modules/GenericDataParser/src/server/ojdbc6.jar"
                exports.serverConfigurationParams.configuration.databaseLocation = "jdbc:oracle:thin:@"
                exports.serverConfigurationParams.configuration.databasePort = ":1521:oradev"
                exports.serverConfigurationParams.configuration.username = "ACAS"
                exports.serverConfigurationParams.configuration.password = "2Ydudu8$pD"
                exports.serverConfigurationParams.configuration.serverPath = "http://acas-d.dart.corp:8080/acas/"
// For preferred ID service
                exports.serverConfigurationParams.configuration.preferredBatchIdService = "http://acas-d.dart.corp:3000/api/preferredBatchId"
                exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType = "SingleBatchNameQueryString";
                exports.serverConfigurationParams.configuration.externalPreferredBatchIdServiceURL = "http://dsanpimapp01:8080/DNS/core/v1/synonyms/preferred/";

// For Login
//                exports.serverConfigurationParams.configuration.userAuthenticationType = "Demo";
//                exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "";
              exports.serverConfigurationParams.configuration.userAuthenticationType = "DNS";
              exports.serverConfigurationParams.configuration.userAuthenticationServiceURL = "http://imapp01:8080/DNS/persons/v1/Persons/authenticate";

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
                exports.serverConfigurationParams.configuration.rapache = "http://acas-d.dart.corp/r-services-api";
                exports.serverConfigurationParams.configuration.rshiny = "http://acas-d.dart.corp:3838"

        })((typeof process === "undefined" || !process.versions ? window.configurationNode = window.configurationNode || {} : exports));

}).call(this);