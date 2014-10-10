context("Testing the function that checks whether analysis files will be overwritten")

test_that("checkAnalysisFiles functionality", {
  require(data.table)
  require(racas)
  require(testthat)
  
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/DNS"), full.names=TRUE))
  lapply(fileList, source)
  
  logFolder <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_analysisFiles/logFiles")
  outputFolder <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_analysisFiles/outputFile")
  emptyFolder <- file.path(originalWD, "public/src/modules/PrimaryScreen/spec/RTestSet/docs/test_analysisFiles")
  
  expect_that(checkAnalysisFiles(testMode=FALSE, dryRun=TRUE, analysisFilePath=logFolder), throws_error("Analysis files already exist for this experiment: runlog.tab, defaultlog.ini"))
  expect_that(checkAnalysisFiles(testMode=FALSE, dryRun=FALSE, analysisFilePath=outputFolder), throws_error("Analysis file already exists for this experiment: output_well_data.srf"))
  checkAnalysisFiles(testMode=FALSE, dryRun=FALSE, analysisFilePath=emptyFolder) # should not throw an error
  
  rm(list=ls())
})