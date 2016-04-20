analyzeScreeningCampaign <- function(request) {
	hasError <- FALSE
	errorMessages <- list()
	transactionId = NULL
	request <- as.list(request)
	user <- request$user
    experimentCode <- request$experimentCode
    inputParameters <- request$inputParameters
    primaryExperimentCodes <- request$primaryExperimentCodes
    confirmationExperimentCodes <- request$confirmationExperimentCodes

	response <- list(
		commit= FALSE,
		transactionId= transactionId,
		results= list(
			htmlSummary= paste("<h2>Analysis Successful</h2><h3>Screening Campaign results go here.</h3> Primary Experiment Codes: ",primaryExperimentCodes," Confirmation Experiment Codes: ", confirmationExperimentCodes)
		),
		hasError= hasError,
		hasWarning = TRUE,
		errorMessages= errorMessages
	)

	return( response)

}
