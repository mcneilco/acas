parseGenericData <- function(request) {
	hasError <- FALSE
	errorMessages <- list()
	transactionId = NULL
	fileName <- request[[1]]
	reportFileName <- request[[2]]
	cat (request[[2]])
	dryRun <- request[[3]]
#	dryRun <- request[[4]]
	if (regexpr("with_error", fileName)>0)  {
		hasError = TRUE
		errorMessages <- c(errorMessages, list(list(errorLevel="error", message="Input file not found")))
	}
	response <- list(
		commit= FALSE,
		transactionId= transactionId,
		results= list(
			path= getwd(),
			fileToParse= fileName,
			dryRun= dryRun,
			htmlSummary= "<h2>load summary goes here</h2><h3>More info</h3>"
		),
		hasError= hasError,
		hasWarning = TRUE,
		errorMessages= errorMessages
	)

	if(dryRun=="false") {
	    response$results$experimentCode = "EXPT-000001"
	}

	return( response)

}

