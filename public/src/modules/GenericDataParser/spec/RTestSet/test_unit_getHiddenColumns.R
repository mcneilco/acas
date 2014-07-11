# Unit tests for getHiddenColumns
# 
# Author: Jennifer Rogers, adapted from
# tests by Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("getHiddenColumns")

errorList <<- list()

test_that("getHiddenColumns handles cases without errors", {
  errorList <<- list()
  expect_identical(c(FALSE,TRUE,TRUE,FALSE,FALSE), getHiddenColumns(c("Text(shown)","Text (hidden)","Date(hidden)","String","NotADatatype("), errorEnv = NULL))
  expect_identical(list(), errorList)
})

test_that("getHiddenColumns handles cases with unrecognized entries in parentheses", {
  errorList <<- list()
  expect_identical(c(FALSE,FALSE), getHiddenColumns(c("Text","Text (hello world!)"), errorEnv = NULL))
  expect_identical(list("In Datatype column B, there is an entry in the parentheses that cannot be understood: 'hello world!'. Please enter 'shown' or 'hidden'."),
                   errorList)
})
  

test_that("getHiddenColumns accepts a variety of missing input", {
  errorList <<- list()
  expect_identical(c(FALSE, FALSE, FALSE), getHiddenColumns(c("", NA_character_, "Text ()")))
  expect_identical(list(), errorList)  
})

test_that("getHiddenColumns doesn't error when given multiple entries in parentheses", {
  errorList <<- list()
  expect_identical(c(FALSE, TRUE), getHiddenColumns(c("Text (hidden) (shown)", "Text (shown) (hidden)")))
  expect_identical(list(), errorList)
})

test_that ("getHiddenColumns accepts varieties of capitalization", {
  errorList <<- list()
  expect_identical(c(TRUE,TRUE,FALSE,FALSE,FALSE), getHiddenColumns(c("rabbit(hidden)", "Text (Hidden)", "Date (Shown)", "Text(shown)", "NotADatatype)"), errorEnv = NULL))
  expect_identical(list(), errorList)
})
