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

require(racas)
source("public/src/conf/customFunctions.R")
source("public/src/conf/genericDataParserConfiguration.R")

#####
# Define Functions
validateMetaData <- function(metaData, configList, formatSettings = list()) {
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
  
  expectedDataFormat <- data.frame(
    headers = c("Format","Protocol Name","Experiment Name","Scientist","Notebook","In Life Notebook", 
                "Short Description", "Experiment Keywords", "Page","Assay Date"),
    class = c("stringValue", "stringValue", "stringValue", "stringValue", "stringValue", "stringValue", "stringValue", "stringValue", "stringValue", "dateValue"),
    isNullable = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE)
  )
  
  if (!is.null(configList$client.include.project) && configList$client.include.project == "TRUE") {
    expectedDataFormat <- rbind(expectedDataFormat, data.frame(headers = "Project", class= "stringValue", isNullable = FALSE))
  }
  if (length(formatSettings) > 0) {
    expectedDataFormat <- rbind(expectedDataFormat, formatSettings[[as.character(metaData$Format)]]$extraHeaders)
  }
  
  if ("Assay Completion Date" %in% names(metaData)) {
    names(metaData)[names(metaData) == "Assay Completion Date"] <- "Assay Date"
  }
  
  if (is.null(metaData$Format)) {
    stop("A Format must be entered in the Experiment Meta Data.")
  }
  
  validatedMetaData <- validateSharedMetaData(metaData, expectedDataFormat)
  
  if (!is.null(metaData$Project)) {
    validatedMetaData$Project <- validateProject(validatedMetaData$Project, configList) 
  }
  if (!is.null(metaData$Scientist)) {
    validatedMetaData$Scientist <- validateScientist(validatedMetaData$Scientist, configList) 
  }
  
  if(grepl("CREATETHISEXPERIMENT$", validatedMetaData$"Experiment Name")) {
    validatedMetaData$"Experiment Name" <- trim(gsub("CREATETHISEXPERIMENT$", "", validatedMetaData$"Experiment Name"))
    duplicateExperimentNamesAllowed <- TRUE
  } else {
    duplicateExperimentNamesAllowed <- FALSE
  }
  
  return(list(validatedMetaData=validatedMetaData, duplicateExperimentNamesAllowed=duplicateExperimentNamesAllowed))
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
  #textTempIds <- grep("\\S",calculatedResults$"Result Desc"[calculatedResults$"Result Type"==tempIdLabel],value=TRUE)
  
  # Get a list of the temporary id's in the calculated results
  tempIdList <- calculatedResults$"Result Desc"[calculatedResults$"Result Type"==tempIdLabel]
  
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
validateCalculatedResults <- function(calculatedResults, dryRun, curveNames, testMode = FALSE, replaceFakeCorpBatchId="") {
  # Valides the calculated results (for now, this only validates the Corporate Batch Ids)
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
  
  # Get the current batch Ids
  batchesToCheck <- calculatedResults$originalCorporateBatchID != replaceFakeCorpBatchId
  batchIds <- unique(calculatedResults$"Corporate Batch ID"[batchesToCheck])
  newBatchIds <- getPreferredId(batchIds, testMode=testMode)
  
  # If the preferred Id service does not return anything, errors will already be thrown, just move on
  if (is.null(newBatchIds)) {
    return(calculatedResults)
  }
  
  # Give warning and error messages for changed or missing id's
  for (batchId in newBatchIds) {
    if (batchId["preferredName"] == "") {
      errorList <<- c(errorList, paste0("Corporate Batch Id '", batchId["requestName"], 
                                        "' has not been registered in the system. Contact your system administrator for help."))
    } else if (as.character(batchId["requestName"]) != as.character(batchId["preferredName"])) {
      warning(paste0("A Corporate Batch ID that you entered, '", batchId["requestName"], 
                     "', was replaced by preferred Corporate Batch ID '", batchId["preferredName"], 
                     "'. If this is not what you intended, replace the Corporate Batch ID with the correct ID."))
    }
  }
  
  # Put the batch id's into a useful format
  preferredIdFrame <- as.data.frame(do.call("rbind",newBatchIds), stringsAsFactors=FALSE)
  names(preferredIdFrame) <- names(newBatchIds[[1]])
  preferredIdFrame <- as.data.frame(lapply(preferredIdFrame,unlist), stringsAsFactors=FALSE)
  
  # Use the data frame to replace Corp Batch Ids with the preferred batch IDs
  calculatedResults$"Corporate Batch ID"[batchesToCheck] <- preferredIdFrame$preferredName[match(calculatedResults$"Corporate Batch ID"[batchesToCheck],preferredIdFrame$requestName)]
  
  #### ================= Check the value kinds =======================================================
  neededValueKinds <- c(calculatedResults$"Result Type", curveNames)
  neededValueKindTypes <- c(calculatedResults$Class, rep("Text", length(curveNames)))
  
  validateValueKinds(neededValueKinds, neededValueKindTypes, dryRun)
  
  # Return the validated results
  return(calculatedResults)
}
getHiddenColumns <- function(classRow) {
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
  if(length(unknownColumns)>0) {
    if(length(unknownColumns)==1) {
      errorList <<- c(errorList,paste0("In Datatype column ",getExcelColumnFromNumber(unknownColumns),", there is an entry in the parentheses that cannot be understood: '", 
                                       dataShown[unknownColumns],
                                       "'. Please enter 'shown' or 'hidden'."))
    } else {
      errorList <<- c(errorList,paste0("In Datatype columns ",paste0(sapply(unknownColumns,getExcelColumnFromNumber),collapse = ", "), 
                                       ", there are unknown entries in the parentheses that cannot be understood: '", 
                                       paste0(dataShown[unknownColumns], collapse="', '"),
                                       "'. Please enter 'shown' or 'hidden'."))
    }
  }
  return(hiddenColumns)
}
validateCalculatedResultDatatypes <- function(classRow,LabelRow, lockCorpBatchId = TRUE, clobColumns=c()) {
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
      errorList <<- c(errorList,paste0("The first row below 'Calculated Results' must begin with 'Datatype'. ",
                                       "Right now, it is '", classRow[1], "'."))
    }
  }
  
  # Remove the hidden/shown info
  classRow <- trim(gsub("\\(.*)","",classRow))
  
  classRow[clobColumns] <- "Clob"
  
  # Check if the datatypes are entered correctly
  badClasses <- setdiff(classRow[1:length(classRow)>1], c("Text","Number","Date","Clob","", NA))
  
  # Let the user know about empty datatypes
  emptyClasses <- which(is.na(classRow) | trim(classRow)=="")
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
      errorList <<- c(errorList,paste0("The loader found classes in the Datatype row that it does not understand: '",
                                       paste(unhandledClasses,collapse = "', '"),
                                       "'. Please enter 'Number','Text', or 'Date'."))
      
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
  
  neededValueKindTypes <- c("numericValue", "stringValue", "dateValue", "clobValue")[match(neededValueKindTypes, c("Number", "Text", "Date", "Clob"))]
  outputList <- checkValueKinds(neededValueKinds, neededValueKindTypes)
  newValueKinds <- outputList$newValueKinds
  wrongTypeKindFrame <- outputList$wrongTypeKindFrame
  oldValueKindTypes <- wrongTypeKindFrame$oldValueKindTypes
  
  oldValueKindTypes <- c("numericValue", "stringValue", "dateValue", "clobValue")[match(oldValueKindTypes, c("Number", "Text", "Date", "Clob"))]
  
  # Throw errors if any values are of types that cannot be entered in SEL
  reservedValueKinds <- wrongTypeKindFrame$oldValueKinds[wrongTypeKindFrame$oldValueKindTypes %in% c("codeValue", "fileValue", "urlValue", "blobValue")]
  if (length(reservedValueKinds) > 0) {
    stop(paste0("The column header ", sqliz(reservedValueKinds), " is reserved and cannot be used"))
  }
  if(nrow(wrongTypeKindFrame) > 0) {
    problemFrame <- wrongTypeKindFrame
    problemFrame$oldValueKindTypes <- c("Number", "Text", "Date", "Clob")[match(wrongTypeKindFrame$oldValueKindTypes, c("numericValue", "stringValue", "dateValue", "clobValue"))]
    problemFrame$matchingValueKindTypes <- c("Number", "Text", "Date", "Clob")[match(wrongTypeKindFrame$enteredValueTypes, c("numericValue", "stringValue", "dateValue", "clobValue"))]
    
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
      valueKindTypes <- neededValueKindTypes[match(newValueKinds, neededValueKinds)]
      valueKindTypes <- c("numericValue", "stringValue", "dateValue", "clobValue")[match(valueKindTypes, c("Number", "Text", "Date", "Clob"))]
      
      # This is for the curveNames, but would catch other added values as well
      valueKindTypes[is.na(valueKindTypes)] <- "stringValue"
      
      saveValueKinds(valueKinds, valueKindTypes)
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
extractResultTypes <- function(resultTypesVector, ignoreHeaders = NULL) {
  # Extracts result types, units, conc, and conc units from a list of strings
  #
  # Args:
  #   resultTypesVector: A charactor vector containing result types in the format "Result Type (units) [Conc ConcUnits]"
  #
  # Returns:
  #  A data frame containing the Result Type, Units, Conc, and ConcUnits for each item in the result types character vector
  
  require('gdata')
  emptyResultTypes <- is.na(resultTypesVector) | (trim(resultTypesVector) == "")
  if (any(emptyResultTypes)) {
    stop(paste0("Column ", paste(getExcelColumnFromNumber(which(emptyResultTypes)), collapse=", "), " has a blank column header. ",
                "Please enter a column header before reuploading."))
  }
  
  dataColumns <- c()
  for(col in 1:length(resultTypesVector)) {
    column <- as.character(resultTypesVector[[col]])
    if(!toupper(column) %in% toupper(ignoreHeaders)) {
      dataColumns <- c(dataColumns,column)
    }
  }
  returnDataFrame <- data.frame("DataColumn" = array(dim = length(dataColumns)), "Kind" = array(dim = length(dataColumns)), "Units" = array(dim = length(dataColumns)), "Conc" = array(dim = length(dataColumns)), "ConcUnits" = array(dim = length(dataColumns)))
  returnDataFrame$DataColumn <- dataColumns
  returnDataFrame$Kind <- trim(gsub("\\[[^)]*\\]","",gsub("(.*)\\((.*)\\)(.*)", "\\1\\3",gsub("\\{[^}]*\\}","",dataColumns))))
  # This removes "Reported" from all columns
  returnDataFrame$Kind <- trim(gsub("Reported","",returnDataFrame$Kind))
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
organizeCalculatedResults <- function(calculatedResults, lockCorpBatchId = TRUE, replaceFakeCorpBatchId = NULL, rawOnlyFormat = FALSE, stateGroups = NULL, splitSubjects = NULL, inputFormat) {
  # Organizes the calculated results section
  #
  # Args:
  #   calculatedResults: 			A "data.frame" of the columns containing the calculated results for the experiment
  #   lockCorpBatchId:        A boolean which marks if the corporate batch id is locked as the left column
  #   replaceFakeCorpBatchId: A string that is not a corp batch id, will be ignored by the batch check, and will be replaced by a column of the same name
  #   rawOnlyFormat:          A boolean that describes the data format, subject based or analysis group based
  #
  # Returns:
  #	  a data frame containing the organized calculated data

  require('reshape')
  require('gdata')
  
  if(ncol(calculatedResults)==1) {
    stop("The rows below Calculated Results must have at least two columns filled: one for Corporate Batch ID's and one for data.")
  }
  
  # Check the Datatype row and get information from it
  hiddenColumns <- getHiddenColumns(as.character(unlist(calculatedResults[1,])))
  
  clobColumns <- vapply(calculatedResults, function(x) any(nchar(as.character(x)) > 255), c(TRUE))

  classRow <- validateCalculatedResultDatatypes(as.character(unlist(calculatedResults[1,])),as.character(unlist(calculatedResults[2,])), lockCorpBatchId, clobColumns)
  
  if(any(clobColumns & !(classRow=="Clob"))) {
    warning("One of your entries had more than 255 characters, so it will be saved as a 'Clob'. In the future, you should use this for your column header.")
  }
  
  # Remove Datatype Row
  calculatedResults <- calculatedResults[1:nrow(calculatedResults)>1,]
  
  # Get the line containing the result types
  calculatedResultsResultTypeRow <- calculatedResults[1:nrow(calculatedResults)==1,]
  
  # Make sure the Corporate Batch Id is included
  if (lockCorpBatchId) {
    if(calculatedResultsResultTypeRow[1]!="Corporate Batch ID") {
      stop("Could not find 'Corporate Batch ID' column. The Corporate Batch ID column should be the first column of the Calculated Results")
    }
  } else {
    if(!("Corporate Batch ID" %in% unlist(calculatedResultsResultTypeRow))) {
      stop("Could not find 'Corporate Batch ID' column.")
    }
  }
  
  if(any(duplicated(unlist(calculatedResultsResultTypeRow)))) {
    errorList <<- c(errorList,paste0("These column headings are duplicated: ",
                                     paste(unlist(calculatedResultsResultTypeRow[duplicated(unlist(calculatedResultsResultTypeRow))]),collapse=", "),
                                     ". All column headings must be unique."))
  }
  
  # These columns are not result types and should not be pivoted into long format
  ignoreTheseAsResultTypes <- c("Corporate Batch ID", "originalCorporateBatchID")
  
  # Call the function that extracts result type names, units, conc, concunits from the headers
  resultTypes <- extractResultTypes(calculatedResultsResultTypeRow, ignoreTheseAsResultTypes)
  
  # Add data class and hidden/shown to the resultTypes
  resultTypes$dataClass <- classRow[calculatedResultsResultTypeRow!="Corporate Batch ID"]
  resultTypes$hidden <- hiddenColumns[calculatedResultsResultTypeRow!="Corporate Batch ID"]
  
  # Grab the rows of the calculated data 
  results <- subset(calculatedResults,1:nrow(calculatedResults) > 1)
  names(results) <- unlist(calculatedResultsResultTypeRow)
  
  # Replace fake corporate batch ids with the column that holds replacements (the column must have the same name that is entered in Corporate Batch ID)
  results$"Corporate Batch ID" <- as.character(results$"Corporate Batch ID")
  results$originalCorporateBatchID <- results$"Corporate Batch ID"
  if (!is.null(replaceFakeCorpBatchId)) {
    replacementRows <- results$"Corporate Batch ID" == replaceFakeCorpBatchId
    results$"Corporate Batch ID"[replacementRows] <- as.character(results[replacementRows,replaceFakeCorpBatchId])
  }
  
  # calculateTreatmentGroupID is in customFunctions.R
  organizedData <- meltWideData(results, resultTypes, stateGroups, splitSubjects, calculateTreatmemtGroupID)
  
  nameChange <- c('batchCode'='Corporate Batch ID', 'valueKind'='Result Type', 'valueUnit'='Result Units', 'concentration'='Conc', 
                  'concentrationUnit'='Conc Units', 'time'='time', 'timeUnit'='timeUnit', 'numericValue'='Result Value', 
                  'stringValue'='Result Desc', 'valueOperator'='Result Operator', 'subjectStateID'='subjectStateID', 
                  'dateValue'='Result Date', 'clobValue'='clobValue', 'valueType'='Class', 'resultTypeAndUnit'='resultTypeAndUnit', 
                  'publicData'='Hidden', 'originalBatchCode'='originalCorporateBatchID', 'splitFunctionID'='treatmentGroupID', 
                  'splitColumnID'='subjectID', 'rowID'='analysisGroupID')
  
  names(organizedData)[names(organizedData) %in% names(nameChange)] <- nameChange[names(organizedData)[names(organizedData) %in% names(nameChange)]]
  organizedData$Hidden <- !organizedData$Hidden
  
  # Right now, extractResultTypes already returns Number, Text, etc.
  #organizedData$Class <- c("Number","Text","Date", "Clob")[match(organizedData$Class,c("numericValue","stringValue","dateValue", "clobValue"))]
  
  # Clean up the data frame to look nice (remove extra columns)
  row.names(organizedData) <- 1:nrow(organizedData)
#   organizedData <- organizedData[c("Corporate Batch ID","Result Type","Result Units","Conc","Conc Units", "time", "timeUnit", "numericValue",
#                                  "stringValue","valueOperator","rowID","dateValue","clobValue","valueType",
#                                  "resultTypeAndUnit","Hidden", "originalCorporateBatchID", "treatmentGroupID", "splitColumnID")]
  
  return(organizedData)
}
organizeRawResults <- function(rawResults, calculatedResults) {
  # Valides and organizes the calculated results section
  #
  # Args:
  #   rawResults: 			  A "data.frame" of the columns containing the raw results for the experiment
  #   calculatedResults:  A "data.frame" of the columns containing the calculated results for the experiment
  #                         It is here used to connect the Corporate Batch ID's
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
  resultTypes <- extractResultTypes(rawResultsTypeRow)
  
  # Get the x and y labels without units
  xLabel <- resultTypes$Kind[match(xLabelWithUnit,resultTypes$DataColumn)]
  yLabel <- resultTypes$Kind[match(yLabelWithUnit,resultTypes$DataColumn)]
  
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
  tempIdTable <- calculatedResults[calculatedResults$"Result Type" == tempIdLabel,]
  longTreatmentGroupResults$"Corporate Batch ID" <- tempIdTable$"Corporate Batch ID"[match(longTreatmentGroupResults[,tempIdLabel],tempIdTable$"Result Value")]
  longTreatmentGroupResults$"Result Units" <- resultTypes$Units[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  longTreatmentGroupResults$"Conc" <- resultTypes$Conc[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  longTreatmentGroupResults$"Conc Units" <- resultTypes$concUnits[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  longTreatmentGroupResults$ResultType <- resultTypes$Kind[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  
  # Get Subject data
  
  # Add a point ID to keep track of the points
  names(results) <- c(sapply(unlist(rawResultsTypeRow),as.character),"pointID")
  
  # Change to a long format
  longResults <- melt(results, id.vars = c("pointID", tempIdLabel), variable_name = "ResultType") 
  
  # Connect Batch ID's
  tempIdTable <- calculatedResults[calculatedResults$"Result Type" == tempIdLabel,]
  longResults$"Corporate Batch ID" <- tempIdTable$"Corporate Batch ID"[match(longResults[,tempIdLabel],tempIdTable$"Result Value")]
  
  # Add units
  longResults$"Result Units" <- resultTypes$Units[match(longResults$"ResultType",resultTypes$DataColumn)]
  longResults$"Conc" <- resultTypes$Conc[match(longResults$"ResultType",resultTypes$DataColumn)]
  longResults$"Conc Units" <- resultTypes$concUnits[match(longResults$"ResultType",resultTypes$DataColumn)]
  longResults$ResultType <- resultTypes$Kind[match(longResults$"ResultType",resultTypes$DataColumn)]
  
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
                                 experimentStates=experimentStates)
  
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
  projectCodes <- sapply(projectList, function(x) x$code)
  if(length(projectCodes) == 0) {errorList <<- c(errorList, "No projects are available, contact your system administrator")}
  if (toupper(projectName) %in% projectCodes) {
    return(toupper(projectName))
  } else {
    errorList <<- c(errorList, paste0("The project you entered is not an available project. Please enter one of these projects: '",
                                      paste(projectCodes, collapse = "', '"), "'."))
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
getExpectedMetaDataFormat <- function() {
  # Has settings for expected metadata format
  expectedDataFormat <- data.frame(
    headers = c("Format","Protocol Name","Experiment Name","Scientist","Notebook","In Life Notebook", 
                "Short Description", "Experiment Keywords", "Page","Assay Date"),
    class = c("Text", "Text", "Text", "Text", "Text", "Text", "Text", "Text", "Text", "Date"),
    isNullable = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE)
  )
  
  
}
uploadRawDataOnly <- function(metaData, lsTransaction, subjectData, experiment, fileStartLocation, 
                              configList, stateGroups, reportFilePath, hideAllData, reportFileSummary, curveNames,
                              recordedBy, replaceFakeCorpBatchId, annotationType, sigFigs, rowMeaning="subject", 
                              includeTreatmentGroupData, inputFormat) {
  # For use in uploading when the results go into subjects rather than analysis groups
  
  require('plyr')
  
  #Change in naming convention
  if (rowMeaning=="subject") {
    subjectData$subjectID <- NULL
    names(subjectData)[names(subjectData) == "analysisGroupID"] <- "subjectID"
  } else if (rowMeaning=="subjectState") {
    names(subjectData)[names(subjectData) == "analysisGroupID"] <- "subjectStateID"
  }
  if(hideAllData) subjectData$Hidden <- TRUE
  
  
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
    batchNameList <- unique(subjectData$"Corporate Batch ID")
    if (!is.null(configList$server.service.external.report.registration.url)) {
      registerReportFile(reportFilePath, batchNameList, reportFileSummary, recordedBy, configList, experiment, lsTransaction, annotationType)
    } else {
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
  nameChange <- c('Corporate Batch ID'='batchCode','Result Type'='valueKind','Result Units'='valueUnit','Conc'='concentration',
                  'Conc Units'='concentrationUnit','time'='time','timeUnit'='timeUnit','Result Value'='numericValue',
                  'Result Desc'='stringValue','Result Operator'='valueOperator','subjectStateID'='subjectStateID',
                  'Result Date'='dateValue','clobValue'='clobValue','Class'='valueType','resultTypeAndUnit'='resultTypeAndUnit',
                  'Hidden'='publicData','originalCorporateBatchID'='originalBatchCode','treatmentGroupID'='treatmentGroupID',
                  'subjectID'='subjectID')
  names(subjectData)[names(subjectData) %in% names(nameChange)] <- nameChange[names(subjectData)]
  subjectData$publicData <- !subjectData$publicData
  subjectData$valueType <- c("numericValue","stringValue","dateValue", "clobValue")[match(subjectData$valueType,c("Number","Text","Date", "Clob"))]
  
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
    if (nrow(newRows)>0) newRows$stateGroupIndex <- stateGroupIndex
    subjectData <- rbind.fill(subjectData,newRows)
    stateGroupIndex <- stateGroupIndex + 1
  }
  
  othersGroupIndex <- which(sapply(stateGroups, function(x) x$includesOthers))
  subjectData$stateGroupIndex[is.na(subjectData$stateGroupIndex)] <- othersGroupIndex
  
  names(subjectData)[names(subjectData) == "Conc"] <- "concentration"
  names(subjectData)[names(subjectData) == "Conc Units"] <- "concentrationUnit"
  
  makeUniqueSubjects <- function(subjectData) {
    subjectData$subjectStateID <- subjectData$subjectStateID[1]
    subjectData$batchCode <- subjectData$batchCode[1]
    subjectData$originalBatchCode <- subjectData$originalBatchCode[1]
    output <- unique(subjectData)
    if (nrow(output) > 1) {
      stop("Values in ", unique(subjectData$resultTypeAndUnit), " are expected to be the same for each subject.")
    }
    return(output)
  }
  for (i in 1:length(stateGroups)) {
    stateGroup <- stateGroups[[i]]
    subjectData <- ddply(subjectData, c("stateGroupIndex"), .fun = function(subjectData) {
      if (subjectData$stateGroupIndex[1] == i && !is.null(stateGroup$collapseGroupBy)) {
        subjectData <- ddply(subjectData, 
                             c("resultTypeAndUnit","subjectID","stateGroupIndex"),
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
    treatmentGroupData <- ddply(.data = treatmentDataStart, .variables = c("treatmentGroupID", "resultTypeAndUnit", "stateGroupIndex"), .fun = createRawOnlyTreatmentGroupData, sigFigs=sigFigs, inputFormat=inputFormat)
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
uploadData <- function(metaData,lsTransaction,calculatedResults,treatmentGroupData,rawResults,
                       xLabel,yLabel,tempIdLabel,testOutputLocation = NULL,developmentMode,
                       protocol,experiment, fileStartLocation, configList, reportFilePath, 
                       reportFileSummary, recordedBy, annotationType) {
  # Uploads all the data to the server
  # 
  # Args:
  #   metaData:     	        A data frame of the meta data
  #   lsTransaction:          A list with information on the transaction
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
  
  # Get a list of codes
  analysisGroupCodeNameList <- getAutoLabels(thingTypeAndKind="document_analysis group", 
                                             labelTypeAndKind="id_codeName", 
                                             numberOfLabels=max(calculatedResults$analysisGroupID)) 
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
    batchNameList <- unique(calculatedResults$"Corporate Batch ID")
    if (!is.null(configList$server.service.external.report.registration.url)) {
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
          dateValue <- as.numeric(format(as.Date(calculatedResults$"Result Date"[i],origin="1970-01-01"), "%s"))*1000
          # The main value (whether it is a numeric, string, or date) creates one value    
          analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                                   lsType = if (calculatedResults$"Result Type"[i]==tempIdLabel) {"stringValue"
                                                                                   } else if (calculatedResults$"Class"[i]=="Text") {"stringValue"
                                                                                   } else if (calculatedResults$"Class"[i]=="Date") {"dateValue"
                                                                                   } else if (calculatedResults$"Class"[i]=="Clob") {"clobValue"
                                                                                   } else {"numericValue"},
                                                                                   lsKind = calculatedResults$"Result Type"[i],
                                                                                   stringValue = if(calculatedResults$"Result Type"[i]==tempIdLabel) {
                                                                                     paste0(calculatedResults$"Result Desc"[i],"_",analysisGroupCodeNameList[[analysisGroupCodeNameNumber]][[1]])
                                                                                   } else if (!is.na(calculatedResults$"Result Desc"[i])) {calculatedResults$"Result Desc"[i]} else {NULL},
                                                                                   clobValue = if (!is.na(calculatedResults$clobValue[i])) {calculatedResults$clobValue[i]} else {NULL},
                                                                                   dateValue = if(is.na(dateValue)) {NULL} else {dateValue},
                                                                                   valueOperator = if(is.na(calculatedResults$"Result Operator"[i])) {NULL} else {calculatedResults$"Result Operator"[i]},
                                                                                   numericValue = if(is.na(calculatedResults$"Result Value"[i]) | calculatedResults$"Result Type"[i]==tempIdLabel) {NULL} 
                                                                                   else {calculatedResults$"Result Value"[i]},
                                                                                   valueUnit = if(is.na(calculatedResults$"Result Units"[i])) {NULL} else {calculatedResults$"Result Units"[i]},
                                                                                   publicData = !calculatedResults$Hidden[i],
                                                                                   lsTransaction = lsTransaction)
        }
        
        if(!is.null(i)) {
          # Adds a value for the batchCode (Corporate Batch ID)
          analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                                   lsType = "codeValue",
                                                                                   lsKind = "batch code",
                                                                                   codeValue = as.character(calculatedResults$"Corporate Batch ID"[analysisGroupID == calculatedResults$analysisGroupID][1]),
                                                                                   publicData = !calculatedResults$Hidden[i],
                                                                                   lsTransaction = lsTransaction)
          
          # Adds a value for the concentration if there is one
          if (!is.na(concentration)) {
            analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(recordedBy = recordedBy,
                                                                                     lsType = "numericValue",
                                                                                     lsKind = "tested concentration",
                                                                                     valueUnit= if(is.na(calculatedResults$"Conc Units"[i])){NULL} else {calculatedResults$"Conc Units"[i]},
                                                                                     numericValue = calculatedResults$"Conc"[i],
                                                                                     publicData = !calculatedResults$Hidden[i],
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
              publicData = !calculatedResults$Hidden[i],
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
      tempID <- calculatedResults$"Result Desc"[calculatedResults$analysisGroupID == analysisGroupID & calculatedResults$"Result Type" == tempIdLabel][1]
      batchID <- as.character(calculatedResults$"Corporate Batch ID"[calculatedResults$analysisGroupID == analysisGroupID][1])
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
              valueUnit= if(is.na(treatmentGroupData$"Result Units"[i])) {NULL} else {treatmentGroupData$"Result Units"[i]},
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
              valueUnit= if(is.na(treatmentGroupData$"Result Units"[i])) {NULL} else {treatmentGroupData$"Result Units"[i]},
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
                valueUnit=if(is.na(rawResults$"Result Units"[i])) {NULL} else {rawResults$"Result Units"[i]},
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
                valueUnit=if(is.na(rawResults$"Result Units"[i])) {NULL} else {rawResults$"Result Units"[i]},
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
runMain <- function(pathToGenericDataFormatExcelFile, reportFilePath=NULL,
                    lsTranscationComments=NULL, dryRun, developmentMode = FALSE, testOutputLocation="./JSONoutput.json",
                    configList, testMode = FALSE, recordedBy) {
  # This function runs all of the functions within the error handling
  # lsTransactionComments input is currently unused
  
  require('RCurl')
  
  lsTranscationComments <- paste("Upload of", pathToGenericDataFormatExcelFile)
  
  genericDataFileDataFrame <- readExcelOrCsv(pathToGenericDataFormatExcelFile)
  
  # Meta Data
  metaData <- getSection(genericDataFileDataFrame, lookFor = "Experiment Meta Data", transpose = TRUE)
  
  formatSettings <- getFormatSettings()
  
  validatedMetaDataList <- validateMetaData(metaData, configList, formatSettings = formatSettings)
  validatedMetaData <- validatedMetaDataList$validatedMetaData
  duplicateExperimentNamesAllowed <- validatedMetaDataList$duplicateExperimentNamesAllowed
  
  inputFormat <- as.character(validatedMetaData$Format)
  
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
    if(!(inputFormat %in% c("Generic", "Dose Response"))) {
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
  
  # Grab the Calculated Results Section
  calculatedResults <- getSection(genericDataFileDataFrame, lookFor = lookFor, transpose = FALSE)
  
  # Organize the Calculated Results
  calculatedResults <- organizeCalculatedResults(calculatedResults, lockCorpBatchId, replaceFakeCorpBatchId, rawOnlyFormat, stateGroups, splitSubjects, inputFormat)
  
  # Validate the Calculated Results
  calculatedResults <- validateCalculatedResults(calculatedResults,
                                                 dryRun, curveNames, testMode=testMode, 
                                                 replaceFakeCorpBatchId=replaceFakeCorpBatchId)
  
  # Grab the Raw Results Section
  rawResults <- getSection(genericDataFileDataFrame, "Raw Results", transpose = FALSE)
  
  # Organize the Raw Results into treatmentGroupData and subjectData 
  # and collect the names of the x, y, and temp labels
  subjectData <- NULL
  treatmentGroupData <- NULL
  tempIdLabel <- ""
  if(!is.null(rawResults)) {
    rawResults <- organizeRawResults(rawResults,calculatedResults)
    # TODO: Should have a validation step to check raw results valueKinds
    xLabel <- rawResults$xLabel
    yLabel <- rawResults$yLabel
    tempIdLabel <-rawResults$tempIdLabel
    treatmentGroupData <- rawResults$treatmentGroupData
    subjectData <- rawResults$subjectData
    
    # Validate the treatment group data
    validateTreatmentGroupData(treatmentGroupData,calculatedResults, tempIdLabel)
  }
  
  # If there are errors, do not allow an upload
  errorFree <- length(errorList)==0
  
  # When not on a dry run, creates a transaction for all of these
  if(!dryRun  && errorFree) {
    lsTransaction <- createLsTransaction(comments = lsTranscationComments)$id
  } else {
    lsTransaction <- NULL
  }
  
  # Get the protocol and experiment and, when not on a dry run, create them if they do not exist
  protocol <- getProtocolByName(protocolName = validatedMetaData$'Protocol Name'[1], inputFormat)
  newProtocol <- is.na(protocol[[1]])
  if (!newProtocol) {
    metaData$'Protocol Name'[1] <- getPreferredProtocolName(protocol, validatedMetaData$'Protocol Name'[1])
  }
  
  if (!dryRun && newProtocol && errorFree) {
    protocol <- createNewProtocol(metaData = validatedMetaData, lsTransaction, recordedBy)
  }
  experiment <- getExperimentByName(experimentName = validatedMetaData$'Experiment Name'[1], protocol, configList, duplicateExperimentNamesAllowed)
  
  newExperiment <- class(experiment[[1]])!="list" && is.na(experiment[[1]])
  
  # If there are errors, do not allow an upload (yes, this is needed a second time)
  errorFree <- length(errorList)==0
  
  # Delete any old data under the same experiment name (delete and reload)
  if(!dryRun && !newExperiment && errorFree) {
    if(configList$server.delete.files.on.reload == "true") {
      deleteSourceFile(experiment, configList)
      deleteAnnotation(experiment, configList)
    }

    deletedExperimentCodes <- c(experiment$codeName, getPreviousExperimentCodes(experiment))
    deleteExperiment(experiment)
  } else {
    deletedExperimentCodes <- NULL
  }
  
  if (!dryRun && errorFree) {
    experiment <- createNewExperiment(metaData = validatedMetaData, protocol, lsTransaction, pathToGenericDataFormatExcelFile, 
                                      recordedBy, configList, deletedExperimentCodes)
    assign(x="experiment", value=experiment, envir=parent.frame())
  }
  
  # Upload the data if this is not a dry run
  if(!dryRun & errorFree) {
    reportFileSummary <- paste0(validatedMetaData$'Protocol Name', " - ", validatedMetaData$'Experiment Name')
    if(rawOnlyFormat) { 
      uploadRawDataOnly(metaData = validatedMetaData, lsTransaction, subjectData = calculatedResults,
                        experiment, fileStartLocation = pathToGenericDataFormatExcelFile, configList, 
                        stateGroups, reportFilePath, hideAllData, reportFileSummary, curveNames, recordedBy, 
                        replaceFakeCorpBatchId, annotationType, sigFigs, rowMeaning, includeTreatmentGroupData, inputFormat)
    } else {
      uploadData(metaData = validatedMetaData,lsTransaction,calculatedResults,treatmentGroupData,rawResults = subjectData,
                 xLabel,yLabel,tempIdLabel,testOutputLocation,developmentMode,protocol,experiment, 
                 fileStartLocation = pathToGenericDataFormatExcelFile, configList=configList, 
                 reportFilePath=reportFilePath, reportFileSummary=reportFileSummary, recordedBy, annotationType)
    }
  }
  
  # Add name modifier to protocol name for viewer
  if (length(protocol) == 0 && !is.na(protocol)) {
    protocolPostfixStates <- protocol$lsStates[lapply(protocol$lsStates, getElement, "lsTypeAndKind") == "metadata_name modifier"]
  } else {
    protocolPostfixStates <- list()
  }
  if (length(protocolPostfixStates) > 0) {
    protocolPostfixState <- protocolPostfixStates[[1]]
    protocolPostfixValues <- protocolPostfixState$lsValues[lapply(protocolPostfixState$lsValues, getElement, "lsTypeAndKind") == "stringValue_postfix"]
    protocolPostfix <- protocolPostfixValues[[1]]$stringValue
  } else {
    protocolPostfix <- ""
  }
  
  if (!is.null(configList$client.service.result.viewer.protocolPrefix)) {
    viewerLink <- paste0(configList$client.service.result.viewer.protocolPrefix, 
                         URLencode(paste0(validatedMetaData$"Protocol Name", protocolPostfix), reserved=TRUE), 
                         configList$client.service.result.viewer.experimentPrefix,
                         URLencode(validatedMetaData$"Experiment Name", reserved=TRUE))
  } else {
    viewerLink <- NULL
  }
  
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
  summaryInfo$info$"Scientist" <- as.character(validatedMetaData$Scientist)
  summaryInfo$info$"Notebook" <- as.character(validatedMetaData$Notebook)
  if(!is.null(validatedMetaData$Page)) {
    summaryInfo$info$"Page" <- as.character(validatedMetaData$Page)
  }
  if(!is.null(validatedMetaData$"In Life Notebook")) {
    notebookIndex <- which(names(summaryInfo$info) == "Notebook")[1]
    summaryInfo$info$"In Life Notebook" <- as.character(validatedMetaData$"In Life Notebook")
  }
  summaryInfo$info$"Assay Date" = as.character(validatedMetaData$"Assay Date")
  summaryInfo$info$"Rows of Data" = max(calculatedResults$analysisGroupID)
  summaryInfo$info$"Columns of Data" = length(unique(calculatedResults$resultTypeAndUnit))
  summaryInfo$info$"Unique Corporate Batch ID's" = length(unique(calculatedResults$"Corporate Batch ID"))
  if (!is.null(subjectData)) {
    summaryInfo$info$"Raw Results Data Points" <- max(subjectData$pointID)
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
getPreviousExperimentCodes <- function(experiment) {
  metadataState <- getStatesByTypeAndKind(experiment, "metadata_experiment metadata")[[1]]
  previousCodeValues <- getValuesByTypeAndKind(metadataState, "codeValue_previous experiment code")
  previousExperimentCodes <- lapply(previousCodeValues, getElement, "codeValue")
  return(previousExperimentCodes)
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
  
  # This is used for outputting the JSON rather than sending it to the server
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
  
  # Set up the error handling for non-fatal errors, and add it to the search path (almost like a global variable)
  errorHandlingBox <- list(errorList = list())
  attach(errorHandlingBox)
  # If there is a global defined by another R code, this will overwrite it
  errorList <<- list()
  
  # Run the function and save output (value), errors, and warnings
  loadResult <- tryCatch.W.E(runMain(pathToGenericDataFormatExcelFile,
                                     reportFilePath = reportFilePath,
                                     dryRun = dryRun,
                                     developmentMode = developmentMode,
                                     configList=configList, 
                                     testMode=testMode,
                                     recordedBy=recordedBy))
  
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
      fileToParse= pathToGenericDataFormatExcelFile,
      dryRun= dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}
