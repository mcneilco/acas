### Compound data operations start here
getAssayCompoundData <- function (filePath, plateData, testMode, tempFilePath, assayData) {
  
  assayCompoundDT <- getPinTransfer(plateAssociationDT=plateData, testMode=testMode, tempFilePath=tempFilePath)
  
  allCompoundData <- formatCompoundData(assayCompoundDT, assayData, testMode=testMode, tempFilePath=tempFilePath)
  
  # Check to make sure that wells don't have more than one compound listed
  overlappingPlate <- list()
  for (barcode in unique(allCompoundData[, assayBarcode])) {
    if(length(unique(allCompoundData[assayBarcode == barcode, wellReference])) != 
         length(allCompoundData[assayBarcode == barcode, wellReference])) {
      overlappingPlate <- c(overlappingPlate, barcode)
    }
  }
  if(length(overlappingPlate) > 0) {
    stopUser(paste0("Some sidecar and compound plates have overlapping wells.\n Please check the plates associated with the following assay(s): ", 
             paste(unlist(overlappingPlate), collapse=", ")))
  }
  
  setkeyv(allCompoundData, c("assayBarcode", "wellReference"))
  setkeyv(assayData, c("assayBarcode", "wellReference"))
  
  allAssayCompoundData <- merge(assayData, allCompoundData, all.x=TRUE)
  setkeyv(allAssayCompoundData, c("assayBarcode", "rowName", "wellReference"))
  
  allAssayCompoundData[ , assayFileName := NULL]
  
  colOrder <- c("plateType","assayBarcode","cmpdBarcode","sourceType","wellReference",
                "rowName","colName","corp_name","batch_number","cmpdConc","supplier","plateOrder")
  
  activityColumns <- setdiff(colnames(allAssayCompoundData), colOrder)
  setcolorder(allAssayCompoundData, c(colOrder, activityColumns))
  
  #setwd(normalizePath("../Analysis/"))
  write.table(allAssayCompoundData, file=file.path(tempFilePath, "output_well_data.srf"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE, na="")
  
  # Needs to return a list for error catching
  # return(list(filePath=filePath, activity=allAssayCompoundData[ , activityColumns, with=FALSE]))
  return(list(filePath=filePath, allAssayCompoundData=allAssayCompoundData, activityColNames=activityColumns))
}