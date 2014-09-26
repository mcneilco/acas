context("Testing the function that adds columns that were in the user input but not found in the data files")

test_that("addMissingColumns functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)

  testDT <- data.table(one=1, two=2)
  testColsToKeep <- c("one","two","three")
  newDT <- suppressWarnings(addMissingColumns(colNamesToKeep=testColsToKeep, inputDataTable=testDT, tempFilePath=tempdir()))
  
  expect_that(addMissingColumns(colNamesToKeep=testColsToKeep, inputDataTable=testDT, tempFilePath=tempdir()), gives_warning("Adding column 'three', coercing to NA."))
  expect_that(class(newDT), equals(c("data.table","data.frame")))
  expect_that(newDT[1, three], equals(as.numeric(NA)))
  
  rm(list=ls())
  
})