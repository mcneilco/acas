context("Testing the function that correlates the user input read order and names to the activity columns")

test_that("formatUserInputActivityColumns functionality", {
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  testReadOrder <- list(1, 2, 3)
  testReadNamesMissOne <- list("Fluorescence","ValidNeuronCount","ValidFieldCount")
  testReadNamesMissAll <- list("Fluorescence","Valid Neuron Count","Valid Field Count")
  testReadNames <- list("ValidNeuronCount","ValidFieldCount","NeuriteTotalLengthPerNeuronCh2")
  testActivityColNames <- c("ValidNeuronCount","NeuriteTotalLengthPerNeuronCh2","ValidFieldCount")  
  tempFilePath <- tempdir()
  
  testColTable <- formatUserInputActivityColumns(readOrder=testReadOrder, readName=testReadNames, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE)
  testColTableMissOne <- suppressWarnings(formatUserInputActivityColumns(readOrder=testReadOrder, readName=testReadNamesMissOne, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE) )
  
  
  expect_that(formatUserInputActivityColumns(readOrder=testReadOrder, readName=testReadNamesMissOne, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE), gives_warning("No match found for read name\\(s): 'Fluorescence'"))
  expect_that(suppressWarnings(formatUserInputActivityColumns(readOrder=testReadOrder, readName=testReadNamesMissAll, activityColNames=testActivityColNames, tempFilePath, matchNames=TRUE)), throws_error("No valid acvitivy columns were found from user input."))
  expect_that(testColTable$newActivityColName, is_identical_to(c("R1 {ValidNeuronCount}","R2 {ValidFieldCount}","R3 {NeuriteTotalLengthPerNeuronCh2}")))
  expect_that(testColTableMissOne$activityColName, is_identical_to(c("None","ValidNeuronCount","ValidFieldCount")))
  expect_that(testColTableMissOne$newActivityColName, is_identical_to(c("R1 {Fluorescence}","R2 {ValidNeuronCount}","R3 {ValidFieldCount}")))
  
  rm(list=ls())
})