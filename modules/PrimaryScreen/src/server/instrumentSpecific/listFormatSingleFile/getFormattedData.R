# This function takes data that is already formatted in a manner that we like, changes the names of the 
# row/column column names, buffers the rowName, and adds in the well reference column.
#
# Input: filename
# Output: assay Data Table
#
# CURRENT ISSUE: currently only works with LumiLux. Tweaks are needed to make the column names prettier.
# Currently relies on a standard column naming convention for Row/Column/Well


getFormattedData <- function(fileName, sepChar, begRow, endRow, headerExists, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "begin getFormattedData\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  assayData <- read.table(
    fileName,
    sep=sepChar,
    skip=begRow - 1,
    nrows=endRow - begRow,
    header=headerExists, 
    fill=TRUE,
    check.names=FALSE,
    comment.char="",
    stringsAsFactors=FALSE
  )
  
  assayData <- as.data.table(assayData)
  if("Wells" %in% colnames(assayData)) {
    setnames(assayData, "Wells", "Well")
  }
  
  assayData[ , rowName := gsub("[0-9]{1,2}","",Well)]
  assayData[ , rowName := sprintf("%2s", rowName)]
  assayData[ , rowName := gsub(" ","-",rowName)]
  
  assayData[ , colName := gsub("[A-Z]{1,2}","",Well)]
  assayData[ , colName := gsub(" ","",colName)]
  
  assayData[ , Row := ""]
  assayData[ , Column := ""]
  assayData[ , c("Well","Row","Column") := NULL]
  if(!is.null(assayData$X)) {
    assayData[ , c("X") := NULL]
  }
  
  suppressWarnings(assayData$"" <- NULL)

  # Because this loop removes a column and then adds it, the column order changes for each 
  # column that is logical. This calls a different "name" and can skip columns if two 
  # "logical" columns are side by side. "rev()" solves this problem by going from the last 
  # name to the first - column order does not get affected for columns that haven't been 
  # tested yet, since the empty string column is added at the end of the data.table.
  for (name in rev(colnames(assayData))) {
    if(class(assayData[ , name, with=FALSE][[1]]) == "logical") {
      assayData[ , name := NULL, with=FALSE]
      assayData[ , name := "", with=FALSE]
    }
  }
  
  getWellReferenceData(assayData, tempFilePath=tempFilePath)
  
  # Checks to make sure that wellReference is unique (and wells only have one read)
  if(length(unique(assayData$wellReference)) != length(assayData$wellReference)) {
    stopUser(paste0("Some wells have multiple reads in file: ", fileName))
  }
  
  setkeyv(assayData, c("rowName","wellReference"))
  
  return(assayData)
  
}