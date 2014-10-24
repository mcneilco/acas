

specificDataPreProcessor <- function (parameters, folderToParse, errorEnv, dryRun, instrumentClass, testMode, tempFilePath) {
  # DNS 
  fileList <- c(list.files(file.path("public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE),
                list.files(file.path("public/src/modules/PrimaryScreen/src/server/instrumentSpecific/", instrumentClass), full.names=TRUE))
  lapply(fileList, source)
  
  readsTable <- getReadOrderTable(readList=parameters$primaryAnalysisReadList)
  
  matchNames <- parameters$matchReadName
  
  instrumentData <- getInstrumentSpecificData(filePath=folderToParse, 
                                              instrument=parameters$instrumentReader, 
                                              readsTable=readsTable, 
                                              testMode=testMode,
                                              errorEnv=errorEnv,
                                              tempFilePath=tempFilePath, # this should be the analysis folder?
                                              dryRun=dryRun,
                                              matchNames=matchNames)
  
  return(instrumentData)
}