runAnalyzeScreeningCampaign <- function(experimentCode, user, dryRun, testMode, inputParameters, 
                                        primaryExperimentCodes, confirmationExperimentCodes) {
  experiment <- getExperimentByCodeName("EXPT-00014365")
  primaryExperimentCodes <- fromJSON("[\"EXPT-00012918\",\"EXPT-00012374\"]")
  confirmationExperimentCodes <- fromJSON("[]")
  inputParameters <- fromJSON("{\"signalDirectionRule\":\"decreasing\",\"aggregateBy\":\"entire assay\",\"aggregationMethod\":\"mean\",\"normalization\":{\"normalizationRule\":\"none\"},\"transformationRuleList\":[{\"transformationRule\":\"percent efficacy\"}],\"hitEfficacyThreshold\":null,\"hitSDThreshold\":null,\"thresholdType\":null,\"useOriginalHits\":false,\"autoHitSelection\":false}")
  # ACASDEV-758: get data for linked experiments
#   allData1 <- ldply(primaryExperimentCodes, function(code) {
#     query("select data from table1 join table2")
#   })
  # ACASDEV-764: get data for confirmation
#   allData2 <- ldply(confirmationExperimentCodes, function(code) {
#     query("select data from table1 join table2")
#   })
  # allData <- rbind(allData1, allData2)
  
  
  # ACASDEV-759: get plate order
#   plateOrderVector <- lapply(primaryExperimentCodes, getPlateOrderForExperiment)
#   addPlateOrder(allData, plateOrderVector)
  
  # ACASDEV-763: make spotfire file, see saveReports.R for inspiration
  
  # ACASDEV-765: find list of confirmed compounds, looking at existing code for screening campaigns
  
  # ACASDEV-766: calculate confirmation rate out of set tested
  
  # ACASDEV-767: draw confirmation graph
  
  
  summaryInfo <- list(
    info = list(
      "Stuff done" = "Yes",
      "Primary Experiment Codes" = "Test"
    ), experiment = experiment
  )
}

getPlateOrderForExperiment <- function(experiment) {
  # In progress
  experiment <- getExperimentByCodeName(experiment)
  metadataStates <- getStatesByTypeAndKind(experiment, "metadata_experiment metadata")
  sourceFileValues <- getValuesByTypeAndKind(metadataStates[1], "codeValue_source file")
  fileLink <- getAcasFileLink(sourceFileValues[1])
  zipFile <- tempfile()
  download.file(fileLink, zipFile)
  targetFolder <- tempdir()
  unzip(exdir = targetFolder, zipfile = zipFile)
  # Then get plate order like it is done in PrimaryAnalysis.R and return
}

analyzeScreeningCampaign <- function(request) {
  # Highest level function, runs everything else 
  
  library('racas')
  globalMessenger <- messenger()$reset()
  globalMessenger$devMode <- FALSE
  save(request, file="request.Rda")
  
  request <- as.list(request)
  
  experimentCode <- request$experimentCode
  inputParameters <- request$inputParameters
  primaryExperimentCodes <- request$primaryExperimentCodes
  confirmationExperimentCodes <- request$confirmationExperimentCodes
  dryRun <- as.logical(request$dryRunMode)
  user <- request$user
  testMode <- as.logical(request$testMode)
  developmentMode <- globalMessenger$devMode
  
  if (developmentMode) {
    loadResult <- list(value = runAnalyzeScreeningCampaign(
      experimentCode, 
      user, 
      dryRun, 
      testMode, 
      inputParameters,
      primaryExperimentCodes,
      confirmationExperimentCodes))
  } else {
    loadResult <- tryCatchLog(runAnalyzeScreeningCampaign(
      experimentCode, 
      user, 
      dryRun, 
      testMode, 
      inputParameters,
      primaryExperimentCodes,
      confirmationExperimentCodes))
  }
  
  allTextErrors <- getErrorText(loadResult$errorList)
  warningList <- getWarningText(loadResult$warningList)
  
  # Organize the error outputs
  hasError <- length(allTextErrors) > 0
  hasWarning <- length(warningList) > 0
  
  errorMessages <- list()
  
  # This is code that could put the error and warning messages into a format that is displayed at the bottom of the screen
  errorMessages <- c(errorMessages, lapply(allTextErrors, function(x) {list(errorLevel="error", message=x)}))
  errorMessages <- c(errorMessages, lapply(warningList, function(x) {list(errorLevel="warning", message=x)}))
  #   errorMessages <- c(errorMessages, list(list(errorLevel="info", message=countInfo))) 
  
  # Create the HTML to display
  htmlSummary <- createHtmlSummary(hasError, allTextErrors, hasWarning, warningList, 
                                   summaryInfo=loadResult$value, dryRun)
  
  tryCatch({
    if(is.null(loadResult$value$experiment)) {
      experiment <- getExperimentById(experimentId)
    } else {
      experiment <- loadResult$value$experiment
    }
    saveAnalysisResults(experiment, hasError, htmlSummary, user, dryRun)
  }, error= function(e) {
    htmlSummary <- paste(htmlSummary, "<p>Could not get the experiment</p>")  
  })
  
  # Return the output structure
  response <- list(
    commit= (!dryRun & !hasError),
    transactionId = loadResult$value$lsTransactionId,
    results= list(
      path= getwd(),
      dryRun= dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}
