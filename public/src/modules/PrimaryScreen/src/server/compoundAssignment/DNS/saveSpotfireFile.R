saveSpotfireFile <- function(inputTable, saveLocation) {
  
  inputTable <- changeColNameReadability(inputTable, readabilityChange="computerToHuman")

  newColNames <- colnames(inputTable)
  
  # find activity columns
  activityColNames <- colnames(inputTable)[grep("^R[0-9]{1,2} ",colnames(inputTable))]
  
  # ANY NAMES CHANGED HERE should also be changed in getColNameChangeDataTables()
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
  # Because we are formatting for spotfire, we don't need to warn user that columns are being added or removed
  inputTable <- suppressWarnings(removeColumns(colNamesToCheck=newColNames,
                              colNamesToKeep=keepColumns,
                              inputDataTable=inputTable))
  inputTable <- suppressWarnings(addMissingColumns(requiredColNames=requiredColumns, inputTable))
  
  setcolorder(inputTable, requiredColumns)
  
  write.table(inputTable, file=file.path(saveLocation,"spotfire-DRAFT.txt"), quote=FALSE, na="", row.names=FALSE, sep="\t")
  
  return(file.path(saveLocation, "spotfire-DRAFT.txt"))
}


  
  