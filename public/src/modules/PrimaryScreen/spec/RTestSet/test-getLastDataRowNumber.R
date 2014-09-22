context("Testing the function getting the number of the last data row from the assay plate file")

test_that("getLastDataRowNumber functionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFile <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data", "X4502052.txt")
  testString <- "^[A-Z]{1,2}\t"
  
  expect_that(getLastDataRowNumber(fileName=testFile, searchString=testString, tempFilePath=tempFilePath), equals(39))
  
  testFile <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates", "arrayScan-YB000560.txt")
  
  expect_that(length(getLastDataRowNumber(fileName=testFile, searchString=testString, tempFilePath=tempFilePath)), equals(8))
  expect_that(getLastDataRowNumber(fileName=testFile, searchString=testString, tempFilePath=tempFilePath)[7], equals(83))
  
  rm(list=ls())
})