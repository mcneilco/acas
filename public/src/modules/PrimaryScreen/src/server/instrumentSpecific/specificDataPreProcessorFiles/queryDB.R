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

sqlQuery <- function(queryString='sql query', host='***REMOVED***', port='1521', sid='ORATEST', ***REMOVED***, ***REMOVED***){
  require(RJDBC)
  jdbcDriverJar  <- file.path("public/src/modules/PrimaryScreen/spec/RTestSet/docs", "ojdbc6.jar")  
  drv <- JDBC('oracle.jdbc.driver.OracleDriver', jdbcDriverJar);
  jdbcURL <- paste0('jdbc:oracle:thin:@', host, ':', port, ':', sid)
  conn<- dbConnect(drv, jdbcURL, userName, userPassword);
  results <- dbGetQuery(conn, queryString)
  dbDisconnect(conn)

  return(results)
}
