# Unit tests for getLinkColumns
#
# Author: Jennifer Rogers, adapted from
# tests by Sam Meyer

library(testthat)
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

context("getLinkColumns")

test_that("getLinkColumns handles cases without errors", {
  errorList <<- list()
  expect_identical(c(TRUE,FALSE,FALSE,FALSE,FALSE), getLinkColumns(c("Text[link]","Text (link)","Date[]","String","NotADatatype("), errorEnv = NULL))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c(TRUE), getLinkColumns(c("[link]")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c(TRUE), getLinkColumns(c("Text   [link]")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c(TRUE, FALSE), getLinkColumns(c("Text [link]", "link")))
  expect_identical(list(), errorList)
})

test_that("getLinkColumns handles cases with unrecognized entries in brackets", {
  errorList <<- list()
  expect_identical(c(FALSE,FALSE), getLinkColumns(c("Text [.hello world!]", "Text [ ]"), errorEnv = NULL))
  expect_identical(list("In Datatype columns A, B, there are unknown entries in the brackets that cannot be understood: '.hello world!', ' '. Please enter 'link' or nothing."),
                   errorList)
})

test_that("getLinkColumns accepts a variety of missing input", {
  errorList <<- list()
  expect_identical(c(FALSE, FALSE, FALSE), getLinkColumns(c("", NA_character_, "Text []")))
  expect_identical(list(), errorList)  
})

test_that("getLinkColumns doesn't error when given multiple entries in parentheses", {
  errorList <<- list()
  expect_identical(c(TRUE, FALSE), getLinkColumns(c("Text [link] (shown)", "Text (hidden)")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c(TRUE, FALSE), getLinkColumns(c("Text (hidden) [link]", "Text (hidden)")))
  expect_identical(list(), errorList)
})

test_that("getLinkColumns does not allow more than one link", {
  expect_that(getLinkColumns(c("Text [link]", "Text [link]")), throws_error())
})

test_that ("getLinkColumns accepts varieties of capitalization", {
  errorList <<- list()
  expect_identical(c(TRUE), getLinkColumns(c("rabbit[Link]"), errorEnv = NULL))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c(TRUE), getLinkColumns(c("Text [LINK]"), errorEnv = NULL))
  expect_identical(list(), errorList)
})