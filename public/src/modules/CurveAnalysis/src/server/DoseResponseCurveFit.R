library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- logger(logName = "com.acas.doseresponse.fit.experiment", logToConsole = FALSE)
myMessenger$logger$debug("dose response fit experiment initiated")

fitDoseResponse <- function(request){
  myMessenger <- Messenger$new()
  myMessenger$logger <- logger(logName = "com.acas.doseresponse.fit.experiment", logToConsole = FALSE)
  myMessenger$logger$debug("dose response fit experiment initiated")
  request <- as.list(request)
  myMessenger$logger$debug(toJSON(request))

  simpleFitSettings <- fromJSON(request$inputParameters)
  experimentCode <- request$experimentCode
  user <- request$user
  testMode <- as.logical(request$testMode)
  modelFitType <- request$modelFitType
  myMessenger$capture_output(response <- api_doseResponse_experiment(simpleFitSettings, modelFitType, user, experimentCode, testMode))
  return(response)
}
