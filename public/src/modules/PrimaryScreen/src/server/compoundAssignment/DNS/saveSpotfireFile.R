saveSpotfireFile <- function(inputTable) {
  inputTable <- as.data.frame(inputTable)
  
  inputTable <- renameColumnsForSpotfire(inputTable)  
  newColNames <- colnames(inputTable)
  
  # find activity columns
  activityColNames <- colnames(inputTable)[grep("^R[0-9]{1,2} ",colnames(inputTable))]
  
  # ANY NAMES CHANGED HERE should also be changed in renameColumnsForSpotfire()
  requiredColumns <- c("Plate Type", "Assay Barcode", "Compound Barcode", "Source Type",
                       "Well", "Row", "Column", "Plate Order", "Well Type", "Corporate Name",
                       "Batch Number", "Corporate Batch Name", "Compound Concentration",
                       activityColNames,
                       "Efficacy", "SD Score", "Z' By Plate", "Z'", "Activity", 
                       "Normalized Activity", "Flag Type", "Flag Observation", "Flag Reason",
                       "Flag Comment", "Auto Flag Type", "Auto Flag Observation",
                       "Auto Flag Reason")
  
  # get the columns in the current inputTable that correspond to the spotfire spec
  keepColumns <- intersect(newColNames, requiredColumns)
  
  inputTable <- data.table(inputTable)
  inputTable <- removeColumns(colNamesToCheck=newColNames,
                              colNamesToKeep=keepColumns,
                              inputDataTable=inputTable)
  
  requiredColList <- c(requiredColumns, activityColNames)
  
  inputTable <- addMissingColumns(requiredColNames=requiredColumns, inputTable)
  setcolorder(inputTable, requiredColumns)
  
  write.csv(inputTable, file="", quote=FALSE, na="", row.names=FALSE)
  
}

renameColumnsForSpotfire <- function(inputTable){
  # Changes the names of the resultTable to conform with a spotfire file
  # ANY NAMES CHANGED HERE should also be changed in createSpotfireFile()
  require(plyr)
  
  inputTable <- rename(inputTable, replace=c("plateType"="Plate Type"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("assayBarcode"="Assay Barcode"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("cmpdBarcode"="Compound Barcode"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("sourceType"="Source Type"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("well"="Well"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("row"="Row"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("column"="Column"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("plateOrder"="Plate Order"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("wellType"="Well Type"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("batchName"="Corporate Name"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("batch_number"="Batch Number"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("batchCode"="Corporate Batch Name"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("cmpdConc"="Compound Concentration"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("transformed_% efficacy"="Efficacy"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("transformed_sd"="SD Score"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("zPrimeByPlate"="Z' By Plate"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("zPrime"="Z'"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("activity"="Activity"), warn_missing=FALSE)
  inputTable <- rename(inputTable, replace=c("normalizedActivity"="Normalized Activity"), warn_missing=FALSE)
  
  #   inputTable <- rename(inputTable, replace=c(""="Flag Type"), warn_missing=FALSE)
  #   inputTable <- rename(inputTable, replace=c(""="Flag Observation"), warn_missing=FALSE)
  #   inputTable <- rename(inputTable, replace=c(""="Flag Reason"), warn_missing=FALSE)
  #   inputTable <- rename(inputTable, replace=c(""="Flag Comment"), warn_missing=FALSE)
  #   inputTable <- rename(inputTable, replace=c(""="Auto Flag Type"), warn_missing=FALSE)
  #   inputTable <- rename(inputTable, replace=c(""="Auto Flag Observation"), warn_missing=FALSE)
  #   inputTable <- rename(inputTable, replace=c(""="Auto Flag Reason"), warn_missing=FALSE)

  return(inputTable)

}