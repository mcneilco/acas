library(testthat)
library(compare)
library(rdap)

context("Testing the function getting the Dap data (envision)")

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

test_that("executeDap functionality (envision)", {
  require(data.table)
  require(racas)
  require(testthat)
  tempFilePath <- tempdir()
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_envision/EXPT00EV01/Raw_data")
  
  readOrder <- list(1,2)
  readNames <- list("R1","R2")
  readsTable <- data.table(readOrder=readOrder, readNames=readNames, activityCol=TRUE) 
  
  instrumentSpecData <- getInstrumentSpecificData(filePath=normalizePath(testFilePath, winslash = "\\", mustWork=NA), instrument="envision", testMode=TRUE, tempFilePath=tempFilePath, readsTable=readsTable, matchNames=FALSE)
  getCompoundAssignments(filePath=testFilePath, plateData=instrumentSpecData$plateAssociationDT, testMode=TRUE, tempFilePath=tempFilePath, assayData=instrumentSpecData$assayData)
  
  testFile <- normalizePath(file.path(tempdir(), "output_well_data.srf"))
  testTable <- read.table(testFile, sep="\t", stringsAsFactors=TRUE, header=TRUE)
  testTable <- as.data.table(testTable)
  setcolorder(testTable, c("assayBarcode","wellReference","rowName","colName","R1..R1.","R2..R2.","cmpdBarcode","plateType","corp_name","batch_number","cmpdConc","supplier","sourceType"))
  setwd(testFilePath)
  rdaTest(testTable, normalizePath("../Analysis/output_well_data.rda"))
  setwd(originalWD)
  rm(list=ls())
})