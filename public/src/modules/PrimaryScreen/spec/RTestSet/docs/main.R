# I want to read the data from the put-together test file so that I can take out 
# the columns that I want, and recreate the function that will put all of the 
# data in the output file.
#
# Input: test well mod file, tab delimited (fileName)
# Output: compound data (data frame?)
# Potential issues:
#   not all rows have the same number of columns

#   require(data.table)
#   require(testthat)
  
  plateAssociationData <- data.table(getPlateAssociationData(fileName=system.file("docs", "test-microBeta-NOP binding 10-31-13.csv", package="rdap")))
  plateAssociationData$plateOrder <- (1:nrow(plateAssociationData))
  
  # This uses getEntireAssayData to make the table, has "invalid in this locale" error but still compiles the correct data
  # system.file("docs", paste0("test-microBeta-", assayBarcode, ".txt"), package="rdap") 
      # tried to use this to magically pass through 
      # assayBarcode and file name to all of the functions.
  # list.files(path = "~/Documents/DAP MODULES/MicroBeta/TEST0002732/raw_data/", pattern="*.txt")
  microBetaAssayData <- plateAssociationData[, getMicroBetaAssayData(paste0("~/Documents/acas/rdap/inst/docs/test-microBeta-", assayBarcode, ".txt")), by=assayBarcode]
  
  setkey(plateAssociationData, assayBarcode)
  setkey(microBetaAssayData, assayBarcode)
  microBetaAssayData <- merge(plateAssociationData, microBetaAssayData)
  
  setnames(microBetaAssayData, "compound1","compoundBarcode")
  setkeyv(microBetaAssayData, c("wellReference","compoundBarcode"))
  
  microBetaCompoundData <- getMicroBetaCompoundData(fileName="~/Documents/DAP MODULES/MicroBeta/TEST0002732/TEST0002732_well_data.out", sepChar="\t")
  
  fileToWrite <- merge(microBetaAssayData,microBetaCompoundData, all.x=TRUE)
  expect_that(max(nrow(microBetaCompoundData),nrow(microBetaAssayData)),equals(nrow(fileToWrite)))
  expect_that(fileToWrite[768,assayBarcode], equals("E0021206A"))
  expect_that(fileToWrite[764,sourcePlateType], equals(as.character(NA)))
  
  # write.table(fileToWrite, file="~/Documents/test/fileToWrite.txt", sep="\t", quote=FALSE,row.names=FALSE)
