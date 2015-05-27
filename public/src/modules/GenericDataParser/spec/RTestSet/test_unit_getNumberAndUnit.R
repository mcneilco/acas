# Tests getNumberAndUnit
#
# Author: Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("getNumberAndUnit")

test_that("numbers get parsed", {
  expect_equal(getNumberAndUnit("10 uM"), list(num=10, unit="uM"))
  expect_equal(getNumberAndUnit(c("10 uM", "20uM")), list(num=c(10, 20), unit=c("uM", "uM")))
})

test_that("blanks become NA", {
  expect_equal(getNumberAndUnit(""), list(num=NA_real_, unit=NA_character_))
  expect_equal(getNumberAndUnit(c("", "20.5uM")), list(num=c(NA_real_, 20.5), unit=c(NA_character_, "uM")))
})

test_that("/ is valid (was ACASDEV-134)", {
  expect_equal(getNumberAndUnit(c("45 mg/kg", "20uM")), list(num=c(45, 20), unit=c("mg/kg", "uM")))
})

test_that("Missing a number is an error", {
  expect_error(getNumberAndUnit("beasdfasdf"), "beasdfasdf")
})

test_that("invalid numbers are an error", {
  expect_error(getNumberAndUnit("2342342.234.23423"), "2342342\\.234\\.23423")
})