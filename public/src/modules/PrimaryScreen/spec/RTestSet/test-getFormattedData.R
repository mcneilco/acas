context("Testing the function get gets plate data from files that are already in columns")

test_that("getFormattedData functionality", {  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  fileName     <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_assay_plates/", "lumiLux-A111550.txt")
  sepChar      <- ","
  begRow       <- getDataRowNumber(fileName, "^Well,Group,Index", tempFilePath=tempFilePath)
  endRow       <- getLastDataRowNumber(fileName, "^[A-Z]{1,2}[0-9]{1,2},", tempFilePath=tempFilePath)
  headerExists <- TRUE
  
  testTable <- getFormattedData(fileName, sepChar, begRow, endRow, headerExists, tempFilePath=tempFilePath)
  
  expect_that(testTable[23,X..Resp.Max...Base.Mean.....Base.Mean], is_identical_to(12889798.39))
  expect_that(testTable[88, X..Resp.Above.Base], is_identical_to(10156960204.71))
  expect_that(nrow(testTable), equals(1536))
  expect_that(ncol(testTable), equals(33))
  rm(list=ls())
})