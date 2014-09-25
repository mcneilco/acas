addMissingColumns <- function(colNamesToKeep, inputDataTable, tempFilePath)  {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin addMissingColumns"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  for(column in colNamesToKeep) {
    if(!grepl(gsub("\\{","",column), gsub("\\{","",paste(colnames(inputDataTable),collapse=",")))) {
      inputDataTable[[column]] <- as.numeric(NA)
      warnUser(paste0("Adding column '",column,"', coercing to NA."))
    }
  }
  return(inputDataTable)
}