# Runs all of the R tests for generic data parser
# Author: Jennifer Rogers
#
# Usage: Run all tests with testGenericDataParser. Run an individual test
#        by typing "test" + its context -- one of the headings you see 
#        when you run testGenericDataParser (ie, test the context 
#        validateScientist with testValidateScientist)
#
# Note: This testing schema is dependent upon the file structure of ACAS.
#       If you change the location of the tests, be sure the change the
#       path here. If you change the location of generic_data_parser, be
#       sure to change it in ALL the test files
#       This file will run regardless of where it is located in the ACAS
#       file structure.

library(racas)
library(testthat)

# File path to R tests (all file names should start with 'test')
filePathToTests <- file.path(racas::applicationSettings$appHome,
                                      "public",
                                      "src",
                                      "modules",
                                      "GenericDataParser",
                                      "spec",
                                      "RTestSet")

testGenericDataParser <- function() {
  test_dir(filePathToTests)
}

# Our own expectation: gives_no_warning()
# Please copy/paste into any unit test file
# where you want to use it
gives_no_warning <- function() {
  function(expr)
  {
    warnings <- evaluate_promise(expr)$warnings
    expectation(
      length(warnings) == 0,
      paste0(length(warnings), " warnings created")
    )
  }
}


testGetExcelColumnFromNumber <- function() {
  test_file(file.path(filePathToTests, "test_unit_getExcelColumnFromNumber.R"))
}

testGetHiddenColumns <- function() {
  test_file(file.path(filePathToTests, "test_unit_getHiddenColumns.R"))
}

testGetLinkColumns <- function() {
  test_file(file.path(filePathToTests, "test_unit_getLinkColumns.R"))
}

testTryCatch.W.E <- function() {
  test_file(file.path(filePathToTests, "test_unit_tryCatchWE.R"))
}

testValidateCalculatedResultDatatypes <- function() {
  test_file(file.path(filePathToTests, "test_unit_validateDatatypes.R"))
}

testValidateScientist <- function() {
  test_file(file.path(filePathToTests, "test_unit_validateScientist.R"))
}

testValidationFunctions <- function() {
  test_file(file.path(filePathToTests, "test_unit_validatingFunctions.R"))
}

testExtractValueKinds <- function() {
  test_file(file.path(filePathToTests, "test_unit_extractValueKinds.R"))
}

testValidateMetaData <- function() {
  test_file(file.path(filePathToTests, "test_unit_validateMetaData.R"))
}

testGetNumberAndUnit <- function() {
  test_file(file.path(filePathToTests, "test_unit_getNumberAndUnit.R"))
}

