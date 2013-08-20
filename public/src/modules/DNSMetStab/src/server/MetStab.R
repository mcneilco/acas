source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

parseMetStabData <- function(request){
  # Needs a list:
  # dryRun
  # testMode
  # inputParameters:
  #   format
  #             protocolName
  #             scientist
  #             notebook
  #             project
  #             fileLocation
  request <- as.list(request)
  inputParameters <- request$inputParameters
  preProcessorCall <- tryCatch({
    require(dmpk)
	outputFileName <- paste0(request$fileToParse, "Processed.csv")
    response <- galileoToSEL(inputFilePath = request$fileToParse, outputFilePath = outputFileName, exptMetaData = inputParameters, logDir = racas::applicationSettings$logDir)
    list(completedSuccessfully = TRUE, preProcessorResponse = response)
  }, error = function(err) {
    return(list(completedSuccessfully = FALSE, preProcessorResponse = err$message))			
  })
  if(preProcessorCall$completedSuccessfully) {
    parserInput <- preProcessorCall$preProcessorResponse
    parserInput$dryRunMode <- request$dryRunMode
    parserInput$user <- request$user
    parserResponse <- parseGenericData(parserInput)
    if (!interpretJSONBoolean(request$dryRunMode)) {
    	experiment <- fromJSON(getURL(paste0(racas::applicationSettings$serverPath, "experiments/codename/", parserResponse$results$experimentCode)))[[1]]
    	moveFileToExperimentFolder(request$fileToParse, experiment, request$user, response$transactionId, 
                               racas::applicationSettings$fileServiceType, racas::applicationSettings$externalFileService)
  	}
    parserResponse$results <- c(parserResponse$results,preProcessorCall$preProcessorResponse)
    return(parserResponse)
  } else {
      htmlSummary = paste0("<h4>The custom pre-processor encountered an error during execution</h4>",
      						"<p>Please report the following error to your system administrator:</p>",
      						"<p>",preProcessorCall$preProcessorResponse,"</p>")
	  response <- list(
	   commit= FALSE,
	   transactionId = -1,
	   results= list(
		 path= getwd(),
		 fileToParse= NULL,
		 dryRun= request$dryRunMode,
		 htmlSummary= htmlSummary
	   ),
	   hasError= TRUE,
	   hasWarning= FALSE,
	   errorMessages= list(list(errorLevel="error", message=preProcessorCall$preProcessorResponse))
	   )
    return(response)
  }
}