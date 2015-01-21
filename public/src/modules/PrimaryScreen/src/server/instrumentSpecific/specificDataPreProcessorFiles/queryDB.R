# queryDB.R
#
#
# Guy Oshiro
# guy@mcneilco.com
# Copyright 2013 John McNeil & Co. Inc.
#######################################################################################
# Get info from the database
# simple DB connection script
# could expand to more robust racas version
#######################################################################################

sqlQuery <- function(queryString='sql query', host='***REMOVED***', port='1521', sid='ORADEV', ***REMOVED***, ***REMOVED***){
  connectionInfo <- list(server.database.r.driver = racas::applicationSettings$server.database.r.driver,
                         server.database.host = host,
                         server.database.port = port,
                         server.database.name = sid,
                         server.database.username = userName,
                         server.database.password = userPassword)
  tryCatch({
    conn <- getDatabaseConnection(connectionInfo)
  }, error = function(e) {
    # This section for local development when it may be easier to use JDBC rather than other drivers
    library(RJDBC)
    jdbcDriverJar  <- file.path("public/src/modules/PrimaryScreen/spec/RTestSet/docs", "ojdbc6.jar")  
    connectionInfo$server.database.r.driver <- "JDBC('oracle.jdbc.driver.OracleDriver', jdbcDriverJar)"
    conn <- getDatabaseConnection(connectionInfo)
  })
  on.exit({DBI::dbDisconnect(conn)})
  #conn<- dbConnect(drv, jdbcURL, userName, userPassword);
  results <- query(queryString, conn = conn)
  #dbDisconnect(conn)

  return(results)
}
