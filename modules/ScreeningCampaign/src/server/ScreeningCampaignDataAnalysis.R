runAnalyzeScreeningCampaign <- function(experimentCode, user, dryRun, testMode, inputParameters, 
                                        primaryExperimentCodes, confirmationExperimentCodes) {
  experiment <- getExperimentByCodeName("EXPT-00014365")
  primaryExperimentCodes <- fromJSON("[\"EXPT-00012918\",\"EXPT-00012374\"]")
  confirmationExperimentCodes <- fromJSON("[]")
  inputParameters <- fromJSON("{\"signalDirectionRule\":\"decreasing\",\"aggregateBy\":\"entire assay\",\"aggregationMethod\":\"mean\",\"normalization\":{\"normalizationRule\":\"none\"},\"transformationRuleList\":[{\"transformationRule\":\"percent efficacy\"}],\"hitEfficacyThreshold\":null,\"hitSDThreshold\":null,\"thresholdType\":null,\"useOriginalHits\":false,\"autoHitSelection\":false}")
  
  # ACASDEV-758: get data for linked experiments
  library(plyr)
  library(data.table)
  allData1 <- ldply(primaryExperimentCodes, function(codeName) {
    exptQuery <- paste0("select e.code_name as EXPT_CODE, eag.ANALYSIS_GROUP_ID, atg.treatment_group_id, s.id as SUBJECT_ID, 
    ss.ls_type_and_kind as SUB_STATE_TYPE_AND_KIND, sv.id as SUB_VALUE_ID, sv.ls_kind as VALUE_KIND, sv.ls_type as VALUE_TYPE, 
                        sv.code_value, sv.numeric_value, sv.string_value, 
                        sv.unit_kind, sv.concentration, sv.conc_unit
                        from experiment e
                        JOIN experiment_analysisgroup eag ON eag.experiment_id=e.id
                        left outer join analysis_group ag on ag.id = eag.ANALYSIS_GROUP_ID and ag.ignored = '0'
                        left outer join analysisgroup_treatmentgroup atg on atg.ANALYSIS_GROUP_ID = ag.id
                        left outer join treatment_group tg on tg.id = atg.treatment_group_id and tg.ignored = '0'
                        left outer join treatmentgroup_subject tgs on tgs.treatment_group_id = tg.id
                        left outer join subject s on s.id = tgs.subject_id and s.ignored = '0'
                        left outer join subject_state ss on ss.subject_id = s.id and ss.ignored = '0'
                        left outer join subject_value sv on sv.subject_state_id = ss.id and sv.ignored = '0'
                        where e.code_name ='", codeName, "'")
    return(query(exptQuery))
  })
  
  allData1 <- as.data.table(allData1)
  setnames(allData1, toupper(names(allData1)))
  allData1[, combinedTypeAndKind := paste0(SUB_STATE_TYPE_AND_KIND, "_", VALUE_KIND)]
  
  # TODO: pivot data, makeWideData is close to what to do
  wideData1 <- makeWideData(allData1)
  
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

makeWideData <- function(exptDT) {
  # Changes from database input to input for fitting as a data.table
  library('reshape2')
  
  neededDT <- exptDT[, list(EXPT_CODE, combinedTypeAndKind, SUBJECT_ID, VALUE_TYPE, VALUE_KIND, CODE_VALUE, NUMERIC_VALUE, STRING_VALUE, CONCENTRATION, CONC_UNIT)]
  
  numericRows <- neededDT[VALUE_TYPE == "numericValue", list(EXPT_CODE, combinedTypeAndKind, SUBJECT_ID, NUMERIC_VALUE)]
  stringRows <- neededDT[VALUE_TYPE == "stringValue", list(EXPT_CODE, combinedTypeAndKind, SUBJECT_ID, STRING_VALUE)]
  codeRows <- neededDT[VALUE_TYPE == "codeValue" & VALUE_KIND != "batch code", list(EXPT_CODE, SUBJECT_ID, combinedTypeAndKind, CODE_VALUE)]
  batchCodeRows <- neededDT[VALUE_TYPE == "codeValue" & VALUE_KIND == "batch code", list(EXPT_CODE, SUBJECT_ID, combinedTypeAndKind, CODE_VALUE, CONCENTRATION, CONC_UNIT)]
  
  wideNumeric <- reshape(numericRows, v.names = "NUMERIC_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  wideString <- reshape(stringRows, v.names = "STRING_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  wideCode <- reshape(codeRows, v.names = "CODE_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  wideBatchCode <- reshape(batchCodeRows, v.names = "CODE_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  
  combined <- merge(wideNumeric, wideString, by = c("SUBJECT_ID", "EXPT_CODE"))
  combined <- merge(combined, wideCode, by = c("SUBJECT_ID", "EXPT_CODE"))
  combined <- merge(combined, wideBatchCode, by = c("SUBJECT_ID", "EXPT_CODE"))
  setnames(combined, 
           c("EXPT_CODE", "NUMERIC_VALUE.data_results_normalized activity", 
             "NUMERIC_VALUE.data_results_transformed standard deviation", 
             "NUMERIC_VALUE.data_results_efficacy", "STRING_VALUE.metadata_plate information_well name", 
             "STRING_VALUE.metadata_plate information_well type",
             "STRING_VALUE.data_user flag_comment", 
             "CODE_VALUE.metadata_plate information_barcode", "CODE_VALUE.data_auto flag_flag status", 
             "CODE_VALUE.data_auto flag_flag observation", "CODE_VALUE.data_auto flag_flag cause", 
             "CODE_VALUE.data_user flag_flag status", 
             "CODE_VALUE.data_user flag_flag observation", "CODE_VALUE.data_user flag_flag cause", 
             "CONCENTRATION", "CONC_UNIT", "CODE_VALUE.data_results_batch code"), 
           c("experimentCode", "normalizedActivity", "transformed_sd", "transformed_percent efficacy", 
             "well", "wellType", "flagComment", "assayBarcode", "autoFlagType", "autoFlagObservation", 
             "autoFlagReason", "flagType", "flagObseration", "flagReason", "concentration", "concUnit", "batchCode"))
  return(as.data.table(combined))
}

getPlateOrderForExperiment <- function(experimentCode) {
  
  
  #download.file(getAcasFileLink(experimentFolderPath$fileValue), newPath)
}

downloadAcasFile <- function(fileValue, newFilePath) {
  newPath <- tempfile("plateAnalysisInput", fileext = ".zip")
  if (exists(customFileDownload)) {
    fileInfo <- fromJSON(getURLcheckStatus(paste0(getAcasFileLink(experimentFolderPath$fileValue), "/metadata.json")))
    file.copy(fileInfo[[1]]$dnsFile$path, newPath)
  } else {
    download.file(getAcasFileLink(experimentFolderPath$fileValue), newPath)
  }
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
