saveSpotfireFile <- function(inputTable, saveLocation) {
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
  
  inputTable <- addMissingColumns(requiredColNames=requiredColumns, inputTable)
  setcolorder(inputTable, requiredColumns)
  
  write.table(inputTable, file=file.path(saveLocation,"spotfire.csv"), quote=FALSE, na="", row.names=FALSE, sep="\t")
  
  return(file.path(saveLocation, "spotfire.csv"))
}

renameColumnsForSpotfire <- function(inputTable){
  # Changes the names of the resultTable to conform with a spotfire file
  # ANY NAMES CHANGED HERE should also be changed in createSpotfireFile()
  require(plyr)
  
  
  
  ### Use this 'rename' until Flag column names have been stabilized
  inputTable <- rename(inputTable, replace=c("plateType"="Plate Type",
                                             "assayBarcode"="Assay Barcode",
                                             "cmpdBarcode"="Compound Barcode",
                                             "sourceType"="Source Type",
                                             "well"="Well",
                                             "row"="Row",
                                             "column"="Column",
                                             "plateOrder"="Plate Order",
                                             "wellType"="Well Type",
                                             "batchName"="Corporate Name",
                                             "batch_number"="Batch Number",
                                             "batchCode"="Corporate Batch Name",
                                             "cmpdConc"="Compound Concentration",
                                             "transformed_% efficacy"="Efficacy",
                                             "transformed_sd"="SD Score",
                                             "zPrimeByPlate"="Z' By Plate",
                                             "zPrime"="Z'",
                                             "activity"="Activity",
                                             "normalizedActivity"="Normalized Activity"), warn_missing=FALSE)
  
  #### Use this 'rename' instead once Flag column names have been stabilized.
  #   inputTable <- rename(inputTable, replace=c("plateType"="Plate Type",
  #                                              "assayBarcode"="Assay Barcode",
  #                                              "cmpdBarcode"="Compound Barcode",
  #                                              "sourceType"="Source Type",
  #                                              "well"="Well",
  #                                              "row"="Row",
  #                                              "column"="Column",
  #                                              "plateOrder"="Plate Order",
  #                                              "wellType"="Well Type",
  #                                              "batchName"="Corporate Name",
  #                                              "batch_number"="Batch Number",
  #                                              "batchCode"="Corporate Batch Name",
  #                                              "cmpdConc"="Compound Concentration",
  #                                              "transformed_% efficacy"="Efficacy",
  #                                              "transformed_sd"="SD Score",
  #                                              "zPrimeByPlate"="Z' By Plate",
  #                                              "zPrime"="Z'",
  #                                              "activity"="Activity",
  #                                              "normalizedActivity"="Normalized Activity",
  #                                              ""="Flag Type",
  #                                              ""="Flag Observation",
  #                                              ""="Flag Reason",
  #                                              ""="Flag Comment",
  #                                              ""="Auto Flag Type",
  #                                              ""="Auto Flag Observation",
  #                                              ""="Auto Flag Reason"), warn_missing=FALSE)
  
  return(inputTable)
  
}