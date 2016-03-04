parseGenericData <- function(request) {
	hasError <- FALSE
	errorMessages <- list()
	transactionId <- NULL
	request <- as.list(request)
	fileName <- request$fileToParse
	reportFileName <- request$reportFile
	cat(request$testMode)
	dryRun <- request$dryRunMode
	if (grepl("unhandled_error", fileName, fixed = TRUE)) {
	  stop("unhandled R error")
	}
	if (grepl("with_error", fileName, fixed = TRUE))  {
		hasError <- TRUE
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

	if (as.logical(dryRun)==FALSE) {
	    response$results$experimentCode = "EXPT-000001"
	    #Only needs to be returned in the case that dose response analysis is run after (not during generic loads)
	    response$results$renderingHint = "4 parameter D-R"
	}

	return(response)

}

