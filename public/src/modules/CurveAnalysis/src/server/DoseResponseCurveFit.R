library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- logger(logName = "com.acas.doseresponse.fit.experiment", logToConsole = FALSE)
myMessenger$logger$debug("dose response fit experiment initiated")

fitDoseResponse <- function(request){
  myMessenger$logger$debug("got here man")
  saveSession("~/Desktop/blahl")
  request <- as.list(request)
  myMessenger$logger$debug(toJSON(request))

  simpleFitSettings <- fromJSON(request$inputParameters)
  experimentCode <- request$experimentCode
  user <- request$user
  testMode <- as.logical(request$testMode)

  response <- api_doseResponse.experiment(simpleFitSettings, user, experimentCode, testMode)
  return( response)
}
