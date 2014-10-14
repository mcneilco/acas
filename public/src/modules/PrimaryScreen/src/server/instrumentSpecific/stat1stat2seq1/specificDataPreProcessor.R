specificDataPreProcessor <- function(parameters=parameters, folderToParse=folderToParse, errorEnv=errorEnv, dryRun=dryRun, instrumentClass=instrumentReadParams$dataFormat, testMode) {
  # IFF
  fileNameTable <- validateInputFiles(folderToParse)
  
  # TODO maybe: http://stackoverflow.com/questions/2209258/merge-several-data-frames-into-one-data-frame-with-a-loop/2209371
  
  resultList <- apply(fileNameTable,1,combineFiles)
  resultTable <- as.data.table(do.call("rbind",resultList))
  
  return(resultTable)
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
    row.names=1
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