saveSpotfireFile <- function(inputTable, saveLocation, experiment, parameters, recordedBy, customSourceFileMove, skipFileText=FALSE) {
  # Saves spotfire file with correct column names

  # Change well type names
  translationList <- list(
    test = "Compound Discrete (Tested Lot)", 
    VC = "Vehicle Control",
    PC = "Positive Control",
    NC = "Negative Control",
    BLANK = "Blank")
  inputTable[wellType %in% names(translationList), wellType := unlist(translationList[wellType])]
 
  inputTable <- changeColNameReadability(inputTable, readabilityChange="computerToHuman", parameters)

  newColNames <- colnames(inputTable)
  
  # find activity columns
  activityColNames <- colnames(inputTable)[grep("^R[0-9]{1,2} ",colnames(inputTable))]
  
  # ANY NAMES CHANGED HERE should also be changed in getColNameChangeDataTables()
  requiredColumns <- c("Plate Type", "Assay Barcode", "Compound Barcode", "Source Type",
                       "Well", "Row", "Column", "Plate Order", "Well Type", "Corporate Name",
                       "Batch Number", "Corporate Batch Name", "Compound Concentration",
                       activityColNames,
                       "Efficacy", "SD Score", "Z' By Plate", "Raw Z' By Plate", "Z'", "Raw Z'", getActivityFullName(parameters), 
                       "Normalized Activity", "Flag Type", "Flag Observation", "Flag Reason",
                       "Flag Comment", "Auto Flag Type", "Auto Flag Observation",
                       "Auto Flag Reason", "experimentCode")
  
  # get the columns in the current inputTable that correspond to the spotfire spec
  keepColumns <- intersect(newColNames, requiredColumns)
  
  inputTable <- data.table(inputTable)
  # Because we are formatting for spotfire, we don't need to warn user that columns are being added or removed
  inputTable <- suppressWarnings(removeColumns(colNamesToCheck=newColNames,
                              colNamesToKeep=keepColumns,
                              inputDataTable=inputTable))
  inputTable <- suppressWarnings(addMissingColumns(requiredColNames=requiredColumns, inputTable))
  
  setcolorder(inputTable, requiredColumns)
  
  fileLocation <- getUploadedFilePath(file.path(saveLocation,"spotfire-DRAFT.txt"))
  write.table(inputTable, file=fileLocation, quote=FALSE, na="", row.names=FALSE, sep="\t")
  
  if (!skipFileText) {
    fileText <- readChar(fileLocation, nchar=file.info(fileLocation)$size)
  } else {
    fileText <- NULL
  }
  
  # targetPath is only for testing
  finalLocation <- moveFileToFileServer(fileLocation, experiment = experiment, recordedBy = recordedBy, 
                                        targetPath = "testSpotfire.txt", customSourceFileMove=customSourceFileMove)
  
  if (racas::applicationSettings$server.service.external.file.type == "custom") {
    # example: tibcospotfire:server:http\://severName/:analysis:/user/HTSWells:configurationBlock:HTSExperimentCode=\'EXPT-0002\';HTSDataURL=\'http\://imapp01-d\:8080/exampleClient/files/v1/Files/FILE1419587.txt\
    spotfirePrefix <- paste0("tibcospotfire:server:http\\://", 
                             racas::applicationSettings$client.service.spotfire.host,
                             "/:analysis:",
                             racas::applicationSettings$client.service.spotfire.path,
                             ":configurationBlock:")
    experimentParam <- paste0("HTSExperimentCode=\\'", experiment$codeName, "\\'")
    fileParam <- paste0("HTSDataURL=\\'", 
                        gsub(":", "\\\\:", racas::applicationSettings$server.service.external.file.service.url), 
                        finalLocation, ".txt\\'")
    userLink <- paste0(spotfirePrefix, experimentParam, ";", fileParam, ";")
    fileLink <- paste0(racas::applicationSettings$server.service.external.file.service.url, finalLocation)
  } else {
    userLink <- paste0('http://', racas::applicationSettings$client.host, ":", 
                       racas::applicationSettings$client.port, '/dataFiles/', finalLocation)
    fileLink <- paste0(racas::applicationSettings$server.nodeapi.path, '/dataFiles/', finalLocation)
  }
  return(list(title="Spotfire", link=userLink, fileLink=fileLink, fileText=fileText, download = FALSE))
}
