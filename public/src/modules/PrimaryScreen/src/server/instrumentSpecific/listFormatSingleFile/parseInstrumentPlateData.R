# This function gathers all of the little functions together to get the well reference data
# from a vector of assay barcodes.
#
# Input: vectorOfData from getAssayBarcode
# Output: wellReferenceData
# Potential issues:
#   references documents that are not in the correct folder

parseInstrumentPlateData <- function(fileName, parseParams, titleVector, tempFilePath) {
  #listFormatSingleFile
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin parseInstrumentPlateData\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  # Returns a vector if there are multiple data sets
  headerRowVector   <- getDataRowNumber(fileName, searchString=parseParams$headerRowSearchString, tempFilePath=tempFilePath)
  lastDataRowVector <- getLastDataRowNumber(fileName, searchString=parseParams$dataRowSearchString, tempFilePath=tempFilePath)
  
  assayDataDT <- getFormattedData(fileName, sepChar=parseParams$sepChar, begRow=headerRowVector, endRow=lastDataRowVector, headerExists=parseParams$headerExists, tempFilePath=tempFilePath)
  
  # Checks to make sure all columns exist in the assay plate. If not, missing ones are added in
  if(!identical(setdiff(titleVector, colnames(assayDataDT)), character(0))) {
    assayDataDT[ , c(setdiff(titleVector, colnames(assayDataDT))) := as.character(NA)]
  }
  setcolorder(assayDataDT, c("rowName","colName","wellReference",titleVector))
  
  return(assayDataDT)
}


