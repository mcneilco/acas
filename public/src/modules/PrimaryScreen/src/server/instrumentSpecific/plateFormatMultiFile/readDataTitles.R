# reads the assay files for the actual data


readDataTitles <- function(fileName, parseParams, headerRowVector, tempFilePath) {
  # plateFormatMultiFile
  dataTitleRowVector <- getDataRowNumber(fileName, 
                                         searchString=parseParams$dataTitleIdentifier, 
                                         tempFilePath=tempFilePath)
  
  titleRowTable <- data.table(titleRow=dataTitleRowVector)
  
  dataTitles <- titleRowTable[ , read.table(fileName, 
                                            sep=parseParams$sepChar, 
                                            skip=titleRow-1, 
                                            nrows=1, 
                                            header=FALSE, 
                                            stringsAsFactors=FALSE)[1,1], by=titleRow]
  
  setnames(dataTitles,"V1","dataTitle")
  dataTitles$titleRow <- NULL
  
  return(dataTitles)
}