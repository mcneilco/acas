# Plate_Data & Plate_Order
# includes: assayFileName, number of data sets on plate, plate order

getPlateDataOrder <- function(filePath, instrument, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getPlateDataOrder\tfilePath=",filePath,"\tinstrument=",instrument), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  csvFile     					<- getCsvFileName(filePath, tempFilePath=tempFilePath)
  plateAssociationDT 		<- getPlateAssociationData(fileName=csvFile, tempFilePath=tempFilePath)
  
  assayBarcodeDT <- data.table(assayBarcode=plateAssociationDT$assayBarcode)
  assayBarcodeDT <- assayBarcodeDT[ , getAssayFileName(assayBarcode, tempFilePath=tempFilePath), by=assayBarcode]
  plateAssociationDT <- merge(plateAssociationDT, assayBarcodeDT, by="assayBarcode")
  
  if(length(assayBarcodeDT$assayFileName) != length(list.files(pattern=".txt"))) {
    stopUser("Not all assay files in file path are found in plate association.")
  }
  
  plateAssociationDT[ , instrumentType := checkInstrumentType(assayFileName, instrument, tempFilePath=tempFilePath), by=assayFileName]  
    
  parseParams <- loadInstrumentReadParameters(instrument, tempFilePath=tempFilePath)
  
  dataTitles <- plateAssociationDT[ , getDataSectionTitles(assayFileName, parseParams, tempFilePath=tempFilePath), by=assayFileName]
  
  setkey(plateAssociationDT, assayFileName)
  setkey(dataTitles, assayFileName)
  
  plateData <- merge(dataTitles, plateAssociationDT)
  
  # Reorder columns
  if (TRUE %in% grepl("sidecarBarcode", colnames(plateAssociationDT))) {
    setcolorder(plateData, c("plateOrder", "readOrder", "assayBarcode", "compoundBarcode_1", "sidecarBarcode", "assayFileName", "instrumentType", "dataTitle"))
  } else {
    setcolorder(plateData, c("plateOrder", "readOrder", "assayBarcode", "compoundBarcode_1", "assayFileName", "instrumentType", "dataTitle"))
  }
  
  return(plateData)
}