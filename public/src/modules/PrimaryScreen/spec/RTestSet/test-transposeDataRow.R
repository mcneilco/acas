context("Testing the function transposing the rows of data")

test_that("transposeDataRow functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testRowName <- c("-A","-M","-Z","AA","AM","AZ")
  colName1 <- c(1:6)
  colName2 <- c(7:12)
  colName3 <- c(13:18)
  
  testDT <- data.table("1"=colName1, "2"=colName2, "3"=colName3, rowName=testRowName)
  testDT <- testDT[, transposeDataRow(.SD, "activity", tempFilePath=tempFilePath), by=rowName]
  
  expect_that(testDT[10, rowName], equals("AA"))
  expect_that(testDT[15, activity], equals(17))
  expect_that(testDT[8, colName], equals(2))
  expect_that(ncol(testDT), equals(3))
  expect_that(nrow(testDT), equals(18))
  
  rm(list=ls())
  
})