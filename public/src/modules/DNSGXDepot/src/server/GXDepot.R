# pathToSourceFile <- "~/Documents/clients/DNS/GXDepot/Expt_design_info_example_r4.xlsx"
source("public/src/conf/customFunctions.R")
parseGXFileListMain <- function(pathToSourceFile, recordedBy, dryRun = TRUE, developmentMode = FALSE, testMode = FALSE, 
                                errorEnv = NULL) {
  library(plyr)
  inputDataFrame <- readExcelOrCsv(pathToSourceFile)
  
  #Remove later
  testMode <- TRUE
  
  # Meta Data
  metaData <- getSection(inputDataFrame, lookFor = "Experiment Meta Data", transpose = TRUE)
  
  expectedDataFormat <- data.frame(
    headers = c("Owner", "Title", "Date", "Notebook", "Protocol", "Project", "Short description", "Keywords"),
    class = c("stringValue", "stringValue", "dateValue", "stringValue", "stringValue", "stringValue", "stringValue", "stringValue"),
    isNullable = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE),
    stringsAsFactors = F
  )
  validatedMetaDataList <- validateSharedMetaData(metaData, expectedDataFormat, errorEnv = errorEnv)
  
  fileSection <- getSection(inputDataFrame, lookFor = "File Data", transpose = FALSE)
  
  names(fileSection) <- fileSection[1, ]
  fileSection <- fileSection[2:nrow(fileSection), ]
  
  resultTypes <- data.frame("DataColumn" = c("Fastq Files", "Sample Names", "Conditions"), 
                            "Kind" = c("fastq file", "sample names", "condition"), 
                            "dataClass" = c("fileValue", "stringValue", "stringValue"), 
                            "Units" = c(NA), 
                            "Conc" = c(NA), 
                            "ConcUnits" = c(NA),
                            "hidden" = F,
                            stringsAsFactors = F)
  
  resultFrame <- meltWideData(fileSection, resultTypes)
  resultFrame$stateGroupIndex <- 1
  adapterSection <- getSection(inputDataFrame, lookFor = "Adapter Sequences", transpose = FALSE)
  if(nrow(adapterSection) %% 2 == 1) {
    stop("There must be an even number of rows in section 'Adapter Sequences'")
  }
  adapterFrame <- data.frame(valueKind = adapterSection[[1]][seq(1, nrow(adapterSection), 2)],
                             clobValue = adapterSection[[1]][seq(2, nrow(adapterSection), 2)],
                             stringsAsFactors = F)
  adapterFrame$valueType <- "clobValue"
  adapterFrame$publicData <- TRUE
  adapterFrame$rowID <- max(resultFrame$rowID + 1):max(resultFrame$rowID + nrow(adapterFrame))
  adapterFrame$stateGroupIndex <- 2
  # Maybe add resultTypeAndUnit and UnparsedValue
  
  allData <- rbind.fill(resultFrame, adapterFrame)
  
  protocol <- getProtocolByName(validatedMetaDataList$Protocol)
  
  if(dryRun) return(list(info=list("DryRun" = "Passed")))
  lsTransaction <- createLsTransaction("GX Depot")$id
  # Get the protocol
  # Save the experiment
  experiment <- createNewExperiment(validatedMetaDataList, protocol, lsTransaction, recordedBy) 
  
  # Save the source file
  moveFileToExperimentFolder(pathToSourceFile, experiment, recordedBy=recordedBy, lsTransaction=lsTransaction)
  # Add states to each frame
  # Save the fileValues to the file service
  saveFileToService <- function(filePath, fileService = racas::applicationSettings$server.service.external.file.service.url) {
    library("XML")
    
    tryCatch({
      response <- postForm(fileService,
                           FILE = fileUpload(filename = filePath),
                           OWNING_URL = paste0(racas::applicationSettings$client.service.persistence.fullpath,
                                               "experiments/codename/", experiment$codeName),
                           CREATED_BY_LOGIN = recordedBy,
                           DATE_EXPIRED = ifelse(testMode, "2013/12/19 01:01:01", ""))
      parsedXML <- xmlParse(response)
      serverFileLocation <- xmlValue(xmlChildren(xmlChildren(parsedXML)$dnsFile)$corpFileName)
    }, error = function(e) {
      stop(paste("There was an error contacting the file service:", e))
    })
    
    file.remove(filePath)
    return(serverFileLocation)
  }
  
  #Replace fileValues with locations after saving them to the service
  allData$fileValue[!is.na(allData$fileValue)] <- vapply(allData$fileValue[!is.na(allData$fileValue)], saveFileToService, c(""))
  
  allData$analysisGroupID <- allData$rowID
  allData$treatmentGroupID <- allData$rowID
  allData$subjectID <- allData$rowID
  
  #################################
  # Save it all
  
  # Get a list of codes
  analysisGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_analysis group", 
                                                    labelTypeAndKind="id_codeName",
                                                    numberOfLabels=length(unique(allData$analysisGroupID))),
                                      use.names=FALSE)
  
  subjectCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_subject", 
                                              labelTypeAndKind="id_codeName", 
                                              numberOfLabels=length(unique(allData$subjectID))),
                                use.names=FALSE)
  
  treatmentGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_treatment group", 
                                                     labelTypeAndKind="id_codeName", 
                                                     numberOfLabels=length(unique(allData$treatmentGroupID))),
                                       use.names=FALSE)
  
  experiment$lsStates <- NULL
  experiment$analysisGroups <- NULL
  analysisGroups <- lapply(FUN= createAnalysisGroup, X= analysisGroupCodeNameList,
                           recordedBy=recordedBy, lsTransaction=lsTransaction, experiment=experiment)
  
  savedAnalysisGroups <- saveAcasEntities(analysisGroups, "analysisgroups")
  
  analysisGroupIds <- vapply(savedAnalysisGroups, getElement, c(1), "id")
  
  allData$analysisGroupID <- analysisGroupIds[allData$analysisGroupID]
  
  #Treatment Groups
  allData$treatmentGroupCodeName <- treatmentGroupCodeNameList[allData$treatmentGroupID]
  
  createLocalTreatmentGroup <- function(localData) {
    return(createTreatmentGroup(
      analysisGroup = list(id = localData$analysisGroupID[1], version = 0),
      codeName = localData$treatmentGroupCodeName[1],
      recordedBy = recordedBy,
      lsTransaction = lsTransaction))
  }
  
  treatmentGroups <- dlply(.data= allData, .variables= .(treatmentGroupID), .fun= createLocalTreatmentGroup)
  names(treatmentGroups) <- NULL
  
  savedTreatmentGroups <- saveAcasEntities(treatmentGroups, "treatmentgroups")
  
  treatmentGroupIds <- vapply(savedTreatmentGroups, getElement, c(1), "id")
  
  allData$treatmentGroupID <- treatmentGroupIds[allData$treatmentGroupID]
  
  # Subjects
  allData$subjectCodeName <- subjectCodeNameList[allData$subjectID]
  
  createRawOnlySubject <- function(localData) {
    return(createSubject(
      treatmentGroup=list(id=localData$treatmentGroupID[1],version=0),
      codeName=localData$subjectCodeName[1],
      recordedBy=recordedBy,
      lsTransaction=lsTransaction))
  }
  
  subjects <- dlply(.data= allData, .variables= .(subjectID), .fun= createRawOnlySubject)
  names(subjects) <- NULL
  
  savedSubjects <- saveAcasEntities(subjects, "subjects")
  
  subjectIds <- vapply(savedSubjects, getElement, c(1), "id")
  
  allData$subjectID <- subjectIds[allData$subjectID]
  
  ### Subject States ===============================================
  #######  
  
  allData$stateID <- paste0(allData$subjectID, "-", allData$stateGroupIndex, "-", 
                                allData$concentration, "-", allData$concentrationUnit, "-",
                                allData$time, "-", allData$timeUnit, "-", allData$subjectStateID)
  
  stateGroups <- list(list(entityKind = "subject", stateType = "data", stateKind = "raw data", includesOthers = TRUE, includesCorpName = FALSE),
                      list(entityKind = "subject", stateType = "data", stateKind = "adapter sequences", includesOthers = TRUE, includesCorpName = FALSE))
  
  stateAndVersion <- saveStatesFromLongFormat(allData, "subject", stateGroups, "stateID", recordedBy, lsTransaction)
  allData$stateID <- stateAndVersion$entityStateId
  allData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### Subject Values ======================================================================= 
  if (is.null(allData$stateVersion)) allData$stateVersion <- 0
  
  uniqueValueKinds <- unique(allData[, c("valueKind", "valueType")])
  outputList <- checkValueKinds(neededValueKinds=uniqueValueKinds$valueKind, neededValueKindTypes=uniqueValueKinds$valueType)
  newValueKinds <- outputList$newValueKinds
  saveValueKinds(newValueKinds, uniqueValueKinds$valueType[newValueKinds == uniqueValueKinds$valueKind], errorEnv = errorEnv)
  
  savedSubjectValues <- saveValuesFromLongFormat(allData, "subject", stateGroups, lsTransaction, recordedBy)
  
  return(list(info = list("Finished" = "TRUE!")))
}
createNewExperiment <- function(metaData, protocol, lsTransaction, recordedBy, replacedExperimentCodes = NULL) {
  # creates an experiment using the metaData
  # 
  # Args:
  #   metaData:               A data.frame including "Experiment Name", "Scientist", "Notebook", "Page", and "Assay Date"
  #   protocol:               A list that is a protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #   recordedBy:             username of person saving
  #   replacedExperimentCodes: codes of previous experiments that were deleted and replaced with this one
  #
  # Returns:
  #  A list that is an experiment
  
  library('RCurl')
  library('gdata')
  
  experimentStates <- list()
  
  # Store the metaData in experiment values
  experimentValues <- list()
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                     lsKind = "notebook",
                                                                     stringValue = metaData$Notebook[1],
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "dateValue",
                                                                     lsKind = "completion date",
                                                                     dateValue = as.numeric(format(as.Date(metaData$Date[1]), "%s"))*1000,
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                     lsType = "stringValue",
                                                                     lsKind = "scientist",
                                                                     stringValue = metaData$Owner,
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                     lsKind = "status",
                                                                     stringValue = "Approved",
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                     lsKind = "analysis status",
                                                                     stringValue = "parsing input",
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "clobValue",
                                                                     lsKind = "analysis result html",
                                                                     clobValue = "<p>Analysis not yet completed</p>",
                                                                     lsTransaction= lsTransaction)
  
  if (!is.null(metaData$Project)) {
    experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "codeValue",
                                                                       lsKind = "project",
                                                                       codeValue = metaData$Project[1],
                                                                       lsTransaction= lsTransaction)
  }
  if (!is.null(replacedExperimentCodes)) {
    for (experimentCode in replacedExperimentCodes) {
      experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "codeValue",
                                                                         lsKind = "previous experiment code",
                                                                         codeValue = experimentCode,
                                                                         lsTransaction= lsTransaction)
    }
  }
  # Create an experiment state for metadata
  experimentStates[[length(experimentStates)+1]] <- createExperimentState(experimentValues=experimentValues,
                                                                          lsTransaction = lsTransaction, 
                                                                          recordedBy=recordedBy, 
                                                                          lsType="metadata", 
                                                                          lsKind="experiment metadata")
  
  # Create a label for the experiment name
  experimentLabels <- list()
  experimentLabels[[length(experimentLabels)+1]] <- createExperimentLabel(lsTransaction = lsTransaction, 
                                                                          recordedBy=recordedBy, 
                                                                          lsType="name", 
                                                                          lsKind="experiment name",
                                                                          labelText=experimentName <- trim(gsub("CREATETHISEXPERIMENT$", "", metaData$"Title"[1])),
                                                                          preferred=TRUE)
  protocol$lsStates <- NULL
  # Create the experiment
  experiment <- createExperiment(lsTransaction = lsTransaction, 
                                 protocol = protocol,
                                 lsKind = "gx depot",
                                 shortDescription = if(!is.null(metaData$"Short description"[1])) {
                                   metaData$"Short description"[1]
                                 } else {
                                   "experiment created for GX Depot"
                                 },  
                                 recordedBy=recordedBy, 
                                 experimentLabels=experimentLabels,
                                 experimentStates=experimentStates)
  
  # Save the experiment to the server
  experiment <- saveExperiment(experiment)
  experiment <- fromJSON(getURL(URLencode(paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/", experiment$id))))
  return(experiment)
}
parseGXFileListCMD <- function(pathToSourceFile, recordedBy, dryRun = TRUE, developmentMode = FALSE, testMode = FALSE) {
  # To run from command line
  
  errorList <- list()
  errorEnv <- environment()
  
  output <- parseGXFileListMain(pathToSourceFile, recordedBy, dryRun, developmentMode, testMode, errorEnv = errorEnv)
  
  if(length(errorList) > 0) {
    print("Errors")
    print(errorList)
  }
  
  return(output)
}
parseGXFileList <- function(request) {
  # Highest level function
  # 
  # Outputs a response with labels: 
  #   value (a list with numbers of analysis groups, treatment groups, and subjects to be uploaded)
  #   warningList (a character vector)
  #   errorList (a character vector)
  #   error (a boolean)
  
  library(racas)
  
  # Stop toJSON from using scientific notation
  options("scipen" = 15)
  
  # This is used for outputting the JSON rather than sending it to the server
  developmentMode <- FALSE
  
  # Collect the information from the request
  request <- as.list(request)
  pathToSourceFile <- request$fileToParse
  dryRun <- request$dryRunMode
  testMode <- request$testMode
  recordedBy <- request$user
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- as.boolean(dryRun)
  testMode <- as.boolean(testMode)
  if(length(testMode) == 0) {
    testMode <- FALSE
  }
  
  experiment <- NULL
  
  errorList <- list()
  errorEnv <- environment()
  
  # Run the function and save output (value), errors, and warnings
  loadResult <- tryCatch.W.E(parseGXFileListMain(pathToSourceFile = pathToSourceFile,
                                                 dryRun = dryRun,
                                                 developmentMode = developmentMode,
                                                 testMode = testMode,
                                                 recordedBy = recordedBy,
                                                 errorEnv = errorEnv))
  
  # If the output has class simpleError or is not a list, save it as an error
  if(class(loadResult$value)[1] == "simpleError") {
    errorList <- c(errorList, list(loadResult$value$message))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value) == "SQLException") > 0) {
    errorList <- c(errorList, list(paste0("There was an error in connecting to the SQL server ", 
                                          racas::applicationSettings$server.database.host, racas::applicationSettings$server.database.port, ":", 
                                          as.character(loadResult$value), ". Please contact your system administrator.")))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value) == "error") > 0 || class(loadResult$value) != "list") {
    errorList <- c(errorList,list(as.character(loadResult$value)))
    loadResult$value <- NULL
  }
  
  # Save warning messages but not the function call, which is only useful while programming
  loadResult$warningList <- lapply(loadResult$warningList, getElement, "message")
  if (length(loadResult$warningList)>0) {
    loadResult$warningList <- strsplit(unlist(loadResult$warningList), "\n")
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
  htmlSummary <- createHtmlSummary(hasError, errorList, hasWarning, loadResult$warningList, summaryInfo=loadResult$value, dryRun)
  
  # Detach the box for error handling
  detach(errorHandlingBox)
  
  if(!dryRun) {
    htmlSummary <- saveAnalysisResults(experiment=experiment, hasError, htmlSummary, loadResult$value$lsTransactionId)
  }
  
  # Return the output structure
  response <- list(
    commit= (!dryRun & !hasError),
    transactionId = loadResult$value$lsTransactionId,
    results= list(
      path= getwd(),
      experimentCode= experiment$codeName,
      fileToParse= pathToSourceFile,
      dryRun= dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}
