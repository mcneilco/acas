
fitDoseResponse <- function(request){
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
    transactionId <- 1
  request <- as.list(request)
  inputParameters <- request$inputParameters
  status <- "complete"
  if (regexpr("fail", request$experimentCode)>0)  {
       hasError = TRUE
       errorMessages <- c(errorMessages, list(list(errorLevel="error", message="Input file not found")))
       transactionId <- NULL
       status <- "error"
   }

response <- list(
    transactionId= transactionId,
    results= list(
        htmlSummary= "<h2>fit summary goes here</h2><h3>More info</h3>",
        status= status
    ),
    hasError= hasError,
    hasWarning = FALSE,
    errorMessages= errorMessages
)

return( response)

}
