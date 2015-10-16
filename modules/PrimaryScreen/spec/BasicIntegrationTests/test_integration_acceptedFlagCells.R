# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests that a user can flag an analysis group any way
# they want, as long as there is no more than one flag
# per group
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

context("acceptedFlagCells")

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

test_that("A user can flag every single well with the same information as is in the 'hit' column", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/allUserHits.xlsx"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

test_that("A user doesn't have to flag the first cell in an analysis group", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/oddlyFlaggedGroups.csv"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

test_that("Unflagged analysis groups revert to their default flagging, and don't affect other groups", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/hitsChangedAndMissing.csv"
  response <- runPrimaryAnalysis(request)
  
  # Should have the same Z's (they're computed using wells, not analysis groups),
  # but a different number of hits (we changed two groups to 'no hit')
  expect_true(grepl(105, response$results$htmlSummary)) #The number of hits
  expect_true(grepl(-0.607, response$results$htmlSummary)) #Z'
  expect_true(grepl(-0.526, response$results$htmlSummary)) #Robust Z'
  expect_true(grepl(-85.030, response$results$htmlSummary)) #Z
  expect_true(grepl(-16.063, response$results$htmlSummary)) #Robust Z
  expectNoProblems(response)
})

test_that("Users have the option of leaving all flags blank, and the calculated result will be used", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/missingHits.csv"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

