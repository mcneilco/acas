# If matchNames is false, overwrites (with warning) existing dataTitles
# If matchNames is true, scans through data titles for what we want

adjustColumnsToUserInput <- function(inputColumnTable, inputDataTable, tempFilePath) {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin adjustColumnsToUserInput"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  setnames(inputDataTable, inputColumnTable[activityColName != "None", ]$activityColName, inputColumnTable[activityColName != "None", ]$newActivityColName)
  
  colNamesToCheck <- setdiff(colnames(inputDataTable), c("assayFileName", "assayBarcode", "rowName", "colName", "wellReference", "plateOrder"))
  colNamesToKeep <- inputColumnTable$newActivityColName
  
  inputDataTable <- removeColumns(colNamesToCheck, colNamesToKeep, inputDataTable, tempFilePath)
  inputDataTable <- addMissingColumns(colNamesToKeep, inputDataTable, tempFilePath)
  return(inputDataTable)
}