

adjustColumnsToUserInput <- function(inputColumnTable, inputDataTable, tempFilePath) {
  # inputColumnTable: 
  #   userReadOrder: numbers
  #   userReadName: character
  #   activityColName: character
  #   newActivityColName: character
  #   activityCol: boolean
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin adjustColumnsToUserInput"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  setnames(inputDataTable, inputColumnTable[activityColName != "None", ]$activityColName, inputColumnTable[activityColName != "None", ]$newActivityColName)
  
  colNamesToCheck <- setdiff(colnames(inputDataTable), c("assayFileName", "assayBarcode", "rowName", "colName", "wellReference", "plateOrder"))
  colNamesToKeep <- inputColumnTable$newActivityColName
  
  inputDataTable <- removeColumns(colNamesToCheck, colNamesToKeep, inputDataTable, tempFilePath)
  inputDataTable <- addMissingColumns(colNamesToKeep, inputDataTable, tempFilePath)
  
  # copy the read column that we want to do transformation/normalization on (user input)
  activityColName <- inputColumnTable$newActivityColName[inputColumnTable$activityCol]
  inputDataTable$activity <- inputDataTable[ , get(activityColName)]
  
  return(inputDataTable)
}