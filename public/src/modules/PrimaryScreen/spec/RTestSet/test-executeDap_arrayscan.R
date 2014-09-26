library(testthat)
library(compare)
library(rdap)

context("Testing the function getting the Dap data (arrayScan)")

packageWD <- getwd()
on.exit(setwd(packageWD))


rdaTest <- function(newResults, acceptedResultsPath, updateResults = FALSE) {
  if(updateResults) {
    acceptedResults <- newResults
    return(save(acceptedResults , file = acceptedResultsPath))
  } else {    
    load(acceptedResultsPath)
    return(expect_that(newResults,
                       equals(acceptedResults)))
  }
}

test_that("executeDap functionality (arrayScan)", {
  require(data.table)
  require(racas)
  require(testthat)
  tempFilePath <- tempdir()
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_arrayscan/EXPT00AS01/Raw_data")
  
  readOrder <- list(1,2,3,4,5,6,7,8) 
  readNames <- list("ValidNeuronCount","NeuriteTotalLengthPerNeuronCh2","ValidFieldCount","NeuriteTotalLengthPerNeuriteCh2","NeuriteTotalCountPerNeuronCh2","BranchPointTotalCountPerNeuronCh2","BranchPointCountPerNeuriteLengthCh2","Chamber CO2 Percent")
  readsTable <- data.table(readOrder=readOrder, readNames=readNames, activityCol=TRUE) 
  
  instrumentSpecData <- getInstrumentSpecificData(filePath=normalizePath(testFilePath, winslash = "\\", mustWork=NA), instrument="arrayScan", testMode=TRUE, tempFilePath=tempFilePath, readsTable=readsTable, matchNames=FALSE)
  getCompoundAssignments(filePath=testFilePath, plateData=instrumentSpecData$plateAssociationDT, testMode=TRUE, tempFilePath=tempFilePath, assayData=instrumentSpecData$assayData)

  testFile <- normalizePath(file.path(tempdir(), "output_well_data.srf"))
  testTable <- read.table(testFile, sep="\t", stringsAsFactors=TRUE, header=TRUE)
  testTable <- as.data.table(testTable)
  
  setcolorder(testTable, c("assayBarcode","wellReference","rowName","colName","R1..ValidNeuronCount.","R2..NeuriteTotalLengthPerNeuronCh2.","R3..ValidFieldCount.","R4..NeuriteTotalLengthPerNeuriteCh2.","R5..NeuriteTotalCountPerNeuronCh2.","R6..BranchPointTotalCountPerNeuronCh2.","R7..BranchPointCountPerNeuriteLengthCh2.","R8..Chamber.CO2.Percent.","cmpdBarcode","plateType","corp_name","batch_number","cmpdConc","supplier","sourceType"))
  
  setwd(testFilePath)
  rdaTest(testTable, normalizePath("../Analysis/output_well_data.rda"))
  setwd(originalWD)
  rm(list=ls())
})