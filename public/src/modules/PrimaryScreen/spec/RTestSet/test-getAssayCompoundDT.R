context("Testing the function getting Assay Compound Data Table")

test_that("getAssayCompoundDT functionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testDT <- read.table(file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test-plateAssociationDT.txt"), sep="\t", header=TRUE, stringsAsFactors=FALSE)
  testDT <- as.data.table(testDT)
  
  testTable <- getAssayCompoundDT(inputDT=testDT, tempFilePath=tempFilePath)
  
  expect_that(testTable[1, assayBarcode], equals("X4502052"))
  expect_that(testTable[4, sourceType], equals("compound"))
  expect_that(nrow(testTable), equals(6))
  expect_that(ncol(testTable), equals(3))
#   expect_that(expect_that(testTable[1, assayBarcode], equals("X4502054")), throws_error())
#   expect_that(expect_that(testTable[4, sourceType], equals("sidecar")), throws_error())
#   expect_that(expect_that(nrow(testTable), equals(3)), throws_error())
#   expect_that(expect_that(ncol(testTable), equals(4)), throws_error())
  rm(list=ls())
})