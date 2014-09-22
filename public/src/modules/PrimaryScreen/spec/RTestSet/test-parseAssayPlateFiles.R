context("Testing the function parsing the assay plate files")

test_that("parseAssayPlateFiles - one set of data", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  setwd(file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data")) 
  testTitleVector <- c("R1")
  testParseFile <-  parseAssayPlateFiles(assayFileName="X4502052.txt", instrumentType="flipr", titleVector=testTitleVector, tempFilePath=tempFilePath)
  
  expect_that(testParseFile[1150, R1], equals("1524.58"))
  expect_that(testParseFile[1341, wellReference], equals("AB045"))
  expect_that(nrow(testParseFile), equals(1536))
  expect_that(ncol(testParseFile), equals(4))
  
  setwd(originalWD)
  rm(list=ls())
})

test_that("parseAssayPlateFiles - multiple data sets, shuffled", {
  library(data.table)
  library(testthat)
  library(racas)
  fileList <- c(list.files("public/src/modules/PrimaryScreen/src/server/instrumentSpecific/", full.names=TRUE), 
                list.files("public/src/modules/PrimaryScreen/src/server/compoundAssignment/", full.names=TRUE))
  lapply(fileList, source)
  originalWD <- getwd()
  
  tempFilePath <- tempdir()
  setwd(file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates"))
  testDT <- data.table(assayFileName=c("arrayScan-YB000560.txt","arrayScan-YB00056SHUFFLE.txt"))
  parseParams <- loadInstrumentReadParameters("arrayScan",tempFilePath)
  testReadOrder <- testDT[ , getDataSectionTitles(assayFileName, parseParams, tempFilePath=tempFilePath), by=assayFileName]
  
  testAssayData <- data.frame()
  testAssayData <- testDT[ , parseAssayPlateFiles(assayFileName, instrumentType="arrayScan", unique(testReadOrder$dataTitle), tempFilePath=tempFilePath), by=assayFileName]
  
  expect_that(testAssayData[1:96, ValidNeuronCount], equals(testAssayData[97:192, ValidNeuronCount]))
  expect_that(testAssayData[1:96, NeuriteTotalLengthPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalLengthPerNeuronCh2]))
  expect_that(testAssayData[1:96, ValidFieldCount], equals(testAssayData[97:192, ValidFieldCount]))
  expect_that(testAssayData[1:96, NeuriteTotalLengthPerNeuriteCh2], equals(testAssayData[97:192, NeuriteTotalLengthPerNeuriteCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, BranchPointCountPerNeuriteLengthCh2], equals(testAssayData[97:192, BranchPointCountPerNeuriteLengthCh2]))
  expect_that(testAssayData[102, BranchPointCountPerNeuriteLengthCh2], equals("0.0098"))
  expect_that(testAssayData[191, NeuriteTotalLengthPerNeuriteCh2], equals("8.2093"))
  
  setwd(originalWD)
  rm(list=ls())
})

test_that("parseAssayPlateFiles - multiple data sets, missing", {
  library(data.table)
  library(testthat)
  library(racas)
  fileList <- c(list.files("public/src/modules/PrimaryScreen/src/server/instrumentSpecific/", full.names=TRUE), 
                list.files("public/src/modules/PrimaryScreen/src/server/compoundAssignment/", full.names=TRUE))
  lapply(fileList, source)
  originalWD <- getwd()
  
  tempFilePath <- tempdir()
  # test multiple data sets - missing data
  setwd(file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates"))
  testDT <- data.table(assayFileName=c("arrayScan-YB000560.txt","arrayScan-YB00056MINUS.txt"))
  parseParams <- loadInstrumentReadParameters("arrayScan",tempFilePath)
  testReadOrder <- testDT[ , getDataSectionTitles(assayFileName, parseParams, tempFilePath=tempFilePath), by=assayFileName]
  
  testAssayData <- data.frame()
  testAssayData <- testDT[ , parseAssayPlateFiles(assayFileName, instrumentType="arrayScan", unique(testReadOrder$dataTitle), tempFilePath=tempFilePath), by=assayFileName]
  
  expect_that(testAssayData[1:96, ValidFieldCount], equals(testAssayData[97:192, ValidFieldCount]))
  expect_that(testAssayData[1:96, NeuriteTotalLengthPerNeuriteCh2], equals(testAssayData[97:192, NeuriteTotalLengthPerNeuriteCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, BranchPointCountPerNeuriteLengthCh2], equals(testAssayData[97:192, BranchPointCountPerNeuriteLengthCh2]))
  expect_that(testAssayData[102, BranchPointCountPerNeuriteLengthCh2], equals("0.0098"))
  expect_that(testAssayData[97, ValidNeuronCount], equals(as.character(NA)))
  expect_that(testAssayData[145, NeuriteTotalLengthPerNeuronCh2], equals(as.character(NA)))
  expect_that(testAssayData[191, NeuriteTotalLengthPerNeuriteCh2], equals("8.2093"))
  
  setwd(originalWD)
  rm(list=ls())
})