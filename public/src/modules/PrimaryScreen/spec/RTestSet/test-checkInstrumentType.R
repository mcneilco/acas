context("Testing the function checking the instrument type")

test_that("checkInstrumentType fuctionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates/")
  setwd(testFilePath)
  
  #   acumenFileName      <- 
  arrayScanFileName   <- "arrayScan-YB000560.txt"
  biacoreFileName     <- "biacore-E0000364A.txt"
  #   envisionFileName    <- 
  fliprFileName       <- "flipr-X4502052.txt"
  lumiLuxFileName     <- "lumiLux-A111550.txt"
  microBetaFileName   <- "microBeta-E0013328A.txt"
  thermalMeltFileName <- "abi7900ht-T4241922.txt"
  viewLuxFileName     <- "viewLux-T1219227.Txt"
  
  #   expect_that(checkInstrumentType(assayFileName=acumenFileName, inspectFile=TRUE, tempFilePath=tempFilePath), equals("acumen"))
  expect_that(checkInstrumentType(assayFileName=arrayScanFileName, instrument="arrayScan", tempFilePath=tempFilePath), equals("arrayScan"))
  expect_that(checkInstrumentType(assayFileName=biacoreFileName, instrument="biacore", tempFilePath=tempFilePath), equals("biacore"))
  #   expect_that(checkInstrumentType(assayFileName=envisionFileName, inspectFile=TRUE, tempFilePath=tempFilePath), equals("envision"))
  expect_that(checkInstrumentType(assayFileName=fliprFileName, instrument="flipr", tempFilePath=tempFilePath), equals("flipr"))
  expect_that(checkInstrumentType(assayFileName=lumiLuxFileName, instrument="lumiLux", tempFilePath=tempFilePath), equals("lumiLux"))
  expect_that(checkInstrumentType(assayFileName=microBetaFileName, instrument="microBeta", tempFilePath=tempFilePath), equals("microBeta"))
  
  expect_that(checkInstrumentType(assayFileName=fliprFileName, instrument="arrayScan", tempFilePath=tempFilePath), throws_error("Input instrument \\(arrayScan) does not match instrument type in file"))
  expect_that(checkInstrumentType(assayFileName=fliprFileName, instrument="jimbob", tempFilePath=tempFilePath), throws_error("Instrument not loaded in to system."))
  expect_that(checkInstrumentType(assayFileName=thermalMeltFileName, instrument="thermalMelt", tempFilePath=tempFilePath), throws_error("Instrument not loaded in to system."))
  expect_that(checkInstrumentType(assayFileName=viewLuxFileName, instrument="viewLux", tempFilePath=tempFilePath), throws_error("Instrument not loaded in to system."))
  
  setwd(originalWD)
  
  rm(list=ls())
})