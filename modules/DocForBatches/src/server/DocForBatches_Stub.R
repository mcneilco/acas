saveDocForBatches <- function(request) {
	error <- FALSE
	errorMessages <- list()
	transactionId = 1

	batch1 <- request$docForBatches$batchNameList[[1]]
	if (batch1[[3]] =="" ) {
		error = TRUE
		errorMessages <- c(errorMessages, list(list(errorLevel="error", message="Batch none_1234::1 does not exist")))
		transactionId = NULL
	}
	response <- list(
		commit= FALSE,
		transactionId= transactionId,
		results= list(
			id= transactionId
		),
		error= error,
		errorMessages= errorMessages
	)
	return( response)

}

