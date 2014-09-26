

specificDataPreProcessor <- function (parameters, folderToParse, errorEnv, dryRun, instrumentClass) {
  fileList <- c(list.files(file.path(Sys.getenv("ACAS_HOME"),"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(Sys.getenv("ACAS_HOME"),"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  readsTable <- getReadOrderTable(readList=parameters$primaryAnalysisReadList)
  
  matchNames <- parameters$matchReadName
  
  instrumentData <- getInstrumentSpecificData(filePath=file.path(Sys.getenv("ACAS_HOME"), folderToParse), 
                                              instrument=parameters$instrumentReader, 
                                              readsTable=readsTable, 
                                              testMode=TRUE,
                                              errorEnv=errorEnv,
                                              tempFilePath=NULL, # this should be the analysis folder?
                                              dryRun=dryRun,
                                              matchNames=matchNames)
  
  return(instrumentData)
}