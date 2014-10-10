context("Testing the function that adds and removes columns according to user input")

test_that("adjustColumnsToUserInput functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  testInputColumnTable <- data.table(userReadOrder=c(1,2,3), userReadName=c("Alpha", "Beta", "Delta"), activityColName=c("Alpha","Beta","None"), newActivityColName=c("R1 {Alpha}", "R2 {Beta}", "R3 {Delta}"), activityCol=c(TRUE,FALSE,FALSE))
  
  testInputDataTable <- data.table(wellReference="A001", Alpha=1, Beta=2, Kappa=3, Epsilon=5)
  newDT <- suppressWarnings(adjustColumnsToUserInput(inputColumnTable=testInputColumnTable, inputDataTable=testInputDataTable, tempFilePath=tempdir()))
  
  testInputDataTable <- data.table(wellReference="A001", Alpha=1, Beta=2, Kappa=3, Epsilon=5)
  expect_that(adjustColumnsToUserInput(inputColumnTable=testInputColumnTable, inputDataTable=testInputDataTable, tempFilePath=tempdir()), gives_warning("Adding column 'R3 \\{Delta}', coercing to NA."))
  testInputDataTable <- data.table(wellReference="A001", Alpha=1, Beta=2, Kappa=3, Epsilon=5)
  expect_that(adjustColumnsToUserInput(inputColumnTable=testInputColumnTable, inputDataTable=testInputDataTable, tempFilePath=tempdir()), gives_warning("Removed 2 data columns: 'Kappa','Epsilon'"))
  expect_that(colnames(newDT), equals(c("wellReference","R1 {Alpha}", "R2 {Beta}", "R3 {Delta}", "activity")))
  expect_that(newDT$"R3 {Delta}", equals(as.numeric(NA)))
  
  rm(list=ls())
})