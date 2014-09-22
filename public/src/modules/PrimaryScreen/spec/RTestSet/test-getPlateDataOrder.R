context("Testing the function that gets the plate data order")

test_that("getPlateDataOrder functionality", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_arrayscan/EXPT00AS01/Raw_data")
  testInstrument <- "arrayScan"
  setwd(testFilePath)
  
  testPlateDataOrder <- suppressWarnings(getPlateDataOrder(filePath=testFilePath, instrument=testInstrument, tempFilePath=tempFilePath))
  
  expect_that(testPlateDataOrder[assayFileName=="YB000570.txt", ]$readOrder, is_identical_to(as.integer(c(1,2,3,4,5,6,7))))
  expect_that(testPlateDataOrder[assayFileName=="YB000569.txt", ]$readOrder, is_identical_to(as.integer(c(1,2,3,4,5,6,7,8))))
  
  setwd(originalWD)
  
  rm(list=ls())
  
})