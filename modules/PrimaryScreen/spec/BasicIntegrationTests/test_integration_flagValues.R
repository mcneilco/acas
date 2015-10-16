# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests that the parser accepts a variety of flag values
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

context("flagValues")

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

test_that("Special characters and NA are passed through as flag values, with an input csv (known bug if using old version of readExcelOrCsv)", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/oddFlagNames.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expectNoProblems(response)
  expect_true(grepl("Flagged wells: 5", response$result$htmlSummary))
})

test_that("Special characters and NA are passed through as flag values, with an input Excel file", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/oddFlagNames.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expectNoProblems(response)
  expect_true(grepl("Flagged wells: 5", response$result$htmlSummary))
})
