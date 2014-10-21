# Tests validateDate, validateNumeric, and validateCharacter
#
# Author: Jennifer Rogers, modifying functions by Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("validationFunctions")

errorList <<- list()


test_that("validateCharacter (from racas) works in normal cases", {
  expect_equal("hello world!", validateCharacter("hello world!"))
  expect_equal("42", validateCharacter(42))
})

test_that("validateCharacter handles missing cases", {
  expect_equal(NULL, validateCharacter(NULL))
  expect_equal(NA, validateCharacter(NA))
  expect_equal(NA_character_, validateCharacter(NA_character_))
  expect_equal("", validateCharacter(""))
})

test_that("validateCharacter handles special punctuation and characters", {
  expect_equal("we.ir .d p_unct!uation", validateCharacter("we.ir .d p_unct!uation"))
  expect_equal("RetainCaps", validateCharacter("RetainCaps"))
})

test_that("validateCharacter handles factors as input", {
  expect_equal("i", validateCharacter(factor("i")))
  expect_equal("42", validateCharacter(factor(42)))
})

test_that("validateDate (from racas) works in normal cases", {
  expect_equal(validateDate("2012-12-05"), "2012-12-05")
  expect_equal(validateDate(factor("2012-12-05")), "2012-12-05")
})

test_that("validateDate gives warnings", {
  # Check that there is a warning (bad date format)
  output <- tryCatch.W.E(expect_equal("2012-02-05", validateDate("02-05-2012")))
  expect_true(output$value$passed)
  expect_equal(1, length(output$warningList))
  
  output <- tryCatch.W.E(expect_equal("2005-03-16", validateDate("3/16/05")))
  expect_true(output$value$passed)
  expect_equal(1,length(output$warningList))
  
  # Try passing bad dates
  expect_equal(validateDate("99/99/1999"), "")
  # The future isn't allowed (over one year)
  expect_equal(validateDate("2059-06-20"), "")
  # Nor is the past (over 50 years)
  expect_equal(validateDate("1941-12-07"), "")
})

test_that("validateDate handles missing values", {
  expect_equal(NA, validateDate(NA))
})

test_that ("validateNumeric (from racas) works in typical cases", {
  expect_equal(42, validateNumeric(42))
  expect_equal(3.14159, validateNumeric(3.14159))
  expect_equal(3, validateNumeric("3"))
  expect_equal(1000, validateNumeric("1,000.0"))
  expect_equal(-0.05, validateNumeric("-.05"))
  expect_equal(0.123456789, validateNumeric("0.123456789"))
  expect_equal(1234567.89, validateNumeric("1234,567.89"))
  expect_equal(1234, validateNumeric("01234.0"))
})

test_that("validateNumeric accepts factors", {
  expect_equal(43, validateNumeric(factor(43)))
  expect_equal(-1, validateNumeric(factor("-1")))
})

test_that("validateNumeric gives NA for non-numeric values", {
  errorList<<-list()
  expect_equal(validateNumeric("pi"), as.numeric(NA))
  expect_identical(list("An entry was expected to be a number but was: 'pi'. Please enter a number instead."), errorList)
  
  errorList<<-list()
  expect_true(is.na(validateNumeric(as.Date("2013-01-04"))))
  expect_identical(list("An entry was expected to be a number but was: '2013-01-04'. Please enter a number instead."), errorList)
})

test_that("validateDate consistently returns a date (was bug RACAS#6)", {
  expect_that(validateDate("2012-11-07"), is_a("character"))
  expect_that(suppressWarnings(validateDate("2012/11/07")), is_a("character"))
})