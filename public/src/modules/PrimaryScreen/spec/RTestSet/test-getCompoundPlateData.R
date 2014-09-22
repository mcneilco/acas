context("Testing the function getting the compound plate data")

test_that("getCompoundPlateData fuctionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testPlateData <- getCompoundPlateData(barcodes=c("C1108712", "C1104682"), testMode=TRUE, tempFilePath=tempFilePath)
  
  expect_that(testPlateData[1,6], equals(8.5714))
  expect_that(testPlateData[126,4], equals("DNS001133837"))
  expect_that(ncol(testPlateData), equals(7))
  expect_that(nrow(testPlateData), equals(1376))
  rm(list=ls())
})