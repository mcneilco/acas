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
  # File path to R tests (all file names should start with 'test')
  test_dir(filePathToTests)
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
