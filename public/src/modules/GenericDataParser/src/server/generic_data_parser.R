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
# Figure out how to store values either in protocol or in a text file
# Information to store: lockcorpname, states to create, replaceFakeCorpBatchId
# Remove points with Exclude from treatment groups

# How to run: 
#   Before running: 
#     Set your working directory to the checkout of SeuratAddOns
#     setwd("~/Documents/clients/Wellspring/SeuratAddOns/")
#   To run:
#     parseGenericData(list(pathToGenericDataFormatExcelFile, dryRun = TRUE, ...))
#     Example: 
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/Mia-Paca.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/Mia-Paca.xls", dryRunMode = "true", testMode = "true"))
#       file.copy(from="public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve.xls", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_Curve.xls", dryRunMode = "true", testMode = "true"))
#       file.copy(from="~/Documents/clients/DNS/Neuro/Example upload 3_13_2013_testVersion.xlsx", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/Example upload 3_13_2013_testVersion.xlsx", dryRunMode = "true", testMode = "true"))
#       file.copy(from="~/Documents/clients/DNS/Neuro/EXP23102_rCFC_PDE2A_DNS001306266_dates.xlsx", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
#       parseGenericData(c(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/EXP23102_rCFC_PDE2A_DNS001306266_dates.xlsx", dryRunMode = "true", testMode = "true"))
# To use traceback() for debugging purposes:
#   runMain(pathToGenericDataFormatExcelFile,serverPath,dryRun,developmentMode,testOutputLocation)
#     runMain(pathToGenericDataFormatExcelFile="serverOnlyModules/blueimp-file-upload-node/public/files/Example upload 3_13_2013_version6.xlsx",serverPath,dryRun=TRUE,developmentMode=TRUE,configList=configList)
#     runMain(pathToGenericDataFormatExcelFile="serverOnlyModules/blueimp-file-upload-node/public/files/LindaExampleData.xls",serverPath="http://host3.labsynch.com:8080/labseer",dryRun=FALSE,developmentMode=TRUE,configList = list(serverName="http://localhost",portNumber="3000",serverAddress="host3.labsynch.com",driver="org.postgresql.Driver",driverLocation="public/src/modules/GenericDataParser/src/server/postgresql-9.1-901.jdbc3.jar",databaseLocation="jdbc:postgresql://",databasePort=":5432/compound",username="seurat",password="seurat",serverPath="http://host3.labsynch.com:8080/labseer/",preferredBatchIdService="http://localhost:3000/api/preferredBatchId"))
#     runMain(pathToGenericDataFormatExcelFile="serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_Curve.xls",serverPath="http://host3.labsynch.com:8080/labseer",dryRun=FALSE,developmentMode=TRUE,configList = list(serverName="http://localhost",portNumber="3000",serverAddress="host3.labsynch.com",driver="org.postgresql.Driver",driverLocation="public/src/modules/GenericDataParser/src/server/postgresql-9.1-901.jdbc3.jar",databaseLocation="jdbc:postgresql://",databasePort=":5432/compound",username="labseer",password="labseer",serverPath="http://host3.labsynch.com:8080/acas/",preferredBatchIdService="http://localhost:3000/api/preferredBatchId"))


# #configList <-list(serverName="http://localhost",portNumber="3000",serverAddress="host3.labsynch.com",driver="org.postgresql.Driver",
# driverLocation="public/src/modules/GenericDataParser/src/server/postgresql-9.1-901.jdbc3.jar",
# databaseLocation="jdbc:postgresql://",databasePort=":5432/compound",username="seurat",password="seurat",
# serverPath="http://host3.labsynch.com:8080/labseer/",preferredBatchIdService="http://localhost:3000/api/preferredBatchId")

# Other files:
# "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve.xls"
# "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve_Example2.xls"
# "public/src/modules/GenericDataParser/spec/specFiles/ExampleInputFormat_with_Curve2.xls"
# "public/src/modules/GenericDataParser/spec/specFiles/LindaExampleData.xls"


# Store in a text file: format information
#     lockCorpBatchId <- FALSE
#     lookFor <- "Raw Data"
#     replaceFakeCorpBatchId <- "Vehicle"
#     expectedDataFormat <- data.frame(
#       headers = c("Format","Protocol Name","Experiment Name","Scientist","Notebook","Assay Completion Date","Project"),
#       class = c("Text", "Text", "Text", "Text", "Text", "Date","Text"),
#       isNullable = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,FALSE)
#     A list of what to find from protocol
#
# Store in the protocol: data information
#         groupingColumns <- c("Corporate Batch ID","Dose (mg/kg)")
#         optionalGroupingColumns <- c("Condition")
#         subjectStateGroups <- list(list(stateType = "metadata", 
#                                         stateKind = "animal information", 
#                                         valueKinds = c("Species","Strain","Sex","Vendor","Date of Arrival", "Date of Birth", "Animal ID", "Cohort"),
#                                         includesOthers = FALSE,
#                                         includesCorpName = FALSE),
#                                    list(stateType = "data",
#                                         stateKind = "treatment",
#                                         valueKinds = c("Condition", "Dose", "Vehicle", "Administration route","Treatment time"),
#                                         includesOthers = FALSE,
#                                         includesCorpName = TRUE),
#                                    list(stateType = "data",
#                                         stateKind = "raw data",
#                                         includesOthers = TRUE,
#                                         includesCorpName = FALSE))

#########################################################################


# JSON scripts source
source("public/src/modules/serverAPI/src/server/labSynch_JSON_library.R")
source("public/src/modules/sharedFunctions.R")


#####
# Define Functions
getSection <- function(genericDataFileDataFrame, lookFor, transpose = FALSE) {
  # Retrieves a section of the generic excel file
  #
  # Args:
  #   genericDataFileDataFrame: A data frame of lines 
  #    lookFor: A string identifier to user as regext for the line before the start of the seciton
  #    transpose: a boolean to set if the data should be transposed
  # Returns:
  #   A dataframe of the of section in the generic excel file
  
  # Get the first line matching the section
  lookFor <- lookFor
  listMatch <- sapply(genericDataFileDataFrame,grep,pattern = lookFor,ignore.case = TRUE, perl = TRUE)
  firstInstanceInEachColumn <- suppressWarnings(unlist(lapply(listMatch, min)))
  startSection <- firstInstanceInEachColumn[is.finite(firstInstanceInEachColumn)][1]
  if(is.na(startSection) && lookFor =="Raw Results") {
    return(NULL)
  }
  if(is.na(startSection)) {
    stop("The spreadsheet appears to be missing an important section header. The loader needs '",lookFor,"' to be somewhere in the spreadsheet.",sep="")
  }
  
  if((startSection+2)>length(genericDataFileDataFrame[[1]])) {
    stop(paste0("There must be at least two rows filled in after '", lookFor, 
                "'. Either there is extra data that you need to fill in, or you may wish to remove '", 
                lookFor, "' entirely."))
  }
  
  # Get the indexes of columns in the section, using the longest of either of the first two rows
  sectionHeaderRow <- genericDataFileDataFrame[startSection + 1,]
  secondRow <- genericDataFileDataFrame[startSection + 2,]
  sectionHeaderColumns <- grep(pattern="\\S", sapply(sectionHeaderRow,as.character))
  secondHeaderColumns <- grep(pattern="\\S", sapply(secondRow,as.character))
  if (length(sectionHeaderColumns)==0 && length(secondHeaderColumns)==0) {
    stop(paste0("There must be at least two rows filled in after '", lookFor, "'."))
  }
  dataColumnIndexes <- 1:max(sectionHeaderColumns, secondHeaderColumns)
  
  # Get the last line matching the section
  sectionColumn <- genericDataFileDataFrame[,names(startSection)]
  sectionColumnSubset <- subset(sectionColumn, 1:length(sectionColumn) > startSection)
  sectionLength <- which(sectionColumnSubset %in% "")[1]
  if(is.na(sectionLength)) {
    sectionLength <- length(sectionColumnSubset) + 1
  }
  endSection <- startSection + sectionLength
  
  #Use the start and end variables to grab the data frame
  startSectionColumnNumber <- match(names(startSection),names(genericDataFileDataFrame))
  foundData <- subset(x = genericDataFileDataFrame, subset = 1:nrow(genericDataFileDataFrame) > startSection & 1:nrow(genericDataFileDataFrame) < endSection, select = dataColumnIndexes)
  
  # Transpose the data frame if option is set
  if(transpose == TRUE) {
    row.names(foundData) <- foundData[,1]
    foundData <- subset(foundData,select = 2:length(foundData))
    foundData <- as.data.frame(t(foundData))
  }
  
  return(foundData)
}
validateDate <- function(inputValue, expectedFormat = "%Y-%m-%d") {
  # Validates and/or coerces a given string to a specified date format
  #
  # Args:
  #   inputValue: A string representing a date 
  #  expectedFormat: A character string representing the desired date format. (see ?format.POSIXct)
  # Returns:
  #   A date coerced or maintained to be in the expectedFormat
  
  returnDate <- ""
  
  if (inputValue == "") {return (NA)}
  
  # Function to attempt to coerce the date into a given format
  coerceToDate <- function(format, inputValue) {
    # Coerces a string to a given format
    #
    # Args:
    #	format: A character string representing the desired date format. (see ?format.POSIXct)
    #	inputValue: A string representing a date
    # Returns:
    #	A coerced date object or an NA if unable to coerce properly
    return(as.Date(as.character(inputValue), format))
  }
  isInFormat <- function(format, inputValue) {
    # Coerces a string to a given format, and then evaluates whether it is reasonable or not
    #
    # Args:
    #	format: A character string representing the desired date format. (see ?format.POSIXct)
    #	inputValue: A string representing a date
    # Returns:
    #	A boolean as to whether the date is correctly coercible to the given format
    
    # Coerce the date
    coercedDate <- coerceToDate(format, inputValue)
    if(!is.na(coercedDate)) {
      # If the value was coerced then evaluate how many years into the future or in the paste it is
      numYearsFromToday <- as.numeric(format(coercedDate, "%Y")) - as.numeric(format(Sys.Date(), "%Y"))
      if(numYearsFromToday > -50 && numYearsFromToday < 1) {
        # If the date is less than 50 years in the paste or less than 1 year in the future, then it is somewhat reasonable
        return(TRUE)
      }
    }
    return(FALSE)
  }
  
  # Check if can be coerced to the expected format
  if(!isInFormat(expectedFormat, inputValue )) {
    #First try substituting out the seperators in the inputValue for those in the expected format
    expectedSeperator <- ifelse(grepl("-",expectedFormat),"-", "/")
    inputValueWExpectedSeperator <- gsub("-|/",expectedSeperator,inputValue)
    
    #Test again with new seperators
    if(!isInFormat(expectedFormat, inputValueWExpectedSeperator)) {
      #This means the value is still not in the expected format, now check for other common formats to see if any of them are reasonable
      commonFormats <- c("%Y-%m-%d","%y-%M-%d","%d-%m-%y","%m-%d-%y","%m-%d-%Y","%b-%d-%Y","%b-%d-%Y")
      formatsAbleToCoerce <- commonFormats[unlist(lapply(commonFormats,isInFormat, inputValue = inputValueWExpectedSeperator))]
      if(length(formatsAbleToCoerce) > 0) {
        # If any of the formats were coercible then we will attempt to pick the best one by getting the one value closest to today
        possibleDates <- do.call("c",lapply(formatsAbleToCoerce, coerceToDate, inputValueWExpectedSeperator))
        possibleDatesInExpectedFormat <- as.Date(format(possibleDates, expectedFormat))
        daysFromToday <- abs(as.Date(format(Sys.Date(), expectedFormat)) - possibleDates)
        minDaysFromToday <- min(daysFromToday)
        bestMatchingDate <- possibleDatesInExpectedFormat[daysFromToday == minDaysFromToday][1]
        
        # Add to the warnings that we coerced the date to a "Best Match" TODO: need to make xkcd open in a new tab
        warning(paste0("A date is not in the proper format. Found: \"",inputValue,"\" This was interpreted as \"",bestMatchingDate, 
                       "\". Please enter dates in the following format: \"", format(Sys.Date(), expectedFormat),
                       "\", or click  <a href=\"http://xkcd.com/1179/\">here</a>"))
        returnDate <- bestMatchingDate
      } else {
        # If we couldn't parse the data into any of the formats, then we add this to the erorrs and return no date
        errorList <<- c(errorList,paste0("The loader was unable to change the date '", inputValue, 
                                         "' to the proper format. Please change it to the following format: \"",
                                         format(Sys.Date(), expectedFormat),"\"",
                                         ," or click  <a href=\"http://xkcd.com/1179/\">here</a>"))
      }
    } else {
      # If the change in the seperators fixed the issue, then we add this to the warnings and return the coerced date
      warning(paste0("A date is not in the proper format. Found: \"",inputValue,"\" This was interpreted as \"",
                     inputValueWExpectedSeperator, 
                     "\". Please enter dates in the following format: \"", format(Sys.Date(), expectedFormat),"\""))
      returnDate <- inputValueWExpectedSeperator
    }
  } else {
    # If the date was coercible to the given format with no changes, then good, just return what they gave us as a date
    returnDate <- coerceToDate(expectedFormat, inputValue)
  }
  # Return the date
  return(returnDate)	
}
validateCharacter <- function(inputValue) {
  # Validates and/or coerces an input to a character format
  #
  # Args:
  #   inputValue: A string representing a character 
  #
  # Returns:
  #   A character string
  
  # Checks if the entry is NULL
  if (is.null(inputValue)) {
    errorList <<- c(errorList,paste("An entry was expected to be a set of characters but the entry was: NULL"))
    return (NULL)
  }
  
  
  #Checks if the input is similar enough as a character to be interpreted as one
  if (as.character(inputValue)!=inputValue) {
    # If it cannot be coerced to character, throw an error
    if (is.na(as.character(inputValue))) {
      errorList <<- c(errorList,paste("An entry was expected to be a set of characters but the entry was:", inputValue))
    }
    warning(paste("An entry was expected to be a set of characters but the entry was:", inputValue))
  }
  # Returns the input as a character
  return(as.character(inputValue))
}
validateNumeric <- function(inputValue) {
  # Validates and/or coerces an input to a numeric format
  #
  # Args:
  #   inputValue: A value representing a number
  #
  # Returns:
  #   A numeric value
  
  isCoercibleToNumeric <- !is.na(suppressWarnings(as.numeric(as.character(inputValue))))
  if(!isCoercibleToNumeric) {
    errorList <<- c(errorList,paste0("An entry was expected to be a number but was: '", inputValue, "'. Please enter a number instead."))
  }
  return(suppressWarnings(as.numeric(as.character(inputValue))))
}
validateMetaData <- function(metaData, configList) {
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
  
  # Check if extra data was picked up that should not be
  if (length(metaData[[1]])>1) {
    extraData <- c(as.character(metaData[[1]][2:length(metaData[[1]])]),
                   as.character(metaData[[2]][2:length(metaData[[2]])]))
    extraData <- extraData[extraData!=""]
    errorList <<- c(errorList, paste0("Extra data were found next to the Experiment Meta Data ",
                                      "and should be removed: '",
                                      paste(extraData, collapse="', '"), "'"))
    metaData <- metaData[1,]
  }
  
  if (is.null(metaData$Format)) {
    stop("A Format must be entered in the Experiment Meta Data.")
  }
  
  expectedDataFormat <- data.frame(
    headers = c("Format","Protocol Name","Experiment Name","Scientist","Notebook","Page","Assay Date"),
    class = c("Text", "Text", "Text", "Text", "Text", "Text", "Date"),
    isNullable = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE)
  )
  
  if (!is.null(configList$includeProject) && configList$includeProject == "TRUE") {
    expectedDataFormat <- rbind(expectedDataFormat, data.frame(headers = "Project", class= "Text", isNullable = FALSE))
  }
  if (!is.null(configList$includeInLifeNotebook) && configList$includeInLifeNotebook == "TRUE") {
    expectedDataFormat <- rbind(expectedDataFormat, data.frame(headers = "In Life Notebook", class = "Text", isNullable = TRUE))
  }
  
  # Extract the expected headers from the input variable
  expectedHeaders <- expectedDataFormat$headers
  
  # Validate that there are no missing required columns, add errors for any expected fields that are missing
  missingColumns <- expectedHeaders[is.na(match(toupper(expectedHeaders),toupper(names(metaData)))) 
                                    & !(expectedDataFormat$isNullable)]
  for(m in missingColumns) {
    errorList <<- c(errorList,paste("The loader could not find required Experiment Meta Data row:",m))
  }
  
  # Validate that the matched columns are of the same data type and non-nullable fields are not null
  # return modified metaData with results of the validation of each field
  matchedColumns <- metaData[,!is.na(match(toupper(names(metaData)), toupper(expectedHeaders)))]
  validatedMetaData <- metaData
  for(m in 1:length(matchedColumns)) {
    # Get the name of the column
    column <- names(matchedColumns)[m]
    
    # Find if it is Nullable
    nullable <- expectedDataFormat$isNullable[expectedDataFormat$headers == column]
    
    
    
    expectedDataType <- as.character(expectedDataFormat$class[expectedDataFormat$headers == column])
    receivedValue <- matchedColumns[1,m]
    
    if(!nullable && (is.null(receivedValue) | receivedValue==""  | receivedValue=="")) {
      errorList <<- c(errorList,paste0("The loader could not find an entry for '", column, "' in the Experiment Meta Data"))
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
  if (length(additionalColumns)>0) {
    if (length(additionalColumns)==1) {
      warning(paste0("The loader found an extra Experiment Meta Data row that will be ignored: '", 
                     additionalColumns, 
                     "'. Please remove this row."))
    } else {
      warning(paste0("The loader found extra Experiment Meta Data rows that will be ignored: '", 
                     paste(additionalColumns,collapse="' ,'"), 
                     "'. Please remove these rows."))
    }
  }
  
  metaDataNames <- names(metaData)
  if ("Assay Completion Date" %in% metaDataNames) {
    validatedMetaData$"Assay Date" <- validatedMetaData$"Assay Completion Date"
  }
  
  if (!is.null(metaData$Project)) {
    validatedMetaData$Project <- validateProject(validatedMetaData$Project, configList)
    
  }
  
  # Return the validated Meta Data
  return(validatedMetaData)
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
  textTempIds <- grep("\\S",calculatedResults$"Result Desc"[calculatedResults$"Result Type"==tempIdLabel],value=TRUE)
  
  # Get a list of the temporary id's in the calculated results
  tempIdList <- calculatedResults$"Result Value"[calculatedResults$"Result Type"==tempIdLabel]
  
  # Find if any of the temporoary id's for the treatment groups do not have a match in the list
  missingTempIds <- setdiff(treatmentGroupData[,tempIdLabel],tempIdList)
  missingTempIds <- missingTempIds[!is.na(missingTempIds)]
  
  # Report any errors
  if (length(textTempIds)>1) {
    errorList <<- c(errorList, paste0("In the Calculated Results section, there are ", tempIdLabel, "'s that have text: '", 
                                      paste(textTempIds, collapse="', '"), "'. Remove text from all temp id's."))
  } else if (length(textTempIds)>0) {
    errorList <<- c(errorList, paste0("In the Calculated Results section, there is a ", tempIdLabel, " that has text: '", 
                                      textTempIds, "'. Remove text from all temp id's."))
  } else if (length(missingTempIds)>1) {
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
validateCalculatedResults <- function(calculatedResults, preferredIdService, testMode = FALSE, replaceFakeCorpBatchId="") {
  # Valides the calculated results (for now, this only validates the Corporate Batch Ids)
  #
  # Args:
  #	  calculatedResuluts:	      A "data.frame" of the calculated results
  #   preferredIdService:       A string that is the web address of the preferred ID service
  #   testMode:                 A boolean
  #   replaceFakeCorpBatchId:   A string that is not a corp batch id, will be ignored by the batch check, and will be replaced by a column of the same name
  #
  # Returns:
  #   a "data.frame" of the validated calculated results
  
  # Get the current batch Ids
  batchesToCheck <- calculatedResults$originalCorporateBatchID != replaceFakeCorpBatchId
  batchIds <- unique(calculatedResults$"Corporate Batch ID"[batchesToCheck])
  newBatchIds <- getPreferredId(batchIds, preferredIdService, testMode)
  
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
validateCalculatedResultDatatypes <- function(classRow,LabelRow, lockCorpBatchId = TRUE) {
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
  
  # Check if the datatypes are entered correctly
  badClasses <- setdiff(classRow[1:length(classRow)>1],c("Text","Number","Date",""))
  
  # Let the user know about empty datatypes
  emptyClasses <- which(classRow=="" | classRow==" ")
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
    classRow[classRow==""] <- "Number"
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
      if (classRow[i] != oldClassRow[i]) {
        warning(paste0("In column \"", LabelRow[i], "\", the loader found '", oldClassRow[i], 
                       "' as a datatype and interpreted it as '", classRow[i], 
                       "'. Please enter 'Number','Text', or 'Date'."))
      }
    }
    
    # Those that can't be interpreted throw errors
    unhandledClasses <- setdiff(classRow[1:length(classRow)>1],c("Text","Number","Date",""))
    if (length(unhandledClasses)>0) {
      errorList <<- c(errorList,paste0("The loader found classes in the Datatype row that it does not understand: '",
                                       paste(unhandledClasses,collapse = "', '"),
                                       "'. Please enter 'Number','Text', or 'Date'."))
      
    }
  }
  
  # Return classRow
  return(classRow)
}
getPreferredId <- function(batchIds, preferredIdService, testMode=FALSE) {
  # Gets preferred Ids from a service
  #
  # Args:
  #   batchIds:	            A character vector of the batch Ids
  #   preferredIdService:   A string that is the web address of the preferred ID service
  #   testMode:             A boolean marking if the testMode should be used
  #
  # Returns:
  #   a list of pairs of requested IDs and preferred IDs
  #   on an error, returns NULL
  
  # Put the batchIds in the correct format
  requestIds <- list()
  if (testMode) {
    requestIds$testMode <- "true"
  }
  requestIds$requests = lapply(batchIds,function(input) {return(list(requestName=input))})
  
  
  # Get the preferred ids from the server
  response <- list(error=FALSE)
  tryCatch({
    response <- getURL(
      preferredIdService,
      customrequest='POST',
      httpheader=c('Content-Type'='application/json'),
      postfields=toJSON(requestIds))
  }, error = function(e) {
    errorList <<- c(errorList,paste("Error in contacting the preferred ID service:", e$message))
  })
  if (substring(response,1,1)!="{") {
    stop("Error in contacting the preferred ID service: ", response)
  } else {
    tryCatch({
      response <- fromJSON(response)
    }, error = function(e) {
      stop("The loader was unable to parse the response it got from the preferred ID service: ", response)
    })
  }
  
  # Error handling
  if (grepl("^Error:",response[1])) {
    errorList <<- c(errorList, paste("The preferred ID service is having a problem:", response))
    return(NULL)
  } else if (response$error) {
    errorList <<- c(errorList, paste("The preferred ID service is having a problem:", response$errorMessages))
  }
  
  # Return the useful part
  return(response$results)
}
getExcelColumnFromNumber <- function(number) {
  # Function to get an Excel-style column name from a column number
  # translated from php at http://stackoverflow.com/questions/3302857/algorithm-to-get-the-excel-like-column-name-of-a-number
  #
  #
  # Args:
  #    number:    A numeric of the column number
  #
  # Returns:
  #   An excel-style set of column names (i.e. "B" or "AR")
  
  if (number < 1) {
    warning(paste("An invalid column number was attempted to be turned into a letter:",number))
    return("none")
  }
  
  alphabet <-c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
               "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
  divisionResult <- floor((number-1)/26)
  remainder <- (number-1)%%26
  if (divisionResult > 0) {
    return(paste0(getExcelColumnFromNumber(divisionResult),alphabet[remainder+1]))
  } else {
    return(alphabet[remainder+1])
  }
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
  
  if (sum(is.na(resultTypesVector))!=0 || sum(resultTypesVector=="")!=0 || sum(resultTypesVector==" ")!=0) {
    stop("Some of the column labels in the 'Calculated Results' section are blank. Enter a label for each column.")
  }
  
  dataColumns <- c()
  for(col in 1:length(resultTypesVector)) {
    column <- as.character(resultTypesVector[[col]])
    if(!toupper(column) %in% toupper(ignoreHeaders)) {
      dataColumns <- c(dataColumns,column)
    }
  }
  returnDataFrame <- data.frame("DataColumn" = array(dim = length(dataColumns)), "Type" = array(dim = length(dataColumns)), "Units" = array(dim = length(dataColumns)), "Conc" = array(dim = length(dataColumns)), "ConcUnits" = array(dim = length(dataColumns)))
  returnDataFrame$DataColumn <- dataColumns
  returnDataFrame$Type <- trim(gsub("\\[[^)]*\\]","",gsub("\\([^)]*\\)","",dataColumns)))
  #TODO Will anyone ever want 'Reported' in the data columns? Probably not
  returnDataFrame$Type <- trim(gsub("Reported","",returnDataFrame$Type))
  returnDataFrame$Units <- gsub(".*\\((.*)\\).*||(.*)", "\\1",dataColumns) 
  concAndUnits <- gsub("^([^\\[]+)(\\[(.+)\\])?", "\\3", dataColumns) 
  returnDataFrame$Conc <- as.numeric(gsub("[^0-9]", "", concAndUnits))
  returnDataFrame$concUnits <- as.character(gsub("[^a-zA-Z]", "", concAndUnits))
  
  # Return the validated Meta Data
  return(returnDataFrame)
}
organizeCalculatedResults <- function(calculatedResults, lockCorpBatchId = TRUE, replaceFakeCorpBatchId = NULL, rawOnlyFormat = FALSE, stateGroups = NULL) {
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
  
  if(ncol(calculatedResults)==1) {
    stop("The rows below Calculated Results must have at least two columns filled: one for Corporate Batch ID's and one for data.")
  }
  
  # Check the Datatype row and get information from it
  hiddenColumns <- getHiddenColumns(as.character(unlist(calculatedResults[1,])))
  classRow <- validateCalculatedResultDatatypes(as.character(unlist(calculatedResults[1,])),as.character(unlist(calculatedResults[2,])),lockCorpBatchId)
  
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
  ignoreTheseAsResultTypes <- c("Corporate Batch ID","originalCorporateBatchID")
  
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
    replacementRows <- results$"Corporate Batch ID"==replaceFakeCorpBatchId
    results$"Corporate Batch ID"[replacementRows] <- as.character(results[replacementRows,replaceFakeCorpBatchId])
  }
  
  # Add a temporary analysisGroupID to keep track of how rows match up
  results$analysisGroupID <- seq(1,length(results[[1]]))
  
  #Temp for treatment groups
  # TODO: may need separate formats for each sheet, as Context fear has a Condition column that NOR does not
  if (rawOnlyFormat) {
    treatmentGrouping <- which(lapply(stateGroups, getElement, "stateKind") == "treatment")
    groupingColumns <- stateGroups[[treatmentGrouping]]$valueKinds
    groupingColumns <- groupingColumns[groupingColumns %in% names(results)]
    if(stateGroups[[treatmentGrouping]]$includesCorpName) {
      groupingColumns <- c(groupingColumns,"Corporate Batch ID")
    }
    
    results$treatmentGroupID <- do.call(paste,results[,groupingColumns])
    results$treatmentGroupID <- as.numeric(factor(results$treatmentGroupID))
  } else {
    results$treatmentGroupID <- NA
  }
  
  # Remove blank columns
  blankSpaces <- lapply(as.list(results),function(x) return (x != ""))
  emptyColumns <- unlist(lapply(blankSpaces, sum) == 0)
  resultTypes <- resultTypes[!(resultTypes$DataColumn %in% names(results)[emptyColumns]),]
  
  #Convert the results to long format
  longResults <- reshape(results, idvar=c("id"), ids=row.names(results), v.names="UnparsedValue",
                         times=resultTypes$DataColumn, timevar="resultTypeAndUnit",
                         varying=list(resultTypes$DataColumn), direction="long", drop = names(results)[emptyColumns])
  
  # Add the extract result types information to the long format
  longResults$"Result Units" <- resultTypes$Units[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
  longResults$"Conc" <- resultTypes$Conc[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
  longResults$"Conc Units" <- resultTypes$concUnits[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
  #longResults$"Result Units" <- resultTypes$Units[match(longResults$"Result Type",resultTypes$Type)]
  longResults$Class <- resultTypes$dataClass[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
  longResults$"Result Type" <- resultTypes$Type[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
  longResults$Hidden <- resultTypes$hidden[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
  
  # Parse numeric data from the unparsed values
  matchExpression <- "[0-9]+.[0-9]*|[0-9]*.[0-9]+|[0-9]+"
  matches <- gregexpr(matchExpression,longResults$"UnparsedValue")
  longResults$"Result Value" <- longResults$"UnparsedValue"
  regmatches(longResults$"Result Value",matches, invert = TRUE) <- ""
  
  # Parse string values from the unparsed values
  longResults$"Result Desc" <-  gsub(matchExpression,"",longResults$"UnparsedValue")
  
  # Parse Operators from the unparsed value
  matchExpression <- ">|<"
  longResults$"Result Operator" <- longResults$"UnparsedValue"
  matches <- gregexpr(matchExpression,longResults$"UnparsedValue")
  regmatches(longResults$"Result Operator",matches, invert = TRUE) <- ""
  
  # Turn result values to numeric values
  # Warnings are supressed because the dates give error values 
  suppressWarnings(longResults$"Result Value" <-  as.numeric(gsub(matchExpression,"",longResults$"Result Value")))
  
  # For the results marked as "Text":
  #   Set the Result Desc to the original value
  #   Clear the other categories
  longResults$"Result Desc"[which(longResults$Class=="Text")] <- as.character(longResults$UnparsedValue[which(longResults$Class=="Text")])
  longResults$"Result Value"[which(longResults$Class=="Text")] <- rep(NA, sum(longResults$Class=="Text"))
  longResults$"Result Operator"[which(longResults$Class=="Text")] <- rep(NA, sum(longResults$Class=="Text"))
  
  
  # For the results marked as "Date":
  #   Apply the function validateDate to each entry
  longResults$"Result Date" <- rep(NA, length(longResults$analysisGroupID))
  if (length(which(longResults$Class=="Date")) > 0) {
    longResults$"Result Date"[which(longResults$Class=="Date")] <- sapply(longResults$UnparsedValue[which(longResults$Class=="Date")], FUN=validateDate)
  }
  longResults$"Result Value"[which(longResults$Class=="Date")] <- rep(NA, sum(longResults$Class=="Date"))
  longResults$"Result Operator"[which(longResults$Class=="Date")] <- rep(NA, sum(longResults$Class=="Date"))
  longResults$"Result Desc"[which(longResults$Class=="Date")] <- rep(NA, sum(longResults$Class=="Date"))
  
  # Clean up the data frame to look nice (remove extra columns)
  row.names(longResults) <- 1:nrow(longResults)
  organizedData <- longResults[c("Corporate Batch ID","Result Type","Result Units","Conc","Conc Units","Result Value",
                                 "Result Desc","Result Operator","analysisGroupID","Result Date","Class",
                                 "resultTypeAndUnit","Hidden", "originalCorporateBatchID", "treatmentGroupID")]
  
  # Turn empty string into NA
  organizedData[organizedData==" " | organizedData=="" | is.na(organizedData)] <- NA
  
  # Remove rows
  organizedData <-organizedData[!(is.na(organizedData$"Result Value") 
                                  & is.na(organizedData$"Result Desc") 
                                  & is.na(organizedData$"Result Operator")
                                  & is.na(organizedData$"Result Date")),]
  
  # Order
  organizedData <- organizedData[do.call(order,organizedData[c("Corporate Batch ID","Result Type")]),]
  
  # Return the organized calculated results
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
  xLabel <- resultTypes$Type[match(xLabelWithUnit,resultTypes$DataColumn)]
  yLabel <- resultTypes$Type[match(yLabelWithUnit,resultTypes$DataColumn)]
  
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
  longTreatmentGroupResults$ResultType <- resultTypes$Type[match(longTreatmentGroupResults$"ResultType",resultTypes$DataColumn)]
  
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
getProtocolByName <- function(protocolName, configList, formFormat) {
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
  
  #TODO check for errors for fromJSON
  protocolList <- fromJSON(getURL(URLencode(paste0(configList$serverPath, "protocols/protocolname/", protocolName))))
  
  # If no protocol with the given name exists, warn the user
  if (length(protocolList)==0) {
    genericDataParserConfig <- readLines("public/src/modules/GenericDataParser/config/genericDataParserConfiguration.txt")
    protocolCreationSetting <- genericDataParserConfig[grepl("allowProtocolCreationWithFormats",genericDataParserConfig)]
    allowedCreationFormats <- gsub("(.*)allowProtocolCreationWithFormats: (.*)", "\\2", protocolCreationSetting)
    allowedCreationFormats <- unlist(strsplit(allowedCreationFormats, ","))
    if(all(allowedCreationFormats=="null")) allowedCreationFormats <- NULL
    if (formFormat %in% allowedCreationFormats) {
      warning(paste0("Protocol '", protocolName, "' does not exist, so it will be created. No user action is needed if you intend to create a new protocol."))
    } else {
      errorList <<- c(errorList, paste0("Protocol '", protocolName, "' does not exist. Please enter a protocol name that exists. Contact your system administrator if you would like to create a new protocol."))
    }
    # A flag for when the protocol will be created new
    protocol <- NA
  } else {
    # If the protocol does exist, get the full version
    protocol <- fromJSON(getURL(URLencode(paste0(configList$serverPath, "protocols/", protocolList[[1]]$id))))
  }
  return(protocol)
  
}
getExperimentByName <- function(experimentName, protocol, configList) {
  # Gets the experiment entered as an input, warns if it does exist, and throws an error if it is in the wrong protocol
  # 
  # Args:
  #   experimentName:   		  A string name of the experiment
  #   protocol:               A list that is a protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #   recordedBy:             A string that is the scientist name
  #
  # Returns:
  #  A list that is an experiment
  
  require('RCurl')
  require('rjson')
  
  tryCatch({
    a <- URLencode(paste0(configList$serverPath, "experiments/experimentname/", experimentName))
    save(a, file="test.Rda")
    experimentList <- fromJSON(getURL(URLencode(paste0(configList$serverPath, "experiments/experimentname/", experimentName))))
  }, error = function(e) {
    stop("There was an error checking if the experiment already exists. Please contact your system administrator.")
  })
  
  # If no experiment with the given name exists, warn the user
  if (length(experimentList)==0) {
    experiment <- NA
  } else {
    tryCatch({
      protocolOfExperiment <- fromJSON(getURL(URLencode(paste0(configList$serverPath, "protocols/", experimentList[[1]]$protocol$id))))
    }, error = function(e) {
      stop("There was an error checking if the experiment is in the correct protocol. Please contact your system administrator.")
    })
    
    #TODO choose the preferred label
    if(is.na(protocol) || protocolOfExperiment$protocolLabels[[1]]$id != protocol$protocolLabels[[1]]$id) {
      errorList <<- c(errorList,paste0("Experiment '",experimentName,
                                       "' does not exist in the protocol that you entered, but it does exist in '", protocolOfExperiment$protocolLabels[[1]]$labelText, 
                                       "'. Either change the experiment name or use the protocol in which this experiment currently exists."))
    }
    # If the experiment does exist, get it
    # TODO: put tryCatch block in case server is not set up for codename yet
    experiment <- experimentList[[1]]
    warning(paste0("Experiment '",experimentName,"' already exists, so the loader will delete its current data and replace it with your new upload.",
                   " If you do not intend to delete and reload data, enter a new experiment name."))
  }
  # Return the experiment
  return(experiment)
}
createNewProtocol <- function(metaData, lsTransaction) {
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
                                                                    recordedBy=metaData$Scientist[1], 
                                                                    labelType="name", 
                                                                    labelKind="protocol name",
                                                                    labelText=metaData$'Protocol Name'[1],
                                                                    preferred=TRUE)
  
  # Create the protocol
  protocol <- createProtocol(lsTransaction = lsTransaction,
                             shortDescription="protocol created by generic data parser",  
                             recordedBy=metaData$Scientist[1], 
                             protocolLabels=protocolLabels,
                             protocolStates=protocolStates)
  
  protocol <- saveProtocol(protocol)
}
createNewExperiment <- function(metaData, protocol, lsTransaction, pathToGenericDataFormatExcelFile) {
  # creates an experiment using the metaData
  # 
  # Args:
  #   metaData:               A data.frame including "Experiment Name", "Scientist", "Notebook", "Page", and "Assay Date"
  #   protocol:               A list that is a protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #
  # Returns:
  #  A list that is an experiment
  
  experimentStates <- list()
  
  # Store the metaData in experiment values
  experimentValues <- list()
  experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "stringValue",
                                                                     valueKind = "notebook",
                                                                     stringValue = metaData$Notebook[1])
  if (!is.null(metaData$Page)) {
    experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "stringValue",
                                                                       valueKind = "notebook page",
                                                                       stringValue = metaData$Page[1])
  }
  experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "dateValue",
                                                                     valueKind = "completion date",
                                                                     dateValue = as.numeric(format(as.Date(metaData$"Assay Date"[1]), "%s"))*1000)
  experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "stringValue",
                                                                     valueKind = "status",
                                                                     stringValue = "Approved")
  experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "stringValue",
                                                                     valueKind = "analysis status",
                                                                     stringValue = "running")
  experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "clobValue",
                                                                     valueKind = "analysis result html",
                                                                     clobValue = "<p>Analysis not yet completed</p>")
  
  if (!is.null(metaData$Project)) {
    # TODO: add to config:
    #   name of service
    #   type of service (which code to use)
    #   if project is required

    experimentValues[[length(experimentValues)+1]] <- createStateValue(valueType = "codeValue",
                                                                       valueKind = "project",
                                                                       codeValue = metaData$Project[1])
  }
  
  # Create an experiment state for metadata
  experimentStates[[length(experimentStates)+1]] <- createExperimentState(experimentValues=experimentValues,
                                                                          lsTransaction = lsTransaction, 
                                                                          recordedBy=metaData$Scientist[1], 
                                                                          stateType="metadata", 
                                                                          stateKind="experiment metadata")
  
  # Create a label for the experiment name
  experimentLabels <- list()
  experimentLabels[[length(experimentLabels)+1]] <- createExperimentLabel(lsTransaction = lsTransaction, 
                                                                          recordedBy=metaData$Scientist[1], 
                                                                          labelType="name", 
                                                                          labelKind="experiment name",
                                                                          labelText=metaData$"Experiment Name"[1],
                                                                          preferred=TRUE)
  # Create the experiment
  experiment <- createExperiment(lsTransaction = lsTransaction, 
                                 protocol = protocol,
                                 kind = "generic loader",
                                 shortDescription="experiment created by generic data parser",  
                                 recordedBy=metaData$Scientist[1], 
                                 experimentLabels=experimentLabels,
                                 experimentStates=experimentStates)
  
  # Save the experiment to the server
  experiment <- saveExperiment(experiment)
}
validateProject <- function(projectName, configList) {
  require('RCurl')
  require('rjson')
  projectList <- getURL(configList$projectService)
  tryCatch({
    projectList <- fromJSON(projectList)
  }, error = function(e) {
    errorList <<- c(errorList, paste("There was an error in validating your project:", projectList))
    return("")
  })
  projectCodes <- sapply(projectList, function(x) x$code)
  if(length(projectCodes) == 0) {errorList <<- c(errorList, "No projects are available, contact your system administrator")}
  if (projectName %in% projectCodes) {
    return(projectName)
  } else {
    errorList <<- c(errorList, paste0("The project you entered is not an available project. Please enter one of these projects: '",
                                      paste(projectCodes, collapse = "', '"), "'."))
    return("")
  }
}
uploadRawDataOnly <- function(metaData, lsTransaction, subjectData, serverPath, experiment, fileStartLocation, configList, stateGroups, reportFilePath) {
  # For use in uploading when the results go into subjects rather than analysis groups

  require('plyr')
  
  # TODO: will become an input, probably stored in protocol
  hideAllData <- TRUE
  
  
  #Change in naming convention
  names(subjectData)[names(subjectData) == "analysisGroupID"] <- "subjectID"
  
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
  
  recordedBy <- metaData$Scientist[1]
  
  serverFileLocation <- moveFileToExperimentFolder(fileStartLocation, experiment, recordedBy, lsTransaction, configList$fileServiceType, configList$externalFileService)
  if(!is.null(reportFilePath)) {
    reportFileLocation <- moveFileToExperimentFolder(reportFilePath, experiment, recordedBy, lsTransaction,configList$fileServiceType, configList$externalFileService)
  }
  
  # Analysis group
  analysisGroup <- createAnalysisGroup(experiment=experiment,lsTransaction=lsTransaction,recordedBy=recordedBy)
  
  savedAnalysisGroup <- saveAnalysisGroup(analysisGroup)
  
  # Treatment Groups
  treatmentGroups <- lapply(FUN= createTreatmentGroup, X= treatmentGroupCodeNameList,
                            recordedBy=recordedBy, lsTransaction=lsTransaction, analysisGroup=savedAnalysisGroup, 
                            subjects=NULL,treatmentGroupStates=NULL)
  
  savedTreatmentGroups <- saveAcasEntities(treatmentGroups, "treatmentgroups")
  
  treatmentGroupIds <- sapply(savedTreatmentGroups, getId)
  
  subjectData$treatmentGroupID <- treatmentGroupIds[match(subjectData$treatmentGroupID,1:length(treatmentGroupIds))]
  
  
  
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
  
  subjectIds <- sapply(savedSubjects, getId)
  
  subjectData$subjectID <- subjectIds[subjectData$subjectID]
  
  ### Subject States ===============================================
  #######  
  
  stateGroupIndex <- 1
  subjectData$stateGroupIndex <- NA
  for (state in stateGroups) {
    includedRows <- subjectData$"Result Type" %in% state$valueKinds
    newRows <- subjectData[includedRows & !is.na(subjectData$stateGroupIndex), ]
    subjectData$stateGroupIndex[includedRows & is.na(subjectData$stateGroupIndex)] <- stateGroupIndex
    if (nrow(newRows)>0) newRows$stateGroupIndex <- stateGroupIndex
    subjectData <- rbind.fill(subjectData,newRows)
    stateGroupIndex <- stateGroupIndex + 1
  }
  
  othersGroupIndex <- which(sapply(stateGroups, FUN=readElement, "includesOthers"))
  subjectData$stateGroupIndex[is.na(subjectData$stateGroupIndex)] <- othersGroupIndex
  
  subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex)

  stateAndVersion <- saveStatesFromLongFormat(subjectData, "subject", stateGroups, "stateID", recordedBy, lsTransaction)
  subjectData$stateID <- stateAndVersion$entityStateId
  subjectData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### Subject Values ======================================================================= 
  
  # Reorganization to match formats
  names(subjectData) <- c("batchCode","valueKind","valueUnit","Conc","Conc Units", "numericValue","stringValue",
                          "valueOperator","subjectID","dateValue","valueType", "resultTypeAndUnit","publicData", 
                          "originalBatchCode", "treatmentGroupID", "subjectCodeName", "stateGroupIndex", "stateID", "stateVersion")
  subjectData$publicData <- !subjectData$publicData
  subjectData$valueType <- c("numericValue","stringValue","dateValue")[match(subjectData$valueType,c("Number","Text","Date"))]
  
  batchCodeStateIndices <- which(sapply(stateGroups, function(x) return(x$includesCorpName)))
  if (is.null(subjectData$stateVersion)) subjectData$stateVersion <- 0
  subjectDataWithBatchCodeRows <- rbind.fill(subjectData, meltBatchCodes(subjectData, batchCodeStateIndices))
  
  subjectDataWithBatchCodeRows <<- subjectDataWithBatchCodeRows
  savedSubjectValues <- saveValuesFromLongFormat(subjectDataWithBatchCodeRows, "subject", stateGroups, lsTransaction)
  #
  #####  
  # Treatment Group states =========================================================================
  treatmentGroupIndex <- which(sapply(stateGroups, getElement, "stateKind") == "treatment")
  treatmentValueKinds <- stateGroups[[treatmentGroupIndex]]$valueKinds
  listedValueKinds <- do.call(c,lapply(stateGroups, getElement, "valueKinds"))
  otherValueKinds <- setdiff(unique(subjectData$valueKind),listedValueKinds)
  treatmentDataValueKinds <- c(treatmentValueKinds,otherValueKinds)
  excludedSubjects <- subjectData$subjectID[subjectData$valueKind == "Exclude"]
  treatmentDataStart <- subjectData[subjectData$valueKind %in% treatmentDataValueKinds 
                                    & !(subjectData$subjectID %in% excludedSubjects),]
  
  createRawOnlyTreatmentGroupData <- function(subjectData) {
    isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
    isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
    if(isGreaterThan && isLessThan) {
      resultOperator <- "<>"
      resultValue <- NA
    } else if (isGreaterThan) {
      resultOperator <- ">"
      resultValue <- max(subjectData$numericValue)
    } else if (isLessThan) {
      resultOperator <- "<"
      resultValue <- min(subjectData$numericValue)
    } else {
      resultOperator <- NA
      resultValue <- mean(subjectData$numericValue)
    }
    return(data.frame(
      "batchCode" = subjectData$batchCode[1],
      "valueKind" = subjectData$valueKind[1],
      "vaueUnit" = subjectData$valueUnit[1],
      "Conc" = subjectData$"Conc"[1],
      "Conc Units" = subjectData$"Conc Units"[1],
      "numericValue" = resultValue,
      "stringValue" = if (length(unique(subjectData$stringValue)) == 1) subjectData$stringValue[1] else NA,
      "valueOperator" = resultOperator,
      "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
      "publicData" = subjectData$publicData[1],
      treatmentGroupID = subjectData$treatmentGroupID[1],
      stateGroupIndex = subjectData$stateGroupIndex[1],
      stateID = subjectData$stateID[1],
      stateVersion = subjectData$stateVersion[1],
      valueType = subjectData$valueType[1],
      numberOfReplicates = nrow(subjectData),
      uncertaintyType = if(is.numeric(resultValue)) "standard deviation" else NA,
      uncertainty = sd(subjectData$numericValue),
      stringsAsFactors=FALSE))
  }
  
  treatmentGroupData <- ddply(.data = treatmentDataStart, .variables = c("treatmentGroupID", "resultTypeAndUnit"), .fun = createRawOnlyTreatmentGroupData)
  
  treatmentGroupIndices <- c(treatmentGroupIndex,othersGroupIndex)
  
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
                                                        lsTransaction = lsTransaction)
  
  #### Analysis Group States =====================================================================
  analysisGroupIndex <- which(sapply(stateGroups, FUN=readElement, "entityKind")=="analysis group")
  if (length(analysisGroupIndex > 0)) {
    analysisGroupData <- treatmentGroupDataWithBatchCodeRows
    analysisGroupData$analysisGroupID <- savedAnalysisGroup$id
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
                                                          lsTransaction = lsTransaction)
  }
  ### Container creation ==================================================================
  containerIndex <- which(sapply(stateGroups, FUN=readElement, "entityKind")=="container")
  if (length(containerIndex > 0)) {
    containerValueList <- stateGroups[[containerIndex]]$valueKinds
    containerData <- subjectData[subjectData$stateGroupIndex %in% containerIndex,]
    
    containerCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="material_container", 
                                                  labelTypeAndKind="id_codeName", 
                                                  numberOfLabels=length(unique(containerData$subjectID))),
                                    use.names=FALSE)
    
    containerData$containerCodeName <- containerCodeNameList[as.numeric(factor(containerData$subjectID))]
    
    # TODO: type and kind should be in a config somewhere
    createRawOnlyContainer <- function(containerData) {
      return(createContainer(
        containerType="material",
        containerKind="animal",
        codeName=containerData$containerCodeName[1],
        recordedBy=recordedBy,
        lsTransaction=lsTransaction))
    }
    
    containers <- dlply(.data= containerData, .variables= .(containerCodeName), .fun= createRawOnlyContainer)
    names(containers) <- NULL
    
    savedContainers <- saveAcasEntities(containers, "containers")
    
    containerIds <- sapply(savedContainers, getId)
    
    # Order is not maintained, but that is okay
    containerData$containerID <- containerIds[as.numeric(factor(containerData$subjectID))]
    
    
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
                                                     lsTransaction = lsTransaction)
    
    ### Itx Subject Container =========================================================
    
    createRawOnlyItxSubjectContainer <- function(containerData, recordedBy, lsTransaction) {
      createSubjectContainerInteraction(
        interactionType = "refers to",
        interactionKind = "test subject",
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
                       serverPath,protocol,experiment, fileStartLocation, configList) {
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
  
  # Gets the user name from the metaData
  recordedBy <- metaData$Scientist[1]
  
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
  
  serverFileLocation <- moveFileToExperimentFolder(fileStartLocation, experiment, recordedBy, lsTransaction, configList$fileServiceType, configList$externalFileService)
  
  # Each analysisGroupID creates an analysis group
  analysisGroups <- list()
  for (analysisGroupID in unique(calculatedResults$analysisGroupID)) {
    
    # Each row in the table calculatedResults creates a state
    analysisGroupStates <- list()
    for (concentration in unique(calculatedResults$Conc[analysisGroupID == calculatedResults$analysisGroupID])) {
      
      # Get the rows, but NA's are a special case
      if(is.na(concentration)) {
        selectedRows <- analysisGroupID == calculatedResults$analysisGroupID & is.na(calculatedResults$Conc)
      } else {
        selectedRows <- analysisGroupID == calculatedResults$analysisGroupID & concentration == calculatedResults$Conc
      }
      
      analysisGroupValues <- list()
      for (i in which(selectedRows)) {
        # Prepare the date value
        dateValue <- as.numeric(format(as.Date(calculatedResults$"Result Date"[i],origin="1970-01-01"), "%s"))*1000
        # The main value (whether it is a numeric, string, or date) creates one value    
        analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
          valueType = if (calculatedResults$"Result Type"[i]==tempIdLabel) {"stringValue"}
          else if (calculatedResults$"Class"[i]=="Text") {"stringValue"}  
          else if (calculatedResults$"Class"[i]=="Date") {"dateValue"}
          else {"numericValue"},
          valueKind = calculatedResults$"Result Type"[i],
          stringValue = if(calculatedResults$"Result Type"[i]==tempIdLabel) {
            paste0(calculatedResults$"Result Value"[i],"_",analysisGroupCodeNameList[[analysisGroupCodeNameNumber]][[1]])
          } else if (!is.na(calculatedResults$"Result Desc"[i])) {
            calculatedResults$"Result Desc"[i]
          } else {NULL},
          dateValue = if(is.na(dateValue)) {NULL} else {dateValue},
          valueOperator = if(is.na(calculatedResults$"Result Operator"[i])) {NULL} else {calculatedResults$"Result Operator"[i]},
          numericValue = if(is.na(calculatedResults$"Result Value"[i]) | calculatedResults$"Result Type"[i]==tempIdLabel) {NULL} 
          else {calculatedResults$"Result Value"[i]},
          valueUnit = if(is.na(calculatedResults$"Result Units"[i])) {NULL} else {calculatedResults$"Result Units"[i]},
          publicData = !calculatedResults$Hidden[i],
          lsTransaction = lsTransaction)
      }
      
      # Adds a value for the batchCode (Corporate Batch ID)
      analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
        valueType = "codeValue",
        valueKind = "batch code",
        codeValue = as.character(calculatedResults$"Corporate Batch ID"[analysisGroupID == calculatedResults$analysisGroupID][1]),
        publicData = !calculatedResults$Hidden[i],
        lsTransaction = lsTransaction)
      
      # Adds a value for the concentration if there is one
      if (!is.na(calculatedResults$Conc[i])) {
        analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
          valueType = "numericValue",
          valueKind = "tested concentration",
          valueUnit= if(is.na(calculatedResults$"Conc Units"[i])){NULL} else {calculatedResults$"Conc Units"[i]},
          numericValue = calculatedResults$"Conc"[i],
          publicData = !calculatedResults$Hidden[i],
          lsTransaction = lsTransaction)
      }
      # Creates the state
      analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
                                                                                        recordedBy=recordedBy,
                                                                                        stateType="data",
                                                                                        stateKind=metaData$Format[1],
                                                                                        analysisGroupValues=analysisGroupValues)
    }
    # Creates Treatment Groups based on rawResults
    treatmentGroupList <- list()
    
    if(!is.null(rawResults)) {
      # Gets the temp and batch Id's for the current analysis group
      tempID <- calculatedResults$"Result Value"[calculatedResults$analysisGroupID == analysisGroupID & calculatedResults$"Result Type" == tempIdLabel][1]
      batchID <- as.character(calculatedResults$"Corporate Batch ID"[calculatedResults$analysisGroupID == analysisGroupID][1])
      if (!is.na(tempID) & tempID!="") {
        for (group in unique(treatmentGroupData$treatmentBatch[treatmentGroupData[,tempIdLabel]==tempID])) {
          treatmentGroupStates <- list()
          treatmentGroupValues <- list()
          for (i in which(treatmentGroupData$treatmentBatch==group & treatmentGroupData$ResultType==yLabel)) {
            treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue( 
              valueType= "numericValue", #numericValue or stringValue
              valueKind= treatmentGroupData$ResultType[i], #the label
              numericValue= if(is.na(treatmentGroupData$value[i])) {NULL} else as.numeric(as.character(treatmentGroupData$value[i])),
              uncertainty= if(is.na(treatmentGroupData$sd[i])) {NULL} else treatmentGroupData$sd[i],
              uncertaintyType= "standard deviation",
              numberOfReplicates= treatmentGroupData$n[i],
              valueUnit= if(is.na(treatmentGroupData$"Result Units"[i])) {NULL} else {treatmentGroupData$"Result Units"[i]},
              lsTransaction= lsTransaction)
            
            treatmentGroupStates[[length(treatmentGroupStates)+1]] <- createTreatmentGroupState(
              treatmentGroupValues=treatmentGroupValues,
              recordedBy=recordedBy,
              stateType="data",
              stateKind="results",
              comments=NULL,
              lsTransaction=lsTransaction)
            
            treatmentGroupValues <- list()
          }
          
          for (i in which(treatmentGroupData$treatmentBatch==group & treatmentGroupData$ResultType==xLabel)) {
            treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue( 
              valueType= "numericValue", #numericValue or stringValue
              valueKind= treatmentGroupData$ResultType[i], #the label
              numericValue= if(is.na(treatmentGroupData$value[i])) {NULL} else as.numeric(as.character(treatmentGroupData$value[i])),
              valueUnit= if(is.na(treatmentGroupData$"Result Units"[i])) {NULL} else {treatmentGroupData$"Result Units"[i]},
              lsTransaction= lsTransaction)
            
            # Add a value for the batchCode
            treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue( 
              valueType= "codeValue",
              valueKind= "batch code",
              codeValue= batchID,
              lsTransaction= lsTransaction)
            
            treatmentGroupStates[[length(treatmentGroupStates)+1]] <- createTreatmentGroupState(
              treatmentGroupValues=treatmentGroupValues,
              recordedBy= recordedBy,
              stateType= "data",
              stateKind= "test compound treatment",
              lsTransaction= lsTransaction)
          }
          
          
          
          subjectList <- list()
          
          # xValue is the value of the data in the x column for that treatmentGroup
          xValue <- treatmentGroupData$value[treatmentGroupData$ResultType==xLabel & treatmentGroupData$treatmentBatch==group]
          for(pointID in unique(rawResults$pointID[rawResults$ResultType==xLabel 
                                                   & rawResults$value==as.numeric(xValue)
                                                   & rawResults[,tempIdLabel]==tempID])) {
            
            subjectStates <- list()
            subjectValues <- list()
            for (i in which(rawResults$pointID == pointID & rawResults$ResultType %in% c(yLabel,"flag"))) {
              subjectValues[[length(subjectValues)+1]] <- createStateValue(
                valueType = if(rawResults$ResultType[i]=="flag") {"stringValue"} else {"numericValue"},
                valueKind = rawResults$ResultType[i], #the label
                stringValue = if(rawResults$ResultType[i]=="flag" & !is.na(rawResults$value[i])) {rawResults$value[i]} else {NULL},
                numericValue=if(rawResults$ResultType[i]!="flag") {as.numeric(as.character(rawResults$value[i]))} else {NULL},
                valueUnit=if(is.na(rawResults$"Result Units"[i])) {NULL} else {rawResults$"Result Units"[i]},
                lsTransaction=lsTransaction)
            }
            
            subjectStates[[length(subjectStates)+1]] <- createSubjectState( 
              lsTransaction=lsTransaction, 
              recordedBy=recordedBy,
              stateType="data", 
              stateKind="results",
              subjectValues=subjectValues)
            
            subjectValues <- list()
            
            for (i in which(rawResults$pointID == pointID & rawResults$ResultType %in% c(xLabel))) {
              subjectValues[[length(subjectValues)+1]] <- createStateValue(
                valueType = "numericValue",
                valueKind = rawResults$ResultType[i], #the label
                numericValue=as.numeric(as.character(rawResults$value[i])),
                valueUnit=if(is.na(rawResults$"Result Units"[i])) {NULL} else {rawResults$"Result Units"[i]},
                lsTransaction=lsTransaction)
              
              # Add a value for the batchCode
              subjectValues[[length(subjectValues)+1]] <- createStateValue( 
                valueType="codeValue",
                valueKind="batch code",
                codeValue=batchID,
                lsTransaction=lsTransaction)
              
              subjectStates[[length(subjectStates)+1]] <- createSubjectState( 
                lsTransaction=lsTransaction, 
                recordedBy=recordedBy,
                stateType="data", 
                stateKind="test compound treatment",
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
    
    # Put it all together in Analysis Groups
    analysisGroups[[length(analysisGroups)+1]] <- createAnalysisGroup(
      codeName = analysisGroupCodeNameList[[analysisGroupCodeNameNumber]][[1]],
      kind=metaData$Format[1],
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
    response <- saveAnalysisGroups(analysisGroups)
    # Used during testing
    #cat(toJSON(saveAnalysisGroups(analysisGroups)))
  }
  return(NULL)
}
runMain <- function(pathToGenericDataFormatExcelFile, reportFilePath=NULL, serverPath,
                    lsTranscationComments=NULL, dryRun, developmentMode = FALSE, testOutputLocation="./JSONoutput.json",
                    configList, testMode = FALSE) {
  # This function runs all of the functions within the error handling
  # lsTransactionComments input is currently unused
  
  require('gdata')
  
  lsTranscationComments <- paste("Upload of", pathToGenericDataFormatExcelFile)
  
  # Validate Input Parameters
  if (is.na(pathToGenericDataFormatExcelFile)) {
    stop("Need Excel file path as input")
  }
  if (!file.exists(pathToGenericDataFormatExcelFile)) {
    stop("Cannot find input file")
  }
  
  if (grepl("\\.xlsx?$",pathToGenericDataFormatExcelFile)) {
    tryCatch({
      genericDataFileDataFrame <- read.xls(pathToGenericDataFormatExcelFile, header = FALSE, blank.lines.skip = FALSE)
    }, error = function(e) {
      stop("Cannot read input excel file")
    })
  } else if (grepl("\\.csv$",pathToGenericDataFormatExcelFile)){
    tryCatch({
      genericDataFileDataFrame <- read.csv(pathToGenericDataFormatExcelFile, header = FALSE)
    }, error = function(e) {
      stop("Cannot read input csv file")
    })
  } else {
    stop("The input file must have extension .xls, .xlsx, or .csv")
  }
  

  
  if (nrow(genericDataFileDataFrame) > 3500) {
    stop("The input excel is too long. Please limit your files to under 3500 lines.")
  }
  
  # Meta Data
  metaData <- getSection(genericDataFileDataFrame, lookFor = "Experiment Meta Data", transpose = TRUE)
  
  validatedMetaData <- validateMetaData(metaData, configList)
  
  inputFormat <- metaData$Format
  
  if ("stateGroupsScript" %in% names(configList)) {
    source(configList$stateGroupsScript)
    formatSettings <- getFormatSettings()
  } else {
    formatSettings <- list()
  }

  rawOnlyFormat <- inputFormat %in% names(formatSettings)
  if (rawOnlyFormat) {
    lookFor <- "Raw Data"
    lockCorpBatchId <- FALSE
    replaceFakeCorpBatchId <- "Vehicle"
    stateGroups <- getStateGroups(formatSettings[[inputFormat]])
  } else {
    lookFor <- "Calculated Results"
    lockCorpBatchId <- TRUE
    replaceFakeCorpBatchId <- ""
    stateGroups <- NULL
  }
  
  # Grab the Calculated Results Section
  calculatedResults <- getSection(genericDataFileDataFrame, lookFor = lookFor, transpose = FALSE)
  
  # Organize the Calculated Results
  calculatedResults <- organizeCalculatedResults(calculatedResults, lockCorpBatchId, replaceFakeCorpBatchId, rawOnlyFormat, stateGroups)
  
  # Validate the Calculated Results
  calculatedResults <- validateCalculatedResults(calculatedResults, preferredIdService=configList$preferredBatchIdService, 
                                                 testMode=testMode, replaceFakeCorpBatchId=replaceFakeCorpBatchId)
  
  # Grab the Raw Results Section
  rawResults <- getSection(genericDataFileDataFrame, "Raw Results", transpose = FALSE)
  
  # Organize the Raw Results into treatmentGroupData and subjectData 
  # and collect the names of the x, y, and temp labels
  subjectData <- NULL
  treatmentGroupData <- NULL
  tempIdLabel <- ""
  if(!is.null(rawResults)) {
    rawResults <- organizeRawResults(rawResults,calculatedResults)
    
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
    lsTransaction <- createLsTransaction(comments = lsTranscationComments)
  } else {
    lsTransaction <- NULL
  }
  
  # Get the protocol and experiment and, when not on a dry run, create them if they do not exist
  protocol <- getProtocolByName(protocolName = validatedMetaData$'Protocol Name'[1], configList, inputFormat)
  newProtocol <- is.na(protocol[[1]])
  
  if (!dryRun && newProtocol && errorFree) {
    protocol <- createNewProtocol(metaData = validatedMetaData, lsTransaction)
  }
  
  experiment <- getExperimentByName(experimentName = validatedMetaData$'Experiment Name'[1], protocol, configList)
  
  newExperiment <- class(experiment[[1]])!="list" && is.na(experiment[[1]])
  
  # If there are errors, do not allow an upload (yes, this is needed a second time)
  errorFree <- length(errorList)==0
  
  # Delete any old data under the same experiment name (delete and reload)
  if(!dryRun && !newExperiment && errorFree) {
    deleteExperiment(experiment)
  }
  
  if (!dryRun && errorFree) {
    experiment <- createNewExperiment(metaData = validatedMetaData, protocol, lsTransaction, pathToGenericDataFormatExcelFile)
    assign(x="experiment", value=experiment, envir=parent.frame())
  }
  
  # Upload the data if this is not a dry run
  if(!dryRun & errorFree) {
    if(rawOnlyFormat) {      
      uploadRawDataOnly(metaData = validatedMetaData, lsTransaction, subjectData = calculatedResults,
                        serverPath, experiment, fileStartLocation = pathToGenericDataFormatExcelFile, configList, stateGroups, reportFilePath)
    } else {
      uploadData(metaData = validatedMetaData,lsTransaction,calculatedResults,treatmentGroupData,rawResults = subjectData,
                 xLabel,yLabel,tempIdLabel,testOutputLocation,developmentMode,serverPath,protocol,experiment, 
                 fileStartLocation = pathToGenericDataFormatExcelFile, configList=configList)
    }
  }
  
  if (rawOnlyFormat) {
    summaryInfo <- list(
      format = inputFormat,
      lsTransactionId = lsTransaction$id,
      info = list(
        "Format" = as.character(validatedMetaData$Format),
        "Protocol" = as.character(validatedMetaData$"Protocol Name"),
        "Experiment" = as.character(validatedMetaData$"Experiment Name"),
        "Scientist" = as.character(validatedMetaData$Scientist),
        "Notebook" = as.character(validatedMetaData$Notebook),
        "Assay Date" = as.character(validatedMetaData$"Assay Date"),
        "Rows of Data" = max(calculatedResults$analysisGroupID),
        "Columns of Data" = length(unique(calculatedResults$resultTypeAndUnit)),
        "Unique Corporate Batch ID's" = length(unique(calculatedResults$"Corporate Batch ID"))
      )
    )
    if(!is.null(validatedMetaData$Page)) {
      summaryInfo$info$"Page" = as.character(validatedMetaData$Page)
    }
  } else {
    summaryInfo <- list(lsTransactionId=lsTransaction$id,
                        format=as.character(validatedMetaData$Format),
                        protocol=as.character(validatedMetaData$"Protocol Name"),
                        experiment=as.character(validatedMetaData$"Experiment Name"),
                        scientist=as.character(validatedMetaData$Scientist),
                        notebook=as.character(validatedMetaData$Notebook),
                        page=as.character(validatedMetaData$Page),
                        date=as.character(validatedMetaData$"Assay Date"),
                        newProtocol=newProtocol,
                        newExperiment=newExperiment,
                        calcDataRows=max(calculatedResults$analysisGroupID),
                        calcDataColumns=length(unique(calculatedResults$resultTypeAndUnit)),
                        calcCorpBatchID=length(unique(calculatedResults$"Corporate Batch ID")),
                        calcCurves=length(unique(calculatedResults$"Result Value"[calculatedResults$"Result Type"==tempIdLabel]))
    )
    if (!is.null(subjectData)) {
      summaryInfo$subjectPoints <- max(subjectData$pointID)
      summaryInfo$subjectFlags <- length(subjectData$value[subjectData$ResultType=="flag" & !is.na(subjectData$value)])
    }
  }
  summaryInfo$experimentEntity <- experiment
  
  return(summaryInfo)
}
createGenericDataParserHTML <- function(hasError,errorList,hasWarning,warningList,summaryInfo,dryRun) {
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
                               <p>Experiment Information:</p>
                               <ul>
                               <%=if(!is.null(summaryInfo$lsTransactionId)){paste('<li>Transaction id:', summaryInfo$lsTransactionId,'</li>')}%>
                               <li>Format: <%=summaryInfo$format%> </li>
                               <li><%=if(summaryInfo$newProtocol) {'New '}%> Protocol: <%=summaryInfo$protocol%></li>
                               <li><%=if(summaryInfo$newExperiment) {'New '}%> Experiment: <%=summaryInfo$experiment%></li>
                               <li>Scientist: <%=summaryInfo$scientist%> </li>
                               <li>Notebook: <%=summaryInfo$notebook%> </li>
                               <li>Page: <%=summaryInfo$page%> </li>
                               <li>Assay Date: <%=summaryInfo$date%> </li>
                               </ul>
                               <p>Calculated Results:</p>
                               <ul>
                               <li><%=summaryInfo$calcDataRows%> Row<%=if(summaryInfo$calcDataRows!=1){'s'}%> of Data</li>
                               <li><%=summaryInfo$calcDataColumns%> Data Column<%=if(summaryInfo$calcDataColumns!=1){'s'}%></li>
                               <li><%=summaryInfo$calcCorpBatchID%> Unique Corporate Batch ID<%=if(summaryInfo$calcCorpBatchID!=1){\"'s\"}%></li>")
  }
  
  # If there are Raw Results, add info about them to the brew
  if(!is.null(summaryInfo) && !is.null(summaryInfo$subjectPoints)) {
    htmlOutputFormat <- paste0(htmlOutputFormat,
                               "<li><%=summaryInfo$calcCurves%> Curve<%=if(summaryInfo$calcCurve!=1){'s'}%></li>
                               </ul>
                               <p>Raw Results:</p>
                               <ul>
                               <li><%=summaryInfo$subjectPoints%> Data Point<%=if(summaryInfo$subjectPoints!=1){'s'}%></li>
                               <li><%=summaryInfo$subjectFlags%> Flagged Data Point<%=if(summaryInfo$subjectFlags!=1){'s'}%></li>
                               </ul>")
  } else {
    htmlOutputFormat <- paste0(htmlOutputFormat,"</ul>")
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
                            "and upload a new version of the Excel file by using the 'Back' button at the bottom of this screen.</p>
                            <ul><li>", paste(warningList,collapse='</li><li>'), "</li></ul>")
  
  #brew(text=htmlOutputFormat,output="GenericDataParserTest.html")
  return(paste(capture.output(brew(text=htmlOutputFormat)),collapse="\n"))
  }
moveFileToExperimentFolder <- function(fileStartLocation, experiment, recordedBy, lsTransaction, fileServiceType, fileService) {
  # Creates a folder for the excel file that was parsed and puts the file there. Returns the new location.
  # 
  # Args:
  #   fileStartLocation:            A character vector of the original location of the file
  #   experimentCodeName:           A character vector of the experiment code name
  #
  # Returns:
  #  The new file location
  
  fileName <- basename(fileStartLocation)
  
  experimentCodeName <- experiment$codeName
  
  if (fileServiceType == "blueimp") {
    experimentFolderLocation <- file.path(dirname(fileStartLocation),"experiments")
    dir.create(experimentFolderLocation, showWarnings = FALSE)
    
    fullFolderLocation <- file.path(experimentFolderLocation, experimentCodeName)
    dir.create(fullFolderLocation, showWarnings = FALSE)
    
    # Move the file
    file.rename(from=fileStartLocation, to=file.path(fullFolderLocation, fileName))
    
    serverFileLocation <- file.path("experiments", experimentCodeName, fileName)
  } else if (fileServiceType == "DNS") {
    require("XML")
    
    response <- postForm(fileService,
                         FILE=fileUpload(filename = fileStartLocation),
                         CREATED_BY_LOGIN=recordedBy)
    parsedXML <- xmlParse(response)
    serverFileLocation <- xmlValue(xmlChildren(xmlChildren(parsedXML)$dnsFile)$corpFileName)
  } else {
    stop("Invalid file service")
  }

  locationState <- experiment$experimentStates[lapply(experiment$experimentStates,readElement,"stateKind")=="report locations"]
  
  # Record the location
  if (length(locationState)> 0) {
    locationState <- locationState[[1]]
    
    valueKinds <- lapply(locationState$experimentValues,readElement,"valueKind")
    
    valuesToDelete <- locationState$experimentValues[valueKinds %in% c("source location")]
    
    lapply(valuesToDelete, deleteExperimentValue)
  } else {
    locationState <- createExperimentState(
      recordedBy=recordedBy,
      experiment = experiment,
      stateType="metadata",
      stateKind="raw results locations",
      lsTransaction=lsTransaction)
    
    locationState <- saveExperimentState(locationState)
  }
  
  tryCatch({
    locationValue <- createStateValue(
      valueType = "stringValue",
      valueKind = "source file",
      fileValue = serverFileLocation,
      experimentState = locationState)
    
    saveExperimentValues(list(locationValue))
  }, error = function(e) {
    stop("Could not save the summary and result locations")
  })
  
  return(serverFileLocation)
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
  
  # Info (now in config file at SeuratAddOns/public/src/conf/configurationNode.js)
  #serverPath <- "http://host3.labsynch.com:8080/labseer"
  
  # This is used for outputting the JSON rather than sending it to the server
  developmentMode <- FALSE
  
  # Collect the information from the request
  request <- as.list(request)
  pathToGenericDataFormatExcelFile <- request$fileToParse
  dryRun <- request$dryRun
  testMode <- request$testMode
  reportFilePath <- request$reportFilePath
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  testMode <- interpretJSONBoolean(testMode)
  if(is.null(testMode)) {
    testMode <- FALSE
  }
  
  # Read the config file
  configList <- readConfigFile("public/src/conf/configurationNode.js")
  
  # Set the global for the library
  lsServerURL <<- configList$serverPath
  
  experiment <- NULL
  
  # Set up the error handling for non-fatal errors, and add it to the search path (almost like a global variable)
  errorHandlingBox <- list(errorList = list())
  attach(errorHandlingBox)
  # If there is a global defined by another R code, this will overwrite it
  errorList <<- list()
  
  # Run the function and save output (value), errors, and warnings
  loadResult <- tryCatch.W.E(runMain(pathToGenericDataFormatExcelFile,
                                     reportFilePath = reportFilePath,
                                     serverPath = configList$serverPath,
                                     dryRun = dryRun,
                                     developmentMode = developmentMode,
                                     configList=configList, 
                                     testMode=testMode))
  
  # If the output has class simpleError or is not a list, save it as an error
  if(class(loadResult$value)[1]=="simpleError") {
    errorList <- c(errorList,list(loadResult$value$message))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="SQLException")>0) {
    errorList <- c(errorList,list(paste0("There was an error in connecting to the SQL server ", 
                                         configList$databaseLocation,configList$serverAddress,configList$databasePort, ":", 
                                         as.character(loadResult$value), ". Please contact your system administrator.")))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="error")>0 || class(loadResult$value)!="list") {
    errorList <- c(errorList,list(as.character(loadResult$value)))
    loadResult$value <- NULL
  }
  
  # Save warning messages but not the function call, which is only useful while programming
  loadResult$warningList <- lapply(loadResult$warningList,getWarningMessage)
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
  if (!is.null(loadResult$value$info)) {
    htmlSummary <- createHTML(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value,dryRun)
  } else {
    htmlSummary <- createGenericDataParserHTML(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value,dryRun)
  }
  
  
  # Detach the box for error handling
  detach(errorHandlingBox)
  
  if(!dryRun) {
    htmlSummary <- saveAnalysisResults(experiment=experiment, hasError, htmlSummary)
  }
  
  # Return the output structure
  response <- list(
    commit= (!dryRun & !hasError),
    transactionId = loadResult$value$lsTransactionId,
    results= list(
      path= getwd(),
      fileToParse= pathToGenericDataFormatExcelFile,
      dryRun= dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}