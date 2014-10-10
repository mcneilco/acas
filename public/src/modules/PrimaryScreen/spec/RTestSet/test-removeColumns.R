context("Testing the function that removes columns that were not in the user input")

test_that("removeColumns functionality", {
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  testColNamesToCheck <- c("R1 {Alpha}", "R2 {Beta}", "R4 {Kappa}", "Epsilon")
  testColNamesToKeep <- c("R1 {Alpha}", "R2 {Beta}", "R3 {Delta}")
  testInputDataTable <- data.table(wellRef="A001", "R1 {Alpha}"=1, "R2 {Beta}"=2, "R4 {Kappa}"=3, "Epsilon"=5)
  newDT <- suppressWarnings(removeColumns(colNamesToCheck=testColNamesToCheck, colNamesToKeep=testColNamesToKeep, inputDataTable=testInputDataTable, tempFilePath=tempdir()))
  
  
  expect_that(removeColumns(colNamesToCheck=testColNamesToCheck, colNamesToKeep=testColNamesToKeep, inputDataTable=testInputDataTable, tempFilePath=tempdir()), gives_warning("Removed 2 data columns: 'R4 \\{Kappa}','Epsilon'"))
  expect_that(colnames(newDT), equals(c("wellRef","R1 {Alpha}", "R2 {Beta}")))
  
  rm(list=ls())
})