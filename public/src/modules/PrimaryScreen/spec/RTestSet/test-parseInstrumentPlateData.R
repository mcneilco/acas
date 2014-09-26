context("Testing the function parsing the instrument plate data")

test_that("parseInstrumentPlateData functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  ## Test single data set
  testAssayFileName <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data", "X4502052.txt")
  
  # Creates the test parameter list
  testParams <- loadInstrumentReadParameters(instrumentType="flipr", tempFilePath=tempFilePath)
  
  testTitleVector <- c("R1")
  testParseFile     <- parseInstrumentPlateData(fileName=testAssayFileName, parseParams=testParams, titleVector=testTitleVector, tempFilePath=tempFilePath)
  
  expect_that(testParseFile[1150, R1], equals("1524.58"))
  expect_that(testParseFile[1341, wellReference], equals("AB045"))
  expect_that(nrow(testParseFile), equals(1536))
  expect_that(ncol(testParseFile), equals(4))
  
  ## Test multiple data sets
  testAssayFileName <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates/", "arrayScan-YB000560.txt")
  
  # Creates the test parameter list
  testParams <- loadInstrumentReadParameters(instrumentType="arrayScan", tempFilePath=tempFilePath)
  
  setwd(file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates"))
  testTitleVector <- getDataSectionTitles(fileName="arrayScan-YB000560.txt", testParams, tempFilePath=tempFilePath)$dataTitle
  testParseFile     <- parseInstrumentPlateData(fileName=testAssayFileName,parseParams=testParams, titleVector=testTitleVector, tempFilePath=tempFilePath)
  
  expect_that(testParseFile[49, BranchPointCountPerNeuriteLengthCh2], equals("0.0119"))
  expect_that(testParseFile[7, NeuriteTotalLengthPerNeuronCh2], equals("31.512"))
  expect_that(nrow(testParseFile), equals(96))
  expect_that(ncol(testParseFile), equals(11))
  
  setwd(originalWD)
  rm(list=ls())
  
})