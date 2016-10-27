# Unit tests for extractValueKinds
#
# Author: Jennifer Rogers, adapted from
# tests by Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("extractValueKinds")

errorList <<- list()

test_that("extractValueKinds can extract units", {
  skip("fix later")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector.rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/returnDataFrame.rda")
  
  expect_identical(returnDataFrame, extractValueKinds(valueKindsVector,
                                                      ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                                      uncertaintyType = c(NA_character_, NA_character_, NA_character_, NA_character_),
                                                      uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                                      commentCol = c(FALSE, FALSE, FALSE, FALSE),
                                                      commentCodeWord = "comment@coDeWoRD@"))
})

test_that("extractValueKinds recognizes uncertainty columns", {
  skip("fix later")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector1.rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/returnDataFrame1.rda")
  
  expect_identical(returnDataFrame, extractValueKinds(valueKindsVector,
                                                      ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                                      uncertaintyType = c(NA_character_, NA_character_, NA_character_, NA_character_, "standard deviation"),
                                                      uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                                      commentCol = c(FALSE, FALSE, FALSE, FALSE, FALSE),
                                                      commentCodeWord = "comment@coDeWoRD@"))
})

test_that("extractValueKinds recognizes comment columns", {
  skip("fix later")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector2.rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/returnDataFrame2.rda")
  
  expect_identical(returnDataFrame, extractValueKinds(valueKindsVector,
                                                      ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                                      uncertaintyType = c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_),
                                                      uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                                      commentCol = c(FALSE, FALSE, FALSE, FALSE, TRUE),
                                                      commentCodeWord = "comment@coDeWoRD@"))
})

test_that("extractValueKinds accepts a comment column and a standard deviation column for the same parent column", {
  skip("fix later")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector3.rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/returnDataFrame3.rda")
  
  expect_identical(returnDataFrame, extractValueKinds(valueKindsVector,
                                                      ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                                      uncertaintyType = c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, "standard deviation"),
                                                      uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                                      commentCol = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE),
                                                      commentCodeWord = "comment@coDeWoRD@"))
})

test_that("extractValueKinds throws errors on duplicated columns", {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector4.rda")
  
  expect_that(extractValueKinds(valueKindsVector,
                                ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                uncertaintyType = c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_),
                                uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                commentCol = c(FALSE, FALSE, FALSE, FALSE, FALSE),
                                commentCodeWord = "comment@coDeWoRD@"),
              throws_error(regexp = "log solubility"))
})

test_that("extractValueKinds throws errors on blank column headers", {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector5.rda")
  
  expect_that(extractValueKinds(valueKindsVector,
                                ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                uncertaintyType = c(NA_character_, NA_character_, NA_character_, "standard deviation", NA_character_, NA_character_, NA_character_),
                                uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                commentCol = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
                                commentCodeWord = "comment@coDeWoRD@"),
              throws_error(regexp = "blank column header"))
})

test_that("extractValueKinds accepts times, concentrations, and units together", {
  skip("fix later")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/valueKindsVector6.rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractValueKinds/returnDataFrame6.rda")
  
  expect_identical(returnDataFrame, extractValueKinds(valueKindsVector,
                                                      ignoreHeaders = c("Corporate Batch ID", "originalMainID"),
                                                      uncertaintyType = c(NA_character_, NA_character_, NA_character_, NA_character_),
                                                      uncertaintyCodeWord = "uncertainty@coDeWoRD@",
                                                      commentCol = c(FALSE, FALSE, FALSE, FALSE),
                                                      commentCodeWord = "comment@coDeWoRD@"))
})
