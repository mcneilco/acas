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
  
  rawLines <- readLines(fileName, warn = FALSE, encoding = "latin1")
  dataRowNumber <- grep(searchString, rawLines)
  
  lastDataRowNumber <- c()
  
  for (i in 1:length(dataRowNumber)) {
    lineNumber <- dataRowNumber[i]
    nextLineNumber <- dataRowNumber[(i+1)]
    
    if (lineNumber == max(dataRowNumber)) {
        lastDataRowNumber <- append(lastDataRowNumber, lineNumber, after = length(lastDataRowNumber))
    } else if (lineNumber != (nextLineNumber - 1)) {
        lastDataRowNumber <- append(lastDataRowNumber, lineNumber, after = length(lastDataRowNumber))
    }
  }
  
  return(lastDataRowNumber)
}