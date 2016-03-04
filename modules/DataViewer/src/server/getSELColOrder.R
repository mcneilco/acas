## getSELColOrder.R

#.libPaths('/opt/acas_homes/acas-t/acas/r_libs')
#options(java.parameters = "-Xmx1536m" )
options(scipen=99)
require('RCurl')
require('rjson')
require('data.table')
require('racas')
require('gdata')


myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.getSELColOrder",
                         logFileName = 'geneData.log',
                         logLevel = "DEBUG", logToConsole = FALSE)

myMessenger$logger$debug("get getSELColOrder data initiated")


############ FUNCTIONS from Generic Data Parser -- name spaced away by _DV #########################


getExcelColumnFromNumber_DV <- function(number) {
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
      return(paste0(getExcelColumnFromNumber_DV(divisionResult),LETTERS[remainder+1]))
    } else {
      return(LETTERS[remainder+1])
    }
  }))
}

getHiddenColumns_DV <- function(classRow, errorEnv) {
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
      addError(paste0("In Datatype column ",getExcelColumnFromNumber_DV(unknownColumns),", there is an entry in the parentheses that cannot be understood: '", 
                                       dataShown[unknownColumns],
                                       "'. Please enter 'shown' or 'hidden'."), errorEnv)
    } else {
      addError(paste0("In Datatype columns ",paste0(sapply(unknownColumns,getExcelColumnFromNumber_DV),collapse = ", "), 
                                       ", there are unknown entries in the parentheses that cannot be understood: '", 
                                       paste0(dataShown[unknownColumns], collapse="', '"),
                                       "'. Please enter 'shown' or 'hidden'."), errorEnv)
    }
  }
  return(hiddenColumns)
}

getLinkColumns_DV <- function(classRow, errorEnv) {
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
      addError(paste0("In Datatype column ", getExcelColumnFromNumber_DV(unknownColumns),
                      ", there is an entry in the brackets that cannot be understood: '", 
                      dataShown[unknownColumns],
                      "'. Please enter 'link' or nothing."), errorEnv)
    } else {
      addError(paste0("In Datatype columns ", paste0(sapply(unknownColumns,getExcelColumnFromNumber_DV),collapse = ", "), 
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

getHiddenColumns_DV <- function(classRow, errorEnv) {
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
      addError(paste0("In Datatype column ",getExcelColumnFromNumber_DV(unknownColumns),", there is an entry in the parentheses that cannot be understood: '", 
                                       dataShown[unknownColumns],
                                       "'. Please enter 'shown' or 'hidden'."), errorEnv)
    } else {
      addError(paste0("In Datatype columns ",paste0(sapply(unknownColumns,getExcelColumnFromNumber_DV),collapse = ", "), 
                                       ", there are unknown entries in the parentheses that cannot be understood: '", 
                                       paste0(dataShown[unknownColumns], collapse="', '"),
                                       "'. Please enter 'shown' or 'hidden'."), errorEnv)
    }
  }
  return(hiddenColumns)
}
getLinkColumns_DV <- function(classRow, errorEnv) {
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
      addError(paste0("In Datatype column ", getExcelColumnFromNumber_DV(unknownColumns),
                      ", there is an entry in the brackets that cannot be understood: '", 
                      dataShown[unknownColumns],
                      "'. Please enter 'link' or nothing."), errorEnv)
    } else {
      addError(paste0("In Datatype columns ", paste0(sapply(unknownColumns,getExcelColumnFromNumber_DV),collapse = ", "), 
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

validateCalculatedResultDatatypes_DV <- function(classRow, LabelRow, lockCorpBatchId = TRUE, clobColumns=c(), errorEnv = NULL) {
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
      warnUser(paste0("Column ", getExcelColumnFromNumber_DV(emptyClasses), " (" , LabelRow[emptyClasses], ") does not have a Datatype entered. ",
                     "The loader will attempt to interpret entries in column ", 
                     getExcelColumnFromNumber_DV(emptyClasses), 
                     " as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', 'Image File', or 'Comments'."))
    } else {
      warnUser(paste("Columns", 
                    paste(sapply(emptyClasses[1:length(emptyClasses)-1],getExcelColumnFromNumber_DV),collapse=", "), 
                    "and", getExcelColumnFromNumber_DV(tail(emptyClasses,n=1)), 
                    "do not have a Datatype entered.",
                    "The loader will attempt to interpret entries in columns",
                    paste(sapply(emptyClasses[1:length(emptyClasses)-1],getExcelColumnFromNumber_DV),collapse=", "), 
                    "and", getExcelColumnFromNumber_DV(tail(emptyClasses,n=1)),
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

extractValueKinds_DV <- function(valueKindsVector, ignoreHeaders = NULL, uncertaintyType, uncertaintyCodeWord, commentCol, commentCodeWord) {
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
    stopUser(paste0("Column ", paste(getExcelColumnFromNumber_DV(which(emptyValueKinds)), collapse=", "), " has a blank column header. ",
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

translateClassToValueType_DV <- function(x, reverse = F) {
  # translates Excel style Number formats to ACAS valueTypes (or reverse)
  valueTypeVector <- c("numericValue", "stringValue", "fileValue", "inlineFileValue", "urlValue", "dateValue", "clobValue", "blobValue", "codeValue")
  classVector <- c("Number", "Text", "File", "Image File","URL", "Date", "Clob", "Blob", "Code")
  if (reverse) {
    return(classVector[match(x, valueTypeVector)])
  } else {
    return(valueTypeVector[match(x, classVector)])
  }
}

createStateValue_DV <- function (lsType = "lsType", lsKind = "lsKind", stringValue = NULL, 
    fileValue = NULL, urlValue = NULL, publicData = TRUE, ignored = FALSE, 
    dateValue = NULL, clobValue = NULL, blobValue = NULL, valueOperator = NULL, 
    operatorType = NULL, numericValue = NULL, sigFigs = NULL, 
    uncertainty = NULL, uncertaintyType = NULL, numberOfReplicates = NULL, 
    valueUnit = NULL, unitType = NULL, comments = NULL, lsTransaction = NULL, 
    codeValue = NULL, recordedBy = "username", lsState = NULL, 
    testMode = FALSE, recordedDate = as.numeric(format(Sys.time(),
    "%s")) * 1000, codeType = NULL, codeKind = NULL, codeOrigin = NULL) 
{
    stateValue = list(lsState = lsState, lsType = lsType, lsKind = lsKind, 
        stringValue = stringValue, fileValue = fileValue, urlValue = urlValue, 
        dateValue = dateValue, clobValue = clobValue, blobValue = blobValue, 
        operatorKind = valueOperator, operatorType = if (is.null(valueOperator)) NULL else "comparison", 
        numericValue = numericValue, sigFigs = sigFigs, uncertainty = uncertainty, 
        uncertaintyType = uncertaintyType, numberOfReplicates = numberOfReplicates, 
        unitKind = valueUnit, comments = comments, ignored = ignored, 
        publicData = publicData, codeValue = codeValue, codeOrigin = codeOrigin, 
        codeType = codeType, codeKind = codeKind, recordedBy = recordedBy, 
        recordedDate = if (testMode) 1376954591000 else recordedDate, 
        lsTransaction = lsTransaction)
    return(stateValue)
}

createExperimentState_DV <- function (experimentValues = NULL, recordedBy = "userName", lsType = "lsType", 
    lsKind = "lsKind", comments = "", lsTransaction = NULL, experiment = NULL, 
    testMode = FALSE) 
{
    experimentState = list(experiment = experiment, lsValues = experimentValues, 
        recordedBy = recordedBy, lsType = lsType, lsKind = lsKind, 
        comments = comments, lsTransaction = lsTransaction, ignored = FALSE, 
        recordedDate = if (testMode) 1376954591000 else as.numeric(format(Sys.time(), "%s")) * 1000)
    return(experimentState)
}

removeEmptyValues_DV <- function(values) {
  # The functions that make values will make an entry for every possible value, even if DNET
  # didn't contain any data for that field
  #
  # Input: values, a list of values for a single state
  # Returns: a list of the same structure, but with elements removed if they contain no data
  
  values <- lapply(values, nullifyIfNoData_DV)
  values[sapply(values, is.null)] <- NULL
  
  return(values)
}

nullifyIfNoData_DV <- function(value) {
  # A helper function for removeEmptyValues_DV
  # Input: a single value object (which is a list)
  # Returns: the value if it stores data, or NULL otherwise
  
  if(!(value$lsType %in% c("stringValue", "dateValue", "clobValue", "numericValue", "codeValue"))) {
    stop(paste("Please modify nullifyIfNoData_DV to accept", value$lsType))
  }
  
  #If there is no data recorded, set to NULL (the "" is for the notebook field)
  if ((is.null(value$dateValue) || is.na(value$dateValue)) &&
        (is.null(value$clobValue) || is.na(value$clobValue)) &&
        (is.null(value$codeValue) || is.na(value$codeValue)) &&
        (is.null(value$numericValue) || is.na(value$numericValue)) &&
        (is.null(value$stringValue) || is.na(value$stringValue) || value$stringValue == "")) {
    value <- NULL
  }
  
  return(value)
}

############ END OF COPIED FUNCTIONS ##################





#experimentCode <- "EXPT-00000003"
getExperimentColumns <- function(experimentCode){
	## saved to server.service.persistence.filePath
	filePath <- racas::applicationSettings$server.service.persistence.filePath

	## get source file name
	sourceFileValueJSON <- getURL(
	paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/", experimentCode, "/exptvalues/bystate/metadata/raw%20results%20locations/byvalue/fileValue/source%20file/json"),
	  customrequest='GET',
	  httpheader=c('Content-Type'='application/json'))

	errorFileFlag <- FALSE
	fileFound <- FALSE

	
	if (length(fromJSON(sourceFileValueJSON)) > 0){
		fileName <- fromJSON(sourceFileValueJSON)[[1]]$fileValue
        if (grepl("DNS", racas::applicationSettings$server.service.external.file.service.url)) {
				dnsFileFinfo <- getURL(
					paste0(racas::applicationSettings$server.service.external.file.service.url, fileName, "/metadata.json"),
					  customrequest='GET',
					  httpheader=c('Content-Type'='application/json'))
				sampleDataFile <- fromJSON(dnsFileFinfo)[[1]]$dnsFile$name	

            f = CFILE(sampleDataFile, mode="wb")
            curlPerform(url = paste0(racas::applicationSettings$server.service.external.file.service.url, fileName), writedata = f@ref)
            close(f)
        } else {
		      sampleDataFile <- paste0(filePath, "/", fileName)
        }

		if (file.exists(sampleDataFile)){
			fileFound <- TRUE
			#print(paste0("found the file: ", sampleDataFile))
		} else {
			if (file.exists(paste0(sampleDataFile, 'x'))){
			   #print(paste0("found the file: ", sampleDataFile, 'x'))
			   sampleDataFile <- paste0(sampleDataFile, 'x')
				fileFound <- TRUE
			} else {
				fileNameSplit <- strsplit(fileName, '/')[[1]]
				rootFileName <- fileNameSplit[length(fileNameSplit)]
				if (file.exists(paste0(filePath, '/', rootFileName))){
			   	#print(paste0("found the file: ", rootFileName))
					sampleDataFile <- paste0(filePath, '/', rootFileName)
					fileFound <- TRUE
				} else {
					if (file.exists(paste0(filePath, '/', rootFileName, 'x'))){
			   		#print(paste0("found the file: ", filePath, '/', rootFileName, 'x'))
						sampleDataFile <- paste0(filePath, '/', rootFileName, 'x')
						fileFound <- TRUE
					} 
				} 
			}
		} 
					
		if (fileFound){
		  sheet <- 1 
	  	  header <- FALSE
		  numberOfRows <- 250
		  csvFile <- FALSE

		tryCatch({

			if(grepl(".csv", sampleDataFile)){
				genericDataFileDataFrame <- read.csv(sampleDataFile, header=FALSE, sep=",", stringsAsFactors = FALSE, nrows = numberOfRows )
				csvFile <- TRUE
			} else {
				#wb <- XLConnect::loadWorkbook(sampleDataFile)
				#genericDataFileDataFrame <- XLConnect::readWorksheet(wb, sheet = sheet, header = header, endRow=numberOfRows, dateTimeFormat="%Y-%m-%d")
				genericDataFileDataFrame <- readExcelOrCsv(sampleDataFile)
			}

		   if (grepl("DNS", racas::applicationSettings$server.service.external.file.service.url)) {
		          file.remove(sampleDataFile)
		   }

		  },
		    warning = function(w) {
		    warningFlag <- TRUE
		  },
		    error = function(ex) {
		    errorFileFlag <- TRUE
		  }
		)
			
		} else {
			errorFileFlag <- TRUE
		}
		
	} 
	
	if (!errorFileFlag){
		# Grab the Calculated Results Section
		calculatedResults <- racas::getSection(genericDataFileDataFrame, lookFor = "Calculated Results", transpose = FALSE)
		errorEnv <- globalenv()

		genericDataFileDataFrame$index <- seq(1:nrow(genericDataFileDataFrame))
		if (csvFile){
			inputFormatRow <- subset(genericDataFileDataFrame, V1 == 'Format', index)$index
			inputFormat <- genericDataFileDataFrame$V2[inputFormatRow]

		} else {
			inputFormatRow <- subset(genericDataFileDataFrame, Col1 == 'Format', index)$index
			inputFormat <- genericDataFileDataFrame$Col2[inputFormatRow]
		}
		
		if (inputFormat %in% c("Gene ID Data", "Generic", "Dose Response")) {
    		mainCode <- calculatedResults[2, 1] #Getting this from its standard position
  		} else {
    		mainCode <- "Corporate Batch ID"
  		}

		link <- NULL

		# Check the Datatype row and get information from it
		hiddenColumns <- getHiddenColumns_DV(as.character(unlist(calculatedResults[1,])), errorEnv)
		linkColumns <- getLinkColumns_DV(as.character(unlist(calculatedResults[1,])), errorEnv)
		clobColumns <- vapply(calculatedResults, function(x) any(nchar(as.character(x)) > 255), c(TRUE))

		lockCorpBatchId <- TRUE
		labelRow <- as.character(unlist(calculatedResults[2, ]))
		classRow <- validateCalculatedResultDatatypes_DV(as.character(unlist(calculatedResults[1,])), labelRow, lockCorpBatchId, clobColumns, errorEnv)

		# Remove Datatype Row
		calculatedResults <- calculatedResults[1:nrow(calculatedResults) > 1, ]

		# Get the line containing the value kinds
		calculatedResultsValueKindRow <- calculatedResults[1:nrow(calculatedResults) == 1, ]
  
		# Mark standard deviation columns (designed to allow standard error as well in future)
		uncertaintyType <- rep(NA, length(classRow))
		uncertaintyType[tolower(classRow) == "standard deviation"] <- tolower(classRow)[tolower(classRow) == "standard deviation"]

		# Mark Comment columns
		commentCol <- tolower(classRow) == "comments"

		# These columns are not result types and should not be pivoted into long format
		ignoreTheseAsValueKinds <- c(mainCode, "originalMainID")
		if (!is.null(link)) {
		  ignoreTheseAsValueKinds <- c(ignoreTheseAsValueKinds, "link")
		}

		# Call the function that extracts valueKinds, units, conc, concunits from the headers
		valueKinds <- extractValueKinds_DV(calculatedResultsValueKindRow, ignoreTheseAsValueKinds, uncertaintyType, uncertaintyCodeWord, commentCol, commentCodeWord)

	    # Add data class and hidden/shown to the valueKinds
	    if (!is.null(mainCode)) {
	      notMainCode <- (calculatedResultsValueKindRow != mainCode) & 
	        (is.null(link) | (calculatedResultsValueKindRow != "link"))
	    } else {
	      notMainCode <- (is.null(link) | (calculatedResultsValueKindRow != "link"))
	    }
	    valueKinds$dataClass <- classRow[notMainCode]
	    valueKinds$valueType <- translateClassToValueType_DV(valueKinds$dataClass)
	    hideColumn <- hiddenColumns[2:length(hiddenColumns)]
	    valueKinds <- cbind(valueKinds, hideColumn)
	    valueKinds$order <- seq(1:nrow(valueKinds))
	    valueKinds <- valueKinds[ order(valueKinds$order), ]

	} else {
		valueKinds <- ""
	}

	return(valueKinds)
}



generateExperimentValues <- function(dataRow, recordedBy, lsTransaction){
	values <- list()
	values[[1]] <- createStateValue_DV(lsType = "numericValue",
                                  lsKind = "column order",
                                  lsTransaction = lsTransaction,
                                  recordedBy = recordedBy,
                                  numericValue = dataRow$order
    )
	values[[2]] <- createStateValue_DV(lsType = "stringValue",
                                  lsKind = "column name",
                                  lsTransaction = lsTransaction,
                                  recordedBy = recordedBy,
                                  stringValue = dataRow$valueKind
    )
	values[[3]] <- createStateValue_DV(lsType = "stringValue",
                                  lsKind = "column units",
                                  lsTransaction = lsTransaction,
                                  recordedBy = recordedBy,
                                  stringValue = as.character(dataRow$Units)
    )
	values[[4]] <- createStateValue_DV(lsType = "stringValue",
                                  lsKind = "column type",
                                  lsTransaction = lsTransaction,
                                  recordedBy = recordedBy,
                                  stringValue = dataRow$valueType
    )
	values[[5]] <- createStateValue_DV(lsType = "stringValue",
                                  lsKind = "hide column",
                                  lsTransaction = lsTransaction,
                                  recordedBy = recordedBy,
                                  stringValue = as.character(dataRow$hideColumn)
    )
	return(removeEmptyValues_DV(values))
}



saveExptDataColOrder <- function(codeName){
	resultFlag <- TRUE
	exptDataColumns <- getExperimentColumns(codeName)
	if ((class(exptDataColumns) == 'data.frame') && (nrow(exptDataColumns) > 0)){
		experiment <- getEntityByCodeName(codeName, entityKind="experiments",include="prettyjsonstub")

		## create new experiment state to store the column order information (we will have state tuples for each order)
		lsTransaction <- experiment$lsTransaction
		recordedBy <- experiment$recordedBy
		experimentStates <- list() 
		for (i in 1:nrow(exptDataColumns)){
		  experimentStates[[i]] <- createExperimentState_DV(experimentValues = generateExperimentValues(dataRow=exptDataColumns[i,],	
		                                                                                             recordedBy = recordedBy,
		                                                                                             lsTransaction = lsTransaction
		  ),
		  recordedBy = recordedBy,
		  lsType = "metadata",
		  lsKind = "data column order",
		  comments = "",
		  lsTransaction = lsTransaction,
		  experiment = experiment
		  )
		}
		tryCatch({
		  results <- saveAcasEntitiesInternal(entities=experimentStates, acasCategory="experimentstates")},
		  error = function(ex) {
		  resultFlag <<- FALSE
		})
		
		
	} else {
		resultFlag <- FALSE
	}
	
	return(resultFlag)
}


pivotColOrderData <- function(lsKind, stringValue, numericValue){
	inputDT <- data.table(lsKind, stringValue, numericValue)
	columnName <- inputDT[lsKind=='column name']$stringValue
	columnType <- inputDT[lsKind=='column type']$stringValue
	columnUnits <- inputDT[lsKind=='column units']$stringValue
	columnOrder <- inputDT[lsKind=='column order']$numericValue
	hideColumn <- as.logical(inputDT[lsKind=='hide column']$stringValue)
	outputDT <- data.table(columnOrder, columnName, columnOrder, hideColumn)
	return (outputDT)
}

getExperimentColOrderValues <- function(experimentCode){
	dataCsv <- getURL(
	  paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/", experimentCode, "/exptvalues/bystate/metadata/data%20column%20order/tsv"),
	  customrequest='GET',
	  httpheader=c('Content-Type'='application/json'))
	errorFlag <- FALSE
	tryCatch({
	  dataDF <- read.csv(text = dataCsv, colClasses=c("character"))},
	  error = function(ex) {
	  errorFlag <<- TRUE
	})
	if (errorFlag){
	        colOrderDT <- data.table()
	} else {
	        dataDT <- as.data.table(dataDF)
			colOrderDT <- dataDT[ ,pivotColOrderData(lsKind, stringValue, numericValue), by="stateId"]
			setkey(colOrderDT, columnOrder)
	}

	return(colOrderDT)
	
}


getExperimentColNames <- function(experimentCodeName, showAllColumns=TRUE){
	exptDataColumnsDT <- getExperimentColOrderValues(experimentCode=experimentCodeName)
	if (nrow(exptDataColumnsDT) == 0){
		## save the state values for the SEL column orders
		saveResult <- saveExptDataColOrder(experimentCodeName)
		if (saveResult){
			exptDataColumnsDT <- getExperimentColOrderValues(experimentCode=experimentCodeName)
		}
	}
	if (nrow(exptDataColumnsDT) > 0){
		exptDataColumnsDT$columnOrder <- as.integer(exptDataColumnsDT$columnOrder)
		setkey(exptDataColumnsDT, columnOrder)
		if (showAllColumns) {
			exptDataColumns <- exptDataColumnsDT[ ]$columnName
		} else {
			exptDataColumns <- exptDataColumnsDT[ hideColumn==FALSE]$columnName
		}
	} else {
		experimentFilters <- getURL(
			paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/filters/jsonArray"),
			customrequest='POST',
			httpheader=c('Content-Type'='application/json'),
			postfields=paste0('[', experimentCodeName, ']'))

		efs <- fromJSON(experimentFilters)
		exptDataColumns <- c()
		if (length(efs[[1]]$valueKinds) > 0){
			for (i in 1:length(efs[[1]]$valueKinds)){
				exptDataColumns <- c(exptDataColumns, efs[[1]]$valueKinds[[i]]$lsKind)
			}			
		}
	}

	return(exptDataColumns)
}





