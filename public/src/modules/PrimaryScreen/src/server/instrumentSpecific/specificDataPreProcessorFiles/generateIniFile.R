# Create initial file
#
# Input: file path
# Output: .ini file

generateIniFile <- function(filePath, tempFilePath, instrument) {
  
  #   setwd(filePath)
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin generateIniFile\tfilePath=",filePath), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
 
  plateData <- getPlateDataOrder(filePath=filePath, instrument=instrument, tempFilePath=tempFilePath)
  plateDataHeader <- "[Plate_Data_Order]"  
  
  write.table(plateDataHeader, file = file.path(tempFilePath, "defaultlog.ini"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  suppressWarnings(write.table(plateData, file = file.path(tempFilePath, "defaultlog.ini"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE))

  #   iniData$pinTransfer <- getPinTransfer(plateAssociationDT=iniData$plateData, testMode=testMode, tempFilePath=tempFilePath)
  #   pinTransferHeader <- "[Pin_Transfer]"
  #   write.table(paste0("\n",pinTransferHeader), file = file.path(tempFilePath, "defaultlog.ini"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  #   suppressWarnings(write.table(iniData$pinTransfer, file = file.path(tempFilePath, "defaultlog.ini"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE))
  
  # This is included in the Plate_Data_Order section. Commented out just in case we want to use it later.  
  #   # Plate_Data_Titles
  #   # includes: data titles (multiple for plates with multiple data sets), readOrder (order in which the data titles appear)
  #   
  #   dataTitles <- (c(dataTitle=unique(plateReadOrder$dataTitle), assayFileName=unique(assayFileName)))
  #   setkey(dataTitles, assayFileName)
  #   setkey(assayFileNames, assayFileName)
  #   
  #   plateDataTitles <- merge(assayFileNames, dataTitles)
  #   plateDataTitlesHeader <- "[Plate_Data_Titles]"
  #   
  #   write.table(paste0("\n",plateDataTitlesHeader), file.path(tempFilePath, "defaultlog.ini"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  #   write.table(plateDataTitles, file.path(tempFilePath, "defaultlog.ini"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE)
  #
  #   iniData$plateDataTitles <- plateDataTitles

  return(plateData)
}