# Unit tests for data validation functions
# Author: Jennifer Rogers
# These are NOT integration tests -- we do
# not test that the roo services
# work correctly, just that the function
# performs as expected if the response from
# the roo services is as expected

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("validateScientist")

errorList <<- list()

test_that("Scientists in the database are returned with no errors", {
  # Note: Because this is in test mode, they don't actually have to be in the database
  
  errorList <<- list()
  expect_identical("smeyer", validateScientist("smeyer", racas::applicationSettings, testMode = TRUE))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical("Brian Bolt", validateScientist("Brian Bolt", racas::applicationSettings, testMode = TRUE))
  expect_identical(list(), errorList)
})

test_that("Scientists not in the database are returned as the empty string, and give an error", {
  skip("fix later")
  errorList <<- list()
  expect_identical("", validateScientist("unknownUser", racas::applicationSettings, testMode = TRUE))
  expect_identical(list("The Scientist you supplied, 'unknownUser', is not a valid name. Please enter the scientist's login name."),
                   errorList)
})

test_that("Empty strings are returned as the empty string, with one error", {
  skip("fix later")
  errorList <<- list()
  expect_identical("", validateScientist("", racas::applicationSettings, testMode = TRUE))
  expect_identical(list("There was an error in validating the scientist's name: "),
                   errorList)
})


