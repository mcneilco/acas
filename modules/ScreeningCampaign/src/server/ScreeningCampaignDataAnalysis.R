runAnalyzeScreeningCampaign <- function(experimentCode, user, dryRun, testMode, inputParameters, 
                                        primaryExperimentCodes, confirmationExperimentCodes) {
  
  summaryInfo <- list()
  lsTransaction <- createLsTransaction()$id
  experiment <- getExperimentByCodeName(experimentCode)
  saveInputParameters(inputParameters, experiment, lsTransaction, user)
  
  primaryExperimentCodes <- fromJSON(primaryExperimentCodes)
  confirmationExperimentCodes <- fromJSON(confirmationExperimentCodes)
  inputParameters <- fromJSON(inputParameters)
  #experiment <- getExperimentByCodeName("EXPT-00014365")
  #primaryExperimentCodes <- fromJSON("[\"EXPT-00012918\",\"EXPT-00012374\"]")
  #confirmationExperimentCodes <- fromJSON("[\"EXPT-00014387\"]")
  #inputParameters <- fromJSON("{\"signalDirectionRule\":\"decreasing\",\"aggregateBy\":\"entire assay\",\"aggregationMethod\":\"mean\",\"normalization\":{\"normalizationRule\":\"none\"},\"transformationRuleList\":[{\"transformationRule\":\"percent efficacy\"}],\"hitEfficacyThreshold\":null,\"hitSDThreshold\":null,\"thresholdType\":null,\"useOriginalHits\":false,\"autoHitSelection\":false}")
  
  # ACASDEV-758: get data for linked experiments
  library(plyr)
  library(data.table)

  wideDataPrimary <- getExperimentData(primaryExperimentCodes)
  # ACASDEV-759: get plate order
  primaryPlateOrderFrame <- ldply(primaryExperimentCodes, getPlateOrderForExperiment)
  wideDataPrimary <- merge(wideDataPrimary, as.data.table(primaryPlateOrderFrame), all.x = TRUE, by = c("experimentCode", "assayBarcode"))
  wideDataPrimary[, compoundName := getCompoundName(batchCode)]
  if (length(confirmationExperimentCodes) > 0) {
    wideDataConf <- getExperimentData(confirmationExperimentCodes)
    confPlateOrderFrame <- ldply(confirmationExperimentCodes, getPlateOrderForExperiment)
    wideDataConf <- merge(wideDataConf, as.data.table(confPlateOrderFrame), all.x = TRUE, by = c("experimentCode", "assayBarcode"))
    wideDataConf[, compoundName := getCompoundName(batchCode)]
    wideDataAll <- rbind(wideDataPrimary, wideDataConf, fill = TRUE)
  } else {
    wideDataAll <- copy(wideDataPrimary)  # Need to copy as wideDataAll column names are changed for spotfire file
  }
  
  
  # ACASDEV-763: make spotfire file, see saveReports.R for inspiration
  dir.create(getUploadedFilePath(file.path("experiments", experiment$codeName)), showWarnings = FALSE, recursive = TRUE)
  if (dryRun) {
    reportLocation <- file.path("experiments", experiment$codeName, "dryrun")
  } else {
    reportLocation <- file.path("experiments", experiment$codeName, "analysis")
  }
  dir.create(getUploadedFilePath(reportLocation), showWarnings = FALSE)
  source("src/r/ServerAPI/customFunctions.R", local = TRUE)
  source("src/r/PrimaryScreen/compoundAssignment/exampleClient/saveReports.R", local = TRUE)
  source("src/r/PrimaryScreen/compoundAssignment/exampleClient/saveSpotfireFile.R", local = TRUE)
  source("src/r/PrimaryScreen/PrimaryAnalysis.R", local = TRUE)
  library(RCurl)
  # calculate row and column
  wideDataAll[, row := getRowName(well)]
  wideDataAll[, column := getColumnName(well)]
  # calculate z prime
  source("src/r/PrimaryScreen/compoundAssignment/exampleClient/performCalculations.R", local = TRUE)
  wideDataAll[, zPrime := computeZPrime(
    positiveControls=wideDataAll[wellType == "PC" & (is.na(flagType) | (flagType != "knocked out")), normalizedActivity],
    negativeControls=wideDataAll[wellType == "NC" & (is.na(flagType) | (flagType != "knocked out")), normalizedActivity])]
  computeZPrimeByPlate2 <- function(mainData) {
    positiveControls <- mainData[wellType == "PC" & (is.na(flagType) | (flagType != "knocked out")), normalizedActivity]
    negativeControls <- mainData[wellType == "NC" & (is.na(flagType) | (flagType != "knocked out")), normalizedActivity]
    return(computeZPrime(positiveControls, negativeControls))
  }
  wideDataAll[, zPrimeByPlate := computeZPrimeByPlate2(.SD), by=assayBarcode]
  summaryInfo$reports <- saveReports(NULL, wideDataAll, saveLocation=reportLocation, experiment, inputParameters, user, 
                                           customSourceFileMove=customSourceFileMove, skipFileText=TRUE)
  for (singleReport in summaryInfo$reports) {
    summaryInfo$info[[singleReport$title]] <- paste0(
      '<a href="', singleReport$link, '" target="_blank" ',
      ifelse(singleReport$download, 'download', ''), '>', singleReport$title, '</a>')
  }
  
  totalTested <- length(unique(wideDataPrimary$compoundName))
  # ACASDEV-765: find list of confirmed compounds, looking at existing code for screening campaigns
  if (length(confirmationExperimentCodes) > 0) {
    wideDataConf <- as.data.table(wideDataConf)
    
    # Remove flagged points and get mean per compound and concentration
    confThreshDT <- wideDataConf[wellType=="test" & (is.na(flagType) | (flagType != "knocked out")), 
                                 list(SD = mean(transformed_sd, na.rm = TRUE), 
                                      efficacy = mean(get("transformed_percent efficacy"), na.rm = TRUE)), 
                                 by=list(compoundName, concentration)]
    
    # Remove flagged points and get mean per compound and concentration
    primaryThreshDT <- wideDataPrimary[wellType=="test" & (is.na(flagType) | (flagType != "knocked out")), 
                                       list(SD = mean(transformed_sd, na.rm = TRUE), 
                                            efficacy = mean(get("transformed_percent efficacy"), na.rm = TRUE)), 
                                       by=list(compoundName, concentration)]
    
    # Get max for each compound (could be at any concentration)
    maxConfThreshDT <- confThreshDT[, list(SD=max(SD), efficacy=max(efficacy)), by = compoundName]
    maxPrimaryThreshDT <- primaryThreshDT[, list(SD=max(SD), efficacy=max(efficacy)), by = compoundName]
    
    combinedDT <- merge(maxPrimaryThreshDT, maxConfThreshDT, by="compoundName")
    if (!inputParameters$autoHitSelection || is.null(inputParameters$thresholdType)) {
      maxConfThreshDT[, hit := FALSE]
      xLabel <- "Efficacy Primary"
      yLabel <- "Efficacy Confirmation"
      xValues <- combinedDT$efficacy.x
      yValues <- combinedDT$efficacy.y
      threshold <- NA
    } else if (inputParameters$thresholdType == "sd") {
      maxConfThreshDT[, hit := SD > inputParameters$hitSDThreshold]
      xLabel <- "SD Primary"
      yLabel <- "SD Confirmation"
      xValues <- combinedDT$SD.x
      yValues <- combinedDT$SD.y
      threshold <- inputParameters$hitSDThreshold
    } else if (inputParameters$thresholdType == "efficacy") {
      maxConfThreshDT[, hit := efficacy > inputParameters$hitEfficacyThreshold]
      xLabel <- "Efficacy Primary"
      yLabel <- "Efficacy Confirmation"
      xValues <- combinedDT$efficacy.x
      yValues <- combinedDT$efficacy.y
      threshold <- inputParameters$hitEfficacyThreshold
    }
    if (all(is.na(yValues))) {
      stopUser("Missing data for selected threshold type.")
    }
    
    # ACASDEV-766: calculate confirmation rate out of set tested
    # Get number of compounds confirmed
    totalConfirmed <- length(unique(maxConfThreshDT[hit == TRUE, compoundName]))
    totalRetested <- length(intersect(wideDataPrimary$compoundName, confThreshDT$compoundName))
    confirmationRate <- totalConfirmed / totalRetested * 100  # convert to percent
    
    # ACASDEV-767: draw confirmation graph
    # Each compound has an average for each concentration used, and then the max of those is chosen for the graph
    # The graph simply shows the max efficacy for SD
    plotTitle <- paste(confirmationExperimentCodes, collapse = ", ")
    xLim <- c(min(xValues), max(xValues))
    tempFile <- paste0(experimentCode, "Confirmation.png")
    png(getUploadedFilePath(tempFile))
    plot(xValues, yValues, main = plotTitle, xlab = xLabel, ylab = yLabel, 
         frame.plot = F, col="blue", pch=15, cex=0.8)
    if (!is.na(threshold)) {
      lines(xLim, rep(threshold, 2), col = "green")
    }
    dev.off()
    if (dryRun) {
      confImageFile <- saveAcasFileToExperiment(tempFile, experiment, "metadata", "experiment metadata", 
                                                "dryrun confirmation graph", user, lsTransaction, 
                                                deleteOldFile = FALSE, customSourceFileMove = customSourceFileMove)
    } else {
      confImageFile <- saveAcasFileToExperiment(tempFile, experiment, "metadata", "experiment metadata", 
                                                "confirmation graph", user, lsTransaction,
                                                deleteOldFile = TRUE, customSourceFileMove = customSourceFileMove)
    }
  }
  
  primaryHitList <- unique(wideDataPrimary[flagType=="hit", batchCode])
  tempFile <- paste0(experimentCode, "primaryHits.csv")
  writeLines(primaryHitList, getUploadedFilePath(tempFile))
  if (dryRun) {
    primaryHitFile <- saveAcasFileToExperiment(tempFile, experiment, "metadata", "experiment metadata", 
                                               "dryrun primary hit list", user, lsTransaction, 
                                               deleteOldFile = FALSE, customSourceFileMove = customSourceFileMove)
  } else {
    primaryHitFile <- saveAcasFileToExperiment(tempFile, experiment, "metadata", "experiment metadata", 
                                               "primary hit list", user, lsTransaction, 
                                               deleteOldFile = TRUE, customSourceFileMove = customSourceFileMove)
  }
  
  summaryInfo$experiment <- experiment
  primaryInfo <- list(
    "Compounds Tested in Primary" = totalTested,
    "Primary Experiment Codes" = paste(primaryExperimentCodes, collapse = ", "),
    "Primary Hits" = paste0('<a href="', getAcasFileLink(primaryHitFile, login = TRUE), '" target="_blank">Primary Hits</a>')
  )
  summaryInfo$info <- c(summaryInfo$info, primaryInfo)
  if (length(confirmationExperimentCodes) > 0) {
    extraInfo <- list(
      "Compounds Retested in Confirmation" = totalRetested,
      "Compounds Confirmed in Confirmation" = totalConfirmed,
      "Confirmation Rate" = paste0(round(confirmationRate, 2), "%"),
      "Confirmation Experiment Codes" = paste(confirmationExperimentCodes, collapse = ", "),
      "Confirmation Graph" = paste0('<a href="', getAcasFileLink(confImageFile, login = TRUE), '" target="_blank">Confirmation Graph</a>')
    )
    summaryInfo$info <- c(summaryInfo$info, extraInfo)
  }
  return(summaryInfo)
}
makeWideData <- function(exptDT) {
  # Changes from database input to input for fitting as a data.table
  library('stats')
  
  neededDT <- exptDT[, list(EXPT_CODE, combinedTypeAndKind, SUBJECT_ID, VALUE_TYPE, VALUE_KIND, CODE_VALUE, NUMERIC_VALUE, STRING_VALUE, CONCENTRATION, CONC_UNIT)]
  
  numericRows <- neededDT[VALUE_TYPE == "numericValue", list(EXPT_CODE, combinedTypeAndKind, SUBJECT_ID, NUMERIC_VALUE)]
  stringRows <- neededDT[VALUE_TYPE == "stringValue", list(EXPT_CODE, combinedTypeAndKind, SUBJECT_ID, STRING_VALUE)]
  codeRows <- neededDT[VALUE_TYPE == "codeValue" & VALUE_KIND != "batch code", list(EXPT_CODE, SUBJECT_ID, combinedTypeAndKind, CODE_VALUE)]
  batchCodeRows <- neededDT[VALUE_TYPE == "codeValue" & VALUE_KIND == "batch code", list(EXPT_CODE, SUBJECT_ID, combinedTypeAndKind, CODE_VALUE, CONCENTRATION, CONC_UNIT)]
  
  wideNumeric <- stats::reshape(numericRows, v.names = "NUMERIC_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  wideString <- stats::reshape(stringRows, v.names = "STRING_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  wideCode <- stats::reshape(codeRows, v.names = "CODE_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  wideBatchCode <- stats::reshape(batchCodeRows, v.names = "CODE_VALUE", idvar = "SUBJECT_ID", timevar = "combinedTypeAndKind", direction = "wide")
  
  combined <- merge(wideNumeric, wideString, by = c("SUBJECT_ID", "EXPT_CODE"))
  combined <- merge(combined, wideCode, by = c("SUBJECT_ID", "EXPT_CODE"))
  combined <- merge(combined, wideBatchCode, by = c("SUBJECT_ID", "EXPT_CODE"))
  setnames(combined, 
           c("EXPT_CODE", "NUMERIC_VALUE.data_results_normalized activity", 
             "STRING_VALUE.metadata_plate information_well name", 
             "STRING_VALUE.metadata_plate information_well type",
             "CODE_VALUE.metadata_plate information_barcode", 
             "CONCENTRATION", "CONC_UNIT", "CODE_VALUE.data_results_batch code"), 
           c("experimentCode", "normalizedActivity", 
             "well", "wellType", "assayBarcode", "concentration", "concUnit", "batchCode"))
  optionalNames <- data.frame(
    old=c("STRING_VALUE.data_user flag_comment", "CODE_VALUE.data_auto flag_flag status", 
          "CODE_VALUE.data_auto flag_flag observation", "CODE_VALUE.data_auto flag_flag cause", 
          "CODE_VALUE.data_user flag_flag status", 
          "CODE_VALUE.data_user flag_flag observation", "CODE_VALUE.data_user flag_flag cause", 
          "NUMERIC_VALUE.data_results_transformed standard deviation", 
          "NUMERIC_VALUE.data_results_efficacy"),
    new=c("flagComment", "autoFlagType", "autoFlagObservation", 
          "autoFlagReason", "flagType", "flagObseration", "flagReason", 
          "transformed_sd", "transformed_percent efficacy"),
    stringsAsFactors = FALSE)
  for (i in 1:nrow(optionalNames)) {
    if (optionalNames$old[i] %in% names(combined)) {
      setnames(combined, optionalNames$old[i], optionalNames$new[i])
    } else {
      combined[, (optionalNames$new[i]) := NA]
    }
  }
  return(as.data.table(combined))
}
getPlateOrderForExperiment <- function(experimentCode) {
  experiment <- getExperimentByCodeName(experimentCode)
  
  experimentStates <- getStatesByTypeAndKind(experiment, "metadata_experiment metadata")
  experimentState <- Find(function(x) {x$ignored == FALSE}, experimentStates)
  
  # checking lists cached in database
  plateOrderValues <- getValuesByTypeAndKind(experimentState, "clobValue_plate order")
  plateOrderValue <- Find(function(x) {x$ignored == FALSE}, plateOrderValues)
  if (is.null(plateOrderValue)) {
    sourceFileValues <- getValuesByTypeAndKind(experimentState, "fileValue_source file")
    sourceFileValue <- Find(function(x) {x$ignored == FALSE}, sourceFileValues)
    sourceFilePath <- downloadAcasFile(sourceFileValue)
    
    targetFolder <- tempdir()
    unzip(zipfile = sourceFilePath, exdir = targetFolder)
    csvFiles <- list.files(path=targetFolder, pattern=".csv")
    if (length(csvFiles == 1)) {
      plateAssociationFile <- file.path(targetFolder, csvFiles[1])
      plateAssoc <- read.csv(plateAssociationFile, header = FALSE)
      plateOrder <- data.frame(experimentCode = experimentCode, 
                               assayBarcode = plateAssoc[[1]], 
                               plateOrder = 1:nrow(plateAssoc))
      # Save to experiment for next time
      updateValueByTypeAndKind(paste(plateOrder$assayBarcode, collapse = ","), "experiment", experiment$id, 
                               "metadata", "experiment metadata", "clobValue", "plate order")
    } else {
      plateOrder <- data.frame(experimentCode = character(), 
                               assayBarcode = character(), 
                               plateOrder = numeric())
    }
  } else {
    plateOrderList <- strsplit(plateOrderValue$clobValue, ",")[[1]]
    plateOrder <- data.frame(experimentCode = experimentCode, 
                             assayBarcode = plateOrderList, 
                             plateOrder = 1:length(plateOrderList))
  }
  return(plateOrder)
}
getExperimentData <- function (experimentCodes) {
  # Accepts a list of experiment codes, returns a data.table
  library(data.table)
  
  getDataString <- "select /*+ FIRST_ROWS(10) */ e.code_name as EXPT_CODE, eag.ANALYSIS_GROUP_ID, atg.treatment_group_id, s.id as SUBJECT_ID, 
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
    where e.code_name ='"
  
  allDataPrimary <- ldply(experimentCodes, function(codeName) {
    exptQuery <- paste0(getDataString, codeName, "'")
    return(query(exptQuery))
  })
  
  allDataPrimary <- as.data.table(allDataPrimary)
  setnames(allDataPrimary, toupper(names(allDataPrimary)))
  allDataPrimary[, combinedTypeAndKind := paste0(SUB_STATE_TYPE_AND_KIND, "_", VALUE_KIND)]
  
  # pivot data
  return(makeWideData(allDataPrimary))
}
downloadAcasFile <- function(fileValue) {
  # fileValue is list (ACAS fileValue) with fileValue and comment
  # newFilePath is the target folder for the file
  tempPath <- tempdir()
  newFileName <- fileValue$comments
  if (is.null(newFileName)) {
    newFilePath <- tempfile(tmpdir = tempPath)
  } else {
    newFilePath <- file.path(tempPath, newFileName)
  }
  # TODO: update after creating customFileDownload function
  if (FALSE) {
  # if (exists(customFileDownload)) {
    fileInfo <- fromJSON(getURLcheckStatus(paste0(getAcasFileLink(fileValue$fileValue), "/metadata.json")))
    file.copy(fileInfo[[1]]$dnsFile$path, tempPath)
  } else {
    download.file(getAcasFileLink(fileValue$fileValue), newFilePath)
  }
  return(newFilePath)
}
getRowName <- function(x) {
  gsub(" ", "-", sprintf("%2s", gsub("[0-9]{1,2}", "", x)))
}
getColumnName <- function(x) {
  gsub(" ", "", gsub("[A-Z]{1,2}", "", x))
}
analyzeScreeningCampaign <- function(request) {
  # Highest level function, runs everything else 
  
  library('racas')
  globalMessenger <- messenger()$reset()
  globalMessenger$devMode <- FALSE
  save(request, file="request.Rda")
  
  request <- as.list(request)
  
  experimentCode <- request$exptCode
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
