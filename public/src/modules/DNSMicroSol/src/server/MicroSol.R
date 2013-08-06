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
    response <- pionToSEL(inputFilePath = request$fileToParse, outputFilePath = "output.csv", exptMetaData = inputParameters, logDir = racas::applicationSettings$logDir)
    list(completedSuccessfully = TRUE, preProcessorResponse = response)
  }, error = function(err) {
    return(list(completedSuccessfully = FALSE, preProcessorResponse = err$message))			
  })
  if(preProcessorCall$completedSuccessfully) {
    parserInput <- preProcessorCall$preProcessorResponse
    parserInput$dryRunMode <- request$dryRunMode
    parserInput$user <- request$user
    parserResponse <- parseGenericData(parserInput)
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

# Testing codepaste0("There was an error in the custom pre-processor:", preProcessorResponse$response)
#request <- list(user="bbolt", dryRunMode = "true", "fileToParse"="inst/docs/2013yyy_usol_xxxxx.csv")
#request$inputParameters <- list("protocolName"="ADME_uSol_Kinetic_Solubility",scientist="bbolt","notebook"="BB-000123","project"="UNASSIGNED")
#response <- parseMicroSolData(request)
## 
