context("Testing the function that adds columns that were in the user input but not found in the data files")

test_that("addMissingColumns functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  source(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R"))

  testDT <- data.table(one=1, two=2)
  testColsToKeep <- c("one","two","three")
  newDT <- suppressWarnings(addMissingColumns(requiredColNames=testColsToKeep, inputDataTable=testDT))
  
  expect_that(addMissingColumns(requiredColNames=testColsToKeep, inputDataTable=testDT), gives_warning("Added 1 data column: 'three', coercing to NA."))
  expect_that(class(newDT), equals(c("data.table","data.frame")))
  expect_that(newDT[1, three], equals(as.numeric(NA)))
  
  rm(list=ls())
  
})