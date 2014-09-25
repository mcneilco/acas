# Determines the number of data sets based on how many header row numbers and last data row numbers are found. 
# Finds the Data Titles for sections of data
# 
# Input:  fileName, instrumentType
# Output: countOfSectionsOfData (numeric)

getDataSectionTitles <- function(fileName, parseParams, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getDataSectionTitles\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  # Returns a vector if there are multiple data sets
  headerRowVector <- getDataRowNumber(fileName, parseParams$headerRowSearchString, tempFilePath=tempFilePath)
  lastDataRowVector <- getLastDataRowNumber(fileName, parseParams$dataRowSearchString, tempFilePath=tempFilePath)
  
  # Checks to make sure that the header and last data rows are defined for each data set
  if(length(headerRowVector) != length(lastDataRowVector)) {
    stopUser("Beginning row and ending row not defined for all data sets")
  }
  
  if (parseParams$dataFormat == "listFormatSingleFile" && length(headerRowVector) == 1) {
    # TODO: Checks column names for "formatted" data
    # currently only works for biacore
    dataTitles <- data.table(dataTitle=setdiff(colnames(read.table(fileName, sep=parseParams$sepChar, skip=headerRowVector-1, nrows=1, header=TRUE)), c("Well", "X")))
    dataTitles$readOrder <- 1:nrow(dataTitles) 
  } else if (is.na(parseParams$dataTitleIdentifier)) {
    if(parseParams$dataFormat == "plateFormatMultiFile") {
      
    } else {
      dataTitles <- data.table(dataTitle=c(paste0("R", 1:length(headerRowVector))), readOrder=1:length(headerRowVector))
    }
  } else {
    dataTitleRowVector <- getDataRowNumber(fileName, searchString=parseParams$dataTitleIdentifier, tempFilePath=tempFilePath)
  
    # Shift the vector to a data table with a read order column
    if(parseParams$dataFormat == "plateFormatMultiFile") {
      titleRowTable <- data.table(titleRow=dataTitleRowVector)
    } else {
      titleRowTable <- data.table(titleRow=dataTitleRowVector, readOrder=1:length(dataTitleRowVector))
    }
    
    # Read the file for the data titles
    if(parseParams$dataFormat == "plateFormatMultiFile"){
      dataTitles <- titleRowTable[ , read.table(fileName, sep=parseParams$sepChar, skip=titleRow-1, nrows=1, header=FALSE, stringsAsFactors=FALSE)[1,1], by=titleRow]
      dataTitles$titleRow <- NULL
    } else {
      dataTitles <- titleRowTable[ , read.table(fileName, sep=parseParams$sepChar, skip=titleRow-1, nrows=1, header=FALSE, stringsAsFactors=FALSE)[1,1], by=readOrder]
    }
    setnames(dataTitles,"V1","dataTitle")
    if (length(grep("Feature: ", dataTitles$dataTitle)) != 0) {
      dataTitles$dataTitle <- gsub("Feature: ", "", dataTitles$dataTitle)
    }
  } 
  
  return(dataTitles)
}