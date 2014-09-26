## for testing include the following packages
library(testthat)

context("Testing the function getting the specific instrument Dap data")

test_that("getInstrumentSpecificData & getCompoundAssignments functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  
  readsTable <- data.table(readOrder=1, readNames="R1", activityCol=TRUE) 
  
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data")
  instrumentSpecData <- getInstrumentSpecificData(filePath=testFilePath, testMode=TRUE, instrument="flipr", tempFilePath=tempFilePath, readsTable=readsTable, matchNames=FALSE)
  getCompoundAssignments(filePath=testFilePath, plateData=instrumentSpecData$plateAssociationDT, testMode=TRUE, tempFilePath=tempFilePath, assayData=instrumentSpecData$assayData)
  testFile <- file.path(tempFilePath, "output_well_data.srf")
  testTable <- read.table(testFile, sep="\t", stringsAsFactors=TRUE, header=TRUE)
  testTable <- as.data.table(testTable)
 
  # expect_that(testTable[4608, corp_name], equals("DNS000000001"))
  expect_that(testTable[4446, R1..R1.], equals(69094.77))
  expect_that(nrow(testTable) %% 96, equals(0))
  expect_that(nrow(testTable), equals(4608))
  expect_that(ncol(testTable), equals(12))
  # expect_that(expect_that(testTable[4609, corp_name], equals("DNS000000001")), throws_error())
  # expect_that(expect_that(testTable[4447, activity], equals(69094.77)), throws_error())
  # expect_that(expect_that(nrow(testTable) %% 96, equals(1)), throws_error())
  # expect_that(expect_that(nrow(testTable), equals(1536)), throws_error())
  # expect_that(expect_that(ncol(testTable), equals(15)), throws_error())  

  file.remove(testFile)
  expect_that(read.table(testFile), gives_warning("No such file or directory"))
  
  # # For log file
  # file.remove("defaultlog.ini")
  # expect_that(read.table("defaultlog.ini"), gives_warning())
  
  readsTable <- data.table(readOrder=1, readNames="R1", activityCol=TRUE) 
  
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_microBeta/EXPT00MB01/Raw_data")
  instrumentSpecData <- getInstrumentSpecificData(filePath=testFilePath, testMode=TRUE, instrument="microBeta", tempFilePath=tempFilePath, readsTable=readsTable, matchNames=FALSE)
  getCompoundAssignments(filePath=testFilePath, plateData=instrumentSpecData$plateAssociationDT, testMode=TRUE, tempFilePath=tempFilePath, assayData=instrumentSpecData$assayData)
  testFile <- file.path(tempFilePath, "output_well_data.srf")
  testTable <- read.table(testFile, sep="\t", stringsAsFactors=FALSE, header=TRUE)
  testTable <- as.data.table(testTable)
  
  # expect_that(testTable[479, corp_name], equals("DNS001137825"))
  expect_that(testTable[645, R1..R1.], equals(1958))
  expect_that(nrow(testTable) %% 96, equals(0))
  expect_that(nrow(testTable), equals(768))
  expect_that(ncol(testTable), equals(12))
  
  file.remove(testFile)
  expect_that(read.table(testFile), gives_warning("No such file or directory"))
  
  setwd(originalWD)
  rm(list=ls())
})