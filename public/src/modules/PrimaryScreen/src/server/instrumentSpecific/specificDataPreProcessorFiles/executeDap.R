# executeDap.R

#require(rdap)


getInstrumentSpecificData <- function(filePath=".", instrument=NA_character_, readsTable, testMode=TRUE, errorEnv, tempFilePath=NULL, dryRun=TRUE, matchNames=FALSE) {
  
  originalWD <- getwd()
  require(racas)
  
  setwd(filePath)
  if(is.null(tempFilePath)) {
    if(testMode) {
      tempFilePath <- tempdir()
    } else {
      tempFilePath <- file.path("..", "analysis")
    }
  }
  
  checkAnalysisFiles(testMode=testMode, dryRun=dryRun)
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin executeDap\tfilePath=",filePath,"\ttestMode=",testMode), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  plateAssociationDT <- generateIniFile(filePath, tempFilePath, instrument)
  
  # keep this in this part of the code so that warnings can be relayed to user before uploading data
  userInputReadTable <- formatUserInputActivityColumns(readsTable=readsTable, activityColNames=unique(plateAssociationDT$dataTitle), tempFilePath=tempFilePath, matchNames=matchNames)
  
  ## TODO: dryRun should return "summaryInfo" here?

  assayData <- data.frame()
  assayData <- plateAssociationDT[ , parseAssayPlateFiles(assayFileName, unique(instrumentType), unique(plateAssociationDT$dataTitle), tempFilePath=tempFilePath), by=list(assayFileName, assayBarcode, plateOrder)]
  
  assayData <- adjustColumnsToUserInput(inputColumnTable=userInputReadTable, inputDataTable=assayData, tempFilePath=tempFilePath)

  setwd(Sys.getenv("ACAS_HOME"))
  
  return(list(plateAssociationDT=plateAssociationDT, assayData=assayData))
}





catchExecuteDap <- function(request) {
  # Example: 
  #   catchExecuteDap(list(filePath, testMode))
  #   catchExecuteDap(list(filePath="~/Documents/DAP MODULES/ArrayScan/TEST0001069/raw_data/",
  #                        testMode=FALSE))
  # Outputs a response with labels: 
  #   value (a list with numbers of analysis groups, treatment groups, and subjects to be uploaded)
  #   warningList (a character vector)
  #   errorList (a character vector)
  #   error (a boolean)
  
  #   # Set up high level needs
  #   require('compiler')
  #   enableJIT(3)
  options("scipen"=15)
  #   save(request, file="request.Rda")
  #   # This is used for outputting the JSON rather than sending it to the server
  #   developmentMode <- FALSE
  #
  # refactor to allow following JSON 2014-07-16
  
  require(racas)
  
#   request <- fromJSON('{\"filePath\":\"privateUploads/experiments/test/rawData\",\"instrument\":\"instrumentName\",\"readOrder\":[1,2,3],\"readName":[\"Fluorescence\",\"ValidNeuronCount\",\"ValidFieldCount\"],\"matchReadName\":true,\"testMode\":true,\"tempFilePath\":\"privateTempFiles/\"}')
  request <- fromJSON("{\"primaryAnalysisReads\":[{\"readOrder\":11,\"readName\":\"luminescence\",\"matchReadName\":true},{\"readOrder\":12,\"readName\":\"fluorescence\",\"matchReadName\":true},{\"readOrder\":13,\"readName\":\"other read name\",\"matchReadName\":false}],\"primaryScreenAnalysisParameters\":{\"positiveControl\":{\"batchCode\":\"CMPD-12345678-01\",\"concentration\":10,\"concentrationUnits\":\"uM\"},\"negativeControl\":{\"batchCode\":\"CMPD-87654321-01\",\"concentration\":1,\"concentrationUnits\":\"uM\"},\"agonistControl\":{\"batchCode\":\"CMPD-87654399-01\",\"concentration\":250753.77,\"concentrationUnits\":\"uM\"},\"vehicleControl\":{\"batchCode\":\"CMPD-00000001-01\",\"concentration\":null,\"concentrationUnits\":null},\"instrumentReader\":\"flipr\",\"signalDirectionRule\":\"increasing signal (highest = 100%)\",\"aggregateBy1\":\"compound batch concentration\",\"aggregateBy2\":\"median\",\"transformationRule\":\"(maximum-minimum)/minimum\",\"normalizationRule\":\"plate order\",\"hitEfficacyThreshold\":42,\"hitSDThreshold\":5,\"thresholdType\":\"sd\",\"transferVolume\":12,\"dilutionFactor\":21,\"volumeType\":\"dilution\",\"assayVolume\":24,\"autoHitSelection\":false,\"primaryAnalysisReadList\":[{\"readOrder\":11,\"readName\":\"luminescence\",\"matchReadName\":true},{\"readOrder\":12,\"readName\":\"fluorescence\",\"matchReadName\":true},{\"readOrder\":13,\"readName\":\"other read name\",\"matchReadName\":false}]},\"instrumentReaderCodes\":[{\"code\":\"flipr\",\"name\":\"FLIPR\",\"ignored\":false}],\"signalDirectionCodes\":[{\"code\":\"increasing signal (highest = 100%)\",\"name\":\"Increasing Signal (highest = 100%)\",\"ignored\":false}],\"aggregateBy1Codes\":[{\"code\":\"compound batch concentration\",\"name\":\"Compound Batch Concentration\",\"ignored\":false}],\"aggregateBy2Codes\":[{\"code\":\"median\",\"name\":\"Median\",\"ignored\":false}],\"transformationCodes\":[{\"code\":\"(maximum-minimum)/minimum\",\"name\":\"(Max-Min)/Min\",\"ignored\":false}],\"normalizationCodes\":[{\"code\":\"plate order\",\"name\":\"Plate Order\",\"ignored\":false},{\"code\":\"none\",\"name\":\"None\",\"ignored\":false}],\"readNameCodes\":[{\"code\":\"luminescence\",\"name\":\"Luminescence\",\"ignored\":false}]}")
  
  # Collect the information from the request
  request <- as.list(request)
  filePath <- request$filePath
  instrument <- request$instrument
  testMode <- request$testMode
  dryRun <- request$dryRunMode
  readOrder <- as.list(request$readOrder)
  readNames <- as.list(request$readName)
  matchNames <- request$matchReadName
  
  #   reportFilePath <- request$reportFile
  #   recordedBy <- request$user
  
  # Fix capitalization mismatch between R and javascript
  #   dryRun <- interpretJSONBoolean(dryRun)
  #   testMode <- interpretJSONBoolean(testMode)
  if(is.null(testMode)) {
    testMode <- TRUE
  }
  
  experiment <- NULL
  
  errorList <- list()
  errorEnv  <- environment()
  
  # Run the function and save output (value), errors, and warnings
  loadResult <- tryCatch.W.E(executeDap(filePath=filePath,
                                        instrument=instrument,
                                        readOrder=readOrder,
                                        testMode=testMode,
                                        errorEnv=errorEnv,
                                        tempFilePath=tempFilePath,
                                        dryRun=dryRun,
                                        readNames=readNames,
                                        matchNames=matchNames))
  print(loadResult)
  # If the output has class simpleError or is not a list, save it as an error
  if(class(loadResult$value)[1]=="simpleError") {
    errorList <- c(errorList,list(loadResult$value$message))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="SQLException")>0) {
    errorList <- c(errorList,list(paste0("There was an error in connecting to the SQL server ", 
                                         configList$server.database.host,configList$server.database.port, ":", 
                                         as.character(loadResult$value), ". Please contact your system administrator.")))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="error")>0 || class(loadResult$value)!="list") {
    errorList <- c(errorList,list(as.character(loadResult$value)))
    loadResult$value <- NULL
  }
  
  # Save warning messages but not the function call, which is only useful while programming
  loadResult$warningList <- lapply(loadResult$warningList,function(x) x$message)
  if (length(loadResult$warningList)>0) {
    loadResult$warningList <- strsplit(unlist(loadResult$warningList),"\n")
  }
  
  # Organize the error outputs
  loadResult$errorList <- errorList
  hasError <- length(errorList) > 0
  hasWarning <- length(loadResult$warningList) > 0
  
  errorMessages <- list()
  
  # This is code that could put the error and warning messages into a format that is displayed at the bottom of the screen
  for (singleError in errorList) {
    errorMessages <- c(errorMessages, list(list(errorLevel="error", message=singleError)))
  }
  
  for (singleWarning in loadResult$warningList) {
    errorMessages <- c(errorMessages, list(list(errorLevel="warning", message=singleWarning)))
  }
  #   
  #   errorMessages <- c(errorMessages, list(list(errorLevel="info", message=countInfo)))
  #   
  
  # Create the HTML to display
  htmlSummary <- createHtmlSummary(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value, dryRun)
  
  #   if(!dryRun) {
  #     htmlSummary <- saveAnalysisResults(experiment=experiment, hasError, htmlSummary, loadResult$value$lsTransactionId)
  #   }
  
  # Return the output structure
  response <- list(
    commit= (!hasError), # commit= (!dryRun & !hasError),
    transactionId = loadResult$value$lsTransactionId,
    results= list(
      path= getwd(),
      experimentCode= experiment$codeName,
      fileToParse= filePath
      #       dryRun= dryRun,
      #       htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}
