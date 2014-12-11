# Function containing the loop that reads the assayData from a plate file and formats it in to a list format
# Inputs: headerRowVector (a vector of numbers from getDataRowNumber that are the row numbers of the plate headers)
#         lastDataRowVector (a vector of numbers from getLastDataRowNumber that are the row numbers of the last row of data from the plate)
#         dataTitleRowVector (a vector of numbers from getDataRowNumber that are the row numbers of the data titles. If no data titles exist, this will be a vector of NAs)
#         parseParams (the instrument parameters from getInstrumentReadParameters)
#         fileName (the name of the assayFile that is being formatted)
# Output: assayDataDT (a data.table of the assay data in list format)

formatAssayData <- function(headerRowVector, lastDataRowVector, dataTitleRowVector, parseParams, fileName, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin formatAssayData\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  firstPass <- TRUE
  
  # Can this loop be replaced by a data.table loop 
  for(i in 1:length(headerRowVector)) {
    
    # Returns the ith headerRow/dataRow that defines a single set of data
    begRow       <- headerRowVector[i]
    endRow       <- lastDataRowVector[i]
    
    if(is.na(unique(dataTitleRowVector)[i])) {
      dataTitle <- paste0("R",i)
    } else {
      dataTitleRow <- dataTitleRowVector[i]        
      dataTitle    <- read.table(fileName, sep=parseParams$sepChar, skip=dataTitleRow-1, nrows=1, header=FALSE, stringsAsFactors=FALSE)[1,1]
      if (length(grep("Feature: ", dataTitle)) != 0) {
        dataTitle <-gsub("Feature: ", "", dataTitle)
      }
    }
    assayDataDT  <- getAssayData(fileName, begRow=begRow, endRow=endRow, sepChar=parseParams$sepChar, headerExists=parseParams$headerExists, begCol=parseParams$beginDataColNumber, tempFilePath=tempFilePath)
    assayDataDT  <- assayDataDT[ , transposeDataRow(.SD, dataTitle, tempFilePath=tempFilePath) , by=rowName]
    getWellReferenceData(assayDataDT, tempFilePath=tempFilePath) 
    
    if(firstPass) {
      newTable <- assayDataDT
      setkeyv(newTable, c("rowName", "colName", "wellReference"))
      firstPass <- FALSE
    } else {
      setkeyv(assayDataDT, c("rowName", "colName", "wellReference"))
      newTable <- merge(newTable, assayDataDT)
    }
    assayDataDT <- newTable
  }
  
  return(assayDataDT)
}