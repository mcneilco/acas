acasCmpdRegBatchCheck <- function(input) {
  require('RCurl')
  require('rjson')
  require('racas')

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.cmpdreg.batchCheck",
                         logFileName = 'batchCheck.log',
                         logLevel = "DEBUG", logToConsole = FALSE)

myMessenger$logger$debug("get batch check data initiated")
  inputRequests <- input$requests
  json <- toJSON(inputRequests)

myMessenger$logger$debug(json)



  configList <- racas::applicationSettings

  tryCatch({
	##cmpdreg/api/v1/getPreferredName"
		response <- fromJSON(getURL(
		  paste0(configList$server.service.external.preferred.batchid.url),
		  customrequest='POST',
		  httpheader=c('Accept'='application/json', 'Content-Type'='application/json'),
		  postfields=json))
  }, error = function(e) {
    stop(paste0("The ACAS Compound Batch validation service did not respond correctly, contact your system administrator. ", json))
  })

  return(list(
    error = FALSE,
    errorMessages = list(),
    results = response
  ))

}


