source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

parseMicroSolData <- function(request){
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
    response <- pionToSEL(inputFilePath = request$fileToParse, outputFilePath = outputFileName, exptMetaData = inputParameters, logDir = racas::applicationSettings$server.log.path)
    list(completedSuccessfully = TRUE, preProcessorResponse = response)
  }, error = function(err) {
    return(list(completedSuccessfully = FALSE, preProcessorResponse = err$message))			
  })
  if(preProcessorCall$completedSuccessfully) {
    parserInput <- preProcessorCall$preProcessorResponse
    parserInput$dryRunMode <- request$dryRunMode
    parserInput$user <- request$user
    parserResponse <- parseGenericData(parserInput)
    tryCatch({
      if (!interpretJSONBoolean(request$dryRunMode)) {
        experiment <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/codename/", 
                                             parserResponse$results$experimentCode)))[[1]]
        moveFileToExperimentFolder(request$fileToParse, experiment, request$user, response$transactionId, 
                                   racas::applicationSettings$server.service.external.file.type,
                                   racas::applicationSettings$server.service.external.file.service.url)
      }
    }, error = function(e) {
      parserResponse$results$htmlSummary = paste0(
        parserResponse$results$htmlSummary,
        "<h4>The custom pre-processor encountered an error during execution</h4>",
        "<p>The source file could not be saved</p>")
    })
    parserResponse$results <- c(parserResponse$results,preProcessorCall$preProcessorResponse)
    return(parserResponse)
  } else {
      htmlSummary = paste0("<h4>The custom pre-processor encountered an error during execution</h4>",
      						"<p>Please report the following error to your system administrator:</p>",
      						"<p>",preProcessorCall$preProcessorResponse,"</p>")
	  response <- list(
	   commit= FALSE,
	   transactionId = NULL,
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