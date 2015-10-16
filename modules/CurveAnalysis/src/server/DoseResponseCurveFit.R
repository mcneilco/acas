library(racas)
library(data.table)
myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.doseresponse.fit.experiment", logToConsole = FALSE)
myMessenger$logger$debug("dose response fit experiment initiated")

fitDoseResponse <- function(request){
  myMessenger <- Messenger$new()
  myMessenger$logger <- logger(logName = "com.acas.doseresponse.fit.experiment", logToConsole = FALSE)
  myMessenger$logger$debug("dose response fit experiment initiated")
  request <- as.list(request)
  myMessenger$logger$debug(paste0("request <- ",paste0(capture.output(dput(request)), collapse = "\n")))

  simpleFitSettings <- fromJSON(request$inputParameters)
  experimentCode <- request$experimentCode
  user <- request$user
  testMode <- as.logical(request$testMode)
  modelFitType <- request$modelFitType
  modelFit <- racas::get_model_fit_from_type_code(modelFitType)
  myMessenger$capture_output(response <- api_doseResponse_experiment(simpleFitSettings, modelFitType, user, experimentCode, testMode, modelFit))
  return(response)
}
