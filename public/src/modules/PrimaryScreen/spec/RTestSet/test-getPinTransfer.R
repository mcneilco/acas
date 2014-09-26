context("Testing the function that gets the pin transfer data")

test_that("getPinTransfer functionality", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_arrayscan/EXPT00AS01/Raw_data")
  testInstrument <- "arrayScan"
  setwd(testFilePath)
  
  testPlateAssociationDT <- data.table(plateOrder=c(1,2,3), assayBarcode=c("YB000560","YB000561","YB000562"), compoundBarcode_1=c("","DG0001039","DG0001042"), sidecarBarcode=c("YB000004","YB000004","YB000003"))
  testPinTransfer <- getPinTransfer(testPlateAssociationDT, testMode=TRUE, tempFilePath)
  
  testPlateAssociationDTMissCmpd <- data.table(plateOrder=c(1,2,3), assayBarcode=c("YB000560","YB000561","YB000562"), compoundBarcode_1=c("","KC0001039","DG0001042"), sidecarBarcode=c("YB000004","YB000004","YB000003"))
  expect_that(getPinTransfer(testPlateAssociationDTMissCmpd, testMode=TRUE, tempFilePath), throws_error("Missing compound plate data for 1 compound\\(s): KC0001039"))
  
  setwd(originalWD)
  rm(list=ls())
})