
getExperimentDataForGenes <- function(request){
  # Needs a list:
  # dryRun
  # testMode
  # inputParameters:
  #   user
  #	  experimentCode
  #	  testMode
  #   inputParameters

  hasError <- FALSE
  errorMessages <- list()
  request <- as.list(request)
  if (request$page < 0)  {
       hasError = TRUE
       errorMessages <- c(errorMessages, list(list(errorLevel="error", message="Sort attribute not in the data")))
   }

response <- list(
    results= list(
        htmlSummary= "<h2>fit summary goes here</h2><h3>More info</h3>",
        data= c("res1", "res2", "res3")
    ),
    hasError= hasError,
    hasWarning = FALSE,
    errorMessages= errorMessages
)

return( response)

}
