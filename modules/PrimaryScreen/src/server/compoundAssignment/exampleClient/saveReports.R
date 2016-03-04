saveReports <- function(resultTable, spotfireResultTable, saveLocation, experiment, parameters, recordedBy) {
  # Runs all of the reports needed for a successfully dry run
  #output: a list of links to files
  library(gdata)
  
  reportList <- list()
  
  spotfireHost <- racas::applicationSettings$client.service.spotfire.host
  if (is.null(spotfireHost) || gdata::trim(spotfireHost) == "") {
    reportList$txtFile <- saveTxtReport(inputTable=spotfireResultTable, saveLocation, 
                                        experiment, parameters, recordedBy)
  } else {
    reportList$spotfireFile <- saveSpotfireFile(inputTable=spotfireResultTable, saveLocation, 
                                                experiment, parameters, recordedBy)
  }
  
  return(reportList)
}

saveTxtReport <- function(inputTable, saveLocation, experiment, parameters, recordedBy) {
  # Saves tab-delimited report, responds with a list of list(title="All Data", link=userLink, fileLink=fileLink, fileText=fileText, download = TRUE)
  
  # Change well type names
  translationList <- list(
    test = "Tested Batch", 
    VC = "Vehicle Control",
    PC = "Positive Control",
    NC = "Negative Control",
    BLANK = "Blank")
  inputTable[, wellType := unlist(translationList[wellType])]
  
  inputTable <- changeColNameReadability(inputTable, readabilityChange="computerToHuman", parameters)
  inputTable <- data.table(inputTable)
  
  # Add path to inlineFileValues
  resultTypes <- fread("public/src/modules/PrimaryScreen/src/conf/savingSettings.csv")
  inlineFileValueColumns <- resultTypes[valueType == "inlineFileValue", columnName]
  for (ifvc in inlineFileValueColumns) {
    if (ifvc %in% names(inputTable)) {
      inputTable[!is.na(get(ifvc)), eval(ifvc) := paste0(racas::applicationSettings$server.nodeapi.path, '/dataFiles/', get(ifvc))]
    }
  }
  
  fileLocation <- file.path(saveLocation,"allData-DRAFT.txt")
  write.table(inputTable, file=fileLocation, quote=TRUE, na="", row.names=FALSE, sep="\t")
  
  fileText <- readChar(fileLocation, nchar=file.info(fileLocation)$size)
  
  # targetPath is only for testing
  finalLocation <- moveFileToFileServer(fileLocation, experiment = experiment, recordedBy = recordedBy, 
                                        targetPath = "allData.txt")
  
  if (racas::applicationSettings$server.service.external.file.type == "custom") {
    stop("server.service.external.file.type == 'custom' not implemented for Txt file")
  } else {
    userLink <- paste0('http://', racas::applicationSettings$client.host, ":", 
                       racas::applicationSettings$client.port, '/dataFiles/', finalLocation)
    fileLink <- paste0(racas::applicationSettings$server.nodeapi.path, '/dataFiles/', finalLocation)
  }
  return(list(title="All Data", link=userLink, fileLink=fileLink, fileText=fileText, download = TRUE))
}
