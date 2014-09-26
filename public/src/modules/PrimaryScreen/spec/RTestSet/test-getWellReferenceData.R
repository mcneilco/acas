context("Testing the function getting the well reference data")

test_that("getWellReferenceData functionality", { 
  library(data.table)
  library(testthat)
  library(racas)
  originalWD <- Sys.getenv("ACAS_HOME")
  fileList <- c(list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/instrumentSpecific/specificDataPreProcessorFiles/"), full.names=TRUE), 
                list.files(file.path(originalWD,"public/src/modules/PrimaryScreen/src/server/compoundAssignment/"), full.names=TRUE))
  lapply(fileList, source)
  
  tempFilePath <- tempdir()
  testRowName <- c("-A","-M","-Z","AA","AM","AZ")
  testColName <- c(1:6)
  
  testTable <- data.table(rowName=testRowName, colName=testColName)
  testWellReference <- getWellReferenceData(testTable, tempFilePath=tempFilePath)
  
  expect_that(ncol(testWellReference), equals(3))
  expect_that(testWellReference[3,wellReference], equals("Z003"))
  expect_that(testWellReference[6,wellReference], equals("AZ006"))
  
  rm(list=ls())
})