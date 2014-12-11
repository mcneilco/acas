# Gets and formats compound data table
# Input: dataTable (from iniData)
# Output: allCompoundData



formatCompoundData <- function(assayCompoundDT, assayData, testMode, tempFilePath) {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin getAllCompoundData"), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  compoundData <- data.table(getCompoundPlateData(barcodes=assayCompoundDT$cmpdBarcode, testMode=testMode, tempFilePath=tempFilePath))
  
  if(length(grep("sidecar", assayCompoundDT$sourceType)) > 0) {
    
    setkey(assayData, assayBarcode)
    setkey(assayCompoundDT, assayBarcode)
    sideCarAssayData <- merge(assayData[ ,list(assayBarcode, wellReference)], assayCompoundDT[sourceType=='sidecar', list(cmpdBarcode) ,by=list(assayBarcode)])
    
    setkeyv(sideCarAssayData, c("cmpdBarcode", "wellReference"))
    setkeyv(compoundData, c("cmpdBarcode", "wellReference"))
    sideCarAssayData <- merge(sideCarAssayData, compoundData)
    sideCarAssayData$sourceType <- "sidecar"
  }
  

  setkey(assayData, assayBarcode)
  setkey(assayCompoundDT, assayBarcode)
  cmpdAssayData <- merge(assayData[ ,list(assayBarcode, wellReference)], assayCompoundDT[sourceType=='compound', list(cmpdBarcode) ,by=list(assayBarcode)])
  
  setkeyv(cmpdAssayData, c("cmpdBarcode", "wellReference"))
  setkeyv(compoundData, c("cmpdBarcode", "wellReference"))
  cmpdAssayData <- merge(cmpdAssayData, compoundData)
  cmpdAssayData$sourceType <- "compound"
  
  if(length(grep("sidecar", assayCompoundDT$sourceType)) > 0) {
    allCompoundData <- rbind(sideCarAssayData, cmpdAssayData)
  } else {
    allCompoundData <- cmpdAssayData
  }
  
  return(allCompoundData)
}