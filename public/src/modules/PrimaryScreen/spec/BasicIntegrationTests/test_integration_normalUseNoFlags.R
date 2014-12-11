# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests common use cases where the user adds no flags 
# to the data
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

context("normalUseNoFlags")

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

test_that("If a user doesn't upload a flagged file, analysis proceeds as usual", {
  request$flaggedWells <- NULL
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
  
  #TODO: Which one of these is actually what a missing file looks like?
  
  request$flaggedWells <- ""
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

test_that("The user can give us an unmodified Override file", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/uneditedFile.csv"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
})

test_that("The file gets saved to the correct location", {
  suppressWarnings(file.remove(racas::getUploadedFilePath("experiments/test")))
  
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/uneditedFile.csv"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expectUnmodifiedResults(response)
  expectNoProblems(response)
  expect_true(file.exists(racas::getUploadedFilePath("experiments/test/draft/test_OverrideDRAFT.csv")))
})
