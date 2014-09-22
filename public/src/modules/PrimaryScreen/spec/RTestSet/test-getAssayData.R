context("Testing the function importing the assay data")

test_that("getAssayData fuctionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFile <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data", "X4502052.txt")
  testFrame <- getAssayData(fileName=testFile, begRow=7, endRow=39, begCol=2, sepChar="\t", tempFilePath=tempFilePath)
  setnames(testFrame, colnames(testFrame), paste0("X",colnames(testFrame)))
  
  expect_that(nrow(testFrame) %% 8, equals(0))
  expect_that(ncol(testFrame) %% 12, equals(1))
  expect_that(testFrame, is_a("data.frame"))
  expect_that(testFrame[5,X11], equals("36815.79"))
  expect_that(testFrame[1,X1], equals("867.51"))
  # expect_that(expect_that(testFrame[5,X11], equals(29148.7)), throws_error())  
  
  testFile <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_microBeta/EXPT00MB01/Raw_data", "E0013328A.txt")
  testFrame <- getAssayData(fileName=testFile, begRow=20, endRow=36, begCol=2, sepChar="\t", tempFilePath=tempFilePath)
  setnames(testFrame, colnames(testFrame), paste0("X",colnames(testFrame)))
  
  expect_that(nrow(testFrame) %% 8, equals(0))
  expect_that(ncol(testFrame) %% 12, equals(1))
  expect_that(testFrame, is_a("data.frame"))
  expect_that(testFrame[5,X11], equals("1404"))
  expect_that(testFrame[1,X1], equals("47"))
  rm(list=ls())
})