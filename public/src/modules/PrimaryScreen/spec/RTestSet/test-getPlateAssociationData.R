context("Testing the function getting the data from the plate association file")

test_that("getPlateAssociationData functionality", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFile <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data", "NOP_SAR_11-6-13.csv")
  
  expect_that(getPlateAssociationData(fileName=testFile, tempFilePath=tempFilePath)[1,assayBarcode], equals("X4502052"))
  expect_that(max(getPlateAssociationData(fileName=testFile, tempFilePath=tempFilePath)[,plateOrder]), equals(3))
  expect_that(nrow(getPlateAssociationData(fileName=testFile, tempFilePath=tempFilePath)), equals(3))
  expect_that(ncol(getPlateAssociationData(fileName=testFile, tempFilePath=tempFilePath)), equals(4))
  
  rm(list=ls())
})
