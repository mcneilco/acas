saveSpotfireFile <- function(inputTable, saveLocation, experiment, recordedBy) {
  
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
  
  fileLocation <- file.path(saveLocation,"spotfire-DRAFT.txt")
  write.table(inputTable, file=fileLocation, quote=FALSE, na="", row.names=FALSE, sep="\t")
  
  # targetPath is only for testing
  finalLocation <- moveFileToFileServer(fileLocation, experiment = experiment, recordedBy = recordedBy, 
                                        targetPath = "testSpotfire.txt")
  
  if (racas::applicationSettings$server.service.external.file.type == "custom") {
    # example: tibcospotfire:server:http\://dsantsptdxp/:analysis:/Tien/HTSWells:configurationBlock:HTSExperimentCode=\'EXPT-0002\';HTSDataURL=\'http\://imapp01-d\:8080/DNS/files/v1/Files/FILE1419587.txt\
    spotfirePrefix <- "tibcospotfire:server:http\\://dsantsptdxp/:analysis:/Lead Discovery/HTSWells:configurationBlock:"
    experimentParam <- paste0("HTSExperimentCode=\\'", experiment$codeName, "\\'")
    fileParam <- paste0("HTSDataURL=\\'", 
                        gsub(":", "\\\\:", racas::applicationSettings$server.service.external.file.service.url), 
                        finalLocation, "\\'")
    fileLink <- paste0(spotfirePrefix, experimentParam, ";", fileParam, ";")
  } else {
    fileLink <- paste0('http://', racas::applicationSettings$client.host, ":", 
                       racas::applicationSettings$client.port, '/dataFiles/', finalLocation)
  }
  return(list(title="Spotfire", link=fileLink))
}
