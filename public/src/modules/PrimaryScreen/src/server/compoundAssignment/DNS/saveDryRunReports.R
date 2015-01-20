saveDryRunReports <- function(resultTable, spotfireResultTable, saveLocation, experiment, recordedBy) {
  # Runs all of the reports needed for a successfully dry run
  #output: a list of links to files
  reportList <- list()
  
  reportList$spotfireFile <- saveSpotfireFile(inputTable=spotfireResultTable, saveLocation, experiment, recordedBy)
  
  return(reportList)
}