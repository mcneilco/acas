calculateTreatmemtGroupID <- function(results, inputFormat, stateGroups, resultTypes) {
  # Returns a column that will be added to results that separates treatmentGroups
  
  # insert formats with custom code in "if" statements
  #if(inputFormat == "") {
  if (FALSE) {
  } else {
    # Standard code
    treatmentGrouping <- which(lapply(stateGroups, getElement, "stateKind") == "treatment")
    groupingColumns <- stateGroups[[treatmentGrouping]]$valueKinds
    groupingColumns <- resultTypes$DataColumn[resultTypes$Type %in% groupingColumns]
    if(stateGroups[[treatmentGrouping]]$includesCorpName) {
      groupingColumns <- c(groupingColumns, "Corporate Batch ID")
    }
    a <- do.call(paste,results[,groupingColumns])
    return(as.numeric(factor(a)))
  }
}


createRawOnlyTreatmentGroupData <- function(subjectData, sigFigs, inputFormat) {
  # Calculates the treatment group data when averaging subject level data
  if (inputFormat == "CNS PK") {
    isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
    isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
    if(isGreaterThan && isLessThan) {
      resultOperator <- "<>"
      resultValue <- NA
    } else if (isGreaterThan) {
      resultOperator <- ">"
      resultValue <- max(subjectData$numericValue, na.rm = TRUE)
    } else if (isLessThan) {
      resultOperator <- "<"
      resultValue <- min(subjectData$numericValue, na.rm = TRUE)
    } else {
      resultOperator <- NA
      resultValue <- mean(subjectData$numericValue, na.rm = TRUE)
    }
    if (!is.null(sigFigs)) { 
      resultValue <- signif(resultValue, sigFigs)
    }
    return(data.frame(
      "batchCode" = subjectData$batchCode[1],
      "valueKind" = subjectData$valueKind[1],
      "valueUnit" = subjectData$valueUnit[1],
      "numericValue" = if(is.nan(resultValue)) NA else resultValue,
      "stringValue" = if ((length(unique(subjectData$stringValue)) == 1) && subjectData$valueKind[1]!="CSF Conc.") {subjectData$stringValue[1]}
      else if (any(subjectData$stringValue == "BQL", na.rm=TRUE) && subjectData$valueKind[1]=="CSF Conc.") {"BQL"}
      else if (is.nan(resultValue)) {"NA"}
      else NA,
      "valueOperator" = resultOperator,
      "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
      "publicData" = subjectData$publicData[1],
      treatmentGroupID = subjectData$treatmentGroupID[1],
      stateGroupIndex = subjectData$stateGroupIndex[1],
      stateID = subjectData$stateID[1],
      stateVersion = subjectData$stateVersion[1],
      valueType = subjectData$valueType[1],
      numberOfReplicates = sum(!is.na(subjectData$numericValue)),
      uncertaintyType = if(!is.na(resultValue)) "standard deviation" else NA,
      uncertainty = if(sum(!is.na(subjectData$numericValue)) > 2) {sd(subjectData$numericValue, na.rm=TRUE)} else NA,
      stringsAsFactors=FALSE))
  } else {
    # Standard code
    isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
    isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
    if(isGreaterThan && isLessThan) {
      resultOperator <- "<>"
      resultValue <- NA
    } else if (isGreaterThan) {
      resultOperator <- ">"
      resultValue <- max(subjectData$numericValue, na.rm = TRUE)
    } else if (isLessThan) {
      resultOperator <- "<"
      resultValue <- min(subjectData$numericValue, na.rm = TRUE)
    } else {
      resultOperator <- NA
      resultValue <- mean(subjectData$numericValue, na.rm = TRUE)
    }
    if (!is.null(sigFigs)) { 
      resultValue <- signif(resultValue, sigFigs)
    }
    return(data.frame(
      "batchCode" = subjectData$batchCode[1],
      "valueKind" = subjectData$valueKind[1],
      "valueUnit" = subjectData$valueUnit[1],
      "numericValue" = if(is.nan(resultValue)) NA else resultValue,
      "stringValue" = if (length(unique(subjectData$stringValue)) == 1) {subjectData$stringValue[1]}
      else if (is.nan(resultValue)) {'NA'}
      else NA,
      "valueOperator" = resultOperator,
      "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
      "publicData" = subjectData$publicData[1],
      treatmentGroupID = subjectData$treatmentGroupID[1],
      stateGroupIndex = subjectData$stateGroupIndex[1],
      stateID = subjectData$stateID[1],
      stateVersion = subjectData$stateVersion[1],
      valueType = subjectData$valueType[1],
      numberOfReplicates = sum(!is.na(subjectData$numericValue)),
      uncertaintyType = if(!is.na(resultValue)) "standard deviation" else NA,
      uncertainty = if(sum(!is.na(subjectData$numericValue)) > 2) {sd(subjectData$numericValue, na.rm=TRUE)} else NA,
      stringsAsFactors=FALSE))
  }
}

registerReportFile <- function(reportFilePath, batchNameList, reportFileSummary, recordedBy, configList, 
                               experiment, lsTransaction, annotationType) {
  # Registers a report as a batch annotation
  
  require(RCurl)
  require(rjson)
  
  annotationList <- list(
    dnsAnnotation = list(
      name = basename(reportFilePath),
      contentType = annotationType,
      #description = "report file",
      #dateExpired = "",
      owningUrl = paste0(configList$serverPath, "experiments/codename/", experiment$codeName),
      owningAttribute = "ACAS_experiment_annotation_id",
      showInline = "false",
      createdByLogin = recordedBy
    ))
  
  annotationList$dnsAnnotation$annotationEntities <- lapply(batchNameList, function(batchCode) {
    list(summary = reportFileSummary,
         entity = list(
           entityClass = "BATCH",
           #entityURL = "",
           entityCorpName = batchCode))
  })
  
  tryCatch({response <- postForm(configList$reportRegistrationURL,
                                 FILE=fileUpload(filename = reportFilePath),
                                 PAYLOAD_TYPE="JSON",
                                 PAYLOAD=toJSON(annotationList))
            response <- fromJSON(response)
  }, error = function(e) {
    stop("There was an error uploading the file for batch annotation")
  })
  
  locationState <- experiment$lsStates[lapply(experiment$lsStates, function(x) x$"lsKind")=="report locations"]
  
  # Record the location
  if (length(locationState)> 0) {
    locationState <- locationState[[1]]
  } else {
    locationState <- createExperimentState(
      recordedBy=recordedBy,
      experiment = experiment,
      lsType="metadata",
      lsKind="report locations",
      lsTransaction=lsTransaction)
    
    locationState <- saveExperimentState(locationState)
  }
  
  tryCatch({
    locationValue <- createStateValue(recordedBy = recordedBy,
                                      lsType = "numericValue",
                                      lsKind = "annotation id",
                                      numericValue = response$dnsAnnotation$id,
                                      lsState = locationState,
                                      lsTransaction = lsTransaction)
    
    saveExperimentValues(list(locationValue))
  }, error = function(e) {
    stop("Could not save the annotation location")
  })
  
  file.remove(reportFilePath)
}

deleteSourceFile <- function(experiment, configList) {
  
  require(RCurl)
  require(rjson)
  
  locationState <- experiment$lsStates[lapply(experiment$lsStates, function(x) x$"lsKind")=="raw results locations"]
  if (length(locationState) > 0) {
    locationState <- locationState[[1]]
    
    lsKinds <- lapply(locationState$lsValues, function(x) x$"lsKind")
    
    valuesToDelete <- locationState$lsValues[lsKinds %in% c("source file")]
    
    if (length(valuesToDelete) > 0) {
      fileToDelete <- valuesToDelete[[1]]$fileValue
      tryCatch({
        response <- getURL(
          paste0(configList$externalFileService, "deactivate/", fileToDelete),
          customrequest='DELETE',
          httpheader=c('Content-Type'='application/json'))
      }, error = function(e) {
        stop("There was an error deleting the old source file. Please contact your system adminstrator.")
      })
      if(!grepl("^Deactivated DNSFile", response)) {
        warning(paste("The loader was unable to delete the old experiment source file. Instead, it got this response:", response))
      }
    }
  }
}
deleteAnnotation <- function(experiment, configList) {
  locationState <- experiment$lsStates[lapply(experiment$lsStates, function(x) x$"lsKind")=="report locations"]
  
  # Record the location
  if (length(locationState)> 0) {
    locationState <- locationState[[1]]
    
    lsKinds <- lapply(locationState$lsValues, function(x) x$"lsKind")
    
    valuesToDelete <- locationState$lsValues[lsKinds %in% c("annotation id")]
    
    if (length(valuesToDelete) > 0) {
      tryCatch({
        response <- getURL(
          paste0(configList$reportRegistrationURL, "delete/", valuesToDelete[[1]]$numericValue),
          customrequest='DELETE',
          httpheader=c('Content-Type'='application/json'),
          postfields=toJSON(experiment))
      }, error = function(e) {
        stop("There was an error deleting the old experiment annotation. Please contact your system adminstrator.")
      })
      if(!grepl("Deleted Annotation", response)) {
        stop (paste("The loader was unable to delete the old experiment annotation. Instead, it got this response:", response))
      }
    }
  }
}
customSourceFileMove <- function(fileStartLocation, fileName, fileService, experiment, recordedBy) {
  #This moves the source file to a custom location defined by the company
  
  require("XML")
  
  tryCatch({
    response <- postForm(fileService,
                         FILE = fileUpload(filename = fileStartLocation),
                         OWNING_URL = paste0(racas::applicationSettings$serverPath, "experiments/codename/", experiment$codeName),
                         CREATED_BY_LOGIN = recordedBy)
    parsedXML <- xmlParse(response)
    serverFileLocation <- xmlValue(xmlChildren(xmlChildren(parsedXML)$dnsFile)$corpFileName)
  }, error = function(e) {
    stop(paste("There was an error contacting the file service:", e))
  })
  
  file.remove(fileStartLocation)
  return(serverFileLocation)
}
