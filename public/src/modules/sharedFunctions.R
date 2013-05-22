readConfigFile <- function(configLocation) {
  configFile <- readLines(configLocation)
  configurations <- configFile[grepl("^SeuratAddOns\\.configuration\\.",configFile)]
  configList <- gsub("SeuratAddOns\\.configuration\\.(.*) = (.*)", "\\2", configurations)
  configList <- as.list(gsub("\"","",configList))
  names(configList) <- gsub("SeuratAddOns\\.configuration\\.(.*) = (.*)", "\\1", configurations)
  return (configList)
}

interpretJSONBoolean <- function(JSONBoolean) {
  if (is.null(JSONBoolean)) {
    return(NULL)
  } else if (JSONBoolean=="true") {
    return(TRUE)
  } else if (JSONBoolean=="false") {
    return(FALSE)
  } else {
    return(JSONBoolean)
  }
}

query <- function(qu, configList){
  # Loading RJDBC results in a warning when rJava is loaded
  suppressWarnings(require('RJDBC'))
  drv <- JDBC(configList$driver, configList$driverLocation)
  conn <- dbConnect(drv, paste(configList$databaseLocation,configList$serverAddress,configList$databasePort,sep=""), 
                    user = configList$username, password = configList$password )
  results <- dbGetQuery(conn,qu)
  dbDisconnect(conn)
  return(results)
}

getWarningMessage <- function (warn) {
  # This function takes in a warning and outputs only the message part
  return (warn$message)
}

tryCatch.W.E <- function(expr) {
  # This function is taken from the R demo file and edited
  # http://svn.r-project.org/R/trunk/src/library/base/demo/error.catching.R
  # R-help mailing list, Dec 9, 2010
  #
  # It stores the warnings rather than letting them exit as normal for tryCatch
  #
  W <- list()
  
  w.handler <- function(w){ # warning handler
    W <<- c(W,list(w))
    invokeRestart("muffleWarning")
  }
  
  return(list(value = withCallingHandlers(tryCatch(expr, error = function(e) e),
                                          warning = w.handler),
              warningList = W))
}

createHTML <- function(hasError,errorList,hasWarning,warningList,summaryInfo,dryRun) {
  # Turns the output information into html
  # 
  # Args:
  #   hasError:             A boolean marking that there are errors
  #   errorList:            A list of errors
  #   hasWarning:           A boolean marking that there are warnings
  #   warningList:          A list of warnings
  #   summaryInfo:          A list of information to return to the user
  #   dryRun:               A boolean that marks if information should be saved to the server
  #
  # Returns:
  #  A character vector of html code
  
  require('brew')
  
  # Create a brew to load opening messages, errors, and warnings
  htmlOutputFormat <- "<p><%=startMessage%></p>
  <%=if(hasError) {htmlErrorList}%>
  <%=if(hasWarning&&dryRun) {htmlWarningList}%>"
  
  # If there is summmaryInfo, add it to the brew
  if(!is.null(summaryInfo)) {
    htmlOutputFormat <- paste0(htmlOutputFormat,
                               "<h4>Summary</h4>
                               <p>Information:</p>
                               <ul>
                               <li><%=paste(paste0(names(summaryInfo$info),': ',summaryInfo$info),collapse='</li><li>')%></li>
                               </ul>")
  }
  
  # Create a header based on whether this is a dryRun and if there are warnings and errors
  if (dryRun) {
    if (hasError==FALSE) {
      if (hasWarning) {
        startMessage <- "Please review the warnings and summary before uploading."
      } else {
        startMessage <- "Please review the summary before uploading."
      }
    } else {
      startMessage <- "Please fix the following errors and use the 'Back' button at the bottom of this screen to upload a new version of the file."
    }
  } else {
    if (hasError) {
      startMessage <- "An error occured during uploading. If the messages below are unhelpful, you will need to contact your system administrator."
    } else {
      startMessage <- "Upload completed."
    }
  } 
  
  
  # Create a list of Errors
  htmlErrorList <- paste("<h4 style=\"color:red\">Errors:", length(errorList), "</h4>
                         <ul><li>", paste(errorList,collapse='</li><li>'), "</li></ul>")
  
  # Create a list of Warnings
  htmlWarningList <- paste0("<h4>Warnings: ", length(warningList), "</h4>
                            <p>Warnings provide information on issues found in the upload file. ",
                            "You can proceed with warnings; however, it is recommended that, if possible, ",
                            "you make the changes suggested by the warnings ",
                            "and upload a new version of the file by using the 'Back' button at the bottom of this screen.</p>
                            <ul><li>", paste(warningList,collapse='</li><li>'), "</li></ul>")
  
  return(paste(capture.output(brew(text=htmlOutputFormat)),collapse="\n"))
}

getId <- function(thing) {
  return(thing$id)
}

readElement <- function(entity, element) {
  #Takes a list as input and outputs the named element
  return(entity[[element]])
}

saveAnalysisResults <- function(experiment, hasError, htmlSummary) {
  # Saves (replace) the analysis html and status
  # Notes: experiment must have an "experiment metadata" state with values "analysis result html" and "analysis status"
  
  if (is.null(experiment)) {
    return (htmlSummary)
  }
  
  metadataState <- experiment$experimentStates[lapply(experiment$experimentStates,readElement,"stateKind")=="experiment metadata"][[1]]
  
  valueKinds <- lapply(metadataState$experimentValues,readElement,"valueKind")
  
  valuesToDelete <- metadataState$experimentValues[valueKinds == "analysis result html" | valueKinds == "analysis status"]
  
  htmlValue <- createStateValue(
    valueType = "clobValue",
    valueKind = "analysis result html",
    clobValue = htmlSummary,
    experimentState = metadataState
  )
  
  statusValue <- createStateValue(
    valueType = "stringValue",
    valueKind = "analysis status",
    stringValue = if(hasError) {"failed"} else {"complete"},
    experimentState = metadataState)
  
  tryCatch({
    lapply(valuesToDelete, deleteExperimentValue)
    saveExperimentValues(list(htmlValue,statusValue))
  }, error = function(e) {
    htmlSummary <- paste(htmlSummary, "<p>Could not save the experiment status</p>")
  })
  return (htmlSummary)
}

saveStatesFromLongFormat <- function(entityData, entityKind, stateGroups, idColumn, recordedBy, lsTransaction, stateGroupIndices = NULL) {
  # saves "raw only" states
  # 
  # Args:
  #   entityData:           A data frame that includes columns:
  #     stateGroupIndex:      Integer vector marking the index of the state group for each row
  #     (idColumn):           Integer vector that separates rows into states (used for grouping, does not use numbers)
  #   entityKind:           A string of the kind of the state from list "subject", "treatmentgroup", "container"
  #   stateGroups:          A list of lists, each of which includes details about how to save states
  #   stateGroupIndices:    An integer vector of the indices to use from stateGroups (others are removed)
  #   idColumn:             The name of the column to use to separate groups
  #   recordedBy:           A string of the username
  #   lsTransaction:        A list that is an lsTransaction (must have an "id" element)
  #
  # Returns:
  #   An integer vector of the state id's
  
  require(plyr)
  
  if (is.null(stateGroupIndices)) {
    stateGroupIndices <- which(sapply(stateGroups, function(x) return (x$entityKind)) == entityKind)
  }
  
  createRawOnlyEntityState <- function(entityData, stateGroups, entityKind, recordedBy, lsTransaction) {

    
    stateType <- stateGroups[[entityData$stateGroupIndex[1]]]$stateType
    stateKind <- stateGroups[[entityData$stateGroupIndex[1]]]$stateKind
    entityState <- switch(
      entityKind,
      "analysisgroup" = {createAnalysisGroupState(analysisGroup = list(id=entityData$analysisGroupID[1], version=0),
                                                    stateType=stateType,
                                                    stateKind=stateKind,
                                                    recordedBy=recordedBy,
                                                    lsTransaction=lsTransaction)
      },
      "subject" = {createSubjectState(subject = list(id=entityData$subjectID[1], version=0),
                                      stateType=stateType,
                                      stateKind=stateKind,
                                      recordedBy=recordedBy,
                                      lsTransaction=lsTransaction)
      },
      "treatmentgroup" = {createTreatmentGroupState(treatmentGroup = list(id=entityData$treatmentGroupID[1], version=0),
                                                    stateType=stateType,
                                                    stateKind=stateKind,
                                                    recordedBy=recordedBy,
                                                    lsTransaction=lsTransaction)
      },
      "container" = {createContainerState(container = list(id=entityData$containerID[1], version=0),
                                          stateType=stateType,
                                          stateKind=stateKind,
                                          recordedBy=recordedBy,
                                          lsTransaction=lsTransaction)
      },
      stop(paste("Unrecognized entityKind:", entityKind)))
    return(entityState)
  }
  #TODO: the variables remains sketchy... fix once expanded
  entityStates <- dlply(.data=entityData[entityData$stateGroupIndex %in% stateGroupIndices,], .variables=idColumn, .fun=createRawOnlyEntityState, 
                        stateGroups=stateGroups, entityKind=entityKind, recordedBy=recordedBy, lsTransaction=lsTransaction)
  originalStateIds <- names(entityStates)
  names(entityStates) <- NULL
  savedEntityStates <- saveAcasEntities(entityStates, paste0(entityKind, "states"))
  
  entityStateIds <- sapply(savedEntityStates, getId)
  entityStateVersions <- sapply(savedEntityStates, function(x) return(x$version))
  entityStateTranslation <- data.frame(entityStateId = entityStateIds, 
                                       originalStateId = originalStateIds, 
                                       entityStateVersion = entityStateVersions)
  
  stateIdAndVersion <- entityStateTranslation[match(entityData[[idColumn]], 
                                                    entityStateTranslation$originalStateId),
                                              c("entityStateId", "entityStateVersion")]
  return(stateIdAndVersion)
}
meltBatchCodes <- function(entityData, batchCodeStateIndices) {
  require('plyr')
  # Turns a batchCode column into rows in a long format
  
  # It will run once, mostly. So it is a for loop
  output <- data.frame()
  for (index in batchCodeStateIndices) {
    batchCodeValues  <- unique(entityData[entityData$stateGroupIndex==index,c("batchCode", "stateID", "stateVersion", "stateGroupIndex", "publicData")])
    if (nrow(batchCodeValues) > 0) {
      names(batchCodeValues)[1] <- "codeValue"
      batchCodeValues$valueType <- "codeValue"
      batchCodeValues$valueKind <- "batch code"
      output <- rbind.fill(output, batchCodeValues)
    }
  }
  return(output)
}
saveValuesFromLongFormat <- function(entityData, entityKind, stateGroups = NULL, lsTransaction, stateGroupIndices = NULL, testMode=FALSE) {
  # saves "raw only" states
  # 
  # Args:
  #   entityData:           A data frame that includes columns:
  #     stateGroupIndex:      Integer vector marking the index of the state group for each row
  #     stateID:              An integer that is the ID of the state for each value
  #     valueType:            A string of "stringValue", "dateValue", or "numericValue"
  #     valueKind:            A string value ofthe kind of value
  #     publicData:           Boolean: Marks if each value should be hidden
  #     stateVersion:         An integer that is the version of the state for each value
  #     (Optional columns)
  #     stringValue:          String: a string value
  #     codeValue:            String: a code, such as a batch code
  #     dateValue:            A Date value
  #     valueOperator:        String: The operator for each value
  #     valueUnit:            String: The units for each value
  #     clobValue:            String: for very long strings
  #     numberOfReplicates:   Integer: The number of replicates
  #     uncertainty:          Numeric: the uncertainty
  #     uncertaintyType:      String: the type of uncertainty, such as standard deviation
  #   entityKind:           A string of the kind of the state from list "subject", "treatmentgroup", "container"
  #   stateGroups:          A list of lists, each of which includes details about how to save states
  #   stateGroupIndices:    An integer vector of the indices to use from stateGroups (others are removed)
  #   lsTransaction:        A list that is an lsTransaction (must have an "id" element)
  #   testMode:             A boolean marking if the function should return JSON instead of saving values
  #
  # Returns:
  #   NULL
  
  require(plyr)
  
  if (is.null(stateGroupIndices)) {
    stateGroupIndices <- which(sapply(stateGroups, function(x) return (x$entityKind)) == entityKind)
  }
  
  entityData$rowID <- 1:(nrow(entityData))
  createLocalStateValue <- function(entityData, lsTransaction) {
    if (!is.null(entityData$dateValue)) {
      dateValue <- as.numeric(format(as.Date(entityData$dateValue,origin="1970-01-01"), "%s"))*1000
    } else {
      dateValue <- NA
    }
    stateValue <- createStateValue(
      #The name "entityState" will be replaced with whatever other name is being used
      entityState = list(id=entityData$stateID, version = entityData$stateVersion),
      valueType = if (entityData$valueType=="stringValue") {"stringValue"}  
      else if (entityData$valueType=="dateValue") {"dateValue"}
      else if (entityData$valueType == "codeValue") {"codeValue"}
      else {"numericValue"},
      valueKind = entityData$valueKind,
      stringValue = if (is.character(entityData$stringValue) && !is.na(entityData$stringValue)) {entityData$stringValue} else {NULL},
      dateValue = if(!is.na(dateValue)) {dateValue} else {NULL},
      clobValue = if(is.character(entityData$clobValue) && !is.na(entityData$clobValue)) {entityData$clobValue} else {NULL},
      codeValue = if(is.character(entityData$codeValue) && !is.na(entityData$codeValue)) {entityData$codeValue} else {NULL},
      valueOperator = if(is.character(entityData$valueOperator) && !is.na(entityData$valueOperator)) {entityData$valueOperator} else {NULL},
      numericValue = if(is.numeric(entityData$numericValue) && !is.na(entityData$numericValue)) {entityData$numericValue} else {NULL},
      valueUnit = if(is.character(entityData$valueUnit) && !is.na(entityData$valueUnit)) {entityData$valueUnit} else {NULL},
      publicData = entityData$publicData,
      lsTransaction = lsTransaction,
      numberOfReplicates = if(is.numeric(entityData$numberOfReplicates) && !is.na(entityData$numberOfReplicates)) {entityData$numberOfReplicates} else {NULL},
      uncertainty = if(is.numeric(entityData$uncertainty) && !is.na(entityData$uncertainty)) {entityData$uncertainty} else {NULL},
      uncertaintyType = if(is.character(entityData$uncertaintyType) && !is.na(entityData$uncertaintyType)) {entityData$uncertaintyType} else {NULL}
    )
    return(stateValue)
  }
  entityValues <- dlply(.data = entityData[entityData$stateGroupIndex %in% stateGroupIndices,], 
                        .variables = .(rowID), 
                        .fun = createLocalStateValue, 
                        lsTransaction = lsTransaction)
  
  names(entityValues) <- NULL
  changeName <- function(entityValue, entityKind) {
    newEntity <- switch(entityKind,
                        protocol = "protocolState",
                        experiment = "experimentState",
                        analysisgroup = "analysisGroupState",
                        treatmentgroup = "treatmentGroupState",
                        subject = "subjectState",
                        container = "containerState",
                        stop(paste("Unrecognized entityKind:", entityKind)))
    entityValue[[newEntity]] <- entityValue$entityState
    return(entityValue)
  }
  entityValues <- lapply(entityValues, FUN = changeName, entityKind = entityKind)
  if (testMode) {
    entityValues <- lapply(entityValues, function(x) {x$recordedDate <- 42; return (x)})
    return(toJSON(entityValues))
  } else {
  savedEntityValues <- saveAcasEntities(entityValues, paste0(entityKind, "values"))
  return(savedEntityValues)
  }
}