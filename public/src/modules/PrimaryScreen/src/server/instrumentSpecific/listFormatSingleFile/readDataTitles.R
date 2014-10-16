# reads the assay files for the actual data


readDataTitles <- function(fileName, parseParams, headerRowVector, tempFilePath) {
  # listFormatSingleFile
  # currently only works for biacore
  if (length(headerRowVector) == 1) {
    dataTitles <- data.table(dataTitle=setdiff(colnames(read.table(fileName, 
                                                                   sep=parseParams$sepChar, 
                                                                   skip=headerRowVector-1, 
                                                                   nrows=1, header=TRUE)), c("Well", "X")))
    dataTitles$readOrder <- 1:nrow(dataTitles) 
  } else {
    stopUser("Unknown error in readDataTitles function.")
  }
  
  return(dataTitles)
}