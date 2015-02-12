# Determines the number of data sets based on how many header row numbers and last data row numbers are found. 
# Finds the Data Titles for sections of data
# 
# Input:  fileName, parseParams
# Output: dataTitles 

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
  
  dataTitles <- readDataTitles(fileName, parseParams, headerRowVector, tempFilePath) 
  
  return(dataTitles)
}