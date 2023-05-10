calculateTreatmemtGroupID <- function(results, inputFormat, stateGroups, resultTypes) {
  # Returns a column that will be added to results that separates treatmentGroups
  
  # insert formats with custom code in "if" statements
  if(inputFormat == "") {

  } else {
    # Standard code
    treatmentGrouping <- which(lapply(stateGroups, getElement, "stateKind") == "treatment")
    groupingColumns <- stateGroups[[treatmentGrouping]]$valueKinds
    groupingColumns <- resultTypes$DataColumn[resultTypes$valueKind %in% groupingColumns]
    if(stateGroups[[treatmentGrouping]]$includesCorpName) {
      groupingColumns <- c(groupingColumns, "Corporate Batch ID")
    }
    a <- do.call(paste,results[,groupingColumns, drop=FALSE])
    return(as.numeric(factor(a)))
  }
}

#' Move file to file server
#'
#' @param sourceLocations current location of files, relative from working directory or absolute
#' @param recordedBy logged in username
#' @param fileName name of the file to save
#' @param entity entity object
#' @param deleteOldFile whether to delete the old file or not
#' @param additionalPath additional path to append to the end of the file path
#' @return character file code or path relative from privateUploads
#' @export
#'
customSourceFileMove <- function(sourceLocations, recordedBy, fileNames = NA, entityType = NA, entity = NULL, 
                                               deleteOldFile = TRUE, additionalPath = "") {
                                                
  for (i in 1:length(fileNames)) {
    if(is.na(fileNames[i])) {
      fileNames[i] <- basename(sourceLocations[i])
    }
  }

  # If the entity type is specified then use the entity_paths table to get the path
  folder <- ""
  if(!is.na(entityType)) {
    folder <-entityFileStorePaths[entityType]
  }

  # If the entity is specified then use the entity code name to get the path
  if(!is.null(entity)) {
    folder <- paste0(folder, "/", entity$codeName)
  }

  # If the additional path is specified then append it to the end of the path
  if(!is.na(additionalPath) && additionalPath != "") {
    folder <- paste0(folder, "/", additionalPath)
  }

  # Join the folder and file name together but if folder is empty then just use the file name
  targetLocations <- unlist(lapply(fileNames, function(x) {file.path(folder, x)}))

  # Remove the relative file path from the sourceLocation to get a shortLocation for the service
  shortSourceLocations <- unlist(lapply(sourceLocations, function(x) {gsub(paste0(racas::applicationSettings$server.file.server.path,"/"), "", x)}))
  request <- list()
  for (i in 1:length(sourceLocations)) {
    request[[i]] <- list(
      "sourceLocation" = shortSourceLocations[i],
      "targetLocation" = targetLocations[i],
      metaData = list("recordedBy" = recordedBy)
    )
  }
  request <- toJSON(request)
  racasMessenger$logger$info(paste0("/api/moveDataFiles?deleteSourceFileOnSuccess=true request: ", toJSON(request)))
  url <- paste0(racas::applicationSettings$server.nodeapi.path, "/api/moveDataFiles?deleteSourceFileOnSuccess=", tolower(deleteOldFile))
  results <- fromJSON(racas::postURLcheckStatus(url, request, requireJSON = TRUE))

  savedTargetLocations <- c()
  for(result in results) {
    if(!is.null(result$error)) {
      racasMessenger$logger$error(paste0("Error moving file: ", result$sourceLocation, " to ", result$targetLocation))
      stop(result$error)
    } else {
      racasMessenger$logger$info(paste0("File moved successfully to ", result$targetLocation))
      savedTargetLocations <- c(savedTargetLocations, result$targetLocation)
    }
  }

  return(savedTargetLocations)
}

createRawOnlyTreatmentGroupData <- function(subjectData, sigFigs, inputFormat) {
  # Calculates the treatment group data when averaging subject level data
  if(inputFormat == "") {
    
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
      analysisGroupID = subjectData$analysisGroup[1],
      stateGroupIndex = subjectData$stateGroupIndex[1],
      stateID = if(all(is.na(subjectData$stateID))) NA else max(subjectData$stateID, na.rm = T),
      stateVersion = subjectData$stateVersion[1],
      valueType = subjectData$valueType[1],
      numberOfReplicates = sum(!is.na(subjectData$numericValue)),
      uncertaintyType = if(!is.na(resultValue)) "standard deviation" else NA,
      uncertainty = if(sum(!is.na(subjectData$numericValue)) > 2) {sd(subjectData$numericValue, na.rm=TRUE)} else NA,
      stringsAsFactors=FALSE))
  }
}