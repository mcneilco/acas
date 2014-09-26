context("Testing the function getting the data row number from the assay plate file")

test_that("getDataRowNumber functionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testFile <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data","X4502052.txt")
  testDataNumber <- getDataRowNumber(fileName=testFile, searchString="^\t1", tempFilePath=tempFilePath)
  
  expect_that(testDataNumber, equals(7))
  rm(list=ls())
})

# testFile <- "../test_files/E0000050.txt"
# testFile <- system.file("docs", "test-E0000050.txt", package="rdap")
# Sys.setlocale('LC_ALL','C')  to suppress "invalid in this locale warning"