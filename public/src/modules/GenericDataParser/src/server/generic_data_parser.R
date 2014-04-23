# generic_data_parser.R
#
#
# Brian Bolt
# brian@mcneilco.com
#
# Sam Meyer
# sam@mcneilco.com
# Copyright 2012 John McNeil & Co. Inc.
#########################################################################
# Parses a "Generic" formatted excel file into an upload file for ACAS
#########################################################################

#TODO:
# Deploy server changes to host3
# Figure out how to store values either in protocol or in a text file in a way that will work for UI as well
# Information to store: lockcorpname, states to create, replaceFakeCorpBatchId
# Don't blow up when all points are excluded
# Deal with numbers in the assay date area
# Error handling for project service

# How to run: 
#   Before running: 
#     Set your working directory to the checkout of SeuratAddOns
#     setwd("~/Documents/ACAS/")
#   To run:
#     parseGenericData(list(pathToGenericDataFormatExcelFile, dryRun = TRUE, ...))
#     Example: 
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/explicit_ACAS_format.xlsx", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/explicit_ACAS_format.xlsx", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/DR_SaveToExistingExperiment.xlsx", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/DR_SaveToExistingExperiment.xlsx", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/Mia-Paca.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/Mia-Paca.xls", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_error.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_Curve.xls", reportFile="serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_error.xls", dryRunMode = "false", user="smeyer"))

# Other files:
# "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve.xls"
# "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve_Example2.xls"
# "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve2.xls"
# "public/src/modules/GenericDataParser/spec/specFiles/LindaExampleData.xls"

#########################################################################

library(racas)
source("public/src/conf/customFunctions.R")
source("public/src/conf/genericDataParserConfiguration.R")

#####
# Define Functions
validateMetaData <- function(metaData, configList, formatSettings = list(), errorEnv = NULL) {
  # Valides the meta data section
  #
  # Args:
  #   metaData: 			A "data.frame" of two columns containing the Meta data for the experiment
  #	expectedDataFormat:	A "data.frame" of three columns and the same number of rows as metaData describing the Meta data data frame and it's expected classes
  #							Column 1) headers		- String values of the experiment meta data to extract
  #							Column 2) class		- String value of the expected class of the given value
  #							Column 3) isNullable	- Boolean containing whether the field is nullable or not
  # Returns:
  #  A data frame containing the validated meta data
  
  require('gdata')
  
  # Turn NA into "NA"
  metaDataNames <- names(metaData)
  metaData <- as.data.frame(lapply(metaData, function(x) if(is.na(x)) "NA" else x), stringsAsFactors=FALSE)
  names(metaData) <- metaDataNames
  
  # Check if extra data was picked up that should not be
  if (length(metaData[[1]])>1) {
    extraData <- c(as.character(metaData[[1]][2:length(metaData[[1]])]),
                   as.character(metaData[[2]][2:length(metaData[[2]])]))
    extraData <- extraData[extraData!=""]
    addError(paste0("Extra data were found next to the Experiment Meta Data ",
                    "and should be removed: '",
                    paste(extraData, collapse="', '"), "'"),
             errorEnv)
    metaData <- metaData[1,]
  }
  
  if (is.null(metaData$Format)) {
    stop("A Format must be entered in the Experiment Meta Data.")
  }
  
  useExisting <- metaData$Format %in% c("Use Existing Experiment", "Precise For Existing Experiment")
  
  if (useExisting) {
    expectedDataFormat <- data.frame(
      headers = c("Format","Experiment Code Name"),
      class = c("Text", "Text"),
      isNullable = c(FALSE, FALSE)
    )
  } else {
    expectedDataFormat <- data.frame(
      headers = c("Format","Protocol Name","Experiment Name","Scientist","Notebook","In Life Notebook", 
                  "Short Description", "Experiment Keywords", "Page","Assay Date"),
      class = c("Text", "Text", "Text", "Text", "Text", "Text", "Text", "Text", "Text", "Date"),
      isNullable = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE)
    )
    
    if (!is.null(configList$client.include.project) && configList$client.include.project && !useExisting) {
      expectedDataFormat <- rbind(expectedDataFormat, data.frame(headers = "Project", class= "Text", isNullable = FALSE))
    }
    if (length(formatSettings) > 0) {
      expectedDataFormat <- rbind(expectedDataFormat, formatSettings[[as.character(metaData$Format)]]$extraHeaders)
    }
    
    # Allows Assay Completion Date to be the same as Assay Date
    if ("Assay Completion Date" %in% names(metaData)) {
      names(metaData)[names(metaData) == "Assay Completion Date"] <- "Assay Date"
    }
  }
  
  # Extract the expected headers from the input variable
  expectedHeaders <- expectedDataFormat$headers
  
  # Validate that there are no missing required columns, add errors for any expected fields that are missing
  missingColumns <- expectedHeaders[is.na(match(toupper(expectedHeaders),toupper(names(metaData)))) 
                                    & !(expectedDataFormat$isNullable)]
  for(m in missingColumns) {
    addError(paste("The loader could not find required Experiment Meta Data row:",m), errorEnv)
  }
  
  # Validate that the matched columns are of the same data type and non-nullable fields are not null
  # return modified metaData with results of the validation of each field
  matchedColumnVector <- !is.na(match(toupper(names(metaData)), toupper(expectedHeaders)))
  matchedColumns <- metaData[, matchedColumnVector]
  
  # Deals with R returning a vector rather than a data.frame when only one is selected
  if (sum(matchedColumnVector) == 1) {
    matchedColumns <- as.data.frame(matchedColumns)
    names(matchedColumns) <- names(metaData)[matchedColumnVector]
  }
  validatedMetaData <- metaData
  for(m in 1:length(matchedColumns)) {
    # Get the name of the column
    column <- names(matchedColumns)[m]
    
    # Find if it is Nullable
    nullable <- expectedDataFormat$isNullable[expectedDataFormat$headers == column]
    
    
    
    expectedDataType <- as.character(expectedDataFormat$class[expectedDataFormat$headers == column])
    receivedValue <- matchedColumns[1,m]
    
    if(!nullable && (is.null(receivedValue) | receivedValue==""  | receivedValue=="")) {
      addError(paste0("The loader could not find an entry for '", column, "' in the Experiment Meta Data"), errorEnv = errorEnv)
    }
    
    validationFunction <- switch(expectedDataType, 
                                 "Date" = validateDate, 
                                 "Number" = validateNumeric, 
                                 "Text" = validateCharacter,  
                                 stop(paste("Internal Error: unrecognized class required by the loader:",expectedDataType))
    )
    validatedData <- validationFunction(receivedValue)
    validatedMetaData[,column] <- validatedData
  }
  
  # Add warnings for additional columns sent that are not expected
  additionalColumns <- names(metaData)[is.na(match(names(metaData),expectedHeaders))]
  if (length(additionalColumns) > 0) {
    if (length(additionalColumns) == 1) {
      warning(paste0("The loader found an extra Experiment Meta Data row that will be ignored: '", 
                     additionalColumns, 
                     "'. Please remove this row."))
    } else {
      warning(paste0("The loader found extra Experiment Meta Data rows that will be ignored: '", 
                     paste(additionalColumns,collapse="' ,'"), 
                     "'. Please remove these rows."))
    }
  }
  
  if (!is.null(metaData$Project)) {
    validatedMetaData$Project <- validateProject(validatedMetaData$Project, configList) 
  }
  if (!is.null(metaData$Scientist)) {
    validatedMetaData$Scientist <- validateScientist(validatedMetaData$Scientist, configList) 
  }
  
  if(!is.null(validatedMetaData$"Experiment Name") && grepl("CREATETHISEXPERIMENT$", validatedMetaData$"Experiment Name")) {
    validatedMetaData$"Experiment Name" <- trim(gsub("CREATETHISEXPERIMENT$", "", validatedMetaData$"Experiment Name"))
    duplicateExperimentNamesAllowed <- TRUE
  } else {
    duplicateExperimentNamesAllowed <- FALSE
  }
  
  return(list(validatedMetaData=validatedMetaData, duplicateExperimentNamesAllowed=duplicateExperimentNamesAllowed, useExisting=useExisting))
}
validateTreatmentGroupData <- function(treatmentGroupData,calculatedResults,tempIdLabel) {
  # Valides the treatment group data (for now, this only validates the temp id's)
  #
  # Args:
  #   treatmentGroupData: 	A "data.frame" of the treatment group data
  #	  calculatedResuluts:	  A "data.frame" of the calculated results
  #   tempIdLabel:          A character string of the label that is for the temp Id
  #
  # Returns:
  #   NULL
  
  # Get a list of any temp id's that are text (not allowed)
  #textTempIds <- grep("\\S",calculatedResults$"stringValue"[calculatedResults$"valueKind"==tempIdLabel],value=TRUE)
  
  # Get a list of the temporary id's in the calculated results
  tempIdList <- calculatedResults$"stringValue"[calculatedResults$"valueKind"==tempIdLabel]
  
  # Find if any of the temporoary id's for the treatment groups do not have a match in the list
  missingTempIds <- setdiff(treatmentGroupData[,tempIdLabel],tempIdList)
  missingTempIds <- missingTempIds[!is.na(missingTempIds)]
  
  # Report any errors
#   if (length(textTempIds)>1) {
#     errorList <<- c(errorList, paste0("In the Calculated Results section, there are ", tempIdLabel, "'s that have text: '", 
#                                       paste(textTempIds, collapse="', '"), "'. Remove text from all temp id's."))
#   } else if (length(textTempIds)>0) {
#     errorList <<- c(errorList, paste0("In the Calculated Results section, there is a ", tempIdLabel, " that has text: '", 
#                                       textTempIds, "'. Remove text from all temp id's."))
#   } else if (length(missingTempIds)>1) {
  if (length(missingTempIds)>1) {
    errorList <<- c(errorList, paste0("In the Raw Results section, there are temp id's that have no match in the Calculated Results section: '", 
                                      paste(missingTempIds, collapse="', '"),
                                      "'. Please ensure that all id's have a matching row in the Calculated Results."))
  } else if (length(missingTempIds)>0) {
    errorList <<- c(errorList, paste0("In the Raw Results section, there is a temp id that has no match in the Calculated Results section: '", 
                                      missingTempIds,
                                      "'. Please ensure that all id's have a matching row in the Calculated Results."))
  }
  
  # Find if there are temp ids without raw results
  extraTempIds <- setdiff(tempIdList,treatmentGroupData[,tempIdLabel])
  extraTempIds <- extraTempIds[!is.na(extraTempIds)]
  if (length(extraTempIds)>1) {
    warning(paste0("In the Calculated Results section, there are ", tempIdLabel, "'s that have no matching data in the Raw Results section: '", 
                   paste(extraTempIds, collapse="', '"), "'. Without raw data, a curve cannot be drawn throught the points."))
  } else if (length(extraTempIds)>0) {
    warning(paste0("In the Calculated Results section, there is a ", tempIdLabel, " that has no match in the Raw Results section: '", 
                   extraTempIds, "'. Without raw data, a curve cannot be drawn throught the points."))
  }
  return(NULL) 
}
validateCalculatedResults <- function(calculatedResults, dryRun, curveNames, testMode = FALSE, replaceFakeCorpBatchId="", mainCode, errorEnv = NULL) {
  # Valides the calculated results (for now, this only validates the mainCode)
  #
  # Args:
  #	  calculatedResuluts:	      A "data.frame" of the calculated results
  #   testMode:                 A boolean
  #   dryRun:                   A boolean
  #   replaceFakeCorpBatchId:   A string that is not a corp batch id, will be ignored by the batch check, and will be replaced by a column of the same name
  #   curveNames:               A character vector of curveNames that will be needed as extra valueKinds
  #
  # Returns:
  #   a "data.frame" of the validated calculated results
  
  require(data.table)
  
  # Get the current batch Ids
  batchesToCheck <- calculatedResults$originalMainID != replaceFakeCorpBatchId
  batchIds <- unique(calculatedResults$batchCode[batchesToCheck])
  newBatchIds <- getPreferredId(batchIds, testMode=testMode)
  
  # If the preferred Id service does not return anything, errors will already be thrown, just move on
  if (is.null(newBatchIds)) {
    return(calculatedResults)
  }
  
  # Give warning and error messages for changed or missing id's
  for (batchId in newBatchIds) {
    if (batchId["preferredName"] == "") {
      addError(paste0(mainCode, " '", batchId["requestName"], 
                                        "' has not been registered in the system. Contact your system administrator for help."))
    } else if (as.character(batchId["requestName"]) != as.character(batchId["preferredName"])) {
      warning(paste0("A ", mainCode, " that you entered, '", batchId["requestName"], 
                     "', was replaced by preferred ", mainCode, " '", batchId["preferredName"], 
                     "'. If this is not what you intended, replace the ", mainCode, " with the correct ID."))
    }
  }

  # Put the batch id's into a useful format
  preferredIdFrame <- as.data.frame(do.call("rbind", newBatchIds), stringsAsFactors=FALSE)
  names(preferredIdFrame) <- names(newBatchIds[[1]])
  preferredIdFrame <- as.data.frame(lapply(preferredIdFrame, unlist), stringsAsFactors=FALSE)

  # Use the data frame to replace Corp Batch Ids with the preferred batch IDs
  if (!is.null(preferredIdFrame$referenceName)) {
    prefDT <- as.data.table(preferredIdFrame)
    prefDT[ referenceName == "", referenceName := preferredName ]
    preferredIdFrame <- as.data.frame(prefDT)
    calculatedResults[[mainCode]][batchesToCheck] <- preferredIdFrame$referenceName[match(calculatedResults[[mainCode]][batchesToCheck],preferredIdFrame$requestName)]
  } else {
    calculatedResults[[mainCode]][batchesToCheck] <- preferredIdFrame$preferredName[match(calculatedResults[[mainCode]][batchesToCheck],preferredIdFrame$requestName)]
  }
  
  #### ================= Check the value kinds =======================================================
  neededValueKinds <- c(calculatedResults$"valueKind", curveNames)
  neededValueKindTypes <- c(calculatedResults$Class, rep("Text", length(curveNames)))
  
  validateValueKinds(neededValueKinds, neededValueKindTypes, dryRun)
  
  # Return the validated results
  return(calculatedResults)
}
getHiddenColumns <- function(classRow, errorEnv) {
  # Get information about which columns to hide (publicData = FALSE)
  #
  # Args:
  #   classRow:   		A character vector of the Datatypes of the calculated results with (hidden) to mark hidden points
  #
  # Returns:
  #	  a boolean vector of which results are hidden
  
  # Pull out info about hidden columns
  dataShown <- gsub(".*\\((.*)\\).*||.*", "\\1",classRow)
  dataShown[is.na(dataShown)] <- ""
  hiddenColumns <- grepl("hidden",dataShown)
  shownColumns <- grepl("shown",dataShown)
  defaultColumns <- dataShown %in% ""
  unknownColumns <- which(!hiddenColumns & !shownColumns & !defaultColumns)
  
  # Error handling for unknown entries rather than 'shown' or 'hidden'
  if(length(unknownColumns) > 0) {
    if(length(unknownColumns) == 1) {
      addError(paste0("In Datatype column ",getExcelColumnFromNumber(unknownColumns),", there is an entry in the parentheses that cannot be understood: '", 
                                       dataShown[unknownColumns],
                                       "'. Please enter 'shown' or 'hidden'."), errorEnv)
    } else {
      addError(paste0("In Datatype columns ",paste0(sapply(unknownColumns,getExcelColumnFromNumber),collapse = ", "), 
                                       ", there are unknown entries in the parentheses that cannot be understood: '", 
                                       paste0(dataShown[unknownColumns], collapse="', '"),
                                       "'. Please enter 'shown' or 'hidden'."), errorEnv)
    }
  }
  return(hiddenColumns)
}
getLinkColumns <- function(classRow, errorEnv) {
  # Get information about which column is a link to lower levels
  #
  # Args:
  #   classRow:     	A character vector of the Datatypes of the calculated results with [link] to mark links
  #
  # Returns:
  #	  a numeric vector of which results are links
  
  # Pull out info about hidden columns
  dataShown <- gsub(".*\\[(.*)\\].*||.*", "\\1",classRow)
  dataShown[is.na(dataShown)] <- ""
  linkColumns <- grepl("link",dataShown)
  defaultColumns <- dataShown %in% ""
  unknownColumns <- which(!linkColumns & !defaultColumns)
  
  # Error handling for unknown entries rather than 'link'
  if(length(unknownColumns) > 0) {
    if(length(unknownColumns) == 1) {
      addError(paste0("In Datatype column ", getExcelColumnFromNumber(unknownColumns),
                      ", there is an entry in the brackets that cannot be understood: '", 
                      dataShown[unknownColumns],
                      "'. Please enter 'link' or nothing."), errorEnv)
    } else {
      addError(paste0("In Datatype columns ", paste0(sapply(unknownColumns,getExcelColumnFromNumber),collapse = ", "), 
                      ", there are unknown entries in the brackets that cannot be understood: '", 
                      paste0(dataShown[unknownColumns], collapse="', '"),
                      "'. Please enter 'link' or nothing."), errorEnv)
    }
  }
  
  if (sum(linkColumns) > 1) {
    stop("Only one column may be marked as [link].")
  }
  
  return(linkColumns)
}
validateCalculatedResultDatatypes <- function(classRow,LabelRow, lockCorpBatchId = TRUE, clobColumns=c(), errorEnv = NULL) {
  # Checks that datatypes entered in the Datatype row of the calculated results are valid
  #
  # Args:
  #   classRow:     	  A character vector of the Datatypes of the calculated results (with hidden information as well)
  #   labelRow:         A character vector with the labels for each column
  #   lockCorpBatchId:  A boolean marking whether the corp batch id must be in the leftmost column
  #
  # Returns:
  #	  a character vector of the datatypes
  
  require('gdata')
  
  if(lockCorpBatchId) {
    # Check that the first entry says Datatype (users may try to enter data if we don't warn them)
    if (classRow[1]!="Datatype") {
      addError(paste0("The first row below 'Calculated Results' must begin with 'Datatype'. ",
                                       "Right now, it is '", classRow[1], "'."), errorEnv)
    }
  }
  
  # Remove the hidden/shown info
  classRow <- trim(gsub("\\(.*)","",classRow))
  
  # Remove the link info
  # Remove the hidden/shown info
  classRow <- trim(gsub("\\[.*]","",classRow))
  
  classRow[clobColumns] <- "Clob"
  
  # Check if the datatypes are entered correctly
  badClasses <- setdiff(classRow[1:length(classRow)>1], c("Text","Number","Date","Clob", "Code","", NA))
  
  # Let the user know about empty datatypes
  emptyClasses <- which(is.na(classRow) | trim(classRow) == "")
  if(length(emptyClasses)>0) {
    if(length(emptyClasses)==1) {
      warning(paste0("Column ", getExcelColumnFromNumber(emptyClasses), " (" , LabelRow[emptyClasses], ") does not have a Datatype entered. ",
                     "The loader will attempt to interpret entries in column ", 
                     getExcelColumnFromNumber(emptyClasses), 
                     " as numbers, but it may not work very well. Please enter 'Number','Text', or 'Date'."))
    } else {
      warning(paste("Columns", 
                    paste(sapply(emptyClasses[1:length(emptyClasses)-1],getExcelColumnFromNumber),collapse=", "), 
                    "and", getExcelColumnFromNumber(tail(emptyClasses,n=1)), 
                    "do not have a Datatype entered.",
                    "The loader will attempt to interpret entries in columns",
                    paste(sapply(emptyClasses[1:length(emptyClasses)-1],getExcelColumnFromNumber),collapse=", "), 
                    "and", getExcelColumnFromNumber(tail(emptyClasses,n=1)),
                    "as numbers, but it may not work very well. Please enter 'Number','Text', or 'Date'."))
    }
    classRow[is.na(classRow) | classRow==""] <- "Number"
  }
  
  if(length(badClasses)>0) {
    # Change common datatypes to those used by R
    oldClassRow <- classRow
    for(i in which(classRow %in% badClasses)) {
      classRow[i][grep(pattern = "text", classRow[i], ignore.case = TRUE)] <- "Text"
      classRow[i][grep(pattern = "character", classRow[i], ignore.case = TRUE)] <- "Text"
      classRow[i][grep(pattern = "string", classRow[i], ignore.case = TRUE)] <- "Text"
      classRow[i][grep(pattern = "num", classRow[i], ignore.case = TRUE)] <- "Number"
      classRow[i][grep(pattern = "integer", classRow[i], ignore.case = TRUE)] <- "Number"
      classRow[i][grep(pattern = "float", classRow[i], ignore.case = TRUE)] <- "Number"
      classRow[i][grep(pattern = "double", classRow[i], ignore.case = TRUE)] <- "Number"
      classRow[i][grep(pattern = "date", classRow[i], ignore.case = TRUE)] <- "Date"
      classRow[i][grep(pattern = "clob", classRow[i], ignore.case = TRUE)] <- "Clob"
      if (classRow[i] != oldClassRow[i] & !is.na(LabelRow[i])) {
        warning(paste0("In column \"", LabelRow[i], "\", the loader found '", oldClassRow[i], 
                       "' as a datatype and interpreted it as '", classRow[i], 
                       "'. Please enter 'Number','Text', or 'Date'."))
      }
    }
    
    # Those that can't be interpreted throw errors
    unhandledClasses <- setdiff(classRow[1:length(classRow)>1],c("Text","Number","Date","Clob",""))
    if (length(unhandledClasses)>0) {
      addError(paste0("The loader found classes in the Datatype row that it does not understand: '",
                      paste(unhandledClasses,collapse = "', '"),
                      "'. Please enter 'Number','Text', or 'Date'."), errorEnv)
    }
  }
  
  # Return classRow
  return(classRow)
}
validateValueKinds <- function(neededValueKinds, neededValueKindTypes, dryRun) {
  # Checks that column headers are valid valueKinds (or creates them if they are new)
  #
  # Args:
  #   neededValueKinds:       A character vector listed column headers
  #   neededValueKindTypes:   A character vector of the valueTypes of the above kinds
  #
  # Returns:
  #	  NULL
  
  require(rjson)
  require(RCurl)
  
  # Throw errors for words used with special meanings by the loader
  internalReservedWords <- c("concentration", "time")
  usedReservedWords <- internalReservedWords %in% neededValueKinds
  if (any(usedReservedWords)) {
    stop(paste0(sqliz(internalReservedWords[usedReservedWords]), " is reserved and cannot be used as a column header."))
  }
  
  tryCatch({
    currentValueKindsList <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, "valuekinds/")))
  }, error = function(e) {
    stop("Internal Error: Could not get current value kinds")
  })
  if (length(currentValueKindsList)==0) stop ("Setup error: valueKinds are missing")
  currentValueKinds <- sapply(currentValueKindsList, getElement, "kindName")
  matchingValueTypes <- sapply(currentValueKindsList, function(x) x$lsType$typeName)
  
  newValueKinds <- setdiff(neededValueKinds, currentValueKinds)
  oldValueKinds <- intersect(neededValueKinds, currentValueKinds)
  
  # Check that the value kinds that have been entered before have the correct Datatype (valueType)
  oldValueKindTypes <- neededValueKindTypes[match(oldValueKinds, neededValueKinds)]
  oldValueKindTypes <- c("numericValue", "stringValue", "dateValue", "clobValue")[match(oldValueKindTypes, c("Number", "Text", "Date", "Clob"))]
  currentValueKindTypeFrame <- data.frame(currentValueKinds,  matchingValueTypes, stringsAsFactors=FALSE)
  oldValueKindTypeFrame <- data.frame(oldValueKinds, oldValueKindTypes, stringsAsFactors=FALSE)
  
  comparisonFrame <- merge(oldValueKindTypeFrame, currentValueKindTypeFrame, by.x = "oldValueKinds", by.y = "currentValueKinds")
  wrongValueTypes <- comparisonFrame$oldValueKindTypes != comparisonFrame$matchingValueTypes
  
  # Throw errors if any values are of types that cannot be entered in SEL
  reservedValueKinds <- comparisonFrame$oldValueKinds[comparisonFrame$matchingValueTypes %in% c("codeValue", "fileValue", "urlValue", "blobValue")]
  if (length(reservedValueKinds) > 0) {
    stop(paste0("The column header ", sqliz(reservedValueKinds), " is reserved and cannot be used"))
  }
  
  if(any(wrongValueTypes)) {
    problemFrame <- data.frame(oldValueKinds = comparisonFrame$oldValueKinds)
    problemFrame$oldValueKindTypes <- c("Number", "Text", "Date", "Clob")[match(comparisonFrame$oldValueKindTypes, c("numericValue", "stringValue", "dateValue", "clobValue"))]
    problemFrame$matchingValueKindTypes <- c("Number", "Text", "Date", "Clob")[match(comparisonFrame$matchingValueTypes, c("numericValue", "stringValue", "dateValue", "clobValue"))]
    problemFrame <- problemFrame[wrongValueTypes, ]
    
    for (row in 1:nrow(problemFrame)) {
      errorList <<- c(errorList, paste0("Column header '", problemFrame$oldValueKinds[row], "' is registered in the system as '", problemFrame$matchingValueKindTypes[row],
                                        "' instead of '", problemFrame$oldValueKindTypes[row], "'. Please enter '", problemFrame$matchingValueKindTypes[row],
                                        "' in the Datatype row for '", problemFrame$oldValueKinds[row], "'."))
    }
  }
  
  # Warn about any new valueKinds
  if (length(newValueKinds) > 0) {
    warning(paste0("The following column headers have never been loaded in an experiment before: '", 
                   paste(newValueKinds,collapse="', '"), "'. If you have loaded a similar experiment before, please use the same",
                   " headers that were used previously. If this is a new protocol, you can proceed without worry."))
    if (!dryRun) {
      # Create the new valueKinds, using the correct valueType
      # TODO: also check that valueKinds have the correct valueType when being loaded a second time
      valueTypesList <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, "valuetypes")))
      valueTypes <- sapply(valueTypesList, getElement, "typeName")
      valueKindTypes <- neededValueKindTypes[match(newValueKinds, neededValueKinds)]
      valueKindTypes <- c("numericValue", "stringValue", "dateValue", "clobValue")[match(valueKindTypes, c("Number", "Text", "Date", "Clob"))]
      
      # This is for the curveNames, but would catch other added values as well
      valueKindTypes[is.na(valueKindTypes)] <- "stringValue"
      
      newValueTypesList <- valueTypesList[match(valueKindTypes, valueTypes)]
      newValueKindsUpload <- mapply(function(x, y) list(kindName=x, lsType=y), newValueKinds, newValueTypesList,
                                    SIMPLIFY = F, USE.NAMES = F)
      tryCatch({
        response <- getURL(
          paste0(racas::applicationSettings$client.service.persistence.fullpath, "valuekinds/jsonArray"),
          customrequest='POST',
          httpheader=c('Content-Type'='application/json'),
          postfields=toJSON(newValueKindsUpload))
      }, error = function(e) {
        errorList <<- c(errorList,paste("Error in saving new column headers:", e$message))
      })
    }
  }
  return(NULL)
}
getExcelColumnFromNumber <- function(number) {
  # Function to get an Excel-style column name from a column number
  # translated from php at http://stackoverflow.com/questions/3302857/algorithm-to-get-the-excel-like-column-name-of-a-number
  #
  #
  # Args:
  #    number:    A numeric vector of the column numbers
  #
  # Returns:
  #   An excel-style set of column names (i.e. "B" or "AR")
  
  if (any(number < 1)) {
    warning(paste("An invalid column number was attempted to be turned into a letter:",number))
    return("none")
  }
  
  return(vapply(X=number, FUN.VALUE=c(""), FUN=function(number) {
    divisionResult <- floor((number-1)/26)
    remainder <- (number-1)%%26
    if (divisionResult > 0) {
      return(paste0(getExcelColumnFromNumber(divisionResult),LETTERS[remainder+1]))
    } else {
      return(LETTERS[remainder+1])
    }
  }))
}
extractValueKinds <- function(valueKindsVector, ignoreHeaders = NULL) {
  # Extracts result types, units, conc, and conc units from a list of strings
  #
  # Args:
  #   valueKindsVector: A charactor vector containing result types in the format "Value Kind (units) [Conc ConcUnits]"
  #
  # Returns:
  #  A data frame containing the Value Kind, Units, concentration, and ConcUnits for each item in the result types character vector
  
  require('gdata')
  emptyValueKinds <- is.na(valueKindsVector) | (trim(valueKindsVector) == "")
  if (any(emptyValueKinds)) {
    stop(paste0("Column ", paste(getExcelColumnFromNumber(which(emptyValueKinds)), collapse=", "), " has a blank column header. ",
                "Please enter a column header before reuploading."))
  }
  
  dataColumns <- c()
  for(col in 1:length(valueKindsVector)) {
    column <- as.character(valueKindsVector[[col]])
    if(!toupper(column) %in% toupper(ignoreHeaders)) {
      dataColumns <- c(dataColumns,column)
    }
  }
  returnDataFrame <- data.frame("DataColumn" = array(dim = length(dataColumns)), "valueKind" = array(dim = length(dataColumns)), 
                                "Units" = array(dim = length(dataColumns)), "Conc" = array(dim = length(dataColumns)), 
                                "ConcUnits" = array(dim = length(dataColumns)))
  returnDataFrame$DataColumn <- dataColumns
  returnDataFrame$valueKind <- trim(gsub("\\[[^)]*\\]","",gsub("(.*)\\((.*)\\)(.*)", "\\1\\3",gsub("\\{[^}]*\\}","",dataColumns))))
  # This removes "Reported" from all columns
  returnDataFrame$valueKind <- trim(gsub("Reported","",returnDataFrame$valueKind))
  returnDataFrame$Units <- gsub(".*\\((.*)\\).*||(.*)", "\\1",dataColumns) 
  concAndUnits <- gsub("^([^\\[]+)(\\[(.+)\\])?(.*)", "\\3", dataColumns) 
  returnDataFrame$Conc <- as.numeric(gsub("[^0-9\\.]", "", concAndUnits))
  returnDataFrame$concUnits <- as.character(gsub("[^a-zA-Z]", "", concAndUnits))
  timeAndUnits <- gsub("([^\\{]+)(\\{(.*)\\})?.*", "\\3", dataColumns) 
  returnDataFrame$time <- as.numeric(gsub("[^0-9\\.]", "", timeAndUnits))
  returnDataFrame$timeUnit <- as.character(gsub("[^a-zA-Z]", "", timeAndUnits))
  
  # Return the validated Meta Data
  return(returnDataFrame)
}
organizeCalculatedResults <- function(calculatedResults, lockCorpBatchId = TRUE, replaceFakeCorpBatchId = NULL, 
                                      rawOnlyFormat = FALSE, stateGroups = NULL, splitSubjects = NULL, inputFormat, 
                                      mainCode, errorEnv = NULL, precise = F, link = NULL, calculateGroupingID = NULL) {
  # Organizes the calculated results section
  #
  # Args:
  #   calculatedResults: 			A "data.frame" of the columns containing the calculated results for the experiment
  #   lockCorpBatchId:        A boolean which marks if the mainCode is locked as the left column
  #   replaceFakeCorpBatchId: A string that is not a mainCode, will be ignored by the batch check, and will be replaced by a column of the same name
  #   rawOnlyFormat:          A boolean that describes the data format, subject based or analysis group based
  #   entityLevel:            "analysisGroup", "treatmentGroup", or "subject"
  #
  # Returns:
  #	  a data frame containing the organized calculated data
  
  library('reshape')
  library('gdata')
  
  if(ncol(calculatedResults) == 1) {
    stop("The rows below Calculated Results must have at least two columns filled: one for ", mainCode, "'s and one for data.")
  }
  
  # Check the Datatype row and get information from it
  hiddenColumns <- getHiddenColumns(as.character(unlist(calculatedResults[1,])), errorEnv)
  linkColumns <- getLinkColumns(as.character(unlist(calculatedResults[1,])), errorEnv)
  
  clobColumns <- vapply(calculatedResults, function(x) any(nchar(as.character(x)) > 255), c(TRUE))
  
  classRow <- validateCalculatedResultDatatypes(as.character(unlist(calculatedResults[1,])),as.character(unlist(calculatedResults[2,])), lockCorpBatchId, clobColumns, errorEnv)
  
  if(any(clobColumns & !(classRow=="Clob"))) {
    warning("One of your entries had more than 255 characters, so it will be saved as a 'Clob'. In the future, you should use this for your column header.")
  }
  
  # Remove Datatype Row
  calculatedResults <- calculatedResults[1:nrow(calculatedResults) > 1, ]
  
  # Precise column information (or default)
  stateTypeRow <- rep("data", length(classRow))
  stateKindRow <- rep("results", length(classRow))
  if (precise) {
    stateTypeRow <- calculatedResults[1:nrow(calculatedResults) == 1, ]
    stateKindRow <- calculatedResults[1:nrow(calculatedResults) == 2, ]
    calculatedResults <- calculatedResults[1:nrow(calculatedResults) > 2, ]
  }
  
  # Get the line containing the value kinds
  calculatedResultsValueKindRow <- calculatedResults[1:nrow(calculatedResults) == 1, ]
  
  # Make sure the mainCode is included
  if (lockCorpBatchId) {
    if(calculatedResultsValueKindRow[1] != mainCode && !precise) {
      stop(paste0("Could not find '", mainCode, "' column. The ", mainCode, 
                  " column should be the first column of the Calculated Results"))
    }
  } else {
    if(!(mainCode %in% unlist(calculatedResultsValueKindRow)) && !precise) {
      stop(paste0("Could not find '", mainCode, "' column."))
    }
  }
  
  if(any(duplicated(unlist(calculatedResultsValueKindRow)))) {
    addError(paste0("These column headings are duplicated: ",
                    paste(unlist(calculatedResultsValueKindRow[duplicated(unlist(calculatedResultsValueKindRow))]),collapse=", "),
                    ". All column headings must be unique."), errorEnv)
  }
  
  # These columns are not result types and should not be pivoted into long format
  ignoreTheseAsValueKinds <- c(mainCode, "originalMainID")
  if (!is.null(link)) {
    ignoreTheseAsValueKinds <- c(ignoreTheseAsValueKinds, "link")
  }
  
  # Call the function that extracts valueKinds, units, conc, concunits from the headers
  valueKinds <- extractValueKinds(calculatedResultsValueKindRow, ignoreTheseAsValueKinds)
  
  # Add data class and hidden/shown to the valueKinds
  notMainCode <- calculatedResultsValueKindRow != mainCode & (calculatedResultsValueKindRow != "link" | (is.null(link)))
  valueKinds$dataClass <- classRow[notMainCode]
  valueKinds$valueType <- translateClassToValueKind(valueKinds$dataClass)
  valueKinds$stateType <- stateTypeRow[notMainCode]
  valueKinds$stateKind <- stateKindRow[notMainCode]
  valueKinds$publicData <- !hiddenColumns[notMainCode]
  valueKinds$linkColumn <- linkColumns[notMainCode]
  
  # Grab the rows of the calculated data 
  results <- subset(calculatedResults, 1:nrow(calculatedResults) > 1)
  names(results) <- unlist(calculatedResultsValueKindRow)
  
  # Replace fake mainCodes with the column that holds replacements (the column must have the same name that is entered in mainCode)
  if (mainCode %in% names(results)) {
    results[[mainCode]] <- as.character(results[[mainCode]])
    results$originalMainID <- results[[mainCode]]
    if (!is.null(replaceFakeCorpBatchId) && replaceFakeCorpBatchId != "") {
      replacementRows <- results[[mainCode]] == replaceFakeCorpBatchId
      results[[mainCode]][replacementRows] <- as.character(results[replacementRows, replaceFakeCorpBatchId])
    }
  } else {
    results[[mainCode]] <- NA
    results$originalMainID <- NA
  }
  
  
  
  # Add a rowID to keep track of how rows match up
  results$rowID <- seq(1,length(results[[1]]))
  
  # Link to parent analysis group or subject
  results$linkID <- NA
  if (!is.null(link)) {
    results$linkID <- link$rowID[match(results$link, link$stringValue)]
  }
  
  #Temp ids for treatment groups or other grouping
  results$groupingID <- NA
  results$groupingID_2 <- NA
  if ((rawOnlyFormat || precise)  && is.function(calculateGroupingID)) {
    # calculateTreatmentGroupID is in customFunctions.R
    results$groupingID <- calculateGroupingID(results, inputFormat, stateGroups, valueKinds)
    if (!is.null(splitSubjects)) {
      results$groupingID_2 <- as.numeric(as.factor(do.call(paste0, args=as.list(results[splitSubjects]))))
    }
  }
  
  # Remove blank columns
  blankSpaces <- lapply(as.list(results), function(x) return (x != ""))
  emptyColumns <- unlist(lapply(blankSpaces, sum) == 0)
  valueKinds <- valueKinds[!(valueKinds$DataColumn %in% names(results)[emptyColumns]),]
  
  #Convert the results to long format
  longResults <- reshape(results, idvar=c("id"), ids=row.names(results), v.names="UnparsedValue",
                         times=valueKinds$DataColumn, timevar="valueKindAndUnit",
                         varying=list(valueKinds$DataColumn), direction="long", drop = names(results)[emptyColumns])
  
  # Add the extract result types information to the long format
  matchOrder <- match(longResults$"valueKindAndUnit",valueKinds$DataColumn)
  longResults$"valueUnit" <- valueKinds$Units[matchOrder]
  longResults$"concentration" <- valueKinds$Conc[matchOrder]
  longResults$"concentrationUnit" <- valueKinds$concUnits[matchOrder]
  longResults$Class <- valueKinds$dataClass[matchOrder]
  longResults$valueType <- valueKinds$valueType[matchOrder]
  longResults$"valueKind" <- valueKinds$valueKind[matchOrder]
  longResults$publicData <- valueKinds$publicData[matchOrder]
  longResults$time <- valueKinds$time[matchOrder]
  longResults$timeUnit <- valueKinds$timeUnit[matchOrder]
  longResults$stateType <- valueKinds$stateType[matchOrder]
  longResults$stateKind <- valueKinds$stateKind[matchOrder]
  longResults$linkColumn <- valueKinds$linkColumn[matchOrder]
  
  longResults$"UnparsedValue" <- trim(as.character(longResults$"UnparsedValue"))
  
  # Parse numeric data from the unparsed values
  # TODO: finish this for getting SD
  #stDevValues <- grepl("+/-", longResults$"UnparsedValue") & longResults$Class == "Number"
  #longResults$uncertainty[stDevValues]
  matches <- is.na(suppressWarnings(as.numeric(gsub("^(>|<)(.*)", "\\2", gsub(",","",longResults$"UnparsedValue")))))
  longResults$"numericValue" <- longResults$"UnparsedValue"
  longResults$"numericValue"[matches] <- ""
  
  # Parse string values from the unparsed values
  longResults$"stringValue" <- as.character(longResults$"UnparsedValue")
  longResults$"stringValue"[!matches & longResults$Class != "Text"] <- ""
  
  longResults$clobValue <- as.character(longResults$"UnparsedValue")
  longResults$clobValue[!longResults$Class == "Clob"] <- NA
  longResults$"stringValue"[longResults$Class == "Clob"] <- ""
  
  # Parse Operators from the unparsed value
  matchExpression <- ">|<"
  longResults$"valueOperator" <- longResults$"numericValue"
  matches <- gregexpr(matchExpression,longResults$"numericValue")
  regmatches(longResults$"valueOperator",matches, invert = TRUE) <- ""
  
  # Turn result values to numeric values
  longResults$"numericValue" <-  as.numeric(gsub(",","",gsub(matchExpression,"",longResults$"numericValue")))
  
  ### For the results marked as "Text":
  #   Set the stringValue to the original value
  #   Clear the other categories
  longResults$"numericValue"[which(longResults$Class=="Text")] <- rep(NA, sum(longResults$Class=="Text", na.rm = TRUE))
  longResults$"valueOperator"[which(longResults$Class=="Text")] <- rep(NA, sum(longResults$Class=="Text", na.rm = TRUE))
  
  ### For the results marked as "Date":
  #   Apply the function validateDate to each entry
  longResults$"dateValue" <- rep(NA, length(longResults$rowID))
  if (length(which(longResults$Class=="Date")) > 0) {
    dateTranslation <- lapply(unique(longResults$UnparsedValue[which(longResults$Class=="Date")]), validateDate)
    names(dateTranslation) <- unique(longResults$UnparsedValue[which(longResults$Class=="Date")])
    longResults$"dateValue"[which(longResults$Class=="Date" & 
                                      !is.na(longResults$UnparsedValue) &
                                      longResults$UnparsedValue != "")] <- unlist(dateTranslation[longResults$UnparsedValue[which(longResults$Class=="Date" & 
                                                                                                !is.na(longResults$UnparsedValue))]])
  }
  longResults$"numericValue"[which(longResults$Class=="Date")] <- rep(NA, sum(longResults$Class=="Date", na.rm=TRUE))
  longResults$"valueOperator"[which(longResults$Class=="Date")] <- rep(NA, sum(longResults$Class=="Date", na.rm=TRUE))
  longResults$"stringValue"[which(longResults$Class=="Date")] <- rep(NA, sum(longResults$Class=="Date", na.rm=TRUE))
  
  moveResults <- function(longResults, valueType) {
    longResults[valueType] <- rep(NA, nrow(longResults))
    if (any(longResults$valueType == valueType)) {
      naVector <- rep(NA, sum(longResults$valueType == valueType, na.rm=T))
      longResults$"numericValue"[longResults$valueType == valueType] <- naVector
      longResults$"valueOperator"[longResults$valueType == valueType] <- naVector
      longResults$"stringValue"[longResults$valueType == valueType] <- naVector
      longResults[longResults$valueType == valueType, valueType] <- as.character(longResults$"UnparsedValue")[longResults$valueType == valueType]
    }
    return(longResults)
  }
  
  ### For the results marked as "Code":
  longResults <- moveResults(longResults, "codeValue")
    
  ### For the results marked as "URL":
  longResults <- moveResults(longResults, "urlValue")
    
  ### For the results marked as "File":
  longResults <- moveResults(longResults, "fileValue")
  
  # Clean up the data frame to look nice (remove extra columns)
  row.names(longResults) <- 1:nrow(longResults)
  longResults$batchCode <- longResults[[mainCode]]
  
  organizedData <- longResults[c("batchCode","valueKind","valueUnit","concentration","concentrationUnit", "time", 
                                 "timeUnit", "numericValue", "stringValue","valueOperator", "dateValue","clobValue",
                                 "urlValue", "fileValue", "codeValue",
                                 "Class", "valueType", "valueKindAndUnit","publicData", "originalMainID", 
                                 "groupingID", "groupingID_2", "rowID", "stateType", "stateKind", "linkColumn", "linkID")]
  
  # Turn empty string into NA
  organizedData[organizedData==" " | organizedData=="" | is.na(organizedData)] <- NA
  
  # Remove rows
  organizedData <- organizedData[!(is.na(organizedData$"numericValue") 
                                   & is.na(organizedData$"stringValue") 
                                   & is.na(organizedData$"valueOperator")
                                   & is.na(organizedData$"dateValue")
                                   & is.na(organizedData$clobValue)
                                   & is.na(organizedData$urlValue)
                                   & is.na(organizedData$fileValue)
                                   & is.na(organizedData$codeValue)
                                   ), ]
  
  return(organizedData)
}
organizeRawResults <- function(rawResults, calculatedResults, mainCode) {
  # Valides and organizes the calculated results section
  #
  # Args:
  #   rawResults: 			  A "data.frame" of the columns containing the raw results for the experiment
  #   calculatedResults:  A "data.frame" of the columns containing the calculated results for the experiment
  #                         It is here used to connect the mainCodes
  #
  # Returns:
  #  A list containting:
  #	  subjectData: A data.frame of the subject data
  #   treatmentGroupData: A data.frame of the treatment group data
  #   xLabel: A string of the x Label
  #   yLabel: A string of the y Label
  
  require('reshape')
  
  # Sets the required names for the beginning of Raw Results
  rawResultsRequiredNames <- c("temp id","x","y","flag")
  
  # Check that Raw Results has the correct header
  if (length(unlist(rawResults[1,]))!=4 || sum(unlist(rawResults[1,]) != rawResultsRequiredNames)>0) {
    stop(paste("'Raw Results' must have four columns below it: 'temp id', 'x', 'y', and 'flag' --- Found:", 
               paste(unlist(sapply(rawResults[1,],as.character)), collapse=", ")))
  }
  
  #Check if Raw Results is empty
  if (length(rawResults[[1]])<2) {
    stop("The cell two below 'Raw Results' is empty. Either add a label for the '", rawResults[1,1], 
         "' column, or, if you do not wish to upload Raw Results, delete the section completely.")
  }
  
  # Turn the first row into headers
  names(rawResults) <- as.character(unlist(rawResults[1,]))
  rawResults <- subset(rawResults,1:nrow(rawResults) > 1)
  rawResults <- NULL
  # Get the results row
  rawResultsTypeRow <- rawResults[1,]
  
  # Get the labels as individual values
  tempIdLabel <- as.character(rawResultsTypeRow[rawResultsRequiredNames=="temp id"][[1]])
  xLabelWithUnit <-as.character(rawResultsTypeRow[rawResultsRequiredNames=="x"][[1]])
  yLabelWithUnit <-as.character(rawResultsTypeRow[rawResultsRequiredNames=="y"][[1]])
  flagLabel <- as.character(rawResultsTypeRow[rawResultsRequiredNames=="flag"][[1]])
  
  # Error handling of missing labels
  missingLabels <- list()
  if (tempIdLabel == "") {
    missingLabels <- c(missingLabels,"temp id")
  }
  if (xLabelWithUnit == "") {
    missingLabels <- c(missingLabels,"x")
  }
  if (yLabelWithUnit == "") {
    missingLabels <- c(missingLabels,"y")
  }
  if (flagLabel == "") {
    missingLabels <- c(missingLabels,"flag")
  }
  if (length(missingLabels)>0) {
    if (length(missingLabels)==1) {
      stop(paste0("In the Raw Results, add a label for column: '", paste0(missingLabels, collapse = "', '"), "'"))
    } else {
      stop(paste0("In the Raw Results, add labels for columns: '", paste0(missingLabels, collapse = "', '"), "'"))
    }
  }
  
  # Collect the result types' units
  valueKinds <- extractValueKinds(rawResultsTypeRow)
  
  # Get the x and y labels without units
  xLabel <- valueKinds$Type[match(xLabelWithUnit,valueKinds$DataColumn)]
  yLabel <- valueKinds$Type[match(yLabelWithUnit,resultTypes$DataColumn)]
  
  # Force them to use Dose and Response (would add a flag later for other similar formats that are not Dose Respose)
  if (xLabel != "Dose") {
    errorList <<- c(errorList, "The x Raw Result must be 'Dose' for this format.")
  }
  if (yLabel != "Response") {
    errorList <<- c(errorList, "The y Raw Result must be 'Response' for this format.")
  }
  
  #Drop Columns that are unnecessary in this context
  resultTypes <- resultTypes[,c("DataColumn","Type","Units")]
  
  # Add sd(standard deviation) and n (number of results) as result types
  resultTypes <- rbind(resultTypes, c("sd","sd",NA))
  resultTypes <- rbind(resultTypes, c("n","n",NA))
  
  # The headers for this object are stored in the first row of the data frame
  results <- subset(rawResults,1:nrow(rawResults) > 1)
  
  # Add a temporary pointID to keep track of which data goes together
  results$pointID <- seq(1,length(results[[1]]))
  
  # Create treatment group results (TODO performance: could not figure out how to make vector based)
  treatmentGroupResults <- unique(results[,c("temp id","x")])
  treatmentGroupResults$avg <- NA
  treatmentGroupResults$sd <- NA
  treatmentGroupResults$n <- NA
  
  # For each treatment group, find the unflagged data points that are included
  for (i in seq(1,length(treatmentGroupResults$"temp id"))) {
    valueSet <- (sapply(results$y[results$"temp id"==treatmentGroupResults$"temp id"[i] 
                                  & results$x==treatmentGroupResults$x[i]
                                  & results$flag==""],as.numeric))
    
    # Set the mean, standard deviation, and number of points
    if (length(valueSet>0)) {
      treatmentGroupResults$avg[i] <- mean(valueSet)
      treatmentGroupResults$sd[i] <- sd(valueSet)
      treatmentGroupResults$n[i] <- length(valueSet)
      
      # Or if all points were flagged, set n=0
    } else {
      treatmentGroupResults$n[i] <- 0
    }
  }
  
  #Use the names which were given on the spreadsheet
  names(treatmentGroupResults) <- c(resultTypes$DataColumn[1],xLabelWithUnit,yLabelWithUnit,"sd","n")
  
  # Add an Id for each treatment Group
  treatmentGroupResults$treatmentBatch <- seq(1,length(treatmentGroupResults[[1]]))
  
  
  # Change to long format
  savedNames <- names(treatmentGroupResults)[ which(!(names(treatmentGroupResults) %in% c("treatmentBatch",tempIdLabel,"n","sd"))) ] 
  
  
  # For melt to work right, you need to reverse the order of the measure.vars. I have no idea why.
  savedNames <- rev(savedNames)
  longTreatmentGroupResults <- melt(treatmentGroupResults, id.vars = c("treatmentBatch",tempIdLabel, "n", "sd"), measure.vars = savedNames, variable_name = "ResultType")
  
  # Break results into multiple columns
  tempIdTable <- calculatedResults[calculatedResults$"valueKind" == tempIdLabel,]
  longTreatmentGroupResults[[mainCode]] <- tempIdTable[[mainCode]][match(longTreatmentGroupResults[,tempIdLabel],tempIdTable$"numericValue")]
  longTreatmentGroupResults$"valueUnit" <- resultTypes$Units[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  longTreatmentGroupResults$"concentration" <- resultTypes$Conc[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  longTreatmentGroupResults$"concentrationUnit" <- resultTypes$concUnits[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  longTreatmentGroupResults$ResultType <- resultTypes$Type[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  
  # Get Subject data
  
  # Add a point ID to keep track of the points
  names(results) <- c(sapply(unlist(rawResultsTypeRow),as.character),"pointID")
  
  # Change to a long format
  longResults <- melt(results, id.vars = c("pointID", tempIdLabel), variable_name = "ResultType") 
  
  # Connect Batch ID's
  tempIdTable <- calculatedResults[calculatedResults$"valueKind" == tempIdLabel,]
  longResults[[mainCode]] <- tempIdTable[[mainCode]][match(longResults[,tempIdLabel],tempIdTable$"numericValue")]
  
  # Add units
  longResults$"valueUnit" <- resultTypes$Units[match(longResults$"ResultType",resultTypes$DataColumn)]
  longResults$"concentration" <- resultTypes$Conc[match(longResults$"ResultType",resultTypes$DataColumn)]
  longResults$"concentrationUnit" <- resultTypes$concUnits[match(longResults$"ResultType",resultTypes$DataColumn)]
  longResults$ResultType <- resultTypes$Type[match(longResults$"ResultType",resultTypes$DataColumn)]
  
  # Remove blank spaces from the data
  longTreatmentGroupResults[longTreatmentGroupResults==" " | longTreatmentGroupResults=="" | is.na(longTreatmentGroupResults)] <- NA
  longResults[longResults==" " | longResults=="" | is.na(longResults)] <- NA
  
  # Remove blank rows
  longTreatmentGroupResults <-longTreatmentGroupResults[!(is.na(longTreatmentGroupResults$value)),]
  longResults <-longResults[!(is.na(longResults$value)),]
  
  # Return
  return(list(subjectData = longResults, xLabel = xLabel, yLabel = yLabel, tempIdLabel = tempIdLabel,
              treatmentGroupData = longTreatmentGroupResults))
}
getProtocolByNameAndFormat <- function(protocolName, configList, formFormat) {
  # Gets the protocol entered as an input
  # 
  # Args:
  #   protocolName:     	    A string name of the protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #   recordedBy:             A string that is the scientist name
  #   dryRun:                 A boolean that marks if information should be saved to the server
  #
  # Returns:
  #  A list that is a protocol
  
  require('RCurl')
  require('rjson')
  require('gdata')
  
  forceProtocolCreation <- grepl("CREATETHISPROTOCOL", protocolName)
  if(forceProtocolCreation) {
    protocolName <- trim(gsub("CREATETHISPROTOCOL", "", protocolName))
  }
  
  tryCatch({
    protocolList <- fromJSON(getURL(paste0(configList$client.service.persistence.fullpath, "protocols?FindByProtocolName&protocolName=", URLencode(protocolName, reserved = TRUE))))
  }, error = function(e) {
    stop("There was an error in accessing the protocol. Please contact your system administrator.")
  })
  
  # If no protocol with the given name exists, warn the user
  if (length(protocolList)==0) {
    allowedCreationFormats <- configList$server.allow.protocol.creation.formats
    allowedCreationFormats <- unlist(strsplit(allowedCreationFormats, ","))
    if (formFormat %in% allowedCreationFormats || forceProtocolCreation) {
      warning(paste0("Protocol '", protocolName, "' does not exist, so it will be created. No user action is needed if you intend to create a new protocol."))
    } else {
      errorList <<- c(errorList, paste0("Protocol '", protocolName, "' does not exist. Please enter a protocol name that exists. Contact your system administrator if you would like to create a new protocol."))
    }
    # A flag for when the protocol will be created new
    protocol <- NA
  } else {
    # If the protocol does exist, get the full version
    protocol <- fromJSON(getURL(URLencode(paste0(configList$client.service.persistence.fullpath, "protocols/", protocolList[[1]]$id))))
  }
  return(protocol)
  
}
getExperimentByName <- function(experimentName, protocol, configList, duplicateNamesAllowed = FALSE) {
  # Gets the experiment entered as an input, warns if it does exist, and throws an error if it is in the wrong protocol
  # 
  # Args:
  #   experimentName:   		  A string name of the experiment
  #   protocol:               A list that is a protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #   recordedBy:             A string that is the scientist name
  #   duplicatedNamesAllowed: A boolean marking if experiment names can be repeated in multiple protocols
  #
  # Returns:
  #  A list that is an experiment
  
  require('RCurl')
  require('rjson')
  
  tryCatch({
    experimentList <- fromJSON(getURL(paste0(configList$client.service.persistence.fullpath, "experiments?FindByExperimentName&experimentName=", URLencode(experimentName, reserved=TRUE))))
  }, error = function(e) {
    stop("There was an error checking if the experiment already exists. Please contact your system administrator.")
  })
  
  # Warn the user if the experiment already exists (the else block)
  if (length(experimentList)==0) {
    experiment <- NA
  } else {
    tryCatch({
      protocolIds <- sapply(experimentList, function(x) x$protocol$id)
      if(!is.na(protocol[[1]])) {
        correctExperiments <- experimentList[protocolIds == protocol$id]
        if(length(correctExperiments) > 0) {
          experimentList <- correctExperiments
        }
      }
      protocolOfExperiment <- fromJSON(getURL(URLencode(paste0(configList$client.service.persistence.fullpath, "protocols/", experimentList[[1]]$protocol$id))))
    }, error = function(e) {
      stop("There was an error checking if the experiment is in the correct protocol. Please contact your system administrator.")
    })
    
    if (is.na(protocol) || protocolOfExperiment$id != protocol$id) {
      if (duplicateNamesAllowed) {
        experiment <- NA
      } else {
        errorList <<- c(errorList,paste0("Experiment '",experimentName,
                                         "' does not exist in the protocol that you entered, but it does exist in '", getPreferredProtocolName(protocolOfExperiment), 
                                         "'. Either change the experiment name or use the protocol in which this experiment currently exists."))
        experiment <- experimentList[[1]]
      }
    } else {
      warning(paste0("Experiment '",experimentName,"' already exists, so the loader will delete its current data and replace it with your new upload.",
                     " If you do not intend to delete and reload data, enter a new experiment name."))
      experiment <- experimentList[[1]]
    }
  }
  # Return the experiment
  return(experiment)
}
getPreferredProtocolName <- function(protocol, protocolName = NULL) {
  # gets the preferred protocol name from the protocol and checks that it is the same as the current protocol name
  preferredName <- protocol$lsLabels[vapply(protocol$lsLabels, getElement, c(TRUE), "preferred")][[1]]$labelText
  if (!is.null(protocolName) && preferredName != protocolName) {
    warning(paste0("The protocol name that you entered, '", protocolName, 
                   "', was replaced by the preferred name '", preferredName, "'"))
  }
  return(preferredName)
}
createNewProtocol <- function(metaData, lsTransaction, recordedBy) {
  # creates a protocol with the protocol name and scientist in the metaData
  # 
  # Args:
  #   metaData:     	        A data.frame including "Scientist" and "Protocol Name"
  #   lsTransaction:          A list that is a lsTransaction tag
  #
  # Returns:
  #  A list that is a protocol
  
  protocolStates <- list()
  
  # Add a label for the name
  protocolLabels <- list()
  protocolLabels[[length(protocolLabels)+1]] <- createProtocolLabel(lsTransaction = lsTransaction, 
                                                                    recordedBy=recordedBy, 
                                                                    lsType="name", 
                                                                    lsKind="protocol name",
                                                                    labelText=metaData$'Protocol Name'[1],
                                                                    preferred=TRUE)
  
  # Create the protocol
  protocol <- createProtocol(lsTransaction = lsTransaction,
                             shortDescription="protocol created by generic data parser",  
                             recordedBy=recordedBy, 
                             protocolLabels=protocolLabels,
                             protocolStates=protocolStates)
  
  protocol <- saveProtocol(protocol)
}
createNewExperiment <- function(metaData, protocol, lsTransaction, pathToGenericDataFormatExcelFile, recordedBy, configList, replacedExperimentCodes) {
  # creates an experiment using the metaData
  # 
  # Args:
  #   metaData:               A data.frame including "Experiment Name", "Scientist", "Notebook", "Page", and "Assay Date"
  #   protocol:               A list that is a protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #
  # Returns:
  #  A list that is an experiment
  
  require('gdata')
  
  experimentStates <- list()
  
  # Store the metaData in experiment values
  experimentValues <- list()
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                     lsKind = "notebook",
                                                                     stringValue = metaData$Notebook[1],
                                                                     lsTransaction= lsTransaction)
  if (!is.null(metaData$"In Life Notebook")) {
    experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                       lsKind = "notebook",
                                                                       stringValue = metaData$"In Life Notebook"[1],
                                                                       lsTransaction= lsTransaction)
  }
  if (!is.null(metaData$Page)) {
    experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                       lsKind = "notebook page",
                                                                       stringValue = metaData$Page[1],
                                                                       lsTransaction= lsTransaction)
  }
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "dateValue",
                                                                     lsKind = "completion date",
                                                                     dateValue = as.numeric(format(as.Date(metaData$"Assay Date"[1]), "%s"))*1000,
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                     lsType = "stringValue",
                                                                     lsKind = "scientist",
                                                                     stringValue = metaData$Scientist,
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                     lsKind = "status",
                                                                     stringValue = "Approved",
                                                                     lsTransaction= lsTransaction)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(recordedBy = recordedBy,lsType = "stringValue",
                                                                     lsKind = "analysis status",
                                                                     stringValue = "running",
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
                                                                          labelText=experimentName <- trim(gsub("CREATETHISEXPERIMENT$", "", metaData$"Experiment Name"[1])),
                                                                          preferred=TRUE)
  
  # Create LS Tags
  if("Experiment Keywords" %in% names(metaData)) {
    tagList <- splitOnSemicolon(metaData$"Experiment Keywords"[[1]])
    lsTags <- lapply(tagList, createTag)
  } else {
    lsTags <- NULL
  }
  
  # Create the experiment
  experiment <- createExperiment(lsTransaction = lsTransaction, 
                                 protocol = protocol,
                                 #lsKind = "generic loader",
                                 shortDescription = if(!is.null(metaData$"Short Description"[1])) {
                                   metaData$"Short Description"[1]
                                     } else {
                                   "experiment created by generic data parser"
                                     },  
                                 recordedBy=recordedBy, 
                                 experimentLabels=experimentLabels,
                                 experimentStates=experimentStates,
                                 lsTags=lsTags)
  
  # Save the experiment to the server
  experiment <- saveExperiment(experiment)
  experiment <- fromJSON(getURL(URLencode(paste0(configList$client.service.persistence.fullpath, "experiments/", experiment$id))))
  return(experiment)
}
validateProject <- function(projectName, configList) {
  require('RCurl')
  require('rjson')
  tryCatch({
  projectList <- getURL(paste0(configList$client.host, ":", configList$client.port, configList$client.service.project.path))
  }, error = function(e) {
    stop("The project service did not respond correctly, contact your system administrator")
  })
  tryCatch({
    projectList <- fromJSON(projectList)
  }, error = function(e) {
    errorList <<- c(errorList, paste("There was an error in validating your project:", projectList))
    return("")
  })
  #projectCodes <- sapply(projectList, function(x) x$code)
  projectNames <- sapply(projectList, function(x) x$name)
  if(length(projectNames) == 0) {errorList <<- c(errorList, "No projects are available, contact your system administrator")}
  if (projectName %in% projectNames) {
    return(projectName)
  } else {
    configText <- toJSON(configList)
    errorList <<- c(errorList, paste0("The project you entered is not an available project. Please enter one of these projects: '",
                                      paste(projectNames, collapse = "', '"), "'."))
    return("")
  }
}
validateScientist <- function(scientistName, configList) {
  require('utils')
  require('RCurl')
  require('rjson')
  
  response <- NULL
  username <- "username"
  tryCatch({
    response <- getURL(URLencode(paste0(configList$client.host, ":", configList$client.port, configList$client.service.users.path, "/", scientistName)))
    if (response == "") {
      errorList <<- c(errorList, paste0("The Scientist you supplied, '", scientistName, "', is not a valid name. Please enter the scientist's login name."))
      return("")
    }
  }, error = function(e) {
    errorList <<- c(errorList, paste("There was an error in validating the scientist's name:", scientistName))
    return("")
  })
  
  if (!is.null(response)) {
    tryCatch({
      username <- fromJSON(response)$username
    }, error = function(e) {
      errorList <<- c(errorList, paste("There was an error in validating the scientist's name:", scientistName))
      return("")
    })
  }
  
  return(username)
}
uploadRawDataOnly <- function(metaData, lsTransaction, subjectData, experiment, fileStartLocation, 
                              configList, stateGroups, reportFilePath, hideAllData, reportFileSummary, curveNames,
                              recordedBy, replaceFakeCorpBatchId, annotationType, sigFigs, rowMeaning="subject", 
                              includeTreatmentGroupData, inputFormat, mainCode) {
  # For use in uploading when the results go into subjects rather than analysis groups
  
  library('plyr')
  
  #Change in naming convention
  if (rowMeaning=="subject") {
    subjectData$subjectID <- NULL
    names(subjectData)[names(subjectData) == "analysisGroupID"] <- "subjectID"
  } else if (rowMeaning=="subjectState") {
    names(subjectData)[names(subjectData) == "analysisGroupID"] <- "subjectStateID"
  }
  if(hideAllData) subjectData$publicData <- FALSE
  
  
  # code names
  subjectCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_subject", 
                                              labelTypeAndKind="id_codeName", 
                                              numberOfLabels=max(subjectData$subjectID)),
                                use.names=FALSE)
  
  treatmentGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_treatment group", 
                                                     labelTypeAndKind="id_codeName",
                                                     numberOfLabels=max(subjectData$treatmentGroupID)),
                                       use.names=FALSE)
  
  serverFileLocation <- moveFileToExperimentFolder(fileStartLocation, experiment, recordedBy, lsTransaction, configList$server.service.external.file.type, configList$server.service.external.file.service.url)
  if(!is.null(reportFilePath) && reportFilePath != "") {
    batchNameList <- unique(subjectData[[mainCode]])
    if (configList$server.service.external.report.registration.url != "") {
      registerReportFile(reportFilePath, batchNameList, reportFileSummary, recordedBy, configList, experiment, lsTransaction, annotationType)
    } else {
      # addFileLink should be defined in customFunctions.R
      addFileLink(batchNameList, recordedBy, experiment, lsTransaction, reportFileSummary, reportFilePath, NULL, annotationType)
    }
  }
  
  # Analysis group
  analysisGroup <- createAnalysisGroup(experiment=experiment,lsTransaction=lsTransaction,recordedBy=recordedBy)
  
  savedAnalysisGroup <- saveAnalysisGroup(analysisGroup)
  
  # Treatment Groups
  treatmentGroups <- lapply(FUN= createTreatmentGroup, X= treatmentGroupCodeNameList, lsType="default", lsKind="default",
                            recordedBy=recordedBy, lsTransaction=lsTransaction, analysisGroup=savedAnalysisGroup, 
                            subjects=NULL,treatmentGroupStates=NULL)
  
  savedTreatmentGroups <- saveAcasEntities(treatmentGroups, "treatmentgroups")
  
  treatmentGroupIds <- sapply(savedTreatmentGroups, function(x) x$id)
  
  subjectData$treatmentGroupID <- treatmentGroupIds[match(subjectData$treatmentGroupID,1:length(treatmentGroupIds))]
  
  # Reorganization to match formats
  nameChange <- c(mainCode='batchCode', 'originalMainID'='originalBatchCode')
  names(subjectData)[names(subjectData) %in% names(nameChange)] <- nameChange[names(subjectData)]
  #subjectData$publicData <- !subjectData$publicData
  #subjectData$valueType <- c("numericValue","stringValue","dateValue", "clobValue")[match(subjectData$valueType,c("Number","Text","Date", "Clob"))]
  
  # Subjects
  subjectData$subjectCodeName <- subjectCodeNameList[subjectData$subjectID]
  
  createRawOnlySubject <- function(subjectData) {
    return(createSubject(
      treatmentGroup=list(id=subjectData$treatmentGroupID[1],version=0),
      codeName=subjectData$subjectCodeName[1],
      recordedBy=recordedBy,
      lsTransaction=lsTransaction))
  }
  
  subjects <- dlply(.data= subjectData, .variables= .(subjectID), .fun= createRawOnlySubject)
  names(subjects) <- NULL
  
  savedSubjects <- saveAcasEntities(subjects, "subjects")
  
  subjectIds <- sapply(savedSubjects, function(x) x$id)
  
  subjectData$subjectID <- subjectIds[subjectData$subjectID]
  
  ### Subject States ===============================================
  #######  
  stateGroupIndex <- 1
  subjectData$stateGroupIndex <- NA
  for (stateGroup in stateGroups) {
    includedRows <- subjectData$valueKind %in% stateGroup$valueKinds
    newRows <- subjectData[includedRows & !is.na(subjectData$stateGroupIndex), ]
    subjectData$stateGroupIndex[includedRows & is.na(subjectData$stateGroupIndex)] <- stateGroupIndex
    if (nrow(newRows) > 0) newRows$stateGroupIndex <- stateGroupIndex
    subjectData <- rbind.fill(subjectData,newRows)
    stateGroupIndex <- stateGroupIndex + 1
  }
  
  othersGroupIndex <- which(sapply(stateGroups, function(x) x$includesOthers))
  subjectData$stateGroupIndex[is.na(subjectData$stateGroupIndex)] <- othersGroupIndex
  
  makeUniqueSubjects <- function(subjectData) {
    subjectData$subjectStateID <- subjectData$subjectStateID[1]
    subjectData$batchCode <- subjectData$batchCode[1]
    subjectData$originalBatchCode <- subjectData$originalBatchCode[1]
    output <- unique(subjectData)
    if (nrow(output) > 1) {
      stop("Values in ", unique(subjectData$valueKindAndUnit), " are expected to be the same for each subject.")
    }
    return(output)
  }
  for (i in 1:length(stateGroups)) {
    stateGroup <- stateGroups[[i]]
    subjectData <- ddply(subjectData, c("stateGroupIndex"), .fun = function(subjectData) {
      if (subjectData$stateGroupIndex[1] == i && !is.null(stateGroup$collapseGroupBy)) {
        subjectData <- ddply(subjectData, 
                             c("valueKindAndUnit","subjectID","stateGroupIndex"),
                             .fun=makeUniqueSubjects)
      }
      return(subjectData)
    })
  }
  
  subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex, "-", 
                                subjectData$concentration, "-", subjectData$concentrationUnit, "-",
                                subjectData$time, "-", subjectData$timeUnit, "-", subjectData$subjectStateID)
  
  subjectData <- rbind.fill(subjectData, meltConcentrations(subjectData))
  
  subjectData <- rbind.fill(subjectData, meltTimes(subjectData))
  
  stateAndVersion <- saveStatesFromLongFormat(subjectData, "subject", stateGroups, "stateID", recordedBy, lsTransaction)
  subjectData$stateID <- stateAndVersion$entityStateId
  subjectData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### Subject Values ======================================================================= 
  batchCodeStateIndices <- which(sapply(stateGroups, getElement, "includesCorpName"))
  if (is.null(subjectData$stateVersion)) subjectData$stateVersion <- 0
  subjectDataWithBatchCodeRows <- rbind.fill(subjectData, meltBatchCodes(subjectData, batchCodeStateIndices, replaceFakeCorpBatchId))
  
  savedSubjectValues <- saveValuesFromLongFormat(subjectDataWithBatchCodeRows, "subject", stateGroups, lsTransaction, recordedBy)
  #
  #####  
  
  # Treatment Group states =========================================================================
  if(includeTreatmentGroupData) {
    treatmentGroupIndex <- which(sapply(stateGroups, getElement, "stateKind") == "treatment")
    treatmentValueKinds <- stateGroups[[treatmentGroupIndex]]$valueKinds
    listedValueKinds <- do.call(c,lapply(stateGroups, getElement, "valueKinds"))
    otherValueKinds <- setdiff(unique(subjectData$valueKind),listedValueKinds)
    rawDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="raw data"][[1]]$valueKinds
    treatmentDataValueKinds <- c(treatmentValueKinds, otherValueKinds, rawDataValueKinds)
    excludedSubjects <- subjectData$subjectID[subjectData$valueKind == "Exclude"]
    treatmentDataStart <- subjectData[subjectData$valueKind %in% treatmentDataValueKinds 
                                      & !(subjectData$subjectID %in% excludedSubjects),]
    
    # Note: createRawOnlyTreatmentGroupData can be found in customFunctions.R
    treatmentGroupData <- ddply(.data = treatmentDataStart, .variables = c("treatmentGroupID", "valueKindAndUnit", "stateGroupIndex"), .fun = createRawOnlyTreatmentGroupData, sigFigs=sigFigs, inputFormat=inputFormat)
    treatmentGroupIndices <- c(treatmentGroupIndex,othersGroupIndex)
    if (nrow(treatmentGroupData) > 0) {
      stateAndVersion <- saveStatesFromLongFormat(entityData = treatmentGroupData, 
                                                  entityKind = "treatmentgroup", 
                                                  stateGroups = stateGroups,
                                                  stateGroupIndices = treatmentGroupIndices,
                                                  idColumn = "stateID",
                                                  recordedBy = recordedBy,
                                                  lsTransaction = lsTransaction)
      
      treatmentGroupData$stateID <- stateAndVersion$entityStateId
      treatmentGroupData$stateVersion <- stateAndVersion$entityStateVersion
      
      treatmentGroupData$treatmentGroupStateID <- treatmentGroupData$stateID
      
      #### Treatment Group Values =====================================================================
      batchCodeStateIndices <- which(sapply(stateGroups, function(x) return(x$includesCorpName)))
      if (is.null(treatmentGroupData$stateVersion)) treatmentGroupData$stateVersion <- 0
      treatmentGroupDataWithBatchCodeRows <- rbind.fill(treatmentGroupData, meltBatchCodes(treatmentGroupData, batchCodeStateIndices))
      # TODO: don't save fake batch codes as batch codes
      savedTreatmentGroupValues <- saveValuesFromLongFormat(entityData = treatmentGroupDataWithBatchCodeRows, 
                                                            entityKind = "treatmentgroup", 
                                                            stateGroups = stateGroups, 
                                                            stateGroupIndices = treatmentGroupIndices, 
                                                            lsTransaction = lsTransaction,
                                                            recordedBy = recordedBy)
      
      #### Analysis Group States =====================================================================
      analysisGroupIndices <- which(sapply(stateGroups, function(x) {x$entityKind})=="analysis group")
      if (length(analysisGroupIndices > 0)) {
        analysisGroupData <- treatmentGroupData
        analysisGroupData <- rbind.fill(analysisGroupData, meltBatchCodes(analysisGroupData, batchCodeStateIndices, optionalColumns = "analysisGroupID"))
        if (!is.null(curveNames)) {
          curveRows <- data.frame(stateGroupIndex = analysisGroupIndices, 
                                  valueKind = curveNames, 
                                  publicData = TRUE, 
                                  valueType = "stringValue", 
                                  stringValue = paste0(1:length(curveNames), "_", analysisGroup$codeName),
                                  stringsAsFactors=FALSE)
          renderingHintRow <- data.frame(stateGroupIndex = analysisGroupIndices, 
                                         valueKind = "Rendering Hint", 
                                         publicData = FALSE, 
                                         valueType = "stringValue", 
                                         stringValue = "PK IV PO Single Dose",
                                         stringsAsFactors=FALSE)
          analysisGroupData <- rbind.fill(analysisGroupData, curveRows, renderingHintRow)
        }
        analysisGroupData$analysisGroupID <- savedAnalysisGroup$id
        analysisGroupData$stateID <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex)
        stateAndVersion <- saveStatesFromLongFormat(entityData = analysisGroupData, 
                                                    entityKind = "analysisgroup", 
                                                    stateGroups = stateGroups,
                                                    stateGroupIndices = analysisGroupIndices,
                                                    idColumn = "stateID",
                                                    recordedBy = recordedBy,
                                                    lsTransaction = lsTransaction)
        
        analysisGroupData$stateID <- stateAndVersion$entityStateId
        analysisGroupData$stateVersion <- stateAndVersion$entityStateVersion
        
        analysisGroupData$analysisGroupStateID <- analysisGroupData$stateID
        #### Analysis Group Values =====================================================================
        savedAnalysisGroupValues <- saveValuesFromLongFormat(entityData = analysisGroupData, 
                                                             entityKind = "analysisgroup", 
                                                             stateGroups = stateGroups, 
                                                             stateGroupIndices = analysisGroupIndices,
                                                             lsTransaction = lsTransaction,
                                                             recordedBy = recordedBy)
      }
    }
  }
  ### Container creation ==================================================================
  containerIndex <- which(sapply(stateGroups, function(x) x$"entityKind")=="container")
  if (length(containerIndex) > 0) {
    containerData <- subjectData[subjectData$stateGroupIndex %in% containerIndex, ]
    
    # Link old containers
    allContainerData <- linkOldContainers(containerData, stateGroups, experiment$lsLabels[[1]]$labelText)
    containerData <- allContainerData$entityData
    preexistingContainers <- allContainerData$matchingLabelData
    
    if (nrow(containerData) > 0) {
      containerCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="material_container", 
                                                    labelTypeAndKind="id_codeName", 
                                                    numberOfLabels=length(unique(containerData$subjectID))),
                                      use.names=FALSE)
      
      containerData$containerCodeName <- containerCodeNameList[as.numeric(factor(containerData$subjectID))]
      
      # TODO: type and kind should be in a config somewhere
      createRawOnlyContainer <- function(containerData) {
        return(createContainer(
          lsType="material",
          lsKind="animal",
          codeName=containerData$containerCodeName[1],
          recordedBy=recordedBy,
          lsTransaction=lsTransaction))
      }
      
      containers <- dlply(.data= containerData, .variables= .(containerCodeName), .fun= createRawOnlyContainer)
      names(containers) <- NULL
      
      savedContainers <- saveAcasEntities(containers, "containers")
      
      containerIds <- sapply(savedContainers, function(x) x$id)
      
      # Order is not maintained, but that is okay
      containerData$containerID <- containerIds[as.numeric(factor(containerData$subjectID))]
      
      ### Container Labels ============================================================
      
      saveLabelsFromLongFormat(entityData = containerData, 
                               entityKind = "container", 
                               stateGroups = stateGroups,
                               idColumn = "containerID",
                               recordedBy = recordedBy,
                               lsTransaction = lsTransaction,
                               labelPrefix = experiment$lsLabels[[1]]$labelText)
      
      ### Container States ============================================================
      
      containerData$stateID <- paste0(containerData$containerID, "-", containerData$stateGroupIndex)
      stateAndVersion <- saveStatesFromLongFormat(entityData = containerData, 
                                                  entityKind = "container", 
                                                  stateGroups = stateGroups,
                                                  idColumn = "stateID",
                                                  recordedBy = recordedBy,
                                                  lsTransaction = lsTransaction)
      
      containerData$stateID <- stateAndVersion$entityStateId
      containerData$stateVersion <- stateAndVersion$entityStateVersion
      
      containerData$containerStateID <- containerData$stateID
      
      ### Container Values =========================================================
      if (is.null(containerData$stateVersion)) containerData$stateVersion <- 0
      containerDataWithBatchCodeRows <- rbind.fill(containerData, meltBatchCodes(containerData, batchCodeStateIndices))
      
      savedContainerValues <- saveValuesFromLongFormat(entityData = containerDataWithBatchCodeRows, 
                                                       entityKind = "container", 
                                                       stateGroups = stateGroups, 
                                                       lsTransaction = lsTransaction,
                                                       recordedBy = recordedBy)
    }
    ### Itx Subject Container =========================================================
    
    # Bring back the preexisting containers to create interactions
    containerData <- rbind.fill(containerData, preexistingContainers)
    
    createRawOnlyItxSubjectContainer <- function(containerData, recordedBy, lsTransaction) {
      createSubjectContainerInteraction(
        lsType = "refers to",
        lsKind = "test subject",
        subject = list(id=containerData$subjectID[1], version = 0),
        container = list(id=containerData$containerID[1], version = 0),
        recordedBy=recordedBy,
        lsTransaction=lsTransaction)
    }
    
    subjectContainerInteractions <- dlply(.data = containerData,
                                          .variables = c("subjectID", "containerID"),
                                          .fun = createRawOnlyItxSubjectContainer,
                                          recordedBy=recordedBy, lsTransaction=lsTransaction)
    
    names(subjectContainerInteractions) <- NULL
    
    savedSubjectContainerInteractions <- saveAcasEntities(entities=subjectContainerInteractions,acasCategory="itxsubjectcontainers")   
  }
  return(lsTransaction)
}
uploadData <- function(metaData,lsTransaction,analysisGroupData,treatmentGroupData,subjectData,
                       xLabel,yLabel,tempIdLabel,testOutputLocation = NULL,developmentMode,
                       protocol,experiment, fileStartLocation, configList, reportFilePath, 
                       reportFileSummary, recordedBy, annotationType, mainCode) {
  # Uploads all the data to the server
  # 
  # Args:
  #   metaData:     	        A data frame of the meta data
  #   lsTransaction:          An id of the transaction
  #   calculatedResults:      A data frame of the calculated results (analysis group data)
  #   treatmentGroupData:     A data frame of the treatment group data
  #   rawResults:             A data frame of the raw results (subject group data)
  #   xLabel:                 A string with the name of the variable that is in the 'x' column
  #   yLabel:                 A string with the name of the variable that is in the 'y' column
  #   tempIdLabel:            A string with the name of the variable that is in the 'temp id' column
  #   testOutputLocation:     A string with the file location to output a JSON file to when dryRun is TRUE
  #   developmentMode:        A boolean that marks if the JSON request should be saved to a file
  #
  #   Returns:
  #     NULL
  
  analysisGroupData$lsTransaction <- lsTransaction
  analysisGroupData$recordedBy <- recordedBy
  
  treatmentGroupData$lsTransaction <- lsTransaction
  treatmentGroupData$recordedBy <- recordedBy
  
  subjectData$lsTransaction <- lsTransaction
  subjectData$recordedBy <- recordedBy
  
  
  ### Analysis Group Data
  # Not all of these will be filled
  analysisGroupData$stateID <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex, "-", 
                                analysisGroupData$concentration, "-", analysisGroupData$concentrationUnit, "-",
                                analysisGroupData$time, "-", analysisGroupData$timeUnit, "-", analysisGroupData$stateKind)
  
  analysisGroupData <- rbind.fill(analysisGroupData, meltConcentrations(analysisGroupData))
  analysisGroupData <- rbind.fill(analysisGroupData, meltTimes(analysisGroupData))
  analysisGroupData <- rbind.fill(analysisGroupData, meltBatchCodes(analysisGroupData, 0, optionalColumns = "analysisGroupID"))
  
  analysisGroupIDandVersion <- saveAnalysisGroupData(analysisGroupData)
  
  ### TreatmentGroup Data
  matchingID <- match(treatmentGroupData$analysisGroupID, analysisGroupIDandVersion$tempID)
  treatmentGroupData$analysisGroupID <- analysisGroupIDandVersion$entityID[matchingID]
  treatmentGroupData$analysisGroupVersion <- analysisGroupIDandVersion$entityVersion[matchingID]
  
  treatmentGroupData$stateID <- paste0(treatmentGroupData$treatmentGroupID, "-", treatmentGroupData$stateGroupIndex, "-", 
                                      treatmentGroupData$concentration, "-", treatmentGroupData$concentrationUnit, "-",
                                      treatmentGroupData$time, "-", treatmentGroupData$timeUnit, "-", treatmentGroupData$stateKind)
  
  treatmentGroupData <- rbind.fill(treatmentGroupData, meltConcentrations(treatmentGroupData))
  treatmentGroupData <- rbind.fill(treatmentGroupData, meltTimes(treatmentGroupData))
  treatmentGroupData <- rbind.fill(treatmentGroupData, meltBatchCodes(treatmentGroupData, 0, optionalColumns = "treatmentGroupID"))
  
  treatmentGroupIDandVersion <- saveFullEntityData(treatmentGroupData, "treatmentGroup")
  
  ### subject Data
  matchingID <- match(subjectData$treatmentGroupID, treatmentGroupIDandVersion$tempID)
  subjectData$treatmentGroupID <- treatmentGroupIDandVersion$entityID[matchingID]
  subjectData$treatmentGroupVersion <- treatmentGroupIDandVersion$entityVersion[matchingID]
  
  subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex, "-", 
                                       subjectData$concentration, "-", subjectData$concentrationUnit, "-",
                                       subjectData$time, "-", subjectData$timeUnit, "-", subjectData$stateKind)
  
  subjectData <- rbind.fill(subjectData, meltConcentrations(subjectData))
  subjectData <- rbind.fill(subjectData, meltTimes(subjectData))
  subjectData <- rbind.fill(subjectData, meltBatchCodes(subjectData, 0, optionalColumns = "subjectID"))
  
  subjectIDandVersion <- saveFullEntityData(subjectData, "subject")
  
  return (NULL)
  
   ######################
  analysisGroupData <<- analysisGroupData
  analysisGroupIDandVersion <<- analysisGroupIDandVersion
  #return()
  
  
  subjects <- dlply(.data= subjectData, .variables= .(subjectID), .fun= createRawOnlySubject)
  names(subjects) <- NULL
  
  savedSubjects <- saveAcasEntities(subjects, "subjects")
  
  subjectIds <- sapply(savedSubjects, function(x) x$id)
  
  subjectData$subjectID <- subjectIds[subjectData$subjectID]
  
  ### Subject States ===============================================
  #######  
  stateGroupIndex <- 1
  subjectData$stateGroupIndex <- NA
  for (stateGroup in stateGroups) {
    includedRows <- subjectData$valueKind %in% stateGroup$valueKinds
    newRows <- subjectData[includedRows & !is.na(subjectData$stateGroupIndex), ]
    subjectData$stateGroupIndex[includedRows & is.na(subjectData$stateGroupIndex)] <- stateGroupIndex
    if (nrow(newRows) > 0) newRows$stateGroupIndex <- stateGroupIndex
    subjectData <- rbind.fill(subjectData,newRows)
    stateGroupIndex <- stateGroupIndex + 1
  }
  
  othersGroupIndex <- which(sapply(stateGroups, function(x) x$includesOthers))
  subjectData$stateGroupIndex[is.na(subjectData$stateGroupIndex)] <- othersGroupIndex
  
  makeUniqueSubjects <- function(subjectData) {
    subjectData$subjectStateID <- subjectData$subjectStateID[1]
    subjectData$batchCode <- subjectData$batchCode[1]
    subjectData$originalBatchCode <- subjectData$originalBatchCode[1]
    output <- unique(subjectData)
    if (nrow(output) > 1) {
      stop("Values in ", unique(subjectData$valueKindAndUnit), " are expected to be the same for each subject.")
    }
    return(output)
  }
  for (i in 1:length(stateGroups)) {
    stateGroup <- stateGroups[[i]]
    subjectData <- ddply(subjectData, c("stateGroupIndex"), .fun = function(subjectData) {
      if (subjectData$stateGroupIndex[1] == i && !is.null(stateGroup$collapseGroupBy)) {
        subjectData <- ddply(subjectData, 
                             c("valueKindAndUnit","subjectID","stateGroupIndex"),
                             .fun=makeUniqueSubjects)
      }
      return(subjectData)
    })
  }
  
  subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex, "-", 
                                subjectData$concentration, "-", subjectData$concentrationUnit, "-",
                                subjectData$time, "-", subjectData$timeUnit, "-", subjectData$subjectStateID)
  
  subjectData <- rbind.fill(subjectData, meltConcentrations(subjectData))
  
  subjectData <- rbind.fill(subjectData, meltTimes(subjectData))
  
  stateAndVersion <- saveStatesFromLongFormat(subjectData, "subject", stateGroups, "stateID", recordedBy, lsTransaction)
  subjectData$stateID <- stateAndVersion$entityStateId
  subjectData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### Subject Values ======================================================================= 
  batchCodeStateIndices <- which(sapply(stateGroups, getElement, "includesCorpName"))
  if (is.null(subjectData$stateVersion)) subjectData$stateVersion <- 0
  subjectDataWithBatchCodeRows <- rbind.fill(subjectData, meltBatchCodes(subjectData, batchCodeStateIndices, replaceFakeCorpBatchId))
  
  savedSubjectValues <- saveValuesFromLongFormat(subjectDataWithBatchCodeRows, "subject", stateGroups, lsTransaction, recordedBy)
  
  
  
  
  
  analysisGroupCodeNameNumber <- 1
  
  if(!is.null(rawResults)) {
    subjectCodeNameList <- getAutoLabels(thingTypeAndKind="document_subject", 
                                         labelTypeAndKind="id_codeName", 
                                         numberOfLabels=max(rawResults$pointID))
    subjectCodeNameNumber <- 1
    
    # Get a list of codes for the treatment groups
    treatmentGroupCodeNameList <- getAutoLabels(thingTypeAndKind="document_treatment group", 
                                                labelTypeAndKind="id_codeName", 
                                                numberOfLabels=max(treatmentGroupData$treatmentBatch))
    treatmentGroupCodeNameNumber <- 1
  }
  
  serverFileLocation <- moveFileToExperimentFolder(fileStartLocation, experiment, recordedBy, lsTransaction, 
                                                   configList$server.service.external.file.type, 
                                                   configList$server.service.external.file.service.url)
  if(!is.null(reportFilePath) && reportFilePath != "") {
    batchNameList <- unique(calculatedResults[[mainCode]])
    if (configList$server.service.external.report.registration.url != "") {
      registerReportFile(reportFilePath, batchNameList, reportFileSummary, recordedBy, configList, experiment, lsTransaction, annotationType)
    } else {
      addFileLink(batchNameList, recordedBy, experiment, lsTransaction, reportFileSummary, reportFilePath, NULL, annotationType)
    }
  }
  
  # Each analysisGroupID creates an analysis group
  analysisGroups <- list()
  for (analysisGroupID in unique(calculatedResults$analysisGroupID)) {
    
    # Each row in the table calculatedResults creates a state
    analysisGroupStates <- list()
    for (concentration in unique(calculatedResults$Conc[analysisGroupID == calculatedResults$analysisGroupID])) {
      
      # Get the rows, but NA's are a special case
      if(is.na(concentration)) {
        selectedRowsConc <- analysisGroupID == calculatedResults$analysisGroupID & is.na(calculatedResults$Conc)
      } else {
        selectedRowsConc <- analysisGroupID == calculatedResults$analysisGroupID & concentration == calculatedResults$Conc
      }
      for (timePoint in unique(calculatedResults$time[selectedRowsConc])) {
        if(is.na(timePoint)) {
          selectedRows <- selectedRowsConc & is.na(calculatedResults$time)
        } else {
          selectedRows <- selectedRowsConc & timePoint == calculatedResults$time
        }
        analysisGroupValues <- list()
        for (i in which(selectedRows)) {
          # Prepare the date value
          dateValue <- as.numeric(format(as.Date(calculatedResults$"dateValue"[i],origin="1970-01-01"), "%s"))*1000
          # The main value (whether it is a numeric, string, or date) creates one value    
          analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                                   lsType = if (calculatedResults$"valueKind"[i]==tempIdLabel) {"stringValue"
                                                                                   } else if (calculatedResults$"Class"[i]=="Text") {"stringValue"
                                                                                   } else if (calculatedResults$"Class"[i]=="Date") {"dateValue"
                                                                                   } else if (calculatedResults$"Class"[i]=="Clob") {"clobValue"
                                                                                   } else {"numericValue"},
                                                                                   lsKind = calculatedResults$"valueKind"[i],
                                                                                   stringValue = if(calculatedResults$"valueKind"[i]==tempIdLabel) {
                                                                                     paste0(calculatedResults$"stringValue"[i],"_",analysisGroupCodeNameList[[analysisGroupCodeNameNumber]][[1]])
                                                                                   } else if (!is.na(calculatedResults$"stringValue"[i])) {calculatedResults$"stringValue"[i]} else {NULL},
                                                                                   clobValue = if (!is.na(calculatedResults$clobValue[i])) {calculatedResults$clobValue[i]} else {NULL},
                                                                                   dateValue = if(is.na(dateValue)) {NULL} else {dateValue},
                                                                                   valueOperator = if(is.na(calculatedResults$"valueOperator"[i])) {NULL} else {calculatedResults$"valueOperator"[i]},
                                                                                   numericValue = if(is.na(calculatedResults$"numericValue"[i]) | calculatedResults$"valueKind"[i]==tempIdLabel) {NULL} 
                                                                                   else {calculatedResults$"numericValue"[i]},
                                                                                   valueUnit = if(is.na(calculatedResults$"valueUnit"[i])) {NULL} else {calculatedResults$"valueUnit"[i]},
                                                                                   publicData = calculatedResults$publicData[i],
                                                                                   lsTransaction = lsTransaction)
        }
        
        if(!is.null(i)) {
          # Adds a value for the batchCode (mainCode (Corporate Batch ID/Gene ID))
          analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                                   lsType = "codeValue",
                                                                                   lsKind = "batch code",
                                                                                   codeValue = as.character(calculatedResults[[mainCode]][analysisGroupID == calculatedResults$analysisGroupID][1]),
                                                                                   publicData = calculatedResults$publicData[i],
                                                                                   lsTransaction = lsTransaction)
          
          # Adds a value for the concentration if there is one
          if (!is.na(concentration)) {
            analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                                     lsType = "numericValue",
                                                                                     lsKind = "tested concentration",
                                                                                     valueUnit= if(is.na(calculatedResults$"concentrationUnit"[i])){NULL} else {calculatedResults$"concentrationUnit"[i]},
                                                                                     numericValue = calculatedResults$"Conc"[i],
                                                                                     publicData = calculatedResults$publicData[i],
                                                                                     lsTransaction = lsTransaction)
          }
          
          # Adds a value for the time if there is one
          if (!is.na(timePoint)) {
            analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
              recordedBy = recordedBy,
              lsType = "numericValue",
              lsKind = "time",
              valueUnit= if(is.na(calculatedResults$"timeUnit"[i])){NULL} else {calculatedResults$"timeUnit"[i]},
              numericValue = calculatedResults$"time"[i],
              publicData = calculatedResults$publicData[i],
              lsTransaction = lsTransaction)
          }
          # Creates the state
          analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
                                                                                            recordedBy=recordedBy,
                                                                                            lsType="data",
                                                                                            lsKind=metaData$Format[1],
                                                                                            analysisGroupValues=analysisGroupValues)
        }
      }
    }
    # Creates Treatment Groups based on rawResults
    treatmentGroupList <- list()
    
    if(!is.null(rawResults)) {
      # Gets the temp and batch Id's for the current analysis group
      tempID <- calculatedResults$"stringValue"[calculatedResults$analysisGroupID == analysisGroupID & calculatedResults$"valueKind" == tempIdLabel][1]
      batchID <- as.character(calculatedResults[[mainCode]][calculatedResults$analysisGroupID == analysisGroupID][1])
      if (!is.na(tempID) & tempID!="") {
        for (group in unique(treatmentGroupData$treatmentBatch[treatmentGroupData[,tempIdLabel]==tempID])) {
          treatmentGroupStates <- list()
          treatmentGroupValues <- list()
          for (i in which(treatmentGroupData$treatmentBatch==group & treatmentGroupData$ResultType==yLabel)) {
            treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue(recordedBy = recordedBy, 
              lsType= "numericValue", #numericValue or stringValue
              lsKind= treatmentGroupData$ResultType[i], #the label
              numericValue= if(is.na(treatmentGroupData$value[i])) {NULL} else as.numeric(as.character(treatmentGroupData$value[i])),
              uncertainty= if(is.na(treatmentGroupData$sd[i])) {NULL} else treatmentGroupData$sd[i],
              uncertaintyType= "standard deviation",
              numberOfReplicates= treatmentGroupData$n[i],
              valueUnit= if(is.na(treatmentGroupData$"valueUnit"[i])) {NULL} else {treatmentGroupData$"valueUnit"[i]},
              lsTransaction= lsTransaction)
            
            treatmentGroupStates[[length(treatmentGroupStates)+1]] <- createTreatmentGroupState(
              treatmentGroupValues=treatmentGroupValues,
              recordedBy=recordedBy,
              lsType="data",
              lsKind="results",
              comments=NULL,
              lsTransaction=lsTransaction)
            
            treatmentGroupValues <- list()
          }
          
          for (i in which(treatmentGroupData$treatmentBatch==group & treatmentGroupData$ResultType==xLabel)) {
            treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue(recordedBy = recordedBy, 
              lsType= "numericValue", #numericValue or stringValue
              lsKind= treatmentGroupData$ResultType[i], #the label
              numericValue= if(is.na(treatmentGroupData$value[i])) {NULL} else as.numeric(as.character(treatmentGroupData$value[i])),
              valueUnit= if(is.na(treatmentGroupData$"valueUnit"[i])) {NULL} else {treatmentGroupData$"valueUnit"[i]},
              lsTransaction= lsTransaction)
            
            # Add a value for the batchCode
            treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue(recordedBy = recordedBy, 
              lsType= "codeValue",
              lsKind= "batch code",
              codeValue= batchID,
              lsTransaction= lsTransaction)
            
            treatmentGroupStates[[length(treatmentGroupStates)+1]] <- createTreatmentGroupState(
              treatmentGroupValues=treatmentGroupValues,
              recordedBy= recordedBy,
              lsType= "data",
              lsKind= "test compound treatment",
              lsTransaction= lsTransaction)
          }
          
          
          
          subjectList <- list()
          
          # xValue is the value of the data in the x column for that treatmentGroup
          xValue <- treatmentGroupData$value[treatmentGroupData$ResultType==xLabel & treatmentGroupData$treatmentBatch==group]
          for(pointID in unique(rawResults$pointID[rawResults$ResultType==xLabel 
                                                   & suppressWarnings(as.numeric(as.character(rawResults$value))==as.numeric(xValue))
                                                   & rawResults[,tempIdLabel]==tempID])) {
            
            subjectStates <- list()
            subjectValues <- list()
            for (i in which(rawResults$pointID == pointID & rawResults$ResultType %in% c(yLabel,"flag"))) {
              subjectValues[[length(subjectValues)+1]] <- createStateValue(recordedBy = recordedBy,
                lsType = if(rawResults$ResultType[i]=="flag") {"stringValue"} else {"numericValue"},
                lsKind = rawResults$ResultType[i], #the label
                stringValue = if(rawResults$ResultType[i]=="flag" & !is.na(rawResults$value[i])) {rawResults$value[i]} else {NULL},
                numericValue=if(rawResults$ResultType[i]!="flag") {as.numeric(as.character(rawResults$value[i]))} else {NULL},
                valueUnit=if(is.na(rawResults$"valueUnit"[i])) {NULL} else {rawResults$"valueUnit"[i]},
                lsTransaction=lsTransaction)
            }
            
            subjectStates[[length(subjectStates)+1]] <- createSubjectState( 
              lsTransaction=lsTransaction, 
              recordedBy=recordedBy,
              lsType="data", 
              lsKind="results",
              subjectValues=subjectValues)
            
            subjectValues <- list()
            
            for (i in which(rawResults$pointID == pointID & rawResults$ResultType %in% c(xLabel))) {
              subjectValues[[length(subjectValues)+1]] <- createStateValue(recordedBy = recordedBy,
                lsType = "numericValue",
                lsKind = rawResults$ResultType[i], #the label
                numericValue=as.numeric(as.character(rawResults$value[i])),
                valueUnit=if(is.na(rawResults$"valueUnit"[i])) {NULL} else {rawResults$"valueUnit"[i]},
                lsTransaction=lsTransaction)
              
              # Add a value for the batchCode
              subjectValues[[length(subjectValues)+1]] <- createStateValue(recordedBy = recordedBy, 
                lsType="codeValue",
                lsKind="batch code",
                codeValue=batchID,
                lsTransaction=lsTransaction)
              
              subjectStates[[length(subjectStates)+1]] <- createSubjectState( 
                lsTransaction=lsTransaction, 
                recordedBy=recordedBy,
                lsType="data", 
                lsKind="test compound treatment",
                subjectValues=subjectValues)
              
              subjectValues <- list()
            }
            
            
            
            subjectList[[length(subjectList)+1]] <- createSubject(
              codeName = subjectCodeNameList[[subjectCodeNameNumber]][[1]],
              subjectStates = subjectStates,
              recordedBy=recordedBy,
              comments="",
              lsTransaction=lsTransaction)
            
            subjectCodeNameNumber <- subjectCodeNameNumber + 1
          }
          
          treatmentGroupList[[length(treatmentGroupList)+1]] <- createTreatmentGroup(
            codeName = treatmentGroupCodeNameList[[treatmentGroupCodeNameNumber]][[1]],
            subjects=subjectList,
            treatmentGroupStates=treatmentGroupStates,
            recordedBy=recordedBy,
            comments="",
            lsTransaction=lsTransaction)
          
          treatmentGroupCodeNameNumber <- treatmentGroupCodeNameNumber + 1
        }
      }
    }
    
    if (length(treatmentGroupList) == 0) {
      treatmentGroupList <- NULL
    }
    
    # Put it all together in Analysis Groups
    analysisGroups[[length(analysisGroups)+1]] <- createAnalysisGroup(
      codeName = analysisGroupCodeNameList[[analysisGroupCodeNameNumber]][[1]],
      lsKind=metaData$Format[1],
      experiment = experiment,
      recordedBy=recordedBy,
      lsTransaction=lsTransaction,
      analysisGroupStates = analysisGroupStates,
      treatmentGroups = treatmentGroupList
    )
    
    analysisGroupCodeNameNumber <- analysisGroupCodeNameNumber + 1
  }
  
  if(developmentMode) {
    # Write the data to a file for debugging
    print(testOutputLocation)
    write(toJSON(analysisGroups), file = testOutputLocation)
  } else {
    # Write the data to the server. The response is unused.
    response <- saveAcasEntities(analysisGroups, "analysisgroups")
    # Used during testing
    #cat(toJSON(saveAnalysisGroups(analysisGroups)))
  }
  return(NULL)
}
saveAnalysisGroupData <- function(analysisGroupData) {
  saveFullEntityData(analysisGroupData, "analysisGroup")
}

saveFullEntityData <- function(entityData, entityKind) {
  
  ### local names
  # entityData[[paste0(entityKind, "ID")]] must be numeric
  acasEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  entityID <- paste0(entityKind, "ID")
  tempIds <- c()
  
  ### Error checking
  if (!(entityID %in% names(entityData))) {
    stop(paste0("Internal Error: Column ", entityID, " is not a missing from entityData"))
  }
  
  ### main code
  thingTypeAndKind <- paste0("document_", changeEntityMode(entityKind, "camel", "space"))
  entityCodeNameList <- unlist(getAutoLabels(thingTypeAndKind=thingTypeAndKind, 
                                                    labelTypeAndKind="id_codeName", 
                                                    numberOfLabels=max(entityData[[entityID]])),
                                      use.names=FALSE)
  
  entityData$analysisGroupCodeName <- entityCodeNameList[entityData[[entityID]]]
  
  createEntity <- function(codeName, lsType, lsKind, recordedBy, lsTransaction) {
    return(list(
      codeName=codeName,
      lsType=lsType,
      lsKind=lsKind,
      recordedBy=recordedBy,
      lsTransaction=lsTransaction))
  }
  
  createEntityFromDF <- function(dfData, currentEntity) {
    entity <- createEntity(
      lsType = "default",
      lsKind = "default",
      codeName=dfData[[paste0(currentEntity, "CodeName")]][1],
      recordedBy=dfData$recordedBy[1],
      lsTransaction=dfData$lsTransaction[1])
    upperAcasEntity <- acasEntityHierarchyCamel[which(currentEntity == acasEntityHierarchyCamel) - 1]
    if (is.null(dfData[[paste0(upperAcasEntity, "ID")]][1])) {
      stop("Internal Error: No ", paste0(upperAcasEntity, "ID"), " found in data")
    }
    if (is.null(dfData[[paste0(upperAcasEntity, "ID")]][1])) {
      stop("Internal Error: No ", paste0(upperAcasEntity, "Version"), " found in data")
    }
    entity[[upperAcasEntity]] <- list(id=dfData[[paste0(upperAcasEntity, "ID")]][1],
                                      version=dfData[[paste0(upperAcasEntity, "Version")]][1])
    return(entity)
  }
  
  entities <- dlply(.data=entityData, .variables = paste0(entityKind, "ID"), createEntityFromDF, currentEntity=entityKind)
  tempIds <- as.numeric(names(entities))
  
  names(entities) <- NULL
  savedEntities <- saveAcasEntities(entities, paste0(acasEntity, "s"))
  
  entityIds <- sapply(savedEntities, getElement, "id")
  entityVersions <- sapply(savedEntities, getElement, "version")
  
  entityData[[entityID]] <- entityIds[match(entityData[[entityID]], tempIds)]
  
  ###### entity States #######
  
  stateAndVersion <- saveStatesFromExplicitFormat(entityData, entityKind)
  entityData$stateID <- stateAndVersion$entityStateId
  entityData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### entity Values ======================================================================= 
  
  savedEntityValues <- saveValuesFromExplicitFormat(entityData, entityKind)
  #
  
  return(data.frame(tempID = tempIds, entityID = entityIds, entityVersion = entityVersions))
}
splitOnSemicolon <- function(x) {
  # splits a semicolon delimited list
  unlist(trim(strsplit(x, ";")))
}
runMain <- function(pathToGenericDataFormatExcelFile, reportFilePath=NULL,
                    lsTranscationComments=NULL, dryRun, developmentMode = FALSE, testOutputLocation="./JSONoutput.json",
                    configList, testMode = FALSE, recordedBy, errorEnv = NULL) {
  # This function runs all of the functions within the error handling
  # lsTransactionComments input is currently unused
  
  library('RCurl')
  
  lsTranscationComments <- paste("Upload of", pathToGenericDataFormatExcelFile)
  
  # Validate Input Parameters
  if (is.na(pathToGenericDataFormatExcelFile)) {
    stop("Need Excel file path as input")
  }
  if (!file.exists(pathToGenericDataFormatExcelFile)) {
    stop("Cannot find input file")
  }
  
  genericDataFileDataFrame <- readExcelOrCsv(pathToGenericDataFormatExcelFile)
  
  # Meta Data
  metaData <- getSection(genericDataFileDataFrame, lookFor = "Experiment Meta Data", transpose = TRUE)
  
  formatSettings <- getFormatSettings()
  
  validatedMetaDataList <- validateMetaData(metaData, configList, formatSettings, errorEnv)
  validatedMetaData <- validatedMetaDataList$validatedMetaData
  duplicateExperimentNamesAllowed <- validatedMetaDataList$duplicateExperimentNamesAllowed
  useExisting <- validatedMetaDataList$useExisting
  
  inputFormat <- as.character(validatedMetaData$Format)
  
  if (inputFormat == "Gene ID Data") {
    mainCode <- "Gene ID"
  } else {
    mainCode <- "Corporate Batch ID"
  }
  
  rawOnlyFormat <- inputFormat %in% names(formatSettings)
  if (rawOnlyFormat) {
    lookFor <- "Raw Data"
    lockCorpBatchId <- FALSE
    replaceFakeCorpBatchId <- "Vehicle"
    stateGroups <- getStateGroups(formatSettings[[inputFormat]])
    hideAllData <- formatSettings[[inputFormat]]$hideAllData
    curveNames <- formatSettings[[inputFormat]]$curveNames
    annotationType <- formatSettings[[inputFormat]]$annotationType
    sigFigs <- formatSettings[[inputFormat]]$sigFigs
    splitSubjects <- formatSettings[[inputFormat]]$splitSubjects
    rowMeaning <- formatSettings[[inputFormat]]$rowMeaning
    if(is.null(rowMeaning)) {
      rowMeaning <- "subject"
    }
    includeTreatmentGroupData <- formatSettings[[inputFormat]]$includeTreatmentGroupData
    if (is.null(includeTreatmentGroupData)) {
      includeTreatmentGroupData <- TRUE
    }
  } else {
    # TODO: generate the list dynamically
    if(!(inputFormat %in% c("Generic", "Dose Response", "Gene ID Data", "Use Existing Experiment", "Precise For Existing Experiment"))) {
      stop("The Format must be 'Generic', 'Dose Response', or some custom format that you have been given.")
    }
    lookFor <- "Calculated Results"
    lockCorpBatchId <- TRUE
    replaceFakeCorpBatchId <- ""
    stateGroups <- NULL
    curveNames <- NULL
    sigFigs <- NULL
    annotationType <- "s_general"
    splitSubjects <- NULL
  }
  precise <- inputFormat %in% c("Precise For Existing Experiment", "Precise")
  
  # Grab the Calculated Results Section
  calculatedResults <- getSection(genericDataFileDataFrame, lookFor = lookFor, transpose = FALSE)
  
  # Organize the Calculated Results
  calculatedResults <- organizeCalculatedResults(calculatedResults, lockCorpBatchId, replaceFakeCorpBatchId, 
                                                 rawOnlyFormat, stateGroups, splitSubjects, inputFormat, mainCode,
                                                 errorEnv, precise = precise, 
                                                 calculateGroupingID = ifelse(precise, NA, calculateTreatmemtGroupID))
  if (!is.null(splitSubjects)) {
    calculatedResults$subjectID <- calculatedResults$groupingID_2
    calculatedResults$treatmentGroupID <- calculatedResults$groupingID
    calculatedResults$subjectStateID <- calculatedResults$rowID
  } else if(rawOnlyFormat) {
    calculatedResults$subjectID <- calculatedResults$rowID
    calculatedResults$treatmentGroupID <- calculatedResults$groupingID
  } else {
    calculatedResults$analysisGroupID <- calculatedResults$rowID
    calculatedResults$stateGroupIndex <- 0
  }
  
  # Validate the Calculated Results
  calculatedResults <- validateCalculatedResults(calculatedResults,
                                                 dryRun, curveNames, testMode=testMode, 
                                                 replaceFakeCorpBatchId=replaceFakeCorpBatchId, mainCode)
  
  # Subject and TreatmentGroupData
  subjectData <- NULL
  treatmentGroupData <- NULL
  if (precise) {
    subjectData <- getSection(genericDataFileDataFrame, lookFor = "Raw Results", transpose = FALSE)
    link <- calculatedResults[calculatedResults$linkColumn, c("rowID", "stringValue")]
    treatmentGroupData <- getSection(genericDataFileDataFrame, lookFor = "Treatment Group Results")
    if (treatmentGroupData[1, 1] == "Group By") {
      treatmentGroupData <- getSection(genericDataFileDataFrame, lookFor = "Treatment Group Results", transpose = TRUE)
      
      groupByColumns <- splitOnSemicolon(treatmentGroupData$"Group By")
      groupByColumnsNoUnit <- trim(gsub("\\(\\w*\\)", "", groupByColumns))
      keepColumn <- splitOnSemicolon(treatmentGroupData$Include)
      excludedRowKind <- splitOnSemicolon(treatmentGroupData$"Remove Results With") # Removes results with a value for a certain valueKind
      
      # Other possibilities: average type (geometric or arithmetic), significant figures, SD vs SE, text rules... name of file to run...
      # Could create a new config setting for new function (use default here if not)
      
      
      #removeRowID <- subjectData$rowID[subjectData$valueKind %in% excludedRowKind] # If they were blank, they were not recorded
      #subjectDataKept$treatmentGroupID <- paste(subjectDataKept[groupByColumnsNoUnit], collapse = "-")
      #subjectDataKept <- as.data.table(subjectData)
      #subjectDataKept2 <- subjectDataKept[!(rowID %in% removeRowID), createTreatmentGroupData(.SD), by = groupByColumns]
      
      createPtgFunction <- function (groupByColumns, excludedRowKinds) {
        # Create a function that has the groupByColumns filled in
        function(results, inputFormat, stateGroups, resultTypes) {
          # stateGroups, inputFormat, and resultTypes not used
          # Remove rows that have excludedRowKinds
          keepRows <- as.matrix(is.na(results[excludedRowKinds]))
          ids <- as.numeric(factor(do.call(paste, results[, groupByColumns])))
          ids[apply(keepRows, 1, sum) == 0] <- NA
          return(ids)
        }
      }
      
      calculatePreciseTreatmentGroupID <- createPtgFunction(groupByColumns, excludedRowKind)
      
      subjectData2 <- as.data.table(organizeCalculatedResults(subjectData, lockCorpBatchId= F, inputFormat= inputFormat, 
                                               mainCode= mainCode, errorEnv= errorEnv, precise = T, link = link, 
                                               calculateGroupingID = calculatePreciseTreatmentGroupID))
      
      subjectData2[, treatmentGroupID := groupingID]
      subjectData2[, subjectID := rowID]
      
      concatUniqNonNA <- function(y) {
        if (all(is.na(y))) return (NA)
        paste0(Filter(function (x) {!is.na(x)}, unique(y)), collapse = "-")
      }
      
      uniqueOrNA <- function(x) {
        y <- unique(x)
        ifelse(length(y) == 1, y, NA)
      }
      
      createTreatmentGroupData <- function(x) {
        uncertainty <- as.numeric(sd(x$numericValue, na.rm=T))
        data.table(
          numericValue = as.numeric(mean(x$numericValue, na.rm=T)),
          stringValue = as.character(concatUniqNonNA(x$stringValue)),
          valueOperator = as.character(uniqueOrNA(x$valueOperator)),
          # TODO figure out if this should be coerced
          dateValue = uniqueOrNA(x$dateValue),
          clobValue = as.character(uniqueOrNA(x$clobValue)),
          urlValue = as.character(uniqueOrNA(x$urlValue)),
          fileValue = as.character(uniqueOrNA(x$fileValue)),
          codeValue = as.character(uniqueOrNA(x$codeValue)),
          uncertaintyType = if (is.na(uncertainty)) as.character(NA) else "standard deviation",
          uncertainty = uncertainty
        )
      }
      
      groupByColumnsNoUnit <- trim(gsub("\\(\\w*\\)", "", groupByColumns))
      subjectData3 <- subjectData2[valueKind %in% c(keepColumn, groupByColumnsNoUnit)]
      treatmentGroupData <- subjectData3[!is.na(groupingID), createTreatmentGroupData(.SD), 
                                          by = list(groupingID, valueType, valueKind, concentration, 
                                                    concentrationUnit, time, timeUnit, valueUnit, 
                                                    valueKindAndUnit, publicData, linkID, stateType,
                                                    stateKind)]
      treatmentGroupData[valueKind %in% groupByColumnsNoUnit, c("uncertainty", "uncertainType") := list(NA, NA)]
      treatmentGroupData[, treatmentGroupID := groupingID]
      treatmentGroupData[, analysisGroupID := linkID]
      treatmentGroupData <- as.data.frame(treatmentGroupData)
      
      subjectData <- as.data.frame(subjectData2)
    }
  } else {
    # Grab the Raw Results Section
    rawResults <- getSection(genericDataFileDataFrame, "Raw Results", transpose = FALSE)
    rawResults <- NULL
    # Organize the Raw Results into treatmentGroupData and subjectData 
    # and collect the names of the x, y, and temp labels

    tempIdLabel <- ""
    if(!is.null(rawResults)) {
      rawResults <- organizeRawResults(rawResults, calculatedResults, mainCode)
      # TODO: Should have a validation step to check raw results valueKinds
      xLabel <- rawResults$xLabel
      yLabel <- rawResults$yLabel
      tempIdLabel <- rawResults$tempIdLabel
      treatmentGroupData <- rawResults$treatmentGroupData
      subjectData <- rawResults$subjectData
      
      # Validate the treatment group data
      validateTreatmentGroupData(treatmentGroupData,calculatedResults, tempIdLabel)
    }
  }
  
  
  # If there are errors, do not allow an upload
  errorFree <- length(errorList)==0
  
  # When not on a dry run, creates a transaction for all of these
  lsTransaction <- NULL
  if(!dryRun && errorFree) {
    lsTransaction <- createLsTransaction(comments = lsTranscationComments)$id
  }
  
  # Get the protocol and experiment and, when not on a dry run, create them if they do not exist
  newProtocol <- FALSE
  if (!useExisting) {
    protocol <- getProtocolByNameAndFormat(protocolName = validatedMetaData$'Protocol Name'[1], configList, inputFormat)
    newProtocol <- is.na(protocol[[1]])
    if (!newProtocol) {
      metaData$'Protocol Name'[1] <- getPreferredProtocolName(protocol, validatedMetaData$'Protocol Name'[1])
    }
  }
  
  if (!dryRun && newProtocol && errorFree) {
    protocol <- createNewProtocol(metaData = validatedMetaData, lsTransaction, recordedBy)
  }
  
  useExistingExperiment <- inputFormat %in% c("Use Existing Experiment", "Precise For Existing Experiment")
  if (useExistingExperiment) {
    experiment <- getExperimentByCodeName(validatedMetaData$'Experiment Code Name'[1])
    if (length(experiment) == 0) {
      stop ("Experiment Code Name not found ", validatedMetaData$'Experiment Code Name'[1])
    }
    protocol <- getProtocolById(experiment$protocol$id)
    validatedMetaData$'Protocol Name' <- getPreferredName(protocol)
    validatedMetaData$'Experiment Name' <- getPreferredName(experiment)
  } else {
    experiment <- getExperimentByName(experimentName = validatedMetaData$'Experiment Name'[1], protocol, configList, duplicateExperimentNamesAllowed)
  }
  
  # Checks if we have a new experiment
  newExperiment <- class(experiment[[1]])!="list" && is.na(experiment[[1]])
  
  # If there are errors, do not allow an upload (yes, this is needed a second time)
  errorFree <- length(errorList)==0
  
  # Delete any old data under the same experiment name (delete and reload)
  deletedExperimentCodes <- NULL
  if(!dryRun && !newExperiment && errorFree) {
    deletedExperimentCodes <- deleteOldData(experiment, useExistingExperiment)
  }
  
  if (!dryRun && errorFree && !useExistingExperiment) {
    experiment <- createNewExperiment(metaData = validatedMetaData, protocol, lsTransaction, pathToGenericDataFormatExcelFile, 
                                      recordedBy, configList, deletedExperimentCodes)
    
    # If an error occurs, this allows the experiment to still be accessed
    assign(x="experiment", value=experiment, envir=parent.frame())
  }
  
  # Upload the data if this is not a dry run
  if(!dryRun & errorFree) {
    
    reportFileSummary <- paste0(validatedMetaData$'Protocol Name', " - ", validatedMetaData$'Experiment Name')
    if(rawOnlyFormat) { 
      uploadRawDataOnly(metaData = validatedMetaData, lsTransaction, subjectData = calculatedResults,
                        experiment, fileStartLocation = pathToGenericDataFormatExcelFile, configList, 
                        stateGroups, reportFilePath, hideAllData, reportFileSummary, curveNames, recordedBy, 
                        replaceFakeCorpBatchId, annotationType, sigFigs, rowMeaning, includeTreatmentGroupData, 
                        inputFormat, mainCode)
    } else {
      calculatedResults$experimentID <- experiment$id
      calculatedResults$experimentVersion <- experiment$version
      uploadData(metaData = validatedMetaData,lsTransaction,calculatedResults,treatmentGroupData, subjectData,
                 xLabel,yLabel,tempIdLabel,testOutputLocation,developmentMode,protocol,experiment, 
                 fileStartLocation = pathToGenericDataFormatExcelFile, configList=configList, 
                 reportFilePath=reportFilePath, reportFileSummary=reportFileSummary, recordedBy, annotationType, mainCode)
    }
  }
  
  viewerLink <- getViewerLink(protocol, experiment, validatedMetaData$'Experiment Name')
  
  summaryInfo <- list(
    format = inputFormat,
    lsTransactionId = lsTransaction,
    info = list()
  )
  if (!is.null(lsTransaction)) {
    summaryInfo$info$"Transaction Id" <- lsTransaction
  }
  summaryInfo$info$"Format" <- as.character(validatedMetaData$Format)
  summaryInfo$info$"Protocol" <- as.character(validatedMetaData$"Protocol Name")
  summaryInfo$info$"Experiment" <- as.character(validatedMetaData$"Experiment Name")
  summaryInfo$info$"Scientist" <- validatedMetaData$Scientist
  summaryInfo$info$"Notebook" <- validatedMetaData$Notebook
  if(!is.null(validatedMetaData$Page)) {
    summaryInfo$info$"Page" <- as.character(validatedMetaData$Page)
  }
  if(!is.null(validatedMetaData$"In Life Notebook")) {
    notebookIndex <- which(names(summaryInfo$info) == "Notebook")[1]
    summaryInfo$info$"In Life Notebook" <- as.character(validatedMetaData$"In Life Notebook")
  }
  summaryInfo$info$"Assay Date" = validatedMetaData$"Assay Date"
  summaryInfo$info$"Rows of Data" = max(calculatedResults$analysisGroupID)
  summaryInfo$info$"Columns of Data" = length(unique(calculatedResults$valueKindAndUnit))
  summaryInfo$info[[paste0("Unique ",mainCode,"'s")]] = length(unique(calculatedResults[[mainCode]]))
  if (!is.null(subjectData)) {
    # TODO Kelley: figure out what to replace this with rather than pointID
    summaryInfo$info$"Raw Results Data Points" <- max(subjectData$pointID)
    # TODO Kelley: figure out what to replace this with rather than subjectData$value
    summaryInfo$info$"Flagged Data Points" <- length(subjectData$value[subjectData$ResultType=="flag" & !is.na(subjectData$value)])
  }
  if(!dryRun) {
    summaryInfo$info$"Experiment Code Name" <- experiment$codeName
    if (!is.null(viewerLink)) {       
      summaryInfo$viewerLink <- viewerLink
    }
  }
  summaryInfo$experimentEntity <- experiment
  
  return(summaryInfo)
}
getStateGroups <- function(formatSettings) {
  #Gets stateGroups from configuration list
  
  tryCatch({
    stateGroups <- formatSettings$stateGroups
  }, error = function(e) {
    stop(paste("The format", inputFormat, "is missing stateGroup settings in the configuration file. Contact your system administrator."))
  })
  return(stateGroups)
}
deleteOldData <- function(experiment, useExistingExperiment) {
  # Deletes old data, either the whole experiment or just the analysisgroups
  deletedExperimentCodes <- NULL
  if(racas::applicationSettings$server.delete.files.on.reload == "true") {
    deleteSourceFile(experiment, racas::applicationSettings)
    deleteAnnotation(experiment, racas::applicationSettings)
  }
  if(useExistingExperiment) {
    deleteAnalysisGroupByExperiment(experiment)
  } else {
    deletedExperimentCodes <- c(experiment$codeName, getPreviousExperimentCodes(experiment))
    deleteExperiment(experiment)
  }
  return(deletedExperimentCodes)
}
getPreviousExperimentCodes <- function(experiment) {
  metadataState <- getStatesByTypeAndKind(experiment, "metadata_experiment metadata")[[1]]
  previousCodeValues <- getValuesByTypeAndKind(metadataState, "codeValue_previous experiment code")
  previousExperimentCodes <- lapply(previousCodeValues, getElement, "codeValue")
  return(previousExperimentCodes)
}
getViewerLink <- function(protocol, experiment, experimentName = NULL, protocolName = NULL) {
  # Returns url link for viewer
  
  if(is.null(experimentName)) {
    experimentName <- getPreferredName(experiment)
  }
  
  # Add name modifier to protocol name for viewer
  protocolPostfixStates <- list()
  if (is.list(protocol$lsStates)) {
    protocolPostfixStates <- Filter(function(x) {x$lsTypeAndKind == "metadata_name modifier"}, 
                                    protocol$lsStates)
  }
  
  protocolPostfix <- ""
  if (length(protocolPostfixStates) > 0) {
    protocolPostfixState <- protocolPostfixStates[[1]]
    protocolPostfixValues <- Filter(function(x) {x$lsTypeAndKind == "stringValue_postfix"},
                                    protocolPostfixState)
    protocolPostfix <- protocolPostfixValues[[1]]$stringValue
  }
  
  if (!is.null(racas::applicationSettings$client.service.result.viewer.protocolPrefix)) {
    if (!(is.null(protocolName))) {
      protocolName <- paste0(protocolName, protocolPostfix)
    } else {
      protocol <- getProtocolById(protocol$id)
      
      protocolName <- getPreferredName(protocol)
    }
    
    if (is.list(experiment) && racas::applicationSettings$client.service.result.viewer.experimentNameColumn == "EXPERIMENT_NAME") {
      experimentName <- paste0(experiment$codeName, "::", experimentName)
    }
    viewerLink <- paste0(racas::applicationSettings$client.service.result.viewer.protocolPrefix, 
                         URLencode(protocolName, reserved=TRUE), 
                         racas::applicationSettings$client.service.result.viewer.experimentPrefix,
                         URLencode(experimentName, reserved=TRUE))
  } else {
    viewerLink <- NULL
  }
  return(viewerLink)
}
translateClassToValueKind <- function(x, reverse = F) {
  # translates Excel style Number formats to ACAS valueKinds (or reverse)
  valueTypeVector <- c("numericValue", "stringValue", "fileValue", "urlValue", "dateValue", "clobValue", "blobValue", "codeValue")
  classVector <- c("Number", "Text", "File", "URL", "Date", "Clob", "Blob", "Code")
  if (reverse) {
    return(classVector[match(x, valueTypeVector)])
  } else {
    return(valueTypeVector[match(x, classVector)])
  }
}
parseGenericData <- function(request) {
  # Highest level function
  # 
  # Outputs a response with labels: 
  #   value (a list with numbers of analysis groups, treatment groups, and subjects to be uploaded)
  #   warningList (a character vector)
  #   errorList (a character vector)
  #   error (a boolean)
  
  # Set up high level needs
  require('compiler')
  enableJIT(3)
  options("scipen"=15)
  # This is used for development: outputs the JSON rather than sending it to the
  # server and does not wrap everything in tryCatch so traceback() will work
  developmentMode <- FALSE
  
  # Collect the information from the request
  request <- as.list(request)
  pathToGenericDataFormatExcelFile <- request$fileToParse
  dryRun <- request$dryRunMode
  testMode <- request$testMode
  reportFilePath <- request$reportFile
  recordedBy <- request$user
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  testMode <- interpretJSONBoolean(testMode)
  if(is.null(testMode)) {
    testMode <- FALSE
  }
  
  # Set configList to the applicationSettings (shorter to type)
  configList <- racas::applicationSettings
  
  experiment <- NULL
  
  # If there is a global defined by another R code, this will overwrite it
  errorList <<- list()
  
  # Make this local once all are fixed
  errorEnv <- globalenv()
  
  # Run the function and save output (value), errors, and warnings
  if (developmentMode) {
    return(list(runMain(pathToGenericDataFormatExcelFile,
                        reportFilePath = reportFilePath,
                        dryRun = dryRun,
                        developmentMode = developmentMode,
                        configList=configList, 
                        testMode=testMode,
                        recordedBy=recordedBy,
                        errorEnv = errorEnv)))
  } else {
    loadResult <- tryCatch.W.E(runMain(pathToGenericDataFormatExcelFile,
                                       reportFilePath = reportFilePath,
                                       dryRun = dryRun,
                                       developmentMode = developmentMode,
                                       configList=configList, 
                                       testMode=testMode,
                                       recordedBy=recordedBy,
                                       errorEnv = errorEnv))
  }
  
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
  htmlSummary <- createHtmlSummary(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value,dryRun)
  
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
      fileToParse= pathToGenericDataFormatExcelFile,
      dryRun= dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}


#' Save states from a long format
#'
#' This function saves states to the database specified in \code{\link{applicationSettings}}
#' 
#'
#' @param entityData a data.frame, including one column named 'stateGroupIndex', one that matches idColumn, and one of the form 'entityID'
#' @param entityKind a string, the kind of the state, limited to "protocol", "experiment", "analysisgroup", "treatmentgroup", "subject", "container", "itxcontainercontainer"
#' @param stateGroups a list of lists, each of which includes details about how to save states (TODO link later)
#' @param stateGroupIndices an integer vector of indices to use from stateGroups
#' @param idColumn a string, the name of the column used to separate states (often stateID)
#' @param recordedBy a string, the name of the person recording the data
#' @param lsTransaction an integer, the id of the lsTransaction
#' @param  testMode A boolean marking if the function should return JSON instead of saving values
#' @return A data.frame with columns "entityStateId" and "entityStateVersion", which are often added back to the original data.frame
#' @keywords save, format, stateGroups
#' @details Assumes all higher level entities are new, i.e. version = 0.
#' Does not allow containers or interactions
#' @export

saveStatesFromExplicitFormat <- function(entityData, entityKind, testMode=FALSE) {
  #TODO: should allow containers or interactions
  idColumn = "stateID"
  entityID = paste0(entityKind, "ID")
  entityVersion = paste0(entityKind, "Version")
  
  acasServerEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  
  
  # If no version given, assume version 0
  if (!(entityVersion %in% names(entityData))) {
    entityData[[entityVersion]] <- 0
  }
  
  if (!(idColumn %in% names(entityData))) {
    stop(paste0("Internal Error: ", idColumn, " must be a column in entityData"))
  }
  
  if (!(entityKind %in% racas::acasEntityHierarchyCamel)) {
    stop("Internal Error: entityKind must be in racas::acasEntityHierarchyCamel")
  }
  
  if (!(entityID %in% names(entityData))) {
    stop("Internal Error: ", entityID, " must be included in entityData")
  }
  
  createExplicitLsState <- function(entityData, entityKind) {
    # TODO: add stateType and StateKind to meltBatchCodes
    lsType <- entityData$stateType[1]
    lsKind <- entityData$stateKind[1]
    lsState <- list(lsType = entityData$stateType[1],
                    lsKind = entityData$stateKind[1],
                    recordedBy = entityData$recordedBy[1],
                    lsTransaction = entityData$lsTransaction[1])
    # e.g. lsState$analysisGroup <- list(id=entityData$analysisGroupID[1], version=0)
    lsState[[entityKind]] <- list(id = entityData[[entityID]][1], version = entityData[[entityVersion]][1])
    return(lsState)
  }
  
  lsStates <- dlply(.data=entityData, .variables=idColumn, .fun=createExplicitLsState, entityKind=entityKind)
  originalStateIds <- names(lsStates)
  names(lsStates) <- NULL
  if (testMode) {
    lsStates <- lapply(lsStates, function(x) {x$recordedDate <- 1381939115000; return (x)})
    return(toJSON(lsStates))
  } else {
    savedLsStates <- saveAcasEntities(lsStates, paste0(acasServerEntity, "states"))
  }
  
  lsStateIds <- sapply(savedLsStates, getElement, "id")
  lsStateVersions <- sapply(savedLsStates, getElement, "version")
  entityStateTranslation <- data.frame(entityStateId = lsStateIds, 
                                       originalStateId = originalStateIds, 
                                       entityStateVersion = lsStateVersions)
  stateIdAndVersion <- entityStateTranslation[match(entityData[[idColumn]], 
                                                    entityStateTranslation$originalStateId),
                                              c("entityStateId", "entityStateVersion")]
  return(stateIdAndVersion)
}

#' saves "raw only" values
#' 
#' Saves values from a specific format
#' 
#' @param entityData A data frame that includes columns:
#'    \describe{
#'    \item{stateGroupIndex}{Integer vector marking the index of the state group for each row}
#'    \item{operatorType}{String: the type of the operator}
#'    \item{unitType}{String: the type of the unit}
#'     \item{stateID}{An integer that is the ID of the state for each value}
#'     \item{valueType}{A string of "stringValue", "dateValue", or "numericValue"}
#'     \item{valueKind}{A string value ofthe kind of value}
#'     \item{publicData}{Boolean: Marks if each value should be hidden}
#'     \item{stateVersion}{An integer that is the version of the state for each value}
#'     \item{stringValue}{String: a string value (optional)}
#'     \item{codeValue}{String: a code, such as a batch code (optional)}
#'     \item{fileValue}{String: a code that refers to a file, or a path extension of the blueimp public folder (optional)}
#'     \item{urlValue}{String: a url (optional)}
#'     \item{numericValue}{Number: a number (optional)}
#'     \item{dateValue}{A Date value (optional)}
#'     \item{valueOperator}{String: The operator for each value (optional)}
#'     \item{valueUnit}{String: The units for each value (optional)}
#'     \item{clobValue}{String: for very long strings (optional)}
#'     \item{blobValue}{Anything: no case that exists right now (optional)}
#'     \item{numberOfReplicates}{Integer: The number of replicates (optional)}
#'     \item{uncertainty}{Numeric: the uncertainty (optional)}
#'     \item{uncertaintyType}{String: the type of uncertainty, such as standard deviation (optional)}
#'     \item{comments}{String: mainly used for filenames (fileValue is filled with codes) (optional)}
#'     }
#' @param  entityKind          String: the kind of the state, allowed values are: "protocol", "experiment", "analysisgroup", 
#' "subject", "treatmentgroup", "container", "itxcontainercontainer", "itxsubjectcontainer"
#' @param  stateGroups          A list of lists, each of which includes details about how to save states
#' @param  stateGroupIndices    An integer vector of the indices to use from stateGroups (others are removed)
#' @param  lsTransaction        An id of an lsTransaction
#' @param  testMode             A boolean marking if the function should return JSON instead of saving values
#' @param recordedBy String: the username recording the data
#' @return A list of value objects (lists)
#' @details In longFormatSave.R
#' Will coerce all factors to character
saveValuesFromExplicitFormat <- function(entityData, entityKind, testMode=FALSE) {
  ### static variables
  #TODO: should allow containers or interactions
  idColumn = "stateID"
  acasServerEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  
  #create a uniqueID to split on
  entityData$uniqueID <- 1:(nrow(entityData))
  
  optionalColumns <- c("fileValue", "urlValue", "codeValue", "numericValue", "dateValue",
                       "valueOperator", "valueUnit", "clobValue", "blobValue", "numberOfReplicates",
                       "uncertainty", "uncertaintyType", "comments")
  missingOptionalColumns <- Filter(function(x) !(x %in% names(entityData)),
                                   optionalColumns)
  entityData[missingOptionalColumns] <- NA
  
  ### Error Checking
  requiredColumns <- c("valueType", "valueKind", "publicData", "stateVersion", "stateID")
  if (any(!(requiredColumns %in% names(entityData)))) {
    stop("Internal Error: Missing input columns in entityData, must have ", paste(requiredColumns, collapse = ", "))
  }
  
  # Turns factors to character
  factorColumns <- vapply(entityData, is.factor, c(TRUE))
  entityData[factorColumns] <- lapply(entityData[factorColumns], as.character)
  
  if (is.character(entityData$dateValue)) {
    entityData$dateValue[entityData$dateValue == ""] <- NA
    entityData$dateValue <- as.numeric(format(as.Date(entityData$dateValue,origin="1970-01-01"), "%s"))*1000
  } else if (is.numeric(entityData$dateValue)) {
    # No change
  } else if (is.null(entityData$dateValue) || all(is.na(entityData$dateValue))) {
    entityData$dateValue <- as.character(NA)
  } else {
    stop("Internal Error: unrecognized class of entityData$dateValue: ", class(entityData$dateValue))
  }
  
  
  
  ### Helper function
  createLocalStateValue <- function(valueData) {
    stateValue <- with(valueData, {
      createStateValue(
        lsState = list(id = stateID, version = stateVersion),
        lsType = if (valueType %in% c("stringValue", "fileValue", "urlValue", "dateValue", "clobValue", "blobValue", "numericValue", "codeValue")) {
          valueType
        } else {"numericValue"},
        lsKind = valueKind,
        stringValue = if (is.character(stringValue) && !is.na(stringValue)) {stringValue} else {NULL},
        dateValue = if(is.numeric(stringValue)) {dateValue} else {NULL},
        clobValue = if(is.character(clobValue) && !is.na(clobValue)) {clobValue} else {NULL},
        blobValue = if(!is.null(blobValue) && !is.na(blobValue)) {blobValue} else {NULL},
        codeValue = if(is.character(codeValue) && !is.na(codeValue)) {codeValue} else {NULL},
        fileValue = if(is.character(fileValue) && !is.na(fileValue)) {fileValue} else {NULL},
        urlValue = if(is.character(urlValue) && !is.na(urlValue)) {urlValue} else {NULL},
        valueOperator = if(is.character(valueOperator) && !is.na(valueOperator)) {valueOperator} else {NULL},
        operatorType = if(is.character(operatorType) && !is.na(operatorType)) {operatorType} else {NULL},
        numericValue = if(is.numeric(numericValue) && !is.na(numericValue)) {numericValue} else {NULL},
        valueUnit = if(is.character(valueUnit) && !is.na(valueUnit)) {valueUnit} else {NULL},
        unitType = if(is.character(unitType) && !is.na(unitType)) {unitType} else {NULL},
        publicData = publicData,
        lsTransaction = lsTransaction,
        numberOfReplicates = if(is.numeric(numberOfReplicates) && !is.na(numberOfReplicates)) {numberOfReplicates} else {NULL},
        uncertainty = if(is.numeric(uncertainty) && !is.na(uncertainty)) {uncertainty} else {NULL},
        uncertaintyType = if(is.character(uncertaintyType) && !is.na(uncertaintyType)) {uncertaintyType} else {NULL},
        recordedBy = recordedBy,
        comments = if(is.character(comments) && !is.na(comments)) {comments} else {NULL}
      )
    })
    return(stateValue)
  }
  entityValues <- plyr::dlply(.data = entityData, 
                              .variables = .(uniqueID), 
                              .fun = createLocalStateValue)
  
  names(entityValues) <- NULL
  
  if (testMode) {
    entityValues <- lapply(entityValues, function(x) {x$recordedDate <- 42; return (x)})
    return(toJSON(entityValues))
  } else {
    savedEntityValues <- saveAcasEntities(entityValues, paste0(acasServerEntity, "values"))
    return(savedEntityValues)
  }
}
