# Reads a .txt tab delimited file, returns the row number of the searchString
#
# Input:  fileName
#         searchString - the beginning of line you want to find, "^ \t1"
# Output: numeric row of line
# Possible error cases:           
#   file does not exist
#   wrong file type/delimitation
#   searchString is empty
#   searchString does not exist within file


getDataRowNumber <- function(fileName, searchString, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getDataRowNumber\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  rawLines <- readLines(fileName, n = -1L, warn = FALSE, ok = TRUE)
  dataRowNumber <- grep(searchString, rawLines)
  
  return(dataRowNumber) 
}
