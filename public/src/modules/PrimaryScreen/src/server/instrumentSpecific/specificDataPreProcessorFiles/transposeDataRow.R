# transposeDataRow.R
#
# transposes a row of data into a column of data
#
# Args:
#   dataRow:   A numeric vector of a row of data
#   dataName:   name of the column of data
# Returns:
#   A data.frame  of the row of data


transposeDataRow <- function(dataRow, dataName, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin transposeDataRow"), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)

  dataRow <- replace(dataRow, is.na(dataRow), as.numeric(NA))
  assayDataFrame <- as.data.frame(t(dataRow), stringsAsFactors=FALSE)
  assayDataFrame$colName <- seq(1:length(dataRow))
  names(assayDataFrame) <- c(dataName, 'colName')    
  
  return(assayDataFrame)
}