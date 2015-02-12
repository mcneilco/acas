context("Testing the function getting the .csv file name")

test_that("getCsvFileName fuctionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data")
  
  testFileName <- getCsvFileName(filePath=testFilePath, tempFilePath=tempFilePath)
  
  expect_that(testFileName, equals("NOP_SAR_11-6-13.csv"))
  
  
  rm(list=ls())
})