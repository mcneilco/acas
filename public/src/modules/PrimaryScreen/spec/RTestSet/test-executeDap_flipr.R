library(testthat)
library(compare)

context("Testing the function getting the Dap data (flipr)")

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

test_that("executeDap functionality (flipr)", {
  require(data.table)
  require(racas)
  require(testthat)
  tempFilePath <- tempdir()
  
  originalWD <- Sys.getenv("ACAS_HOME")
  source(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R"))
  basePath <- "public/src/modules/PrimaryScreen/src/server/"
  fileList <- c(fileList <- c(list.files(file.path(originalWD,basePath,"instrumentSpecific/","plateFormatSingleFile"), full.names=TRUE),
                              list.files(file.path(originalWD,basePath,"instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                              list.files(file.path(originalWD,basePath,"compoundAssignment/DNS"), full.names=TRUE)))
  lapply(fileList, source)
  
  testFilePath <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_raw_data_flipr/EXPT00FL01/Raw_data")
  
  readsTable <- data.table(readPosition=1, readName="R1", activity=TRUE) 
  
  instrumentSpecData <- getInstrumentSpecificData(filePath=normalizePath(testFilePath, winslash = "\\", mustWork=NA), instrument="flipr", testMode=TRUE, tempFilePath=tempFilePath, readsTable=readsTable, matchNames=FALSE)
  getAssayCompoundData(filePath=testFilePath, plateData=instrumentSpecData$plateAssociationDT, testMode=TRUE, tempFilePath=tempFilePath, assayData=instrumentSpecData$assayData)
  
  testFile <- normalizePath(file.path(tempdir(), "output_well_data.srf"))
  testTable <- read.table(testFile, sep="\t", stringsAsFactors=TRUE, header=TRUE)
  testTable <- as.data.table(testTable)
  setcolorder(testTable, c("assayBarcode","wellReference","rowName","colName","plateOrder","R1..R1.","cmpdBarcode","plateType","corp_name","batch_number","cmpdConc","supplier","sourceType","activity"))
  
  expect_that(testTable$"R1..R1.", is_identical_to(testTable$activity))
  setwd(testFilePath)
  rdaTest(testTable, normalizePath("../Analysis/output_well_data.rda"))
  setwd(originalWD)
  rm(list=ls())
})