# This adds and reorders columns from getAssayDataFame so that a file can be written
# 
# Input: dataTable from getAssayDataFrame,
# Output: wellData
# Potential issues: 
#   assayBarcode is for the wrong plate
#   not all of the columns exist

getWellReferenceData <- function(dataTable, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getWellReferenceData"), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
#   browser()
  dataTable[ , wellReference := paste0(gsub("-", "", rowName), sprintf("%03d", as.numeric(colName)))]
    
}