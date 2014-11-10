# reads the assay files for the actual data


readDataTitles <- function(fileName, parseParams, headerRowVector, tempFilePath) {
  # plateFormatSingleFile
  if(is.na(parseParams$dataTitleIdentifier)){
    dataTitles <- data.table(dataTitle=c(paste0("R", 1:length(headerRowVector))), 
                             readOrder=1:length(headerRowVector))
  } else {
    dataTitleRowVector <- getDataRowNumber(fileName, 
                                           searchString=parseParams$dataTitleIdentifier, 
                                           tempFilePath=tempFilePath)
    
    titleRowTable <- data.table(titleRow=dataTitleRowVector, readOrder=1:length(dataTitleRowVector))
    
    dataTitles <- titleRowTable[ , read.table(fileName, sep=parseParams$sepChar, skip=titleRow-1, nrows=1, header=FALSE, stringsAsFactors=FALSE)[1,1], by=readOrder]
    
    setnames(dataTitles,"V1","dataTitle")
    if (length(grep("Feature: ", dataTitles$dataTitle)) != 0) {
      dataTitles$dataTitle <- gsub("Feature: ", "", dataTitles$dataTitle)
    }
  }
  
  return(dataTitles)
}