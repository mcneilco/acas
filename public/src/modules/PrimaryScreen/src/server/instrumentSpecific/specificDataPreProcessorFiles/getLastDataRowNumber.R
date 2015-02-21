# Reads a .txt tab delimited file, returns the last row number
# 
# Input:  fileName (the file name of the assay)
#         searchString to find last row of data
# Output: vector of the last row of each data set
# Possible error cases: 
#   file does not exist
#   wrong file type/delimination

getLastDataRowNumber <- function(fileName, searchString, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getLastDataRowNumber\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  dataRowNumber <- getDataRowNumber(fileName, searchString, tempFilePath)
  
  lastDataRowNumber <- c()
  
  for (i in 1:length(dataRowNumber)) {
    lineNumber <- dataRowNumber[i]
    nextLineNumber <- dataRowNumber[(i+1)]
    
    if (lineNumber == max(dataRowNumber)) {
      # last row in the fector
      lastDataRowNumber <- append(lastDataRowNumber, lineNumber, after = length(lastDataRowNumber))
    } else if (lineNumber != (nextLineNumber - 1)) {
      # if there is a gap in the rows, then the next number is the beginning of the next data set
      lastDataRowNumber <- append(lastDataRowNumber, lineNumber, after = length(lastDataRowNumber))
    }
  }
  
  return(lastDataRowNumber)
}