

specificDataPreProcessor <- function (parameters, folderToParse, errorEnv, 
                                      dryRun, instrumentClass, testMode, tempFilePath) {
  ##### exampleClient #####
  # 
  # This function sources the functions that parse the instrument files
  #
  # Input:  parameters (list of GUI parameters)
  #         folderToParse (folder where the raw data files are)
  #         errorEnv
  #         dryRun (boolean)
  #         instrumentClass
  #         testMode (boolean)
  #         tempFilePath (where log files and ini files are saved)
  # Output: instrumentData (list of two data tables: plateAssociationDT, assayData)
  
  instrumentSpecificFolder <- "public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"
  
  fileList <- c(list.files(file.path(instrumentSpecificFolder, "/specificDataPreProcessorFiles/"), full.names=TRUE),
                list.files(file.path(instrumentSpecificFolder, instrumentClass), full.names=TRUE))
  lapply(fileList, source)
  
  readsTable <- getReadOrderTable(readList=parameters$primaryAnalysisReadList)
  
  ## TODO: dryRun should return "summaryInfo" here?
  
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