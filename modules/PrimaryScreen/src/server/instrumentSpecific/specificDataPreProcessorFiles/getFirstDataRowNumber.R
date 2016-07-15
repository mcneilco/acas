# Reads a .txt tab delimited file, returns the first row number for a block of data
# 
# Input:  fileName (the file name of the assay)
#         searchString to find last row of data
# Output: vector of the first row of each data set
# Possible error cases: 
#   file does not exist
#   wrong file type/delimination

getFirstDataRowNumber <- function(fileName, searchString, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getFirstDataRowNumber\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  dataRowNumber <- getDataRowNumber(fileName, searchString, tempFilePath)
  
  firstDataRowNumber <- c()
  
  for (i in 1:length(dataRowNumber)) {
    lineNumber <- dataRowNumber[i]
    nextLineNumber <- dataRowNumber[(i+1)]
    
    if (lineNumber == min(dataRowNumber)) { 
      # first row in the vector
      firstDataRowNumber <- append(firstDataRowNumber, lineNumber, after = length(firstDataRowNumber))
    } else if (lineNumber != (nextLineNumber - 1) && lineNumber != max(dataRowNumber)) {
      # if there is a gap in the rows, then the next number is the beginning of the next data set
      firstDataRowNumber <- append(firstDataRowNumber, nextLineNumber, after = length(firstDataRowNumber))
    }
  }
  
  return(firstDataRowNumber)
}