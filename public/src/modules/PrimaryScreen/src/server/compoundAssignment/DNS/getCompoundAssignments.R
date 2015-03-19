
getCompoundAssignments <- function(folderToParse, instrumentData, testMode, parameters, tempFilePath) {
  # DNS
  fileList <- list.files("public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS", full.names=TRUE)
  lapply(fileList, source)
  
  assayCompoundData <- getAssayCompoundData(filePath=folderToParse,
                                            plateData=instrumentData$plateAssociationDT,
                                            testMode=testMode,
                                            tempFilePath=tempFilePath,
                                            assayData=instrumentData$assayData)
  
  resultTable <- assayCompoundData$allAssayCompoundData[ , c("plateType",
                                                             "assayBarcode",
                                                             "cmpdBarcode",
                                                             "sourceType",
                                                             "wellReference",
                                                             "rowName",
                                                             "colName",
                                                             "plateOrder",
                                                             "corp_name",
                                                             "batch_number",
                                                             "cmpdConc",
                                                             assayCompoundData$activityColNames), with=FALSE]
  # TODO: Check concUnit prior to making this adjustment
  resultTable[ , cmpdConc := cmpdConc * 1000]
  
  resultTable[, batchCode := paste0(corp_name,"::",batch_number)]
  resultTable[batchCode == "NA::NA", batchCode := "::"]
  #   setnames(resultTable, c("wellReference", "assayBarcode", "cmpdConc", "corp_name"), c("well", "barcode", "concentration", "batchName"))
  setnames(resultTable, c("wellReference","rowName", "colName", "corp_name"), c("well","row", "column", "batchName"))
  
  # apply dilution
  if (!is.null(parameters$dilutionRatio) && parameters$dilutionRatio != "") {
    resultTable$cmpdConc <- resultTable$cmpdConc / parameters$dilutionRatio
  }
  
  return(resultTable)
}
