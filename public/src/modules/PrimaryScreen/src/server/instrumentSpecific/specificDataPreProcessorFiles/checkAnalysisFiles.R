# Checks to see if analysis files already exist

checkAnalysisFiles <- function(testMode, dryRun, analysisFilePath=file.path("..","analysis")) {
  if(!testMode) {
    existingFile <- list()
    if(file.exists(file.path(analysisFilePath, "output_well_data.srf"))) {
      existingFile[[length(existingFile)+1]] <- "output_well_data.srf"
    }
    if(file.exists(file.path(analysisFilePath, "runlog.tab")) && dryRun) {
      existingFile[[length(existingFile)+1]] <- "runlog.tab"
    }
    if(file.exists(file.path(analysisFilePath, "defaultlog.ini")) && dryRun) {
      existingFile[[length(existingFile)+1]] <- "defaultlog.ini"
    }
    if(length(existingFile) == 1) {
      stopUser(paste0("Analysis file already exists for this experiment: ", paste(existingFile, collapse=", ")))
    } else if(length(existingFile) !=0) {
      stopUser(paste0("Analysis files already exist for this experiment: ", paste(existingFile, collapse=", ")))
    }
  }
}