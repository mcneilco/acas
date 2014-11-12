# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests what happens when your choice of flagging mode is at odds
# with the flags you have actually changed.
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

context("flagBoth")

test_that("We give warnings for flags when the user promised not to flag them, and don't include them in our analysis.", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/flagBothAGandWells.csv"
  request$flaggingStage <- "analysisGroupFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(grepl(108, response$results$htmlSummary)) #The number of hits
  expect_true(response$hasWarning)
  expect_false(response$hasError)
  expect_true(grepl("flag wells", response$errorMessages[[1]]$message))
  
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(grepl(109, response$results$htmlSummary)) #The number of hits
  expect_true(response$hasWarning)
  expect_false(response$hasError)
  expect_true(grepl("User Defined Hit", response$errorMessages[[1]]$message))
})
