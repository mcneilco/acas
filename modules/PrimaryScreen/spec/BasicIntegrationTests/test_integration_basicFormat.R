# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests the 'basic' format (when users enter barcode and well information
# for flagged samples, instead of editing the provided override file)
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

context("basicFormat")

expectUnmodifiedResults <- function(response) {
  # Check that the statistics are the same as they would be without flags.
  # We sacrifice some rigor for the sake of allowing aesthetic changes to the html
  expect_true(grepl(107, response$results$htmlSummary)) #The number of hits
  expect_true(grepl(-0.607, response$results$htmlSummary)) #Z'
  expect_true(grepl(-0.526, response$results$htmlSummary)) #Robust Z'
  expect_true(grepl(-85.030, response$results$htmlSummary)) #Z
  expect_true(grepl(-16.063, response$results$htmlSummary)) #Robust Z
}

expectNoProblems <- function(response) {
  expect_false(response$hasWarning)
  expect_false(response$hasError)
}

test_that("The parser recognizes the 'basic' file format, which has just barcode, well, and flag fields", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/basicCSV.csv"
  response <- runPrimaryAnalysis(request)
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

test_that("We see an error when the 'flag' column is missing", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/basicMissingColumns.xls"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_false(response$hasWarning)
  expect_true(response$hasError)
  expect_true(grepl("missing", response$errorMessages[[1]]$message))
})

test_that("Flagging points affects which analysis groups are hits", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/basicInfluenceHits.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expectNoProblems(response)
  expect_true(grepl(109, response$results$htmlSummary)) #The number of hits
  expect_true(grepl(-0.609, response$results$htmlSummary)) #Z'
  expect_true(grepl(-0.529, response$results$htmlSummary)) #Robust Z'
  expect_true(grepl(-85.030, response$results$htmlSummary)) #Z
  expect_true(grepl(-16.063, response$results$htmlSummary)) #Robust Z
})

test_that("The basic file format is capitalization independent", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/basicCapitalization.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expectNoProblems(response)
  expect_true(grepl(-92.038, response$results$htmlSummary)) #Z
  expect_true(grepl("Flagged wells: 4", response$results$htmlSummary))
})
