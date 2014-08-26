# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests cases where the user has modified the structure of the
# provided file, or modified the wrong column
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

context("modifiedFileStructure")

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

test_that("We recover gracefully when the 'User Defined Hit' column is absent", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/missingUserHit.csv"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)

  expect_false(response$hasWarning)
  expect_true(response$hasError)
  expect_true(grepl("information", response$errorMessages[[1]]$message))
})

test_that("Altering the 'hit' column (as opposed to the 'user defined hit' column) doesn't actually flag groups", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/flagHitColumn.csv"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

test_that("Removing rows from the provided override file results in a helpful error", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/deficientFlags.xlsx"
  response <- runPrimaryAnalysis(request)
  
  expect_false(response$hasWarning)
  expect_true(response$hasError)
  expect_true(grepl("experiment", response$errorMessages[[1]]$message))
})


