# This function gathers all of the little functions together to get the well reference data
# from a vector of assay barcodes.
#
# Input: vectorOfData from getAssayBarcode
# Output: wellReferenceData
# Potential issues:
#   references documents that are not in the correct folder

parseInstrumentPlateData <- function(fileName, parseParams, titleVector, tempFilePath) {
  #plateFormatSingleFile
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin parseInstrumentPlateData\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  # Returns a vector if there are multiple data sets
  if(parseParams$headerExists) {
    # row number of header row in data set
    firstDataRowVector <- getDataRowNumber(fileName, parseParams$headerRowSearchString, tempFilePath=tempFilePath)  
  } else {
    # row number of first data row in data set
    firstDataRowVector <- getFirstDataRowNumber(fileName, parseParams$dataRowSearchString, tempFilePath=tempFilePath)
  }
  lastDataRowVector <- getLastDataRowNumber(fileName, searchString=parseParams$dataRowSearchString, tempFilePath=tempFilePath)
  dataTitleRowVector <- getDataRowNumber(fileName, searchString=parseParams$dataTitleIdentifier, tempFilePath=tempFilePath)
  
  assayDataDT <- formatAssayData(firstDataRowVector=firstDataRowVector, lastDataRowVector=lastDataRowVector, dataTitleRowVector=dataTitleRowVector, parseParams=parseParams, fileName=fileName, tempFilePath=tempFilePath)     
  
  # Checks to make sure all columns exist in the assay plate. If not, missing ones are added in
  if(!identical(setdiff(titleVector, colnames(assayDataDT)), character(0))) {
    assayDataDT[ , c(setdiff(titleVector, colnames(assayDataDT))) := as.numeric(NA)]
  }
  setcolorder(assayDataDT, c("rowName","colName","wellReference",titleVector))
  
  return(assayDataDT)
}


