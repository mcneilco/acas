source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")
library(racas)

fitDoseResponse <- function(request){
  request <- as.list(request)
  simpleFitSettings <- fromJSON(request$inputParameters)
  experimentCode <- "EXPT-00000036"
  user <- request$user
  testMode <- as.logical(request$testMode)


  response <- api_doseResponse.experiment(simpleFitSettings, user, experimentCode, testMode)
  return( response)
}
