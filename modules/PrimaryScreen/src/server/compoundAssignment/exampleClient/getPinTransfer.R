# Pin_transfer
# includes: compound & sidecar barcodes, as well as plate type

getPinTransfer <- function(plateAssociationDT, testMode, tempFilePath) {
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getPinTransfer\ttestMode=",testMode), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  compoundBarcodes <- getCompoundBarcodes(plateAssociationDT, tempFilePath=tempFilePath)
  compoundData <- as.data.table(getCompoundPlateData(barcodes=compoundBarcodes, testMode=testMode, tempFilePath=tempFilePath))
  
  cmpdBarcodeCheck <- setdiff(compoundBarcodes, compoundData$cmpdBarcode)
  if (length(cmpdBarcodeCheck) != 0) {
    stopUser(paste0("Missing compound plate data for ",length(cmpdBarcodeCheck), " compound(s): '", paste(cmpdBarcodeCheck, collapse="', '"), "'"))
  }
  
  assayCompoundDT <- getAssayCompoundDT(plateAssociationDT, tempFilePath=tempFilePath)
  setkey(assayCompoundDT, "cmpdBarcode")
  compoundDataDT <- unique(data.table(compoundData$cmpdBarcode, compoundData$plateType))
  setnames(compoundDataDT, c("V1", "V2"), c("cmpdBarcode", "plateType"))
  setkey(compoundDataDT, "cmpdBarcode")
  
  pinTransfer <- merge(assayCompoundDT, compoundDataDT)
  setcolorder(pinTransfer, c("assayBarcode", "cmpdBarcode", "sourceType", "plateType"))
  
  return(pinTransfer)
}