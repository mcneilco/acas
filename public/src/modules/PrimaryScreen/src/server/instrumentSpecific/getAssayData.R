# This function pulls out a data set from a .txt tab delimited file based on the 
# first line of the header and the last line of the data.
#
# Inputs: fileName
#         begNumber   - row number of the header line, or first row of data if no header
#         endNumber   - row number of the last line of data
#         sepChar     - column delimiter of data rows in fileName
#         headerExists - is there a header row in fileName
#         begCol      - beginning column of data
# Outputs: data.table of data
# Possible error cases:
#   incorrect filename
#   

getAssayData <- function(fileName, begRow, endRow, sepChar, headerExists=TRUE, begCol=1, tempFilePath) {

  # runlog
  write.table(paste0(Sys.time(), "\tbegin getAssayData\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  assayData <- read.table(
    fileName,
    colClasses=c("character"),
    sep=sepChar,
    skip=begRow - 1,
    nrows=endRow - begRow,
    header=headerExists,
    fill=NA
  )
  
  numberOfRows <- nrow(assayData)
  if (numberOfRows == 8) {
    numberOfCols <- 12
  } else if (numberOfRows == 16) {
    numberOfCols <- 24
  } else if (numberOfRows == 32) {
    numberOfCols <- 48
  } else {
    stopUser(paste0("Undefined assay plate size. Number of rows: ", numberOfRows))
  }
  
  endCol <- begCol + numberOfCols - 1
  assayData <- assayData[ , begCol:endCol] 
  colnames(assayData) <- c(1:numberOfCols)
   
  if (numberOfRows < 27) {
    assayData$rowName <- c(paste0("-",LETTERS[1:numberOfRows]))
  } else {
    assayData$rowName <- c(paste0("-",LETTERS[1:26]), paste0("A",LETTERS[1:(numberOfRows - 26)]))
  }
  
  return(as.data.table(assayData))
}