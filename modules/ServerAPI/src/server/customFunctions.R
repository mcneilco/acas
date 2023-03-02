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
#' @param sourceLocation current location of file, relative from working directory or absolute
#' @param recordedBy logged in username
#' @param fileName name of the file to save
#' @param entity entity object
#' @param deleteOldFile whether to delete the old file or not
#' @param additionalPath additional path to append to the end of the file path
#' @return character file code or path relative from privateUploads
#' @export
#'
customSourceFileMove <- function(sourceLocation, recordedBy, fileName = NA, entityType = NA, entity = NULL, 
                                               deleteOldFile = TRUE, additionalPath = "") {
  if (is.na(fileName)) {
    fileName <- basename(sourceLocation)
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
  targetLocation <- file.path(folder, fileName)

  # Remove the relative file path from the sourceLocation to get a shortLocation for the service
  shortSourceLocation <- gsub(paste0(racas::applicationSettings$server.file.server.path,"/"), "", sourceLocation)
  request <- list(list(
    "sourceLocation" = shortSourceLocation,
    "targetLocation" = targetLocation,
    metadata = list("recordedBy" = recordedBy)
  ))
  url <- paste0(racas::applicationSettings$server.nodeapi.path, "/api/moveDataFiles?deleteSourceFileOnSuccess=true")
  result <- fromJSON(racas::postURLcheckStatus(url, toJSON(request), requireJSON = TRUE))

  if(!is.null(result[[1]]$error)) {
    stop(result[[1]]$error)
  }
  
  return(result[[1]]$targetLocation)
}

moveAllEntityFilesToGCS <- function() {

  racasMessenger$logger$info("Initialize moving all entity files to GCS")
  # The Google Storage API handles only one file at a time, so for bulk uploads you need to use a loop or an apply function. To test it, we can download two random pdfs.
  localRelativePath <- racas::applicationSettings$server.file.server.path
  for(entityType in names(entityFileStorePaths)) {
    entityFolder <- entityFileStorePaths[entityType]
    racasMessenger$logger$info(paste0("Moving files for entity type: ", entityType))
    entityFolderPath <- file.path(racas::applicationSettings$server.file.server.path, entityFolder)
    
    entityFiles <- list.files(entityFolderPath, recursive = TRUE)
    
    for(entityFile in entityFiles) {
      racasMessenger$logger$info(paste0("Moving file: ", entityFile))
      # Get the code name from the first subfolder
      codeName <- strsplit(entityFile, "/")[[1]][1]
      # Try and get the entity from the database using the code name
      # Otherwise, fall back to creting a fake entity so that customSourceFileMove can still work
      entity <- NULL
      if(entityType %in% c("experiment", "protocol")) {
        try(entity <- racas::getEntityByCodeName(codeName, entityFolder, include = NULL), silent = TRUE)
        if(is.null(entity)) {
          racasMessenger$logger$info(paste0("Entity not found in database, saving file anyway: ", codeName))
          entity <- list(codeName = codeName)
          recrodedBy <- "acas"
        } else {
          recordedBy <- entity$recordedBy
        }
        recordedBy <- entity$recordedBy
      } else if (entityType == "cmpdreg_bulkload") {
        entity <- NA
        recordedBy <- "acas"
      }
      relativePath <- getUploadedFilePath(file.path(entityFolder, entityFile))
      result <- customSourceFileMove(relativePath, recordedBy, fileName = NA, entityType = entityType, entity = entity, deleteOldFile = TRUE, additionalPath = "")
      # Decided to not delete the file from the local server
    }
  }
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