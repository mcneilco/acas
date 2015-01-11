saveDryRunReports <- function(resultTable, spotfireResultTable, saveLocation) {
  # Runs all of the reports needed for a successfully dry run
  reportList <- list()
  
  reportList$spotfireFile <- sub(getUploadedFilePath(""), "",
                                 saveSpotfireFile(inputTable=spotfireResultTable, saveLocation))
  
  return(reportList)
}