# This function returns the parameters for instrument types. 
#
# Input:  instrumentType
# Output: assay file parameters (list)

loadInstrumentReadParameters <- function(instrumentType, tempFilePath) {

  # runlog
  write.table(paste0(Sys.time(), "\tbegin loadInstrumentReadParameters\tinstrumentType=",instrumentType), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  #   load(system.file(file.path("instruments",instrumentType,"paramList.Rda"), package="rdap"))
  paramList <- fromJSON(readLines(file.path(Sys.getenv("ACAS_HOME"), "public/src/modules/PrimaryScreen/src/conf/instruments",instrumentType,"paramList.json")))$paramList
  if(paramList$dataTitleIdentifier == "NA") {
    paramList$dataTitleIdentifier <- NA
  }
  
  return(paramList)  
}