
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

parseFullPKData <- function(request){
  # Needs a list:
  # fileToParse
  # reportFile
  # dryRunMode
  # user
  # inputParameters:
  #   format
  #		protocolName
  #		experimentName
  #		scientist
  #		notebook
  #		inLifeNotebook
  #		assayDate
  #		project
  #		bioavailability
  #		aucType
  #
  # format is set as "In Vivo Full PK"
  require(racas)
  require(RCurl)
  require(rjson)
  
  request <- as.list(request)
  inputParameters <- request$inputParameters
  inputParameters$assayDate <- as.Date(inputParameters$assayDate, format="%s")
  inputParameters <- c(experimentMetaData = "", inputParameters)
  bioavailabilityIndex <- which(names(inputParameters)=="bioavailability")
  inputParameters <- c(inputParameters[1:bioavailabilityIndex - 1], list("", "rawData"=""), inputParameters[bioavailabilityIndex:length(inputParameters)])
  preProcessorCall <- tryCatch({
    source("public/src/modules/FullPK/src/server/fullPKPreprocessing.R")
    response <- list(fileToParse = preprocessPK(request$fileToParse, inputParameters))
    list(completedSuccessfully = TRUE, preProcessorResponse = response)
  }, error = function(err) {
    return(list(completedSuccessfully = FALSE, preProcessorResponse = err$message))			
  })
  
  if(preProcessorCall$completedSuccessfully) {
    parserInput <- preProcessorCall$preProcessorResponse
    parserInput$dryRunMode <- request$dryRunMode
    parserInput$user <- request$user
    parserInput$reportFile <- request$reportFile
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
# Testing code
#   #request <- list(user="smeyer", dryRunMode = "true", "fileToParse"="public/src/modules/FullPK/spec/specFiles/Worksheet.xls", reportFile="~/Desktop/new.txt")
#   request <- list(user="smeyer", dryRunMode = "false", fileToParse="~/Documents/clients/DNS/PK/PK514v3.xls", reportFile="serverOnlyModules/blueimp-file-upload-node/public/files/Input v6.xls")
#   request$inputParameters <- list("format"="In Vivo Full PK","protocolName"="PK Protocol 1",scientist="Sam","experimentName"="PK experiment 8","notebook"="SAM-000123", "inLifeNotebook"="LIFE-123","assayDate"="1370822400000","project"="UNASSIGNED","bioavailability"="42.3","aucType"="AUC-0")
#   parseFullPKData(request)
# # 
