
removeColumns <- function(colNamesToCheck, colNamesToKeep, inputDataTable, tempFilePath) {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin removeColumns"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  removeList <- list()
  for(name in colNamesToCheck) {
    if(!grepl(paste0("(",paste(gsub("\\{","\\\\{",colNamesToKeep), collapse="|"), ")"), name)) {
      inputDataTable[[name]] <- NULL
      removeList[[length(removeList) + 1]] <- name
    }
  }
  
  if(length(removeList) == 1) {
    warnUser(paste0("Removed 1 data column: '", removeList[[1]], "'"))
  } else if(length(removeList) > 1) {
    warnUser(paste0("Removed ",length(removeList)," data columns: '", paste(removeList, collapse="','"), "'"))
  }
  return(inputDataTable)
}