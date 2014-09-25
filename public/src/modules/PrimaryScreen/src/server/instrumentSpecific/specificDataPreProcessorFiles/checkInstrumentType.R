# checkInstrumentType.R

# checks the instument reader type to the user input

checkInstrumentType <- function(assayFileName, instrument, tempFilePath){
  # Args:
  #   assayFileName: assay file name
  #   inspectFile: boolean to inspect the file to determine the instrument reader type
  #                future option to pull instrument type from the experiment meta data
  # Returns:
  #   instrumentType: the instrument reader type 
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getInstrumentType\tassayFileName=",assayFileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  if (!file.exists(file.path(Sys.getenv("ACAS_HOME"), "public/src/modules/PrimaryScreen/src/conf/instruments",instrument)) || 
        !file.exists(file.path(Sys.getenv("ACAS_HOME"), "public/src/modules/PrimaryScreen/src/conf/instruments",instrument,"instrumentType.json")) ||
        !file.exists(file.path(Sys.getenv("ACAS_HOME"), "public/src/modules/PrimaryScreen/src/conf/instruments",instrument,"detectionLine.json")) ||
        !file.exists(file.path(Sys.getenv("ACAS_HOME"), "public/src/modules/PrimaryScreen/src/conf/instruments",instrument,"paramList.json"))) 
  {
    stopUser("Instrument not loaded in to system.")
  } 
  
  instrumentType <- fromJSON(readLines(system.file(file.path("instruments",instrument,"instrumentType.json"), package="rdap")))$instrumentType
  if(instrumentType != instrument) {
    stopUser("Instrument data loaded incorrectly.")
  }
  
  detectionLine <- fromJSON(readLines(system.file(file.path("instruments",instrument,"detectionLine.json"), package="rdap")))$detectionLine
  rawLines <- readLines(assayFileName, n = 10, warn = FALSE, ok = TRUE, encoding="UTF-8")
  if (length(grep(detectionLine, rawLines)) == 0) {
    stopUser(paste0("Input instrument (",instrument,") does not match instrument type in file"))
  }    
  return(instrumentType)
}
