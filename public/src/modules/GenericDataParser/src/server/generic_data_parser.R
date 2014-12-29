# generic_data_parser.R
#
#
# Brian Bolt
# brian@mcneilco.com
#
# Sam Meyer
# sam@mcneilco.com
# Copyright 2012-2014 John McNeil & Co. Inc.
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
#     Set your working directory to the ACAS_HOME (RStudio defaults to this)
#     setwd("~/Documents/ACAS/")
#   To run:
#     parseGenericData(list(pathToGenericDataFormatExcelFile, dryRun = TRUE, ...))
#     Example: 
#       file.copy("~/Desktop/6_Standard_Deviation.xlsx", to="privateUploads/", overwrite = TRUE)
#
#       file.copy("/Users/smeyer/Google Drive/McNeilco/DemoACAS/5_Dose_Response.xls", to="privateUploads/", overwrite = TRUE)
#       parseGenericData(c(fileToParse="5_Dose_Response.xls", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/explicit_ACAS_format.xlsx", to="privateUploads/", overwrite = TRUE)
#       parseGenericData(c(fileToParse="explicit_ACAS_format.xlsx", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/DR_SaveToExistingExperiment.xlsx", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/DR_SaveToExistingExperiment.xlsx", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/Mia-Paca.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/Mia-Paca.xls", dryRunMode = "true", user="smeyer"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_error.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_Curve.xls", reportFile="serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_error.xls", dryRunMode = "false", user="smeyer"))
#       request <- c(fileToParse="2_Concentration.xls", dryRunMode = "false", user="smeyer")

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
validateMetaData <- function(metaData, configList, formatSettings = list(), errorEnv = NULL, testMode = FALSE) {
  # Valides the meta data section
  #
  # Args:
  #   metaData: 			A "data.frame" of two columns containing the Meta data for the experiment
  #	  configList:     Also known as racas::applicationSettings
  #   formatSettings: A nested list containing types of experiments and extra information about
  #                   them (particularly relevant here is the "extraHeaders" column)
  # Returns:
  #  A list containing data frame with the validated meta data, a boolean indicating whether duplicate experiment
  #    names are allowed, and a boolean indicating whether the format is "use existing experiment"
  
  require('gdata')

  # Check if extra data was picked up that should not be
  if (length(metaData[[1]]) > 1) {
    extraData <- c(as.character(metaData[[1]][2:length(metaData[[1]])]),
                   as.character(metaData[[2]][2:length(metaData[[2]])]))
    extraData <- extraData[extraData!=""]
    addError(paste0("Extra data were found next to the Experiment Meta Data ",
                    "and should be removed: '",
                    paste(extraData, collapse="', '"), "'"),
             errorEnv)
    metaData <- metaData[1,]
  }
  
  # Turn NA into "NA"
  metaDataNames <- names(metaData)
  metaData <- as.data.frame(lapply(metaData, function(x) if(is.na(x)) "NA" else x), stringsAsFactors=FALSE)
  names(metaData) <- metaDataNames
  
  if (is.null(metaData$Format)) {
    stopUser("A Format must be entered in the Experiment Meta Data.")
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
                                 stopUser(paste("Internal Error: unrecognized class required by the loader:",expectedDataType))
    )
    validatedData <- validationFunction(receivedValue)
    validatedMetaData[,column] <- validatedData
  }
  
  # Add warnings for additional columns sent that are not expected
  additionalColumns <- names(metaData)[is.na(match(names(metaData),expectedHeaders))]
  if (length(additionalColumns) > 0) {
    if (length(additionalColumns) == 1) {
      warnUser(paste0("The loader found an extra Experiment Meta Data row that will be ignored: '", 
                     additionalColumns, 
                     "'. Please remove this row."))
    } else {
      warnUser(paste0("The loader found extra Experiment Meta Data rows that will be ignored: '", 
                     paste(additionalColumns,collapse="' ,'"), 
                     "'. Please remove these rows."))
    }
  }
  
  if (!is.null(metaData$Project)) {
    validatedMetaData$Project <- validateProject(validatedMetaData$Project, configList, errorEnv) 
  }
  if (!is.null(metaData$Scientist)) {
    validatedMetaData$Scientist <- validateScientist(validatedMetaData$Scientist, configList, testMode) 
  }
  
  if(!is.null(validatedMetaData$"Experiment Name") && grepl("CREATETHISEXPERIMENT$", validatedMetaData$"Experiment Name")) {
    validatedMetaData$"Experiment Name" <- trim(gsub("CREATETHISEXPERIMENT$", "", validatedMetaData$"Experiment Name"))
    duplicateExperimentNamesAllowed <- TRUE
  } else {
    duplicateExperimentNamesAllowed <- FALSE
  }
  
  return(list(validatedMetaData=validatedMetaData, duplicateExperimentNamesAllowed=duplicateExperimentNamesAllowed, useExisting=useExisting))
}
validateTreatmentGroupData <- function(treatmentGroupData,calculatedResults,tempIdLabel, errorEnv) {
  # Valides the treatment group data (for now, this only validates the temp id's)
  # As of 2014-06-18, this function appears to be unused.
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
#     addError(paste0("In the Calculated Results section, there are ", tempIdLabel, "'s that have text: '", 
#                                       paste(textTempIds, collapse="', '"), "'. Remove text from all temp id's."))
#   } else if (length(textTempIds)>0) {
#     addError( paste0("In the Calculated Results section, there is a ", tempIdLabel, " that has text: '", 
#                                       textTempIds, "'. Remove text from all temp id's."))
#   } else if (length(missingTempIds)>1) {
  if (length(missingTempIds)>1) {
    addError(paste0("In the Raw Results section, there are temp id's that have no match in the Calculated Results section: '", 
                    paste(missingTempIds, collapse="', '"),
                    "'. Please ensure that all id's have a matching row in the Calculated Results."), 
             errorEnv = errorEnv)
  } else if (length(missingTempIds)>0) {
    addError(paste0("In the Raw Results section, there is a temp id that has no match in the Calculated Results section: '", 
                                      missingTempIds,
                                      "'. Please ensure that all id's have a matching row in the Calculated Results."),
             errorEnv = errorEnv)
  }
  
  # Find if there are temp ids without raw results
  extraTempIds <- setdiff(tempIdList,treatmentGroupData[,tempIdLabel])
  extraTempIds <- extraTempIds[!is.na(extraTempIds)]
  if (length(extraTempIds)>1) {
    warnUser(paste0("In the Calculated Results section, there are ", tempIdLabel, "'s that have no matching data in the Raw Results section: '", 
                   paste(extraTempIds, collapse="', '"), "'. Without raw data, a curve cannot be drawn throught the points."))
  } else if (length(extraTempIds)>0) {
    warnUser(paste0("In the Calculated Results section, there is a ", tempIdLabel, " that has no match in the Raw Results section: '", 
                   extraTempIds, "'. Without raw data, a curve cannot be drawn throught the points."))
  }
  return(NULL) 
}
validateCalculatedResults <- function(calculatedResults, dryRun, curveNames, testMode = FALSE, replaceFakeCorpBatchId="", mainCode, errorEnv = NULL) {
  # Valides the calculated results (for now, this only validates the mainCode)
  #
  # Args:
  #	  calculatedResuluts:	      A "data.frame" of the calculated results
  #   dryRun:                   A boolean
  #   curveNames:               A character vector of curveNames that will be needed as extra valueKinds
  #   testMode:                 A boolean
  #   replaceFakeCorpBatchId:   A string that is not a corp batch id, will be ignored by the batch check, and will be replaced by a column of the same name
  #   mainCode:                 A string, normally the corporate batch ID
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
#       addError(paste0(mainCode, " '", batchId["requestName"], 
#                                         "' has not been registered in the system. Contact your system administrator for help."))
    } else if (as.character(batchId["requestName"]) != as.character(batchId["preferredName"])) {
      warnUser(paste0("A ", mainCode, " that you entered, '", batchId["requestName"], 
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
  #   classRow:   		A character vector of the Datatypes of the calculated results, with (hidden) to mark hidden points
  #
  # Returns:
  #	  a boolean vector of which results are hidden
  
  # Pull out info about hidden columns
  dataShown <- gsub(".*\\((.*)\\).*||.*", "\\1",classRow)
  dataShown[is.na(dataShown)] <- ""
  hiddenColumns <- grepl("hidden",dataShown,ignore.case=TRUE)
  shownColumns <- grepl("shown",dataShown,ignore.case=TRUE)
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
  #	  a logical vector of which results are links
  
  # Pull out info about hidden columns
  dataShown <- gsub(".*\\[(.*)\\].*||.*", "\\1",classRow)
  dataShown[is.na(dataShown)] <- ""
  linkColumns <- grepl("link",dataShown,ignore.case=TRUE)
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
    stopUser("Only one column may be marked as [link].")
  }
  
  return(linkColumns)
}

validateCalculatedResultDatatypes <- function(classRow, LabelRow, lockCorpBatchId = TRUE, clobColumns=c(), errorEnv = NULL) {
  # Checks that datatypes entered in the Datatype row of the calculated results are valid
  #
  # Args:
  #   classRow:     	  A character vector of the Datatypes of the calculated results (with hidden and link information as well)
  #   LabelRow:         A character vector with the labels for each column
  #   lockCorpBatchId:  A boolean marking whether the corp batch id must be in the leftmost column
  #   clobColumns:      Which columns have text more than 255 characters long (and need to be saved as a clobValue)
  #
  # Returns:
  #	  a character vector of the datatypes (without 'hidden' or 'link' information)
  
  require('gdata')
  
  if(lockCorpBatchId) {
    # Check that the first entry says Datatype (users may try to enter data if we don't warn them)
    if (is.na(classRow[1])) {
      addError(paste0("The first row below 'Calculated Results' must begin with 'Datatype'. ",
                      "Right now, 'Datatype' is missing."), errorEnv)
    } else if (classRow[1]!="Datatype") {
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
  badClasses <- setdiff(classRow[1:length(classRow)>1], c("Text","Number","Date","Clob", "Code", "", "Standard Deviation", "Comments", "Image File", NA))
  
  # Let the user know about empty datatypes
  emptyClasses <- which(is.na(classRow) | trim(classRow) == "")
  if(length(emptyClasses) > 0) {
    if(length(emptyClasses) == 1) {
      warnUser(paste0("Column ", getExcelColumnFromNumber(emptyClasses), " (" , LabelRow[emptyClasses], ") does not have a Datatype entered. ",
                     "The loader will attempt to interpret entries in column ", 
                     getExcelColumnFromNumber(emptyClasses), 
                     " as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', 'Image File', or 'Comments'."))
    } else {
      warnUser(paste("Columns", 
                    paste(sapply(emptyClasses[1:length(emptyClasses)-1],getExcelColumnFromNumber),collapse=", "), 
                    "and", getExcelColumnFromNumber(tail(emptyClasses,n=1)), 
                    "do not have a Datatype entered.",
                    "The loader will attempt to interpret entries in columns",
                    paste(sapply(emptyClasses[1:length(emptyClasses)-1],getExcelColumnFromNumber),collapse=", "), 
                    "and", getExcelColumnFromNumber(tail(emptyClasses,n=1)),
                    "as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', 'Image File', or 'Comments'."))
    }
    classRow[is.na(classRow) | classRow==""] <- "Number"
  }
  
  if(length(badClasses) > 0) {
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
      classRow[i][grep(pattern = "comment", classRow[i], ignore.case = TRUE)] <- "Comments"
      classRow[i][grep(pattern = "sd", classRow[i], ignore.case = TRUE)] <- "Standard Deviation"
      classRow[i][grep(pattern = "dev", classRow[i], ignore.case = TRUE)] <- "Standard Deviation"
      classRow[i][grep(pattern = "image", classRow[i], ignore.case = TRUE)] <- "Image File"
      # Accept differences in capitalization
      if (tolower(classRow[i]) != tolower(oldClassRow[i]) & !is.na(LabelRow[i])) {
        warnUser(paste0("In column \"", LabelRow[i], "\", the loader found '", oldClassRow[i], 
                       "' as a datatype and interpreted it as '", classRow[i], 
                       "'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', 'Image File', or 'Comments'."))
      }
    }
    
    # Those that can't be interpreted throw errors
    unhandledClasses <- setdiff(classRow[1:length(classRow) > 1], 
                                c("Text","Number","Date","Clob","Code","Standard Deviation","Comments", "", "Image File"))
    if (length(unhandledClasses)>0) {
      addError(paste0("The loader found classes in the Datatype row that it does not understand: '",
                      paste(unhandledClasses,collapse = "', '"),
                      "'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', 'Image File', or 'Comments'."), errorEnv)
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
  #   dryRun:                 A boolean indicating whether the data should be saved
  #
  # Returns:
  #	  NULL
  
  require(rjson)
  require(RCurl)
  
  # Throw errors for words used with special meanings by the loader
  internalReservedWords <- c("concentration", "time")
  usedReservedWords <- internalReservedWords %in% neededValueKinds
  if (any(usedReservedWords)) {
    stopUser(paste0(sqliz(internalReservedWords[usedReservedWords]), " is reserved and cannot be used as a column header."))
  }
  
  tryCatch({
    currentValueKindsList <- getAllValueKinds()
  }, error = function(e) {
    stopUser("Internal Error: Could not get current value kinds")
  })
  if (length(currentValueKindsList)==0) stopUser("Setup error: valueKinds are missing")
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
    stopUser(paste0("The column header ", sqliz(reservedValueKinds), " is reserved and cannot be used"))
  }
  
  # Use na.rm = TRUE because any types of NA will already have thrown an error (in validateCalculatedResultDatatypes)
  if(any(wrongValueTypes, na.rm = TRUE)) {
    problemFrame <- data.frame(oldValueKinds = comparisonFrame$oldValueKinds)
    problemFrame$oldValueKindTypes <- c("Number", "Text", "Date", "Clob")[match(comparisonFrame$oldValueKindTypes, c("numericValue", "stringValue", "dateValue", "clobValue"))]
    problemFrame$matchingValueKindTypes <- c("Number", "Text", "Date", "Clob")[match(comparisonFrame$matchingValueTypes, c("numericValue", "stringValue", "dateValue", "clobValue"))]
    problemFrame <- problemFrame[wrongValueTypes, ]
    
    for (row in 1:nrow(problemFrame)) {
      addError( paste0("Column header '", problemFrame$oldValueKinds[row], "' is registered in the system as '", problemFrame$matchingValueKindTypes[row],
                                        "' instead of '", problemFrame$oldValueKindTypes[row], "'. Please enter '", problemFrame$matchingValueKindTypes[row],
                                        "' in the Datatype row for '", problemFrame$oldValueKinds[row], "'."),)
    }
  }
  
  # Warn about any new valueKinds
  if (length(newValueKinds) > 0) {
    warnUser(paste0("The following column headers have never been loaded in an experiment before: '", 
                   paste(newValueKinds,collapse="', '"), "'. If you have loaded a similar experiment before, please use the same",
                   " headers that were used previously. If this is a new protocol, you can proceed without worry."))
    if (!dryRun) {
      # Create the new valueKinds, using the correct valueType
      # TODO: also check that valueKinds have the correct valueType when being loaded a second time
      valueTypesList <- getAllValueTypes()
      valueTypes <- sapply(valueTypesList, getElement, "typeName")
      valueKindTypes <- neededValueKindTypes[match(newValueKinds, neededValueKinds)]
      valueKindTypes <- c("numericValue", "stringValue", "dateValue", "clobValue")[match(valueKindTypes, c("Number", "Text", "Date", "Clob"))]
      
      # This is for the curveNames, but would catch other added values as well
      valueKindTypes[is.na(valueKindTypes)] <- "stringValue"
      saveValueKinds(newValueKinds, valueKindTypes)
    }
  }
  return(NULL)
}

validateUploadedImages <- function(imageLocation, listedImageFiles, experimentFolderLocation) {
  # Checks that there is a one-to-one correspondence between files the user has uploaded
  # and file names the user has entered in their Excel sheet.
  # Input: imageLocation: a path to the directory where the images were unzipped. 
  #        Can be absolute or relative from the working directory
  #        listedImageFiles, the image files that the user listed in the spreadsheet
  #        experimentFolderLocation, a relative path from privateUploads
  # Returns: Errors if invalid, or "TRUE" if valid. Could return something different in the future
  #          If invalid, it removes the experiment's folder and returns the zip file to privateUploads
  
  uploadedImageFiles <- list.files(imageLocation)
  
  # Make sure all elements are part of both vectors.
  # We allow the same file to be listed multiple times -- setdiff disregards duplicates (and you can't
  # put the same file into a directory twice, so we don't have a problem there)
  notUploaded <- setdiff(listedImageFiles, uploadedImageFiles)
  notListed <- setdiff(uploadedImageFiles, listedImageFiles)
  
  if (length(notListed) > 0) {
    unlink(experimentFolderLocation, recursive = TRUE)
    stopUser(paste0("The following files were uploaded in a zip file, but were not listed in the spreadsheet: ",
                    paste(notListed, collapse = ", "), ". If in doubt, please check your capitalization."))
  }
  if (length(notUploaded) > 0) {
    unlink(experimentFolderLocation, recursive = TRUE)
    stopUser(paste0("The following files were listed in the spreadsheet, but were not uploaded in a zip file: ",
                    paste(notUploaded, collapse = ", "), ". If in doubt, please check your capitalization."))
  }
  
  return(TRUE)
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
    warnUser(paste("An invalid column number was attempted to be turned into a letter:",number))
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
extractValueKinds <- function(valueKindsVector, ignoreHeaders = NULL, uncertaintyType, uncertaintyCodeWord, commentCol, commentCodeWord) {
  # Extracts result types, units, conc, and conc units from a data frame
  #
  # Args:
  #   valueKindsVector: A data frame containing result types in the format "Value Kind (units) [Conc ConcUnits]"
  #   ignoreHeaders: A character vector of headings whose value kinds we do not need to extract (like "link")
  #   uncertaintyType: A character vector with the type of uncertainty associated with that column (or NA, if no uncertainty)
  #   commentCol: A logical vector indicating whether each column is a comment
  #   uncertaintyCodeWord and commentCodeWord: Reserved words that will not appear in the input
  #
  # Returns:
  #  A data frame containing the column heading, Value Kind, Units, concentration, ConcUnits, reshapeText,
  #       time, timeUnit, uncertaintyType, and isComment, with one row for each non-ignored header
  
  require('gdata')
  
  valueKindWoExtras <- valueKindsVector[is.na(uncertaintyType) & !commentCol]

  if(any(duplicated(unlist(valueKindWoExtras)))) {
    # This has to be a stop, otherwise it throws unexpected errors
    stopUser(paste0("These column headings are duplicated: ",
                    paste(unlist(valueKindWoExtras[duplicated(unlist(valueKindWoExtras))]),collapse=", "),
                    ". All column headings must be unique."))
  }
  
  emptyValueKinds <- is.na(valueKindsVector) | (trim(valueKindsVector) == "")
  if (any(emptyValueKinds)) {
    stopUser(paste0("Column ", paste(getExcelColumnFromNumber(which(emptyValueKinds)), collapse=", "), " has a blank column header. ",
                "Please enter a column header before reuploading."))
  }
  
  dataColumns <- c()
  for(col in 1:length(valueKindsVector)) {
    column <- as.character(valueKindsVector[[col]])
    if(!toupper(column) %in% toupper(ignoreHeaders)) {
      dataColumns <- c(dataColumns,column)
    }
  }
  
  fillerArray <- array(dim = length(dataColumns))
  
  returnDataFrame <- data.frame("DataColumn" = fillerArray, "valueKind" = fillerArray, 
                                "Units" = fillerArray, "Conc" = fillerArray, 
                                "concUnits" = fillerArray, "reshapeText" = fillerArray)
  returnDataFrame$DataColumn <- dataColumns
  returnDataFrame$valueKind <- trim(gsub("\\[[^)]*\\]","",gsub("(.*)\\((.*)\\)(.*)", "\\1\\3",gsub("\\{[^}]*\\}","",dataColumns))))
  returnDataFrame$Units <- gsub(".*\\((.*)\\).*||(.*)", "\\1",dataColumns) 
  concAndUnits <- gsub("^([^\\[]+)(\\[(.+)\\])?(.*)", "\\3", dataColumns) 
  returnDataFrame$Conc <- as.numeric(gsub("[^0-9\\.]", "", concAndUnits))
  returnDataFrame$concUnits <- as.character(gsub("[^a-zA-Z]", "", concAndUnits))
  timeAndUnits <- gsub("([^\\{]+)(\\{(.*)\\})?.*", "\\3", dataColumns) 
  returnDataFrame$time <- as.numeric(gsub("[^0-9\\.]", "", timeAndUnits))
  returnDataFrame$timeUnit <- as.character(gsub("[^a-zA-Z]", "", timeAndUnits))
  # Mark standard deviation and comments with a text string
  returnDataFrame$reshapeText <- ifelse(!is.na(uncertaintyType[2:length(uncertaintyType)]), 
                                        paste0(uncertaintyCodeWord, dataColumns), dataColumns)
  returnDataFrame$reshapeText <- ifelse(commentCol[2:length(commentCol)], 
                                        paste0(commentCodeWord, returnDataFrame$reshapeText), returnDataFrame$reshapeText)
  returnDataFrame$uncertaintyType <- uncertaintyType[2:length(uncertaintyType)]
  returnDataFrame$isComment <- commentCol[2:length(commentCol)]
  
  # Return a data frame with the units separated from the type, and with uncertainties and comments marked
  return(returnDataFrame)
}

organizeCalculatedResults <- function(calculatedResults, inputFormat, formatParameters, mainCode, 
                                      lockCorpBatchId = TRUE, rawOnlyFormat = FALSE, 
                                      errorEnv = NULL, precise = F, link = NULL, calculateGroupingID = NULL,
                                      stateAssignments = NULL) {
  # Organizes the calculated results section
  #
  # Args:
  #   calculatedResults: 			A "data.frame" of the columns containing the calculated results for the experiment
  #                              It can also contain other results, such as raw results
  #   lockCorpBatchId:        A boolean which marks if the mainCode is locked as the left column
  #   replaceFakeCorpBatchId: A string that is not a mainCode, will be ignored by the batch check, and will be replaced by a column of the same name
  #   rawOnlyFormat:          A boolean that describes the data format, subject based or analysis group based
  #   stateGroups:            A list of state groups and their attributes, from getFormatSettings
  #   splitSubjects:          from getFormatSettings
  #   inputFormat:            The experiment format, such as "Dose Response"
  #   calculateGroupingID:    Potentially a function, which will determine the ID for each group (such as a treatmentGroupID)
  #   stateAssignments:       from getFormatSettings
  #
  # Returns:
  #	  a data frame containing the organized calculated data
  
  library('reshape')
  library('gdata')
  library('plyr')
  
  replaceFakeCorpBatchId <- formatParameters$replaceFakeCorpBatchId
  stateGroups <- formatParameters$stateGroups
  splitSubjects <- formatParameters$splitSubjects
  
  uncertaintyCodeWord <- "uncertainty@coDeWoRD@"
  commentCodeWord <- "comment@coDeWoRD@"
  
  if(ncol(calculatedResults) == 1) {
    stopUser(paste0("The rows below Calculated Results must have at least two columns filled: one for ", mainCode, "'s and one for data."))
  } else if (nrow(calculatedResults) == 0) {
    stopUser("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, 'Datatype' is missing.")
  }
  
  # Check the Datatype row and get information from it
  hiddenColumns <- getHiddenColumns(as.character(unlist(calculatedResults[1,])), errorEnv)
  linkColumns <- getLinkColumns(as.character(unlist(calculatedResults[1,])), errorEnv)
  
  clobColumns <- vapply(calculatedResults, function(x) any(nchar(as.character(x)) > 255), c(TRUE))
  
  if (precise) {
    labelRow <- as.character(unlist(calculatedResults[4, ]))
  } else {
    labelRow <- as.character(unlist(calculatedResults[2, ]))
  }
  classRow <- validateCalculatedResultDatatypes(as.character(unlist(calculatedResults[1,])), labelRow, lockCorpBatchId, clobColumns, errorEnv)
  
  if(any(clobColumns & !(classRow=="Clob"))) {
    warnUser("One of your entries had more than 255 characters, so it will be saved as a 'Clob'. In the future, you should use this for your column header.")
  }
  
  # Remove Datatype Row
  calculatedResults <- calculatedResults[1:nrow(calculatedResults) > 1, ]
  
  # Precise column information (or default)
  if (precise) {
    stateTypeRow <- calculatedResults[1:nrow(calculatedResults) == 1, ]
    stateKindRow <- calculatedResults[1:nrow(calculatedResults) == 2, ]
    calculatedResults <- calculatedResults[1:nrow(calculatedResults) > 2, ]
  } else {
    stateTypeRow <- rep("data", length(classRow))
    stateKindRow <- rep("results", length(classRow))
  }
  
  # Get the line containing the value kinds
  calculatedResultsValueKindRow <- calculatedResults[1:nrow(calculatedResults) == 1, ]
  
  # Make sure the mainCode is included
  if (!is.null(mainCode)) {
    if (lockCorpBatchId) {
      if(calculatedResultsValueKindRow[1] != mainCode && !precise) {
        stopUser(paste0("Could not find '", mainCode, "' column. The ", mainCode, 
                    " column should be the first column of the Calculated Results"))
      }
    } else {
      if (!(mainCode %in% unlist(calculatedResultsValueKindRow)) && !precise) {
        stopUser(paste0("Could not find '", mainCode, "' column."))
      }
    }
  }
  
  # These columns are not result types and should not be pivoted into long format
  ignoreTheseAsValueKinds <- c(mainCode, "originalMainID")
  if (!is.null(link)) {
    ignoreTheseAsValueKinds <- c(ignoreTheseAsValueKinds, "link")
  }
  
  # Mark standard deviation columns (designed to allow standard error as well in future)
  uncertaintyType <- rep(NA, length(classRow))
  uncertaintyType[tolower(classRow) == "standard deviation"] <- tolower(classRow)[tolower(classRow) == "standard deviation"]
  
  # Mark Comment columns
  commentCol <- tolower(classRow) == "comments"
  
  # Call the function that extracts valueKinds, units, conc, concunits from the headers
  valueKinds <- extractValueKinds(calculatedResultsValueKindRow, ignoreTheseAsValueKinds, uncertaintyType, uncertaintyCodeWord, commentCol, commentCodeWord)
  
  if (any(duplicated(valueKinds$reshapeText[!is.na(valueKinds$uncertaintyType)]))) {
    stopUser("Only one standard deviation may be assigned for a column. Remove the duplicate standard deviation.")
  }
  if (any(duplicated(valueKinds$reshapeText[valueKinds$isComment]))) {
    stopUser("Only one comment may be assigned for a column. Remove the duplicate comments.")
  }
  
  # Check for standard deviation without parent column
  missingUncertaintyParent <- !(valueKinds$DataColumn[!is.na(valueKinds$uncertaintyType)] %in% valueKinds$DataColumn[is.na(valueKinds$uncertaintyType)])
  if (any(missingUncertaintyParent)) {
    stopUser(paste0("All standard deviation columns must have a column header that matches their parent column. ",
                "There is no main column named: '", 
                paste(valueKinds$DataColumn[missingUncertaintyParent], collapse = "'', '"),
                "'.")
         )
  }
  
  missingCommentParent <- !(valueKinds$DataColumn[valueKinds$isComment] %in% valueKinds$DataColumn[!valueKinds$isComment])
  if (any(missingCommentParent)) {
    stopUser(paste0("All comment columns must have a column header that matches their parent column. ",
                "There is no main column named: '", 
                paste(valueKinds$DataColumn[missingCommentParent], collapse = "'', '"),
                "'.")
    )
  }
  
  # Add data class and hidden/shown to the valueKinds
  if (!is.null(mainCode)) {
    notMainCode <- (calculatedResultsValueKindRow != mainCode) & 
      (is.null(link) | (calculatedResultsValueKindRow != "link"))
  } else {
    notMainCode <- (is.null(link) | (calculatedResultsValueKindRow != "link"))
  }
  
  valueKinds$dataClass <- classRow[notMainCode]
  valueKinds$valueType <- translateClassToValueType(valueKinds$dataClass)
  if(is.null(stateAssignments)) {
    valueKinds$stateKind <- stateKindRow[notMainCode]
    valueKinds$stateType <- stateTypeRow[notMainCode]
  } else {
    valueKinds$stateKind <- stateAssignments$stateKind[match(valueKinds$valueKind, stateAssignments$valueKind)]
    valueKinds$stateType <- stateAssignments$stateType[match(valueKinds$valueKind, stateAssignments$valueKind)]
    valueKinds[is.na(valueKinds$stateKind), "stateKind"] <- "results"
    valueKinds[is.na(valueKinds$stateType), "stateType"] <- "data"
  }
  
  valueKinds$publicData <- !hiddenColumns[notMainCode]
  valueKinds$linkColumn <- linkColumns[notMainCode]
  
  # Grab the rows of the calculated data 
  results <- subset(calculatedResults, 1:nrow(calculatedResults) > 1)
  names(results) <- unlist(calculatedResultsValueKindRow)
  
  names(results)[!is.na(uncertaintyType)] <- paste0(uncertaintyCodeWord, names(results)[!is.na(uncertaintyType)])
  names(results)[commentCol] <- paste0(commentCodeWord, names(results)[commentCol])
  
  # Replace fake mainCodes with the column that holds replacements (the column must have the same name that is entered in mainCode)
  if (nrow(results) == 0) {
    stopUser("The 'Raw Results' section is present, but contains no data. Please either enter data or remove the section.")
  } else {
    results$originalMainID <- NA 
  }
  
  if (!(is.null(mainCode))) {
    if (mainCode %in% names(results)) {
      results[[mainCode]] <- as.character(results[[mainCode]])
      results$originalMainID <- results[[mainCode]]
      if (!is.null(replaceFakeCorpBatchId) && replaceFakeCorpBatchId != "") {
        replacementRows <- results[[mainCode]] == replaceFakeCorpBatchId
        results[[mainCode]][replacementRows] <- as.character(results[replacementRows, replaceFakeCorpBatchId])
      }
    } else {
      results[[mainCode]] <- NA
    }
  }
  
  
  # Add a rowID to keep track of how rows match up
  results$rowID <- seq(1,length(results[[1]]))
  
  # Link to parent analysis group or subject, and include batch codes
  results$linkID <- NA
  if (!is.null(link)) {
    results$linkID <- link$rowID[match(results$link, link$stringValue)]
    if (!is.null(link$originalMainID))
      results$batchCode <- link$originalMainID[match(results$link, link$stringValue)]
  }
  
  #Temp ids for treatment groups or other grouping
  results$groupingID <- NA
  results$groupingID_2 <- NA
  if (is.function(calculateGroupingID)) {
    # calculateTreatmentGroupID is often defined in customFunctions.R
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
                         times=valueKinds$reshapeText, timevar="reshapeText",
                         varying=list(valueKinds$reshapeText), direction="long", drop = names(results)[emptyColumns])
  
  if (!is.null(mainCode)) {
    longResults$batchCode <- longResults[[mainCode]]
  } else {
    longResults$batchCode <- NA
  }
  
  # Merge uncertainty
  matchOrder <- match(longResults$reshapeText, valueKinds$reshapeText)
  longResults$valueKindAndUnit <- valueKinds$DataColumn[matchOrder]
  longResults$uncertaintyType <- valueKinds$uncertaintyType[matchOrder]
  longResults$isComment <- valueKinds$isComment[matchOrder]
  longResultsDT <- as.data.table(longResults)
  longResultsDT2 <- longResultsDT[, list(
    originalMainID = unique(originalMainID),
    rowID = unique(rowID),
    linkID = unique(linkID),
    groupingID = unique(groupingID),
    groupingID_2 = unique(groupingID_2),
    valueKindAndUnit = unique(valueKindAndUnit),
    id = unique(id),
    batchCode = unique(batchCode), 
    UnparsedValue = UnparsedValue[is.na(uncertaintyType) & !isComment],
    uncertainty = if(any(!is.na(uncertaintyType))) {UnparsedValue[!is.na(uncertaintyType)]} else {NA},
    uncertaintyType = if(any(!is.na(uncertaintyType))) {uncertaintyType[!is.na(uncertaintyType)]} else {NA},
    comments = if(any(!isComment)) {UnparsedValue[isComment]} else {NA}),
    keyby="rowID,valueKindAndUnit"]
  
  longResults <- as.data.frame(longResultsDT2)
  
  badUncertainty <- !is.na(longResults$uncertainty) & suppressWarnings(is.na(as.numeric(longResults$uncertainty)))
  if (any(badUncertainty)) {
    addError(paste0("Uncertainties (standard deviation) must be numbers. Entries ", 
                    paste(longResults$uncertainty[badUncertainty], collapse = ", "),
                    " are not valid numbers."),
             errorEnv)
  }
  longResults$uncertainty <- suppressWarnings(as.numeric(longResults$uncertainty))
  
  # Add the extractValueKinds information to the long format
  matchOrder <- match(longResults$"valueKindAndUnit",valueKinds$reshapeText)
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
  longResults$valueKindAndUnit <- valueKinds$DataColumn[matchOrder]
  
  longResults$"UnparsedValue" <- trim(as.character(longResults$"UnparsedValue"))
  
  # Parse numeric data from the unparsed values
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
    if (any(longResults$valueType == valueType, na.rm = TRUE)) {
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
  
  ### For the results marked as "Image File":
  longResults <- moveResults(longResults, "inlineFileValue")
  
  # Clean up the data frame to look nice (remove extra columns)
  row.names(longResults) <- 1:nrow(longResults)
  
  organizedData <- longResults[c("batchCode","valueKind","valueUnit","concentration","concentrationUnit", "time", 
                                 "timeUnit", "numericValue", "stringValue","valueOperator", "dateValue","clobValue",
                                 "urlValue", "fileValue", "inlineFileValue", "codeValue",
                                 "Class", "valueType", "valueKindAndUnit","publicData", "originalMainID", 
                                 "groupingID", "groupingID_2", "rowID", "stateType", "stateKind", "linkColumn", "linkID",
                                 "uncertainty", "uncertaintyType", "comments")]
  
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
                                   & is.na(organizedData$inlineFileValue)
                                   & is.na(organizedData$codeValue)
                                   ), ]
  
  return(organizedData)
}
addFileValue <- function(imageLocation, calculatedResults) {
  # Adds a "fileValue" attribute to entries of calculated results that have an inlineFileValue
  # They have to have both pieces of information because the inline file value is just the
  # file name and extension, whereas the fileValue contains the full path from privateUploads
  # 
  # Input: imageLocation: the file path to the folder where images are stored, relative to the
  #                       working directory
  #        calculatedResults: a data frame of calculated results and their types
  #                           NOTE: This doesn't work if the fileValue column has stringsAsFactors
  # Returns: the calculatedResults data frame, but all the entries with "inlineFileValue" also
  #          have an entry for "fileValue"
  
  # We have to save the fileValue relative to privateUploads, so we need to remove privateUploads from it
  uploadedFilePath <- racas::getUploadedFilePath("")
  imageLocation <- gsub(uploadedFilePath, "", imageLocation)

  fileValueVector <- ifelse(is.na(calculatedResults$inlineFileValue),
                            NA_character_,
                            file.path(imageLocation, calculatedResults$inlineFileValue))
  fileValuesToAdd <- fileValueVector[!is.na(fileValueVector)]
  calculatedResults$fileValue[!is.na(fileValueVector)] <- fileValuesToAdd
  
  return(calculatedResults)
}

addComment <- function(calculatedResults) {
  # Adds the name of each uploaded file to the "comments" section of its entry in calculatedResults
  #
  # Input: calculatedResults, a data frame of results and their types
  # Returns: the same data frame, but every row that had an inlineFileValue has had that value
  #          moved to the "comments" column
  # If the row doesn't have an inlineFileValue, its comments are left as-is
  
  mustAddComment <- !is.na(calculatedResults$inlineFileValue)
  
  fileValuesToAdd <- calculatedResults$inlineFileValue[!is.na(calculatedResults$inlineFileValue)]
  calculatedResults$comments[mustAddComment] <- fileValuesToAdd
  
  return(calculatedResults)
}

addImageFiles <- function(imagesFile, calculatedResults, experiment, dryRun) {
  # Processes the image files that the user (optionally) uploaded with their spreadsheet
  # Unzips the images into the /analysis/uploadedFiles folder, validates them, and
  # adds the full file path to the calculatedResults
  #
  # Input: imagesFile, the path (relative to privateUploads) where the zip file of images is
  #        calculatedResults, a data frame of the results and their types
  #        experiment, a list that is an experiment (with a new code name, if it overwrote an old experiment)
  #        dryRun, a boolean indicating whether the data should skip upload to the database
  # Returns: calculatedResults, the same data frame, but every result that had an "inlineFileValue" now also
  #          has a fileValue
  
  # This is relative to your current working directory
  experimentFolderLocation <- createExperimentFolder(experiment = experiment, dryRun = dryRun)
  
  if (!is.null(imagesFile)) {
    if (racas::applicationSettings$server.service.external.file.type == "blueimp") {
      imageLocation <- unzipUploadedImages(imagesFile = racas::getUploadedFilePath(imagesFile), experimentFolderLocation = experimentFolderLocation)
      listedImageFiles <- calculatedResults[!is.na(calculatedResults$inlineFileValue),]$inlineFileValue
      isValid <- validateUploadedImages(imageLocation = imageLocation, listedImageFiles = listedImageFiles, experimentFolderLocation = experimentFolderLocation)
      calculatedResults <- addFileValue(imageLocation = imageLocation, calculatedResults = calculatedResults)
      calculatedResults <- addComment(calculatedResults = calculatedResults)
      if (dryRun) {
        # We created the experiment folder in order to have a place to unzip the files -- in dryRun mode
        # we never moved anything else into it, so we delete it
        unlink(experimentFolderLocation, recursive = TRUE)
      } else {
        # Otherwise, we should move the zip file from privateUploads into the experiment folder
        file.rename(from = racas::getUploadedFilePath(imagesFile), to = file.path(experimentFolderLocation, basename(imagesFile)))
      }
    } else {
      stopUser("Internal Error: Saving image files for this server.service.external.file.type has not been implemented")
    } 
  } else {
    # If no image files were uploaded, we want to make sure they didn't add an Image File column to their data
    if (any(calculatedResults$Class == "Image File")) {
      stopUser("The spreadsheet contains a column labeled 'Image File', but no image files were uploaded.")
    }
  }
  
  return(calculatedResults)
}

getProtocolByNameAndFormat <- function(protocolName, configList, formFormat) {
  # Gets the protocol entered as an input
  # 
  # Args:
  #   protocolName:     	    A string name of the protocol
  #   configList:             Also known as racas::applicationSettings
  #   formFormat:             The format of the data (as a string). For example, "Dose Response"
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
    protocolList <- getProtocolsByName(protocolName)
  }, error = function(e) {
    stopUser("There was an error in accessing the protocol. Please contact your system administrator.")
  })
  
  # If no protocol with the given name exists, warn the user
  if (length(protocolList)==0) {
    allowedCreationFormats <- configList$server.allow.protocol.creation.formats
    allowedCreationFormats <- unlist(strsplit(allowedCreationFormats, ","))
    if (formFormat %in% allowedCreationFormats || forceProtocolCreation) {
      warnUser(paste0("Protocol '", protocolName, "' does not exist, so it will be created. No user action is needed if you intend to create a new protocol."))
    } else {
      addError( paste0("Protocol '", protocolName, "' does not exist. Please enter a protocol name that exists. Contact your system administrator if you would like to create a new protocol."))
    }
    # A flag for when the protocol will be created new
    protocol <- NA
  } else {
    # If the protocol does exist, get the full version
    protocol <- getProtocolById(protocolList[[1]]$id)
  }
  return(protocol)
}
getExperimentByNameCheck <- function(experimentName, protocol, configList, duplicateNamesAllowed = FALSE) {
  # Gets the experiment entered as an input, warns if it does exist, and throws an error if it is in the wrong protocol
  # 
  # Args:
  #   experimentName:   		  A string name of the experiment
  #   protocol:               A list that is a protocol (containing its name, associated experiments, and other data)
  #   configList:             Also known as racas::applicationSettings
  #   duplicatedNamesAllowed: A boolean marking if experiment names can be repeated in multiple protocols
  #
  # Returns:
  #  A list that is an experiment
  
  require('RCurl')
  require('rjson')
  
  tryCatch({
    experimentList <- getExperimentsByName(experimentName)
  }, error = function(e) {
    stopUser("There was an error checking if the experiment already exists. Please contact your system administrator.")
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
    }, error = function(e) {
      stopUser("There was an error checking if the experiment is in the correct protocol. Please contact your system administrator.")
    })
    protocolOfExperiment <- getProtocolById(experimentList[[1]]$protocol$id)

    
    if (is.na(protocol) || protocolOfExperiment$id != protocol$id) {
      if (duplicateNamesAllowed) {
        experiment <- NA
      } else {
        addError(paste0("Experiment '",experimentName,
                                         "' does not exist in the protocol that you entered, but it does exist in '", getPreferredProtocolName(protocolOfExperiment), 
                                         "'. Either change the experiment name or use the protocol in which this experiment currently exists."))
        experiment <- experimentList[[1]]
      }
    } else {
      warnUser(paste0("Experiment '",experimentName,"' already exists, so the loader will delete its current data and replace it with your new upload.",
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
    warnUser(paste0("The protocol name that you entered, '", protocolName, 
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
  #   recordedBy:             A string
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
  #   pathToGenericDataFormatExcelFile: Currently unused; the file path to the uploaded Excel file
  #   recordedby:             A string of the user who recorded the experiment
  #   configList:             Also known as racas::applicationSettings
  #   replacedExperimentCodes: Used to create a state noting what the experiment code used to be
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
  experiment <- getExperimentById(experiment$id)
  return(experiment)
}
validateProject <- function(projectName, configList, errorEnv) {
  # checks with Roo services to ensure that a project is available and correct
  # 
  # Args:
  #   projectName:         A string naming the project
  #   configList:          Also known as racas::applicationSettings
  #
  # Returns:
  #  The projectName if validation was successful, or the empty string if it was not
  require('RCurl')
  require('rjson')
  tryCatch({
  projectList <- getURL(paste0(racas::applicationSettings$server.nodeapi.path, configList$client.service.project.path))
  }, error = function(e) {
    stopUser("The project service did not respond correctly, contact your system administrator")
  })
  tryCatch({
    projectList <- fromJSON(projectList)
  }, error = function(e) {
    addError(paste("There was an error in validating your project:", projectList), errorEnv = errorEnv)
    return("")
  })
  #projectCodes <- sapply(projectList, function(x) x$code)
  projectNames <- sapply(projectList, function(x) x$name)
  if(length(projectNames) == 0) {addError("No projects are available, contact your system administrator", errorEnv=errorEnv)}
  if (projectName %in% projectNames) {
    return(projectName)
  } else {
    configText <- toJSON(configList)
    addError(paste0("The project you entered is not an available project. Please enter one of these projects: '",
                                      paste(projectNames, collapse = "', '"), "'."), errorEnv=errorEnv)
    return("")
  }
}
validateScientist <- function(scientistName, configList, testMode = FALSE) {
  # validates that the supplied scientist's name is on file with Roo services
  # 
  # Args:
  #   scientistName:          A string
  #   configList:             Also known as racas::applicationSettings
  #   testMode:               If true, the function bypasses Roo services and gives a database-independent answer
  #
  # Returns:
  #  The scientist's name if they are registered, and the empty string if they are not
  require('utils')
  require('RCurl')
  require('rjson')
  
  response <- NULL
  username <- "username"
  
  if (!testMode) {
    response <- tryCatch({
      getURL(URLencode(paste0(racas::applicationSettings$server.nodeapi.path, configList$client.service.users.path, "/", scientistName)))
    }, error = function(e) {
      addError( paste("There was an error in validating the scientist's name:", scientistName))
      return("")
    }) 
  } else { # In test mode, provide the three possible answers
    if (scientistName == "unknownUser") {
      response <- ""
    } else if (scientistName == "") {
      response <- "Cannot GET /api/users/"
    } else {
      response <- toJSON(list(username = scientistName))
    }
  }
  
  if (response == "") {
    addError( paste0("The Scientist you supplied, '", scientistName, "', is not a valid name. Please enter the scientist's login name."))
    return("")
  }
  
  username <- tryCatch({
    fromJSON(response)$username
  }, error = function(e) {
    addError( paste("There was an error in validating the scientist's name:", scientistName))
    return("")
  })
  
  return(username)
}

unzipUploadedImages <- function(imagesFile, experimentFolderLocation = experimentFolderLocation) {
  # Unzips a (flat) folder of image files that the user wishes to upload with their data
  # The images go into the experiment's folder, in the path "analysis/uploadedFiles"
  #
  # Input: imagesFile, the path to the zip folder, relative to the working directory
  #        experimentFolderLocation, the path to the experiment location, relative to the working directory,
  #                                  and without a trailing slash
  # Returns: the file path to the location of the images, relative to the working directory, and without a
  #          trailing slash
  
  if (!file.exists(imagesFile)) {
    stopUser("Input file not found")
  }
  
  if(!grepl("\\.zip$", imagesFile)) {
    stopUser("The uploaded file must be a zip file")
  }
  
  # Create the directory that will house the files
  filesLocation <- file.path(experimentFolderLocation, "analysis", "uploadedFiles")
  dir.create(filesLocation, showWarnings = FALSE, recursive = TRUE)
  
  # Delete the files and folders that may have been in that directory
  oldFiles <- as.list(paste0(filesLocation,"/",list.files(filesLocation)))
  do.call(unlink, list(oldFiles, recursive=T))
  
  # Unzip the folder, and get rid of the internal subdirectory structure
  unzip(zipfile=imagesFile, exdir=filesLocation, junkpaths = TRUE)
  imageLocation = file.path(experimentFolderLocation, "analysis", "uploadedFiles")
  
  return(imageLocation)
  
}

uploadRawDataOnly <- function(metaData, lsTransaction, subjectData, experiment, fileStartLocation, 
                              configList, stateGroups, reportFilePath, hideAllData, reportFileSummary, curveNames,
                              recordedBy, replaceFakeCorpBatchId, annotationType, sigFigs, rowMeaning="subject", 
                              includeTreatmentGroupData, inputFormat, mainCode) {
  # For use in uploading when the results go into subjects rather than analysis groups
  
  library('plyr')
  
  #Change in naming convention
  if (rowMeaning=="subject") {
    if (any(names(subjectData) == "analysisGroupID")) {
      subjectData$subjectID <- NULL
    }
    names(subjectData)[names(subjectData) == "analysisGroupID"] <- "subjectID"
  } else if (rowMeaning=="subjectState") {
    names(subjectData)[names(subjectData) == "rowID"] <- "subjectStateID"
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
  names(subjectData)[names(subjectData) %in% names(nameChange)] <- nameChange[names(subjectData)][names(subjectData) %in% names(nameChange)]
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
      stopUser(paste0("Values in ", unique(subjectData$valueKindAndUnit), " are expected to be the same for each subject."))
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
                       reportFileSummary, recordedBy, annotationType, mainCode, appendCodeNameList) {
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
  #   testOutputLocation:     When dryRun is TRUE, a string naming a file that will hold JSON output
  #   developmentMode:        A boolean that marks if the JSON request should be saved to a file
  #   appendCodeName:         A vector of lsKinds that should have the code name appended to them
  #
  #   Returns:
  #     NULL
  
  analysisGroupData$unitKind <- analysisGroupData$valueUnit
  treatmentGroupData$unitKind <- treatmentGroupData$valueUnit
  subjectData$unitKind <- subjectData$valueUnit
  
  
  analysisGroupData$lsTransaction <- lsTransaction
  analysisGroupData$recordedBy <- recordedBy
  
  
  
  ### Analysis Group Data
  # Not all of these will be filled
  analysisGroupData$tempStateId <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex, "-", 
                                analysisGroupData$concentration, "-", analysisGroupData$concentrationUnit, "-",
                                analysisGroupData$time, "-", analysisGroupData$timeUnit, "-", analysisGroupData$stateKind)
  analysisGroupData$parentId <- analysisGroupData$experimentID
  analysisGroupData$tempId <- analysisGroupData$analysisGroupID
  #   analysisGroupData <- rbind.fill(analysisGroupData, makeConcentrationColumns(analysisGroupData))
  analysisGroupData <- rbind.fill(analysisGroupData, meltTimes2(analysisGroupData))
  analysisGroupData <- rbind.fill(analysisGroupData, gdpMeltBatchCodes(analysisGroupData))
  analysisGroupData[analysisGroupData$valueKind != "batch code", ]$concentration <- NA
  analysisGroupData[analysisGroupData$valueKind != "batch code", ]$concUnit <- NA
  analysisGroupData$concentrationUnit <- NULL
  
  #Note: use unitKind, not valueUnit
  # use operatorKind, not valueOperator
  analysisGroupData$unitKind <- analysisGroupData$valueUnit
  analysisGroupData$operatorKind <- analysisGroupData$valueOperator
  analysisGroupData$tempStateId <- as.numeric(as.factor(analysisGroupData$tempStateId))
  analysisGroupData$lsType <- "default"
  analysisGroupData$lsKind <- "default"
  
  ### TreatmentGroup Data
  if (!is.null(treatmentGroupData)) {
    treatmentGroupData$lsTransaction <- lsTransaction
    treatmentGroupData$recordedBy <- recordedBy
    
    #     treatmentGroupData <- rbind.fill(treatmentGroupData, makeConcentrationColumns(treatmentGroupData))
    treatmentGroupData <- rbind.fill(treatmentGroupData, meltTimes2(treatmentGroupData))
    treatmentGroupData <- rbind.fill(treatmentGroupData, gdpMeltBatchCodes(treatmentGroupData))
    treatmentGroupData[treatmentGroupData$valueKind != "batch code", ]$concentration <- NA
    treatmentGroupData[treatmentGroupData$valueKind != "batch code", ]$concUnit <- NA
    treatmentGroupData$concentrationUnit <- NULL
    
    treatmentGroupData$unitKind <- treatmentGroupData$valueUnit
    if (!is.null(treatmentGroupData$valueOperator)) {
      treatmentGroupData$operatorKind <- treatmentGroupData$valueOperator
    } 
    treatmentGroupData$stateID <- NULL
    treatmentGroupData$tempId <- treatmentGroupData$treatmentGroupID
    treatmentGroupData$tempParentId <- treatmentGroupData$analysisGroupID
    treatmentGroupData$lsType <- "default"
    treatmentGroupData$lsKind <- "default"
  }

  ### subject Data
  if (!is.null(subjectData)) {
    subjectData$lsTransaction <- lsTransaction
    subjectData$recordedBy <- recordedBy
   
    #     subjectData <- rbind.fill(subjectData, makeConcentrationColumns(subjectData))
    subjectData <- rbind.fill(subjectData, meltTimes2(subjectData))
    subjectData <- rbind.fill(subjectData, gdpMeltBatchCodes(subjectData))
    subjectData[subjectData$valueKind != "batch code", ]$concentration <- NA
    subjectData[subjectData$valueKind != "batch code", ]$concUnit <- NA
    subjectData$concentrationUnit <- NULL
    
    subjectData$unitKind <- subjectData$valueUnit
    subjectData$operatorKind <- subjectData$valueOperator
    subjectData$stateID <- NULL
    subjectData$tempId <- subjectData$subjectID
    subjectData$tempParentId <- subjectData$treatmentGroupID
    subjectData$lsType <- "default"
    subjectData$lsKind <- "default"
  }
  
  if(developmentMode) {
    # Write the data to a file for debugging
    print(testOutputLocation)
    write(analysisGroupData, file = testOutputLocation)
    return(lsTransaction)
  } else {
    saveAllViaTsv(analysisGroupData, treatmentGroupData, subjectData, appendCodeNameList)
  }
  
  
  serverFileLocation <- moveFileToExperimentFolder(fileStartLocation, experiment, recordedBy, lsTransaction, 
                                                   configList$server.service.external.file.type, 
                                                   configList$server.service.external.file.service.url)
  if(!is.null(reportFilePath) && reportFilePath != "") {
    batchNameList <- unique(analysisGroupData$batchCode)
    if (configList$server.service.external.report.registration.url != "") {
      registerReportFile(reportFilePath, batchNameList, reportFileSummary, recordedBy, configList, experiment, lsTransaction, annotationType)
    } else {
      addFileLink(batchNameList, recordedBy, experiment, lsTransaction, reportFileSummary, reportFilePath, NULL, annotationType)
    }
  }
  
  return(lsTransaction)
}

createExperimentFolder <- function(experiment, dryRun) {
  # Create a place for this experiment's data to live
  # 
  # Experiment: a list that is an experiment. We particularly care about its code name
  # dryRun: a boolean indicating whether we should skip saving the data to the database. If
  #         we're in dryRun mode, we create this folder in the privateTempFiles instead
  # Returns: The location of the experiment folder, relative to the working directory
  
  if (racas::applicationSettings$server.service.external.file.type == "blueimp") {
    if (dryRun) {
      # We don't necessarily have access to the code name
      fullFolderLocation <- file.path("privateTempFiles", "uploadedExperimentFiles")
      dir.create(fullFolderLocation, showWarnings = FALSE, recursive = TRUE)
    } else {
      experimentCodeName <- experiment$codeName
      fullFolderLocation <- racas::getUploadedFilePath(file.path("experiments", experimentCodeName))
      dir.create(fullFolderLocation, showWarnings = FALSE, recursive = TRUE)
    }
  } else {
    stopUser("Internal Error: Saving image files for this server.service.external.file.type has not been implemented")
  }
  
  return(fullFolderLocation)
}

saveFullEntityData <- function(entityData, entityKind, appendCodeName = c()) {
  # appendCodeName is a vector of lsKinds that should have 
  # Does not work for containers
  
  ### local names
  # entityData[[paste0(entityKind, "ID")]] must be numeric
  acasEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  entityID <- paste0(entityKind, "ID")
  entityCodeName <- paste0(entityKind, "CodeName")
  tempIds <- c()
  
  ### Error checking
  if (!(entityID %in% names(entityData))) {
    stopUser(paste0("Internal Error: Column ", entityID, " is not a missing from entityData"))
  }
  
  ### main code
  thingTypeAndKind <- paste0("document_", changeEntityMode(entityKind, "camel", "space"))
  entityCodeNameList <- unlist(getAutoLabels(thingTypeAndKind=thingTypeAndKind, 
                                                    labelTypeAndKind="id_codeName", 
                                                    numberOfLabels=max(entityData[[entityID]])),
                                      use.names=FALSE)
  
  entityData[[entityCodeName]] <- entityCodeNameList[entityData[[entityID]]]
  
  entityData$stringValue[entityData$valueKind %in% appendCodeName] <- paste0(entityData$stringValue[entityData$valueKind %in% appendCodeName], "_", entityData[entityData$valueKind == appendCodeName, entityCodeName])
  
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
      stopUser(paste0("Internal Error: No ", paste0(upperAcasEntity, "ID"), " found in data"))
    }
    if (is.null(dfData[[paste0(upperAcasEntity, "ID")]][1])) {
      stopUser(paste0("Internal Error: No ", paste0(upperAcasEntity, "Version"), " found in data"))
    }
    entity[[upperAcasEntity]] <- list(id=dfData[[paste0(upperAcasEntity, "ID")]][1],
                                      version=dfData[[paste0(upperAcasEntity, "Version")]][1])
    return(entity)
  }
  
  entities <- dlply(.data=entityData, .variables = paste0(entityKind, "ID"), createEntityFromDF, currentEntity=entityKind)
  tempIds <- as.numeric(names(entities))
  
  names(entities) <- NULL
  savedEntities <- saveAcasEntities(entities, paste0(acasEntity, "s"))
  
  if (length(savedEntities) != length(entities)) {
    stopUser(paste0("Internal Error: roo server did not respond with the same number of ", acasEntity, "s after a post"))
  }
  
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
                    configList, testMode = FALSE, recordedBy, imagesFile = NULL, errorEnv = NULL) {
  # This function runs all of the functions within the error handling
  # lsTransactionComments input is currently unused
  #
  # Args:
  #       pathToGenericDataFormatExcelFile: The path, relative to privateUploads, where the Excel file is located
  #       reportFilePath:                   An (optional) location to which the report file will be saved
  #       dryRun:                           A boolean; if TRUE, the data is not recorded in the database
  #       developmentMode:                  Used for testing; see parseGenericData
  #       testOutputLocation:               When dryRun is TRUE, a string naming a file that will hold JSON output
  #       configList:                       Also known as racas::applicationSettings
  #       testMode:                         Used for getPreferredId (from racas)
  #       recordedBy:                       A string containing a username
  #       imagesFile:                       The name of a zip file (relative to privateUploads) containing images to upload
  #       errorEnv:                         Used to collect errors across multiple function calls
  #
  # Returns: a list of the validated, organized data in the Excel file
  #
  
  library('RCurl')

  pathToGenericDataFormatExcelFile <- racas::getUploadedFilePath(pathToGenericDataFormatExcelFile)
  if (!is.null(reportFilePath) && reportFilePath != "") {
    reportFilePath <- racas::getUploadedFilePath(reportFilePath)
  }
  
  lsTranscationComments <- paste("Upload of", pathToGenericDataFormatExcelFile)
  
  # Validate Input Parameters
  if (is.na(pathToGenericDataFormatExcelFile)) {
    stopUser("Need Excel file path as input")
  }
  if (!file.exists(pathToGenericDataFormatExcelFile)) {
    stopUser("Cannot find input file")
  }
  
  genericDataFileDataFrame <- readExcelOrCsv(pathToGenericDataFormatExcelFile)
  
  # Meta Data
  metaData <- getSection(genericDataFileDataFrame, lookFor = "Experiment Meta Data", transpose = TRUE)
  
  customFormatSettings <- getFormatSettings()
  
  validatedMetaDataList <- validateMetaData(metaData, configList, customFormatSettings, errorEnv)
  validatedMetaData <- validatedMetaDataList$validatedMetaData
  duplicateExperimentNamesAllowed <- validatedMetaDataList$duplicateExperimentNamesAllowed
  useExisting <- validatedMetaDataList$useExisting
  
  inputFormat <- as.character(validatedMetaData$Format)
  
  if (inputFormat == "Gene ID Data") {
    mainCode <- "Gene ID"
  } else {
    mainCode <- "Corporate Batch ID"
  }
  
  rawOnlyFormat <- inputFormat %in% names(customFormatSettings)
  
  formatParameters <- getFormatParameters(rawOnlyFormat, customFormatSettings, inputFormat)
  
  precise <- inputFormat %in% c("Precise For Existing Experiment", "Precise")
  
  # Grab the Calculated Results Section
  calculatedResults <- getSection(genericDataFileDataFrame, lookFor = formatParameters$lookFor, transpose = FALSE)
  
  # Organize the Calculated Results
  stateAssignments <- NULL
  if (inputFormat == "Dose Response") {
    doseResponseKinds <- c(
      "Fitted Min", "SST", "Rendering Hint", "rSquared", "SSE", "Fitted Slope", 
      "Fitted EC50", "Slope", "curve id", "fitSummaryClob", "EC50", 
      "parameterStdErrorsClob", "fitSettings", "flag", "Min", "Fitted Max", 
      "curveErrorsClob", "category", "Max", "reportedValuesClob", "IC50"
    )
    stateAssignments <- data.frame(
      valueKind = doseResponseKinds,
      stateType = rep("data", length(doseResponseKinds)), 
      stateKind = rep("dose response", length(doseResponseKinds)),
      stringsAsFactors = FALSE
    )
  }
  
  calculateGroupingID <- if (rawOnlyFormat) {calculateTreatmemtGroupID} else {NA}
  calculatedResults <- organizeCalculatedResults(
    calculatedResults, inputFormat, formatParameters, mainCode, 
    lockCorpBatchId = formatParameters$lockCorpBatchId, rawOnlyFormat = rawOnlyFormat, 
    errorEnv = errorEnv, precise = precise, calculateGroupingID = calculateGroupingID,
    stateAssignments = stateAssignments)
  
  if (!is.null(formatParameters$splitSubjects)) {
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
  calculatedResults <- validateCalculatedResults(
    calculatedResults, dryRun, curveNames=formatParameters$curveNames, testMode=testMode, 
    replaceFakeCorpBatchId=formatParameters$replaceFakeCorpBatchId, mainCode)
  
  # Subject and TreatmentGroupData
  subjectAndTreatmentData <- getSubjectAndTreatmentData(precise, genericDataFileDataFrame, calculatedResults, inputFormat, mainCode, formatParameters, errorEnv)
  subjectData <- subjectAndTreatmentData$subjectData
  treatmentGroupData <- subjectAndTreatmentData$treatmentGroupData
  
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
      stopUser(paste0("Experiment Code Name not found ", validatedMetaData$'Experiment Code Name'[1]))
    }
    protocol <- getProtocolById(experiment$protocol$id)
    validatedMetaData$'Protocol Name' <- getPreferredName(protocol)
    validatedMetaData$'Experiment Name' <- getPreferredName(experiment)
  } else {
    experiment <- getExperimentByNameCheck(experimentName = validatedMetaData$'Experiment Name'[1], protocol, configList, duplicateExperimentNamesAllowed)
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

  if(!is.null(imagesFile) && imagesFile != "") {
    calculatedResults <- addImageFiles(imagesFile = imagesFile, calculatedResults = calculatedResults, experiment = experiment, dryRun = dryRun)
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
                 reportFilePath=reportFilePath, reportFileSummary=reportFileSummary, recordedBy, annotationType, 
                 mainCode, appendCodeNameList = list(analysisGroup = "curve id"))
    }
  }
  
  if(!dryRun) {
    viewerLink <- getViewerLink(protocol, experiment, validatedMetaData$'Experiment Name') 
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
  if (rawOnlyFormat) {
    summaryInfo$info$"Rows of Data" = max(calculatedResults$rowID)
  } else {
    summaryInfo$info$"Rows of Data" = max(calculatedResults$analysisGroupID)
  }
  summaryInfo$info$"Columns of Data" = length(unique(calculatedResults$valueKindAndUnit))
  summaryInfo$info[[paste0("Unique ", mainCode, "'s")]] = length(unique(calculatedResults$batchCode))
  if (!is.null(subjectData)) {
    summaryInfo$info$"Raw Results Data Points" <- max(subjectData$rowID)
    summaryInfo$info$"Flagged Data Points" <- sum(subjectData$valueKind == "flag")
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

gdpMeltBatchCodes <- function(entityData) {
  # Check for missing batchCode
  output <- data.frame()
  if (is.null(entityData$batchCode) || all(is.na(entityData$batchCode))) {
    return(output)
  }
  
  optionalColumns <- c("lsTransaction", "recordedBy")
  
  neededColumns <- c("batchCode", "tempStateId", "parentId", "tempId", "stateType", "stateKind")
  if (!all(neededColumns %in% names(entityData))) {stop("Internal error: missing needed columns")}
  
  usedColumns <- c(neededColumns, optionalColumns[optionalColumns %in% names(entityData)])
  
  
  batchCodeValues <- unique(entityData[, usedColumns])
  
  names(batchCodeValues)[1] <- "codeValue"
  batchCodeValues$valueType <- "codeValue"
  batchCodeValues$valueKind <- "batch code"
  batchCodeValues$publicData <- TRUE
  batchCodeValues$concentration <- entityData$concentration
  batchCodeValues$concUnit <- entityData$concentrationUnit
  batchCodeValues <- batchCodeValues[!is.na(batchCodeValues$codeValue), ]
  
  return(batchCodeValues)
}

makeConcentrationColumns <- function(entityData) {
  if(any(is.na(entityData$concentration))) {
    return(data.frame())
  }
  
  optionalColumns <- c("lsTransaction", "recordedBy")
  
  neededColumns <- c("concentration", "concentrationUnit", "tempStateId", "parentId", "tempId", "stateType", "stateKind")
  if (!all(neededColumns %in% names(entityData))) {stop("Internal error: missing needed columns")}
  usedColumns <- c(neededColumns, optionalColumns[optionalColumns %in% names(entityData)])
  
  createConcentrationRows <- function(entityData) {
    output <- unique(entityData[, usedColumns])
    if (nrow(output) > 1) stop("Non-unique concentrations in a tempStateId")
    output$concentration <- output$concentration
    output$concUnit <- output$concentrationUnit
    output$valueKind <- "tested concentration"
    output$valueType <- "numericValue"
    output$publicData <- TRUE
#     output$concentration <- NULL
    output$concentrationUnit <- NULL
    return(output)
  }
  
  output <- ddply(.data=entityData, .variables = c("tempStateId"), .fun = createConcentrationRows)
  return(output)
}

getStateGroups <- function(formatSettings) {
  #Gets stateGroups from configuration list
  
  tryCatch({
    stateGroups <- formatSettings$stateGroups
  }, error = function(e) {
    stopUser(paste("The format", inputFormat, "is missing stateGroup settings in the configuration file. Contact your system administrator."))
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
                                    protocolPostfixState$lsValues)
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
translateClassToValueType <- function(x, reverse = F) {
  # translates Excel style Number formats to ACAS valueTypes (or reverse)
  valueTypeVector <- c("numericValue", "stringValue", "fileValue", "inlineFileValue", "urlValue", "dateValue", "clobValue", "blobValue", "codeValue")
  classVector <- c("Number", "Text", "File", "Image File","URL", "Date", "Clob", "Blob", "Code")
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
  imagesFile <- request$imagesFile
  
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
                        imagesFile=imagesFile,
                        errorEnv = errorEnv)))
  } else {
    loadResult <- tryCatch.W.E(runMain(pathToGenericDataFormatExcelFile,
                                       reportFilePath = reportFilePath,
                                       dryRun = dryRun,
                                       developmentMode = developmentMode,
                                       configList=configList, 
                                       testMode=testMode,
                                       recordedBy=recordedBy,
                                       imagesFile=imagesFile,
                                       errorEnv = errorEnv))
  }
  
  # If the output has class simpleError or is not a list, save it as an error
  if (sum(class(loadResult$value)=="userStop") > 0) {
    errorList <- c(errorList,list(loadResult$value$message))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="SQLException") > 0) {
    errorList <- c(errorList,list(paste0("There was an error in connecting to the SQL server ", 
                                         configList$server.database.host,configList$server.database.port, ":", 
                                         as.character(loadResult$value), ". Please contact your system administrator.")))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="simpleError") > 0) {
    errorList <- c(errorList, list(paste0("The system has encountered an internal error: ", 
                                          as.character(loadResult$value$message))))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="error") > 0 || class(loadResult$value)!="list") {
    errorList <- c(errorList,list(as.character(loadResult$value)))
    loadResult$value <- NULL
  }
  
  # Save warning messages but not the function call, which is only useful while programming
  # Paste "Internal Warning: " to the front of errors we didn't intend to throw
  loadResult$warningList <- lapply(loadResult$warningList,function(x) {
    if(any(class(x) == "userWarning")) {
      x$message
      } else {
        paste0("The system has encountered an internal warning: ", x$message)
        }
    })
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
    stopUser(paste0("Internal Error: ", idColumn, " must be a column in entityData"))
  }
  
  if (!(entityKind %in% racas::acasEntityHierarchyCamel)) {
    stopUser("Internal Error: entityKind must be in racas::acasEntityHierarchyCamel")
  }
  
  if (!(entityID %in% names(entityData))) {
    stopUser(paste0("Internal Error: ", entityID, " must be included in entityData"))
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
    lsState[[entityKind]] <- list(id = entityData[[entityID]][[1]], version = entityData[[entityVersion]][1])
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
  
  if (!is.list(savedLsStates) || length(savedLsStates) != length(lsStates)) {
    stopUser("Internal error: the roo server did not respond correctly to saving states")
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
#'     \item{fileValue}{String: a code that refers to a file}
#'     \item{inlineFileValue}{String: similar to a file value, but intended to be shown to users in result viewers (optional)}
#'     \item{urlValue}{String: a url (optional)}
#'     \item{numericValue}{Number: a number (optional)}
#'     \item{dateValue}{Number: date in milliseconds or String in "YYYY-MM-DD" (optional)}
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
  
  optionalColumns <- c("fileValue", "inlineFileValue", "urlValue", "codeValue", "numericValue", "dateValue",
                       "valueOperator", "valueUnit", "clobValue", "blobValue", "numberOfReplicates",
                       "uncertainty", "uncertaintyType", "comments")
  missingOptionalColumns <- Filter(function(x) !(x %in% names(entityData)),
                                   optionalColumns)
  entityData[missingOptionalColumns] <- NA
  
  ### Error Checking
  requiredColumns <- c("valueType", "valueKind", "publicData", "stateVersion", "stateID")
  if (any(!(requiredColumns %in% names(entityData)))) {
    stopUser(paste0("Internal Error: Missing input columns in entityData, must have ", paste(requiredColumns, collapse = ", ")))
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
    stopUser(paste0("Internal Error: unrecognized class of entityData$dateValue: ", class(entityData$dateValue)))
  }
  
  
  
  ### Helper function
  createLocalStateValue <- function(valueData) {
    stateValue <- with(valueData, {
      createStateValue(
        lsState = list(id = stateID, version = stateVersion),
        lsType = if (valueType %in% c("stringValue", "fileValue", "inlineFileValue", "urlValue", "dateValue", "clobValue", "blobValue", "numericValue", "codeValue")) {
          valueType
        } else {"numericValue"},
        lsKind = valueKind,
        stringValue = if (is.character(stringValue) && !is.na(stringValue)) {stringValue} else {NULL},
        dateValue = if(is.numeric(dateValue) && !is.na(dateValue)) {dateValue} else {NULL},
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

organizeSubjectData <- function(subjectData, groupByColumns, excludedRowKinds, inputFormat, mainCode, link, precise, stateAssignments, keepColumn, errorEnv, formatParameters) {
  # Returns two data.frames: subjectData and treatmentGroupData
  
  createPtgFunction <- function (groupByColumns) {
    # Create a function that has the groupByColumns filled in
    function(results, inputFormat, stateGroups, resultTypes) {
      # stateGroups, inputFormat, and resultTypes not used
      # Need to coerce to data frame for single column data frames
      ids <- as.numeric(factor(do.call(paste, as.data.frame(results[, groupByColumns]))))
      return(ids)
    }
  }
  
  preciseTreatmentGroupID <- createPtgFunction(groupByColumns)
  
  subjectData2 <- organizeCalculatedResults(subjectData, inputFormat, formatParameters, mainCode, 
                                            lockCorpBatchId= F, errorEnv= errorEnv, precise = precise, link = link, 
                                            calculateGroupingID = preciseTreatmentGroupID, 
                                            stateAssignments = stateAssignments)
  subjectData2 <- as.data.table(subjectData2)
  
  subjectData2[, treatmentGroupID := groupingID]
  subjectData2[, subjectID := rowID]
  subjectData2[, tempStateId:=as.numeric(as.factor(paste(stateKind, subjectID, sep = "-")))]
  
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
      inlineFileValue = as.character(uniqueOrNA(x$inlineFileValue)),
      codeValue = as.character(uniqueOrNA(x$codeValue)),
      uncertaintyType = if (is.na(uncertainty)) NA_character_ else "standard deviation",
      uncertainty = uncertainty,
      tempStateId = x$tempStateId[1]
    )
  }
  
  groupByColumnsNoUnit <- trim(gsub("\\(\\w*\\)", "", groupByColumns))
  excludedSubjects <- subjectData2$subjectID[subjectData2$valueKind %in% excludedRowKinds]
  subjectData3 <- subjectData2[valueKind %in% c(keepColumn, groupByColumnsNoUnit)]
  treatmentGroupData <- subjectData3[!is.na(groupingID), createTreatmentGroupData(.SD), 
                                     by = list(groupingID, valueType, valueKind, concentration, 
                                               concentrationUnit, time, timeUnit, valueUnit, 
                                               valueKindAndUnit, publicData, linkID, stateType,
                                               stateKind)]
  treatmentGroupData[valueKind %in% groupByColumnsNoUnit, c("uncertainty", "uncertaintyType") := list(NA_real_, NA_character_)]
  treatmentGroupData[, treatmentGroupID := groupingID]
  treatmentGroupData[, analysisGroupID := linkID]
  treatmentGroupData <- as.data.frame(treatmentGroupData)
  
  subjectData <- as.data.frame(subjectData2)
  
  return(list(subjectData=subjectData, treatmentGroupData=treatmentGroupData))
}

getFormatParameters <- function(rawOnlyFormat, customFormatSettings, inputFormat) {
  # Creates a list of format parameters, based on custom format settings if it is a "rawOnlyFormat"
  
  o <- list()
  if (rawOnlyFormat) {
    o$lookFor <- "Raw Data"
    o$lockCorpBatchId <- FALSE
    o$replaceFakeCorpBatchId <- "Vehicle"
    o$stateGroups <- getStateGroups(formatSettings[[inputFormat]])
    o$hideAllData <- formatSettings[[inputFormat]]$hideAllData
    o$curveNames <- formatSettings[[inputFormat]]$curveNames
    o$annotationType <- formatSettings[[inputFormat]]$annotationType
    o$sigFigs <- formatSettings[[inputFormat]]$sigFigs
    o$splitSubjects <- formatSettings[[inputFormat]]$splitSubjects
    o$rowMeaning <- formatSettings[[inputFormat]]$rowMeaning
    if(is.null(rowMeaning)) {
      o$rowMeaning <- "subject"
    }
    o$includeTreatmentGroupData <- formatSettings[[inputFormat]]$includeTreatmentGroupData
    if (is.null(includeTreatmentGroupData)) {
      o$includeTreatmentGroupData <- TRUE
    }
  } else {
    # TODO: generate the list dynamically
    if(!(inputFormat %in% c("Generic", "Dose Response", "Gene ID Data", "Use Existing Experiment", "Precise For Existing Experiment"))) {
      stopUser("The Format must be 'Generic', 'Dose Response', or some custom format that you have been given.")
    }
    o$lookFor <- "Calculated Results"
    o$lockCorpBatchId <- TRUE
    o$replaceFakeCorpBatchId <- ""
    o$stateGroups <- NULL
    o$curveNames <- NULL
    o$sigFigs <- NULL
    o$annotationType <- "s_general"
    o$splitSubjects <- NULL
  }
  return(o)
}

getSubjectAndTreatmentData <- function (precise, genericDataFileDataFrame, calculatedResults, inputFormat, mainCode, formatParameters, errorEnv) {
  # turns Raw Results section into subjectData and treatmentGroupData data.frames
  # Returns a list of two data.frames
  
  subjectData <- NULL
  treatmentGroupData <- NULL
  intermedList <- list()
  if (precise) {
    subjectData <- getSection(genericDataFileDataFrame, lookFor = "Raw Results", transpose = FALSE)
    link <- calculatedResults[calculatedResults$linkColumn, c("rowID", "stringValue")]
    treatmentGroupData <- getSection(genericDataFileDataFrame, lookFor = "Treatment Group Results")
    if (treatmentGroupData[1, 1] == "Group By") {
      treatmentGroupData <- getSection(genericDataFileDataFrame, lookFor = "Treatment Group Results", transpose = TRUE)
      
      groupByColumns <- c(splitOnSemicolon(treatmentGroupData$"Group By"), "link")
      groupByColumnsNoUnit <- trim(gsub("\\(\\w*\\)", "", groupByColumns))
      keepColumn <- splitOnSemicolon(treatmentGroupData$Include)
      excludedRowKinds <- splitOnSemicolon(treatmentGroupData$"Remove Results With") # Removes results with a value for a certain valueKind
      
      # Other possibilities: average type (geometric or arithmetic), significant figures, SD vs SE, text rules... name of file to run...
      # Could create a new config setting for new function (use default here if not)
      
      
      #removeRowID <- subjectData$rowID[subjectData$valueKind %in% excludedRowKind] # If they were blank, they were not recorded
      #subjectDataKept$treatmentGroupID <- paste(subjectDataKept[groupByColumnsNoUnit], collapse = "-")
      #subjectDataKept <- as.data.table(subjectData)
      #subjectDataKept2 <- subjectDataKept[!(rowID %in% removeRowID), createTreatmentGroupData(.SD), by = groupByColumns]
      
      stateAssignments <- data.frame(valueKind = c("Dose", "Response", "flag"), stateType = c("data", "data", "data"), stateKind = c("test compound treatment", "results", "results"))
      
      intermedList <- organizeSubjectData(subjectData, groupByColumns, excludedRowKinds, inputFormat, mainCode, link, precise, stateAssignments = NULL, keepColumn=keepColumn, errorEnv=errorEnv, formatParameters =  formatParameters)
      subjectData <- intermedList$subjectData
      treatmentGroupData <- intermedList$treatmentGroupData
    }
  } else {
    # Grab the Raw Results Section
    subjectData <- getSection(genericDataFileDataFrame, lookFor = "Raw Results", transpose = FALSE)
    
    groupByColumns <- c(subjectData[2, 2], 'link')
    groupByColumnsNoUnit <- trim(gsub("\\(\\w*\\)", "", groupByColumns))
    
    keepColumn <- "Response"
    excludedRowKinds <- "flag"
    
    link <- calculatedResults[calculatedResults$valueKind == "curve id", c("rowID", "stringValue", "originalMainID")]
    if (!is.null(subjectData)) {
      
      if (!all(unlist(subjectData[1, 1:4]) == c("temp id", "x", "y", "flag"))) {
        stopUser("The first row in Raw Results must be 'temp id', 'x', 'y', 'flag'")
      }
      subjectData[1, 1:4] <- c("Datatype", "Number", "Number", "Comments")
      
      if (subjectData[2, 1] != "curve id") {
        stopUser("The second row in Raw Results must start with curve id")
      }
      subjectData[2, 1] <- "link"
      
      subjectData$Col5 <- ifelse(is.na(subjectData[[4]]), NA_character_, "on load")
      subjectData$Col5[1] <- "Text"
      subjectData$Col5[2] <- "flag"
      
      stateAssignments <- data.frame(
        valueKind = c("Dose", "Response", "flag"), 
        stateType = c("data", "data", "data"), 
        stateKind = c("test compound treatment", "results", "results"),
        stringsAsFactors = FALSE
      )
      
      # list(subjectData, treatmentGroupData)
      intermedList <- organizeSubjectData(
        subjectData, groupByColumns, excludedRowKinds, inputFormat, mainCode=NULL,
        link, precise, stateAssignments, keepColumn, errorEnv=errorEnv, 
        formatParameters = formatParameters)
    }
  }
  return(intermedList)
}
