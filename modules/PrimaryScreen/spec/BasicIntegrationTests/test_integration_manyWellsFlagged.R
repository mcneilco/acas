# Integration testing for the flagging features of
# primaryAnalysis (without saving to the database)
#
# Tests what happens when a large number of wells are flagged
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

context("manyWellsFlagged")

expectNoProblems <- function(response) {
  expect_false(response$hasWarning)
  expect_false(response$hasError)
}

test_that("We give a helpful error when all 'test' wells are flagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/allTestsFlagged.csv"
  response <- runPrimaryAnalysis(request)
  
  expect_true(response$hasError)
  expect_false(response$hasWarning)
  expect_true(grepl("wells", response$errorMessages[[1]]$message))
})

test_that("We give a helpful error when only one 'test' well is unflagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/oneUnflaggedTest.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(response$hasError)
  expect_false(response$hasWarning)
  expect_true(grepl("wells", response$errorMessages[[1]]$message))
})

test_that("We give a helpful error when all of the positive controls are flagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/flagAllPC.xlsx"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(response$hasError)
  expect_false(response$hasWarning)
  expect_true(grepl("positive controls", response$errorMessages[[1]]$message))
})

test_that("We give a helpful error when all positive controls in a normalization group are flagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/onePCUnflagged.xlsx"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(response$hasError)
  expect_false(response$hasWarning)
  expect_true(grepl("positive controls", response$errorMessages[[1]]$message))
})

test_that("The minimum number of positive controls will work without errors", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/minimumPC.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expectNoProblems(response)
  expect_true(grepl(68, response$results$htmlSummary)) #The number of hits
  expect_true(grepl(0.424, response$results$htmlSummary)) #Z'
  expect_true(grepl(0.489, response$results$htmlSummary)) #Robust Z'
  expect_true(grepl(-6.352, response$results$htmlSummary)) #Z
  expect_true(grepl(-6.390, response$results$htmlSummary)) #Robust Z
})

test_that("We throw a helpful error when all negative controls are flagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/flagAllNC.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(response$hasError)
  expect_false(response$hasWarning)
  expect_true(grepl("negative controls", response$errorMessages[[1]]$message))
})

test_that("We throw a helpful error when all negative controls in a normalization group are flagged", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/oneNCUnflagged.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expect_true(response$hasError)
  expect_false(response$hasWarning)
  expect_true(grepl("negative controls", response$errorMessages[[1]]$message))
})

test_that("The minimum number of negative controls will work without errors", {
  request$flaggedWells <- 
    "../public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/minimumNC.csv"
  request$flaggingStage <- "wellFlags"
  response <- runPrimaryAnalysis(request)
  
  expectNoProblems(response)
  expect_true(grepl(-0.476, response$results$htmlSummary)) #Z'
  expect_true(grepl(-0.509, response$results$htmlSummary)) #Robust Z'
  expect_true(grepl(-85.030, response$results$htmlSummary)) #Z
  expect_true(grepl(-16.063, response$results$htmlSummary)) #Robust Z
})