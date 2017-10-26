#input <- "{\"requests\":[{\"requestName\":\"CRA-025995-1\"},{\"requestName\":\"CMPD-0000052-01\"}]}"

acasGeneCodeCheck <- function(input) {
  require('RCurl')
  require('jsonlite')
  require('rjson')
  require('racas')


myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.geneCodeCheck",
                         logFileName = 'geneData.log',
                         logLevel = "DEBUG", logToConsole = FALSE)

myMessenger$logger$debug("acasGeneCodeCheck initiated")
myMessenger$logger$debug(input)
#, simplifyDataFrame=FALSE

  jsonInput <- rjson::fromJSON(input)
  jsonRequest <- rjson::toJSON(jsonInput$requests)

myMessenger$logger$debug(jsonRequest)

  configList <- racas::applicationSettings
# "localhost:8080/acas/lsthings/getGeneCodeNameFromNameRequest",

  tryCatch({
	response <- jsonlite::fromJSON(getURL(
	  paste0(configList$client.service.persistence.fullpath, "lsthings/getGeneCodeNameFromNameRequest"),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=jsonRequest))
  }, error = function(e) {
    stop(paste0("The Gene codeName service did not respond correctly, contact your system administrator. ", json))
  })

    return(response)
}

