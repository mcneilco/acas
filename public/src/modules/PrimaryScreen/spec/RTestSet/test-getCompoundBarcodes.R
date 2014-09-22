context("Testing the function getting the compound barcodes")

test_that("getCompoundBarcode fuctionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testDT <- read.table(file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs", "test-plateAssociationDT.txt"), sep="\t", header=TRUE, stringsAsFactors=FALSE)
  testDT <- as.data.table(testDT)
  
  testCompoundBarcodes <- getCompoundBarcodes(inputDT=testDT, tempFilePath=tempFilePath)
  
  expect_that(length(testCompoundBarcodes), equals(2))
  expect_that(testCompoundBarcodes[2], equals("C1128196"))
#   expect_that(expect_that(length(testCompoundBarcodes), equals(1)), throws_error())
#   expect_that(expect_that(testCompoundBarcodes[2], equals("C1111152")), throws_error())
  rm(list=ls())
})