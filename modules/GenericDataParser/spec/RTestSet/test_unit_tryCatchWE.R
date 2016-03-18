# Unit tests for "tryCatch.W.E"
# 
# Author: Jennifer Rogers, modifying tests
# by Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("tryCatch.W.E")

errorList <<- list()

test_that ("tryCatch.W.E (from racas > errorLogging) correctly throws no errors", {
  throwNoErrors <- function() {return("hello world!")}
  expect_identical(list(value="hello world!",warningList=list()), tryCatch.W.E(throwNoErrors()))
})


test_that("tryCatch.W.E correctly throws an error", { 
  throwAnError <- function() {stop("Stop Now")}
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/TryCatch.W.EcaughtError.Rda")
  expect_identical(caughtError, tryCatch.W.E(throwAnError()))
})


test_that("tryCatch.W.E handles warnings", {
  throwAWarning <- function() {
    warning("This is a warning") 
    return("hello world!")
  }
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/TryCatch.W.EcaughtWarning.Rda")
  expect_identical(caughtWarning, tryCatch.W.E(throwAWarning()))
})
  
test_that("tryCatch.W.E can throw a both warnings and errors", {
  throwTwoWarningsAndAnError <- function() {
    warning("This is a warning")
    warning("This is also a warning") 
    stop("Stop Now")
  }
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/TryCatch.W.EcaughtTwoWarningsAndAnError.Rda")
  expect_identical(caughtWarningsAndError, tryCatch.W.E(throwTwoWarningsAndAnError()))
})