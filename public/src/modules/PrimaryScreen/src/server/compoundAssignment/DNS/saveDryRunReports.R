saveDryRunReports <- function(resultTable, saveLocation) {
  # Runs all of the reports needed for a successfully dry run
  reportList <- list()
  
  reportList$spotfireFile <- sub(getUploadedFilePath(""), "",
                                 saveSpotfireFile(inputTable=resultTable, saveLocation))
  
  return(reportList)
}