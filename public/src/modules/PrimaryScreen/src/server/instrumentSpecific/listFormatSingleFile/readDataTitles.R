# reads the assay files for the actual data


readDataTitles <- function(fileName, parseParams, headerRowVector, tempFilePath) {
  # listFormatSingleFile
  if (length(headerRowVector) == 1) {
    dataTitles <- data.table(dataTitle=setdiff(colnames(read.table(fileName, 
                                                                   sep=parseParams$sepChar, 
                                                                   skip=headerRowVector-1, 
                                                                   nrows=1, header=TRUE,
                                                                   check.names=FALSE, fill=NA,
                                                                   comment.char="")), 
                                               c("X")))[dataTitle!=""]
    dataTitles$readOrder <- 1:nrow(dataTitles) 
  } else {
    stopUser("Internal error: Unknown error in readDataTitles function.")
  }
  
  return(dataTitles)
}