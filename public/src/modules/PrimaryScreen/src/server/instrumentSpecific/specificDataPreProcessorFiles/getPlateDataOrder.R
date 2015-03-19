# Plate_Data & Plate_Order
# includes: assayFileName, number of data sets on plate, plate order

getPlateDataOrder <- function(filePath, instrument, tempFilePath) {
  #
  # Reads the .csv file and scans the .txt files to return # of reads, data tiles, and plate order
  #
  # Input:  filePath (folder where the raw data files are)
  #         instrument (instrument type that is being parsed)
  #         tempFilePath (where log files and ini files are saved)
  # Output: plateData (data.table with column names)
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getPlateDataOrder\tfilePath=",filePath,"\tinstrument=",instrument), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  csvFile     					<- getCsvFileName(filePath, tempFilePath=tempFilePath)
  plateAssociationDT 		<- getPlateAssociationData(fileName=file.path(filePath, csvFile), tempFilePath=tempFilePath)
  
  # Get the assay file names in to the plate association DT
  assayBarcodeDT <- data.table(assayBarcode=plateAssociationDT$assayBarcode)
  assayBarcodeDT <- assayBarcodeDT[ , getAssayFileName(assayBarcode, filePath=filePath, tempFilePath=tempFilePath), by=assayBarcode]
  plateAssociationDT <- merge(plateAssociationDT, assayBarcodeDT, by="assayBarcode")
  
  if(length(assayBarcodeDT$assayFileName) != length(list.files(path=filePath, pattern=".txt", ignore.case=TRUE))) {
    filesNotListed <- setdiff(list.files(path=filePath, pattern=".txt", ignore.case=TRUE), assayBarcodeDT$assayFileName)
    warnUser(paste0("Not all assay files in file path are found in the plate association file: ", paste(filesNotListed, collapse=", ")))
  }
  
  plateAssociationDT[ , instrumentType := checkInstrumentType(assayFileName=file.path(filePath, assayFileName), instrument, tempFilePath=tempFilePath), by=assayFileName]  
    
  parseParams <- loadInstrumentReadParameters(instrument)
  
  dataTitles <- plateAssociationDT[ , getDataSectionTitles(fileName=file.path(filePath, assayFileName), parseParams, tempFilePath=tempFilePath), by=assayFileName]
  
  setkey(plateAssociationDT, assayFileName)
  setkey(dataTitles, assayFileName)
  
  plateData <- merge(dataTitles, plateAssociationDT)
  
  # Reorder columns
  if (TRUE %in% grepl("sidecarBarcode", colnames(plateAssociationDT))) {
    setcolorder(plateData, c("plateOrder", "readPosition", "assayBarcode", "compoundBarcode_1", "sidecarBarcode", "assayFileName", "instrumentType", "dataTitle"))
  } else {
    setcolorder(plateData, c("plateOrder", "readPosition", "assayBarcode", "compoundBarcode_1", "assayFileName", "instrumentType", "dataTitle"))
  }
  
  return(plateData)
}