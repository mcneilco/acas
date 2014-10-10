### Compound data operations start here
getAssayCompoundData <- function (filePath, plateData, testMode, tempFilePath, assayData) {
  originalWD <- getwd()
  setwd(filePath)
  assayCompoundDT <- getPinTransfer(plateAssociationDT=plateData, testMode=testMode, tempFilePath=tempFilePath)
  
  allCompoundData <- formatCompoundData(assayCompoundDT, assayData, testMode=testMode, tempFilePath=tempFilePath)
  
  setkeyv(allCompoundData, c("assayBarcode", "wellReference"))
  setkeyv(assayData, c("assayBarcode", "wellReference"))
  
  allAssayCompoundData <- merge(assayData, allCompoundData, all.x=TRUE)
  setkeyv(allAssayCompoundData, c("assayBarcode", "rowName", "wellReference"))
  
  allAssayCompoundData$assayFileName <- NULL
  
  colOrder <- c("plateType","assayBarcode","cmpdBarcode","sourceType","wellReference",
                "rowName","colName","corp_name","batch_number","cmpdConc","supplier","plateOrder")
  
  activityColumns <- setdiff(colnames(allAssayCompoundData), colOrder)
  setcolorder(allAssayCompoundData, c(colOrder, activityColumns))
  
  #setwd(normalizePath("../Analysis/"))
  if(testMode) {
    write.table(allAssayCompoundData, file=file.path(tempFilePath, "output_well_data.srf"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE, na="")
  } else {
    write.table(allAssayCompoundData, file="../Analysis/output_well_data.srf", append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE, na="")
  }
  
  setwd(originalWD)  
  
  # Needs to return a list for error catching
  # return(list(filePath=filePath, activity=allAssayCompoundData[ , activityColumns, with=FALSE]))
  return(list(filePath=filePath, allAssayCompoundData=allAssayCompoundData, activityColNames=activityColumns))
}