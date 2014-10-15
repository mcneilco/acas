# getCsvFileName.R

getCsvFileName <- function(filePath=".", tempFilePath){
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getCsvFileName\tfilePath=",filePath), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  csvFiles <- list.files(path=filePath, pattern=".csv")
  csvFileName <- NULL
  
  if (length(csvFiles) == 1){
    csvFileName <- csvFiles[1]	
  } else if (length(csvFiles) > 1) {
      stopUser("Multiple CSV FILES found. Expecting a single CSV file.")
  }else {
      stopUser("CSV FILE not found")
  }
  
  return(csvFileName)
}