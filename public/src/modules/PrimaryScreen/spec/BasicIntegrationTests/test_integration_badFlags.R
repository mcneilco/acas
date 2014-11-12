# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests that we catch ambiguous or incorrect flags
#
# Requirements: The file "confirmationRegression.zip" must be in the first
#       level of your privateUploads folder. A copy of this zip may be
#       found under BasicIntegrationTests > IO_for_test_files > experiment
#
# Author: Jennifer Rogers

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","PrimaryScreen","src","server","PrimaryAnalysis.R"))
load(file.path("public", "src", "modules", "PrimaryScreen", "spec", "BasicIntegrationTests", 
               "IO_for_test_files", "RObjects", "request.rda"))

context("badFlags")

test_that("Errors when two contradictory flags belong to the same analysis group", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/twoFlags.xlsx"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_false(response$hasWarning)
  expect_true(response$hasError)
  expect_true(grepl("unrecognized flag", response$errorMessages[[1]]$message))
})

test_that("Errors when there is a flag other than 'yes' or 'no'", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/unrecognizedFlag.xlsx"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_false(response$hasWarning)
  expect_true(response$hasError)
  expect_true(grepl("maybe", response$errorMessages[[1]]$message))
})

test_that("Controls cannot be flagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/flagControls.xlsx"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_false(response$hasWarning)
  expect_true(response$hasError)
  expect_true(grepl("CMPD-0137643-1", response$errorMessages[[1]]$message))
  expect_true(grepl("CMPD-0141923-1", response$errorMessages[[1]]$message))
  
  #We put in three flags for CMPD-0137643-1's controls; make sure it only shows
  # up once in the error message (it could be at the end or in the middle, hence
  # either one or two sections are acceptable)
  expect_true(length(strsplit(response$errorMessages[[1]]$message, "CMPD-0137643-1")[[1]]) < 3)
})
