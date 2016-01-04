specificDataPreProcessorStat1Stat2Seq <- function(parameters, folderToParse, errorEnv, dryRun, instrumentClass, testMode, tempFilePath) {
                                                  
  
  # Load necessary libraries to run current function
  library(racas)
  library(data.table)
  library(plyr)
  
  # Call a modified function that validates the seq files when no Stat files are present
  fileNameTable <- validateInputFilesNoStatFiles(folderToParse)
  
  
  # TODO maybe: http://stackoverflow.com/questions/2209258/merge-several-data-frames-into-one-data-frame-with-a-loop/2209371


    
  # Use an updated version of the following function
  resultList <- apply(fileNameTable,1,combineFilesNoStatFiles, timeWindowList=parameters$primaryAnalysisTimeWindowList)
  
  resultTable <- as.data.table(do.call("rbind",resultList))
  assayData <- data.table(assayFileName=unlist(lapply(lapply(lapply(resultTable$fileName, strsplit, split="/"), unlist), tail, n=1)), 
                          assayBarcode=as.character(resultTable$barcode),
                          plateOrder=as.numeric(as.factor(resultTable$barcode)), 
                          rowName=substring(resultTable$well, 1,1), 
                          colName=substring(resultTable$well, 2,3),
                          wellReference=resultTable$well, 
                          num=as.numeric(as.factor(resultTable$well)), 
                          Well=NA,
                          resultTable[, 4:length(resultTable), with = FALSE])
  
  # Rename a subset of the columns in assayData
  setnames(assayData, c("timePoints", "sequence"), c("T_timePoints", "T_sequence"))
  
  # Create lists of unique entries for types of statistics, barcodes and filenames that will be used immediately below
  vectColumnsNames <- names(resultTable)
  # Skip the first 5 names extracted from the resultTable columns (i.e. "well", "barcode", "fileName", "timePoints", "sequence")
  # and start registering the names of all statistics from column 6
  vectStatistics <- (vectColumnsNames[6:length(resultTable)])
  vectBarcodes <- unique(resultTable$barcode)
  vectFiles <- unique(resultTable$fileName)
  
  
  # Modified the range of elements that are accessed for each column of the following dataframe
  plateAssociationDT <- data.table(plateOrder=rep(unique(as.numeric(as.factor(resultTable$barcode))), each=length(vectStatistics)),  #as.numeric(as.factor(resultTable$barcode))[c(1:3, 766:768)], 
                                   readPosition=rep(1:length(vectStatistics), length(vectFiles)), 
                                   assayBarcode=rep(vectBarcodes, each=length(vectStatistics)),   #resultTable$barcode[c(1:3, 766:768)], 
                                   compoundBarcode_1=NA, 
                                   sideCarBarcode=NA, 
                                   assayFileName=rep(vectFiles, each=length(vectStatistics)),    #resultTable$fileName[c(1:3, 766:768)],
                                   instrumentType=rep(parameters$instrumentReader, length(vectStatistics)*length(vectFiles)), 
                                   dataTitle= colnames(resultTable)[rep(6:length(resultTable), length(vectFiles))])
  
  readsTable <- getReadOrderTable(readList=parameters$primaryAnalysisReadList)
  userInputReadTable <- formatUserInputActivityColumns(readsTable=readsTable, 
                                                       activityColNames=unique(plateAssociationDT$dataTitle), 
                                                       tempFilePath=tempFilePath, matchNames=FALSE)
  
  # Rename the final composite output
  newInstrumentData <- list(assayData=assayData, plateAssociationDT=plateAssociationDT, userInputReadTable=userInputReadTable)


  return(newInstrumentData)
}


combineFiles <- function(fileSet) {
  # Takes a set of stat1, stat2, and seq files and merges them
  #
  # Args:
  #   fileSet: a list of files which inclues stat1, stat2, and seq files
  # Returns:
  #   A data.frame with columns stat1, stat2, and seq files in sorted columns
  
  stat1Frame <- parseStatFile(as.character(fileSet[1]))
  stat2Frame <- parseStatFile(as.character(fileSet[2]))
  seqData <- parseSeqFile(as.character(fileSet[3]))

  fluorescentList <- findFluorescents(seqData)
  allStatFrame <- merge(stat1Frame,stat2Frame)
  allStatFrame$fluorescent <- allStatFrame$well %in% fluorescentList
  
  timeValues <- gsub("X","", row.names(seqData))
  allStatFrame$timePoints <- paste(timeValues, collapse = "\t")
  allStatFrame$sequence <- unlist(lapply(seqData[,as.character(allStatFrame$well)], paste, collapse="\t"),use.names=FALSE)
  return(allStatFrame)
}

parseStatFile <- function(fileName) {
  # Parses a stat file
  #
  # Args:
  #   fileName:   the path to a file
  #
  # Returns:
  #   A data.frame with four columns:
  #     "barcode":    barcode of source plate
  #     "well":       well names of source
  #     Statistic:    the values for each well (name taken from the parameters of the stat file)
  #     "fileName":  the path the to source file without the extension
  
  rawLines <- readLines(fileName)
  
  # The first line of the plate grid are the column headers and starts with  \t1
  columnsHeaderLine <- grep("^\t1", rawLines)
  
  # The first line of the user requested paramters
  userParamsLine <- grep("*User Requested Parameters*", rawLines)
  
  # Now collect all non-data lines
  paramLines <- c(rawLines[1:(columnsHeaderLine-1)], rawLines[(userParamsLine+1):length(rawLines)])
  paramLines <- unlist(strsplit(paramLines, "\t"))
  # Find last data array line
  #TODO, make this more robust
  lastLineOfData <- userParamsLine-2
  
  # Get the data
  mainData <- read.table(
    fileName,
    sep="\t",
    skip=columnsHeaderLine-1,
    nrows=lastLineOfData-columnsHeaderLine,
    header=TRUE,
    row.names=1,
    stringsAsFactors = FALSE
  )
  # all the rows end in \t, so I need to kill the last column
  
  mainData <- mainData[,!(names(mainData) %in% "X.1")]
  
  barcode <- getParamByKey(paramLines, "Source Plate 2 Barcode")
  readName <- getParamByKey(paramLines, "Statistic")
  startRead <- getParamByKey(paramLines, "Start Sample")
  endRead <- getParamByKey(paramLines, "End Sample")
  
  barcode <- validateBarcode(barcode, fileName)
  
  statData <- makeDataFrameOfWellsGrid(mainData, barcode, readName)
  statData$fileName <- gsub("(.*)\\.stat.$","\\1",fileName)
  if (readName == "Maximum") {
    statData$startReadMax <- startRead
    statData$endReadMax <- endRead
  } else if (readName == "Minimum") {
    statData$startReadMin <- startRead
    statData$endReadMin <- endRead
  } else {
    stopUser (paste("Unknown Statistic in ", fileName))
  }
  
  return(statData)
}

findFluorescents <- function(seqData) {
  # Finds fluorescent compounds by initial slope
  #
  # Args:
  #   sequenceFile: a path to a sequence file
  # Returns:
  #   A character vector of well names
  
  fluorescentRows <- (seqData[13, ] - seqData[9, ]) > 100
  
  fluorescentRowNums <- which(fluorescentRows)
  
  fluorescentRowCoordinates <- names(seqData)[fluorescentRowNums]
  
  return(fluorescentRowCoordinates)
}

getParamByKey <- function(params, key) {
  line <- params[[grep(key, params)]] 
  components <- strsplit(line, " = ")
  return( components[[1]][[2]])
}

validateBarcode <- function(barcode, filePath) {
  # Checks that the barcode inside the file matches the one in the file path
  # Returns the barcode inside the file name
  fileNameBarcode <- gsub(".+_([^/]+)_[^/]+$", "\\1", filePath)
  if (fileNameBarcode == filePath) {
    fileName <- gsub(".+/([^/]+)+$", "\\1", filePath)
    warnUser(paste0("No barcode could be found between underscores in ", fileName, ", so the barcode inside the file will be used"))
    return (barcode)
  }
  if (fileNameBarcode != barcode) {
    fileName <- gsub(".+/([^/]+)+$", "\\1", filePath)
    warnUser(paste0("The barcode '", barcode, "' inside the file ", fileName, 
                    " was replaced by the barcode '", fileNameBarcode, "'"))
  }
  return(fileNameBarcode)
}

makeDataFrameOfWellsGrid <- function(allData, barcode, valueName) {
  # Takes data and forms it into a data frame
  #
  # Args:
  #   allData:    A matrix or data.frame of data, row.names are wells
  #   barcode:    The barcode for this data
  #   valueName:  a label for the values inside the wells
  # Returns:
  #   A data.frame with three columns:
  #     "barcode":    barcode of source plate
  #     "well":       well names of source
  #     valueName:    the values for each well
  
  wellNames <- c()
  values <- c()
  for (i in 1:length(row.names(allData))) {
    for (j in 1:length(names(allData))) {
      if (j<10) {
        wellName = (paste(sep='0',row.names(allData)[[i]], j))
      } else {
        wellName = (paste(sep='',row.names(allData)[[i]], j))
      }  
      wellNames <- c(wellNames, wellName)
      values <- c(values, allData[i,j])
    }
  }
  out <- data.frame(barcode=barcode, well=wellNames)
  out[valueName] <- values
  return(out)
  
}




# If matchNames is false, overwrites (with warning) existing dataTitles
# If matchNames is true, scans through data titles for what we want
# Sets the activity and column names to the user input. 
# Sets column names included in input parameters to the format of Rn {acivity}
# Inputs: readsTable (data.table with columns readOrder, readNames, activity)
#         activityColNames (assayData) (from instrument files)
# Output: data table that can be used as a reference. Columns: readPosition, readName, ativityColName, newActivityColName, activity

formatUserInputActivityColumns <- function(readsTable, activityColNames, tempFilePath, matchNames) {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin formatUserInputActivityColumns"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  userInput <- copy(readsTable)
  setnames(userInput, c("readPosition", "readName","activity"), c("userReadPosition", "userReadName","activityCol"))
  #userInput$activityCol <- NULL
  userInput[ , activityColName := "None"]
  userInput[ , newActivityColName := "None"]
  
  noMatch <- list()
  overWrite <- list()
  
  if(nrow(readsTable[readsTable$activity]) > 1) {
    stopUser("More than one read column chosen as the activity column.")
  } else if (nrow(readsTable[readsTable$activity]) < 1) {
    stopUser("At least one read column needs to be chosen as the activity column.")
  }
  
  if(length(activityColNames) < nrow(userInput[calculatedRead == FALSE])) {
    stopUser("More fields are defined in read input than are available from data file.")
  }
  
  if (matchNames) {
    # Finds activity columns that match the user input activity. 
    # Assigns new activity column names of format "Rn {activity}"
    # Filters out calculated read columns since those won't match.
    for(name in userInput[calculatedRead == FALSE]$userReadName) {
      columnCount <- 0
      for(activity in activityColNames) {
        if(tolower(name) == tolower(activity)) {
          userInput[userReadName==name, activityColName := activity]
          userInput[userReadName==name, newActivityColName := paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",activity,"}")]
          columnCount <- columnCount + 1
        }
      }
      if(columnCount == 0) {
        noMatch[[length(noMatch) + 1]] <- name
        userInput[userReadName==name, newActivityColName := paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",name,"}")]
      } else if(columnCount > 1) {
        stopUser(paste0("Multiple activity columns found for read name: '", name, "'"))
      } 
    } 
  } else {
    # Finds activity columns that match the user input read position. 
    # Assigns new activity column names of format "Rn {userInputReadName}"
    # Filters out calculated read columns since those don't have a position in the raw data files
    for (order in userInput[calculatedRead == FALSE]$userReadPosition) {
      userInput[userReadPosition == order, activityColName := activityColNames[[order]]]
    }
    # Checks to see if data has a generic name (Rn)
    for(name in userInput[calculatedRead == FALSE]$userReadName) {
      if(!grepl("^R[0-9]+$", userInput[userReadName==name, ]$activityColName) && name != userInput[userReadName==name, ]$activityColName){
        overWrite[[length(overWrite) + 1]] <- userInput[userReadName==name, ]$activityColName
      }
      userInput[userReadName==name, newActivityColName := paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",name,"}")]
    }
  }
  
  # Assigns new activity column names to Calculated Reads
  for(name in userInput[calculatedRead == TRUE]$userReadName) {
    userInput[userReadName == name , newActivityColName := paste0("R", userInput[userReadName==name, ]$userReadOrder, " {",name,"}")]
  }
  
  # these warnings/errors will only happen if matchNames = TRUE
  validActivityColumns <- userInput[activityColName != "None", ]$activityColName
  if(length(noMatch) > 0) {
    warnUser(paste0("No match found for read name(s): '", paste(noMatch, collapse="','"),"'"))
  }
  if(length(validActivityColumns) == 0) {
    stopUser("No valid acvitivy columns were found from user input.")
  } else if(length(unique(validActivityColumns)) != length(validActivityColumns)) {
    warnUser("A single activity column is assigned to multiple input reads.")
  } 
  
  # these warnings/errors will only happen if matchNames = FALSE
  #   if(length(overWrite) > 0) {
  #     warnUser(paste0("Overwriting the following column(s) with user input read names: '", paste(overWrite, collapse="','"),"'"))
  #   }
  
  return(userInput)
}




## Additional functions required in the absence of stat1, stat2 files below


validateInputFilesNoStatFiles <- function(dataDirectory) {
  # Validates and organizes the names of the input files - no stat files present in the folder
  #
  # Args:
  #   dataDirectory:      A string that is a path to a folder full of files
  # Returns:
  #   A data.frame with one column for all files of seq type (no stat1, stat2)
  #     Files are organized alphabetically in rows
  
  
  #possible errors:
  #lack of protocol
  #no files
  #uneven files (no match or different lengths)
  #save(dataDirectory, file="dataDirectory.Rda")
  #collect the names of files
  ## No stat files # fileList <- list.files(path = dataDirectory, pattern = "\\.stat[^\\.]*", full.names = TRUE)
  seqFileList <- list.files(path = dataDirectory, pattern = "\\.seq\\d$", full.names = TRUE)
  
  
  # the program exits when there are no files
  if (length(seqFileList) == 0) {
    stopUser("No files found")
  }
  
  ## No stat files # stat1List <- grep("\\.stat1$", fileList, value="TRUE")
  ## No stat files # stat2List <- grep("\\.stat2$", fileList, value="TRUE")
  
  ##if (length(stat1List) != length(stat2List) | length(stat1List) != length(seqFileList)) {
  ##  stopUser("Number of Maximum and Minimum and sequence files do not match")
  ##}
  
  fileNameTable <- data.frame(seq= sort(seqFileList))
                              ##stat1= sort(stat1List),
                              ##stat2= sort(stat2List),
                              
  
  checkSameName <- function(x) {
    # This function is used below, it checks that all columns have the same name
    firstName <- gsub(pattern="\\.stat1$",replacement="",x[1])
    return(gsub("\\.stat2$","",x[2])==firstName && gsub("\\.seq1$","",x[2])==firstName)
  }
  
  ## Since there are no stat files, there is also no need to invoke the following function
  # TODO: tell user which ones
  ##if (any(apply(fileNameTable,1,checkSameName))) {
  ##  stopUser("File names do not match")
  ##}
  
  return(fileNameTable)
}



combineFilesNoStatFiles <- function(fileSet, timeWindowList) {
  # Takes the seq files and creates an output dataframe in the absence of stat1, stat2 files
  #
  # Args:
  #   fileSet: a list of files which includes seq files and statistic info
  # Returns:
  #   A data.frame with columns seq files in sorted columns
  
  # Creates the basic frame in the absence of stat1, stat2 files
  basicFrame <- parseSeqFileBarcodeFilename(fileSet[1])
  # Rename the column of the dataframe for ease
  colnames(basicFrame)[1] <- "well"
  
  ## No stat files
  #stat1Frame <- parseStatFile(as.character(fileSet[1]))
  #stat2Frame <- parseStatFile(as.character(fileSet[2]))
  
  seqData <- parseSeqFile(as.character(fileSet[1]))
  
  
  # Create the basic frame containing barcodes, fileNames, amd wells before attaching timepoints and sequences below
  allStatFrame <- basicFrame
  
  ## No fluorescent cells detected   
  ## fluorescentList <- findFluorescents(seqData)
  #allStatFrame <- merge(stat1Frame,stat2Frame)
  #allStatFrame$fluorescent <- allStatFrame$well %in% fluorescentList
  
  timeValues <- gsub("X","", row.names(seqData))
  allStatFrame$timePoints <- paste(timeValues, collapse = "\t")
  
  # Isolate the string that contains all the timepoints collapsed with /t.
  # Assuming that all strings in all elements of timePoints vector are identical, then the first string is selected and
  # parsed into multiple elements of a list, then unlisted and saved in one vector as numeric values
  timeSequence <- allStatFrame$timePoints[1]
  timePointList <- strsplit(timeSequence, "\t")
  vectTime <- unlist(timePointList)
  vectTime <- as.numeric(vectTime)
  
  
  # Find the index of the vector elements (i.e. numerical indices) that bracket the time window of interest
  findTimeWindowBrackets <- function(vectTime, timeWindowStart, timeWindowEnd) {
    # This function is used immediately below and finds the indices of two elements in a vector containing incrementing timepoints,
    # one pointing to the start the other ot the end of the time window of interest
    #
    # Args:
    #   vectTime:         a vector that contains time points sorted in an incremental fashion
    #   timeWindowStart:  time in seconds denoting the start of the time window of interest
    #   timeWindowEnd:    time in seconds denoting the end of the time window of interest
    # Returns:
    #   A list containing two values: element index pointing to the start and element index pointing to the end of the time window
    
    logicTimeStart <- (vectTime>=timeWindowStart)
    startReadIndex <- min(which(logicTimeStart == TRUE))
    logicTimeEnd <- (vectTime<timeWindowEnd)
    endReadIndex <- max(which(logicTimeEnd == TRUE))
    components <- list(startReadIndex = startReadIndex, endReadIndex = endReadIndex)
    return(components)
  }
  

  allStatFrame$sequence <- unlist(lapply(seqData[,as.character(allStatFrame$well)], paste, collapse="\t"),use.names=FALSE)
  

  for (timeWindow in timeWindowList) {
    currentStatWindow <- findTimeWindowBrackets(vectTime, timeWindow$windowStart, timeWindow$windowEnd)
    
    if (timeWindow$statistic=="max") {
      functionToApply=max
    } else if (timeWindow$statistic=="min") {
      functionToApply=min
    }
    
    calculatedStatistic <- vapply(allStatFrame$sequence, applyFunctionTabDelimited, 1,
                                  startIndex=currentStatWindow$startReadIndex, 
                                  endIndex=currentStatWindow$startReadIndex, 
                                  functionApply=functionToApply)
    

    allStatFrame[, paste("T", as.character(timeWindow$position), sep="")] <- calculatedStatistic
  }
  
  
  return(allStatFrame)
}



applyFunctionTabDelimited <- function(stringElement, startIndex, endIndex, functionApply) {
  # Finds the minimum or maximum in a string that passes raw data from the instrument, within predetermined time windows,
  # depending on the definition of functionApply (minimum or maximum, respectively)
  #
  # Args:
  #   stringElement:    A string where subsequent measurements are separated by the "\t" character
  #   startIndex:       Element index that defines the start of the time window to apply the function
  #   endIndex:         Element index that defines the end of the time window to apply the function
  #   functionApply:    The type of function that is needed to be applied to the raw data (minimum or maximum)
  #
  # Returns:
  #   A vector with the calculated value for the minimum or maximum
  
  # Parse the input string into multiple elements of a list, then unlist and save in vector as numeric values
  seqList <- strsplit(stringElement, "\t")
  vectElement <- unlist(seqList)
  vectElement <- as.numeric(vectElement)
  
  # apply chosen function (minimum or maximum) in sequence elements specified as arguments in current function
  appliedOptimum <- functionApply(vectElement[c(startIndex:endIndex)])
  
  return(appliedOptimum)
}



parseSeqFileBarcodeFilename <- function(fileName) {
  # Parses a seq file and retrieves wells, barcode, and filename
  #
  # Args:
  #   fileName:   the path to a seq file
  #
  # Returns:
  #   A data.frame with a column for each well
  
  # Extract wells and parameters embedded in the seq file and rename the columns of dataframes for ease  
  inputData <- read.delim(file=fileName, as.is=TRUE, stringsAsFactors = FALSE)
  well <- inputData[5]
  colnames(well) <- "AA"
  paramLines <- inputData[1]
  colnames(paramLines) <- "Alpha"
  
  # Locate the element of the parameters dataframe that contains the plate barcode and isolate the barcode
  key <- "Source Plate 2 Barcode"
  index <- grep(key, paramLines$Alpha)
  line <- paramLines[index, ]
  components <- unlist(strsplit(line, " = "))
  barcode <- components[2]

  # Extract the fileName and truncate
  fileName <- gsub("(.*)\\.seq.$","\\1",fileName)
  
  # Validation of the barcode
  barcode <- validateBarcode(barcode, fileName)

  # Normalize the wells in terms of number of characters per well name
  backDigits <- substr(well$A, 2, nchar(well$A))
  normalizedDigits <- ifelse(nchar(backDigits)==1, yes=paste0("0",backDigits), no=backDigits)
  frontLetter <- substr(well$A, 1, 1)
  normalizedWells <- paste0("", frontLetter, normalizedDigits)
  
  # Structure the output dataframe
  outputData <- data.frame(normalizedWells)
  outputData$barcode <- rep(barcode, times=nrow(outputData))
  outputData$fileName <- rep(fileName, times=nrow(outputData))
  return(outputData)
}