# Unit Tests for getExcelColumnFromNumber
#
# Author: Jennifer Rogers, modifying code
# from Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("getExcelColumnFromNumber")

test_that("getExcelColumnFromNumber gets the right column", {
  expect_equal("A", getExcelColumnFromNumber(1))
  expect_equal("AP", getExcelColumnFromNumber(42))
  expect_equal("RFU", getExcelColumnFromNumber(12345))
})

test_that("getExcelColumnFromNumber refuses bad column numbers", {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getExcelColumn0.Rda")
  expect_identical(getExcelColumn0, tryCatch.W.E(getExcelColumnFromNumber(0)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getExcelColumnNegative1.Rda")
  expect_identical(getExcelColumnNegative1, tryCatch.W.E(getExcelColumnFromNumber(-1)))
})
