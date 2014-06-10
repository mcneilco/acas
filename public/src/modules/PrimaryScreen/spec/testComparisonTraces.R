# Tests for the saveComparisonTraces function
# Author: Jennifer Rogers
# Note, you should have the unkeyed, original
#       resultTable in your global environment
#       (or, just load it in this file)
# And, importantly, the tests work on that SPECIFIC table

library(data.table)
library(testthat)
source('~/Documents/Data Analysis Tool/saveComparisonTraces3.R')

gives_no_warning <- function() {
  function (expr) 
  {
    warnings <- evaluate_promise(expr)$warnings
    expectation(length(warnings) == 0, "warnings given")
  }
}

test_that("colors are chosen correctly", {
  expect_identical(getColor("NC"), "darkgreen")
  expect_identical(getColor("no agonist"), "blue")
  expect_identical(getColor("test"), "red")
})


# If these err, check that you are getting batchNames that are at the
# beginning of the alphabet, with no breaks (ie, when you alphabetize
# the batchNames, you have to take from numbers 1, 2, and 3, not 4, 5, and
# 7). You can take the NC from anywhere.
test_that("no data table with appropriate factors will give an error", {
  setkey(resultTable, batchName)
  
  distinctSeries <- resultTable[c(1, 3, 5, 7, 672, 673)]
  doubledSeries <- resultTable[c(1:8, 672, 673)]
  onlyTest <- resultTable[c(3, 7, 672, 673)]
  onlyNoAgonist <- resultTable[c(1, 5, 672, 673)]
  twoCompounds <- resultTable[c(1:16, 672, 673)]
  moreNCs <- resultTable[c(1, 3, 5, 7, 641:657, 673:682)]
  
  expect_that(saveComparisonTraces(resultTable, "~/Desktop/smallplot", debugMode = TRUE), 
              gives_no_warning())
  expect_that(saveComparisonTraces(distinctSeries, "~/Desktop/smallplot", debugMode = TRUE),
              gives_no_warning())
  expect_that(saveComparisonTraces(doubledSeries, "~/Desktop/smallplot", debugMode = TRUE),
              gives_no_warning())
  expect_that(saveComparisonTraces(onlyTest, "~/Desktop/smallplot", debugMode = TRUE),
              gives_no_warning())
  expect_that(saveComparisonTraces(onlyNoAgonist, "~/Desktop/smallplot", debugMode = TRUE),
              gives_no_warning())
  expect_that(saveComparisonTraces(twoCompounds, "~/Desktop/smallplot", debugMode = TRUE),
              gives_no_warning())
  expect_that(saveComparisonTraces(moreNCs, "~/Desktop/smallplot", debugMode = TRUE),
              gives_no_warning())
})

test_that("output vectors have NA's in them", {
  setkey(resultTable, batchName)
  
  distinctSeries <- resultTable[c(1, 3, 5, 7, 672, 673)]
  doubledSeries <- resultTable[c(1:8, 672, 673)]
  onlyTest <- resultTable[c(3, 7, 672, 673)]
  onlyNoAgonist <- resultTable[c(1, 5, 672, 673)]
  twoCompounds <- resultTable[c(1:16, 672, 673)]
  moreNCs <- resultTable[c(1, 3, 5, 7, 641:657, 673:682)]
  
  expect_that(any(is.na(saveComparisonTraces(resultTable, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
  expect_that(any(is.na(saveComparisonTraces(distinctSeries, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
  expect_that(any(is.na(saveComparisonTraces(doubledSeries, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
  expect_that(any(is.na(saveComparisonTraces(onlyTest, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
  expect_that(any(is.na(saveComparisonTraces(onlyNoAgonist, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
  expect_that(any(is.na(saveComparisonTraces(twoCompounds, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
  expect_that(any(is.na(saveComparisonTraces(moreNCs, "~/Desktop/smallplot", debugMode = TRUE))), 
              is_true())
})

test_that("the function will fail gracefully if it isn't give wells of type test or no agonist", {
  setkey(resultTable, batchName)
  
  onlyNCs <- resultTable[c(641:657, 673:682)]
  emptyTable <- resultTable[wellType == 'nothing']
  
  expect_that(saveComparisonTraces(onlyNCs, "~/Desktop/smallplot", debugMode = TRUE), 
              throws_error("Internal error: No wells of type 'test' or 'no agonist' were supplied"))
  expect_that(saveComparisonTraces(emptyTable, "~/Desktop/smallplot", debugMode = TRUE), 
              throws_error("Internal error: No wells of type 'test' or 'no agonist' were supplied"))
}) 

