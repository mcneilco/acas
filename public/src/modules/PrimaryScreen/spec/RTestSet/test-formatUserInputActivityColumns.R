context("Testing the function that correlates the user input read order and names to the activity columns")

test_that("formatUserInputActivityColumns functionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  testReadOrder <- list(1, 2, 3)
  testReadNamesMissOne <- list("Fluorescence","ValidNeuronCount","ValidFieldCount")
  testReadNamesMissAll <- list("Fluorescence","Valid Neuron Count","Valid Field Count")
  testReadNames <- list("ValidNeuronCount","ValidFieldCount","NeuriteTotalLengthPerNeuronCh2")
  testActivityColNames <- c("ValidNeuronCount","NeuriteTotalLengthPerNeuronCh2","ValidFieldCount") 
  testReadsTable <- data.table(readOrder=testReadOrder, readNames=testReadNames, activityCol=c(TRUE, FALSE, FALSE))
  testReadsTableMissOne <- data.table(readOrder=testReadOrder, readNames=testReadNamesMissOne, activityCol=c(TRUE, FALSE, FALSE))
  testReadsTableMissAll <- data.table(readOrder=testReadOrder, readNames=testReadNamesMissAll, activityCol=c(TRUE, FALSE, FALSE))
  tempFilePath <- tempdir()
  
  testColTable <- formatUserInputActivityColumns(readsTable=testReadsTable, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE)
  testColTableMissOne <- suppressWarnings(formatUserInputActivityColumns(readsTable=testReadsTableMissOne, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE) )
  
  
  expect_that(formatUserInputActivityColumns(readsTable=testReadsTableMissAll, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE), gives_warning("No match found for read name\\(s): 'Fluorescence'"))
  expect_that(suppressWarnings(formatUserInputActivityColumns(readsTable=testReadsTableMissAll, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE)), throws_error("No valid acvitivy columns were found from user input."))
  expect_that(testColTable$newActivityColName, is_identical_to(c("R1 {ValidNeuronCount}","R2 {ValidFieldCount}","R3 {NeuriteTotalLengthPerNeuronCh2}")))
  expect_that(testColTableMissOne$activityColName, is_identical_to(c("None","ValidNeuronCount","ValidFieldCount")))
  expect_that(testColTableMissOne$newActivityColName, is_identical_to(c("R1 {Fluorescence}","R2 {ValidNeuronCount}","R3 {ValidFieldCount}")))
  
  rm(list=ls())
})