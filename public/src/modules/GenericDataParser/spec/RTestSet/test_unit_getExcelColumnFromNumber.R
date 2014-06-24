# Unit Tests for getExcelColumnFromNumber
#
# Author: Jennifer Rogers, modifying code
# from Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("getExcelColumnFromNumber")

errorList <<- list()

test_that("getExcelColumnFromNumber gets the right column", {
  expect_equal("A", getExcelColumnFromNumber(1))
  expect_equal("AP", getExcelColumnFromNumber(42))
  expect_equal("RFU", getExcelColumnFromNumber(12345))
})

test_that("getExcelColumnFromNumber refuses bad column numbers", {
  expect_equal("none", tryCatch.W.E(getExcelColumnFromNumber(0))$value)
  expect_equal(2, length(tryCatch.W.E(getExcelColumnFromNumber(0))))
  
  expect_equal("none", tryCatch.W.E(getExcelColumnFromNumber(-1))$value)
  expect_equal(2, length(tryCatch.W.E(getExcelColumnFromNumber(-1))))
})
