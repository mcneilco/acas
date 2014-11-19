context("Testing the function getting the assay file name")

test_that("getAssayFileName fuctionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data")
  
  
  testBarcode <- "4502052"
  testName <- getAssayFileName(barcode=testBarcode, filePath=testFilePath, tempFilePath=tempFilePath)
  #multReads <- getAssayFileName(barcode="45020", filePath=testFilePath, tempFilePath=tempFilePath)
  
  #expect_that(nrow(multReads), equals(3))
  #expect_that(paste(multReads$readOrder, sep="",collapse=""), equals("123"))
  expect_that(getAssayFileName(barcode="45020", filePath=testFilePath, tempFilePath=tempFilePath), throws_error("Multiple assay files found for barcode: 45020"))
  expect_that(getAssayFileName(barcode="551", filePath=testFilePath, tempFilePath=tempFilePath), throws_error("Assay file not found for barcode: 551"))
  expect_that(testName$assayFileName, equals("X4502052.txt"))
  
  
  rm(list=ls())
})