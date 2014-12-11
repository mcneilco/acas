context("Testing the function parsing the assay plate files")

test_that("parseAssayPlateFiles - one set of data", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  basePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/")
  source(file.path(basePath,"PrimaryAnalysis.R"))
  fileList <- c(list.files(file.path(basePath,"instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(basePath,"compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  
  
  tempFilePath <- tempdir()
  testTitleVector <- c("R1")
  parameters <- loadInstrumentReadParameters("flipr")
  instrumentSpecificFunctions <- list.files(file.path(basePath,"instrumentSpecific",parameters$dataFormat), full.names=TRUE)
  lapply(instrumentSpecificFunctions, source)
  
  testFilePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data")
  testParseFile <-  parseAssayPlateFiles(assayFileName=file.path(testFilePath,"X4502052.txt"), instrumentType="flipr", titleVector=testTitleVector, tempFilePath=tempFilePath)
  
  expect_that(testParseFile[1150, R1], equals(1524.58))
  expect_that(testParseFile[1341, wellReference], equals("AB045"))
  expect_that(nrow(testParseFile), equals(1536))
  expect_that(ncol(testParseFile), equals(4))
  
  rm(list=ls())
})

test_that("parseAssayPlateFiles - multiple data sets, shuffled", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  basePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/")
  source(file.path(basePath,"PrimaryAnalysis.R"))
  fileList <- c(list.files(file.path(basePath,"instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(basePath,"compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  parameters <- loadInstrumentReadParameters("arrayScan")
  instrumentSpecificFunctions <- list.files(file.path(basePath,"instrumentSpecific",parameters$dataFormat), full.names=TRUE)
  lapply(instrumentSpecificFunctions, source)
  
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates")
  testDT <- data.table(assayFileName=c("arrayScan-YB000560.txt","arrayScan-YB00056SHUFFLE.txt"))
  parseParams <- loadInstrumentReadParameters("arrayScan")
  testReadOrder <- testDT[ , getDataSectionTitles(file.path(testFilePath,assayFileName), parseParams, tempFilePath=tempFilePath), by=assayFileName]
  
  testAssayData <- data.frame()
  testAssayData <- testDT[ , parseAssayPlateFiles(file.path(testFilePath,assayFileName), instrumentType="arrayScan", unique(testReadOrder$dataTitle), tempFilePath=tempFilePath), by=assayFileName]
  
  expect_that(testAssayData[1:96, ValidNeuronCount], equals(testAssayData[97:192, ValidNeuronCount]))
  expect_that(testAssayData[1:96, NeuriteTotalLengthPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalLengthPerNeuronCh2]))
  expect_that(testAssayData[1:96, ValidFieldCount], equals(testAssayData[97:192, ValidFieldCount]))
  expect_that(testAssayData[1:96, NeuriteTotalLengthPerNeuriteCh2], equals(testAssayData[97:192, NeuriteTotalLengthPerNeuriteCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, BranchPointCountPerNeuriteLengthCh2], equals(testAssayData[97:192, BranchPointCountPerNeuriteLengthCh2]))
  expect_that(testAssayData[102, BranchPointCountPerNeuriteLengthCh2], equals("0.0098"))
  expect_that(testAssayData[191, NeuriteTotalLengthPerNeuriteCh2], equals("8.2093"))
  
  rm(list=ls())
})

test_that("parseAssayPlateFiles - multiple data sets, missing", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  basePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/")
  source(file.path(basePath,"PrimaryAnalysis.R"))
  fileList <- c(list.files(file.path(basePath,"instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(basePath,"compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  parameters <- loadInstrumentReadParameters("arrayScan")
  instrumentSpecificFunctions <- list.files(file.path(basePath,"instrumentSpecific",parameters$dataFormat), full.names=TRUE)
  lapply(instrumentSpecificFunctions, source)
  
  tempFilePath <- tempdir()
  # test multiple data sets - missing data
  testFilePath <- file.path(originalWD,"public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates")
  testDT <- data.table(plateOrder=c(as.integer(1),as.integer(2),as.integer(3)),
                       assayFileName=c("arrayScan-YB000560.txt","arrayScan-YB00056MINUS.txt","arrayScan-YB00056copy.txt"),
                       assayBarcode=c("arrayScan-YB000560","arrayScan-YB00056MINUS","arrayScan-YB00056copy"),
                       compoundBarcode_1="YB000004",
                       sidecarBarcode="DG0001021",
                       instrumentType="arrayScan")
  parseParams <- loadInstrumentReadParameters("arrayScan")
  testReadOrder <- testDT[ , getDataSectionTitles(file.path(testFilePath,assayFileName), parseParams, tempFilePath=tempFilePath), by=assayFileName]
  
  setkey(testDT, assayFileName)
  setkey(testReadOrder, assayFileName)
  testDT <- merge(testDT, testReadOrder)
  
  testAssayData <- data.frame()
  testAssayData <- testDT[ , parseAssayPlateFiles(file.path(testFilePath,assayFileName), 
                                                  instrumentType="arrayScan", 
                                                  unique(testReadOrder$dataTitle), 
                                                  tempFilePath=tempFilePath), 
                          by=list(assayFileName, assayBarcode, plateOrder)]
  
  expect_that(testAssayData[1:96, ValidFieldCount], equals(testAssayData[97:192, ValidFieldCount]))
  expect_that(testAssayData[1:96, NeuriteTotalLengthPerNeuriteCh2], equals(testAssayData[97:192, NeuriteTotalLengthPerNeuriteCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, NeuriteTotalCountPerNeuronCh2], equals(testAssayData[97:192, NeuriteTotalCountPerNeuronCh2]))
  expect_that(testAssayData[1:96, BranchPointCountPerNeuriteLengthCh2], equals(testAssayData[97:192, BranchPointCountPerNeuriteLengthCh2]))
  expect_that(testAssayData[102, BranchPointCountPerNeuriteLengthCh2], equals("0.0098"))
  expect_that(testAssayData[97, ValidNeuronCount], equals(as.character(NA)))
  expect_that(testAssayData[145, NeuriteTotalLengthPerNeuronCh2], equals(as.character(NA)))
  expect_that(testAssayData[191, NeuriteTotalLengthPerNeuriteCh2], equals("8.2093"))
  
  rm(list=ls())
})
