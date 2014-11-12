# Runs all of the R tests for primaryAnalysis
# Author: Jennifer Rogers
#
# Usage: Run all tests with testPrimaryAnalysis. Run an individual test
#        by typing "test" + its context -- one of the headings you see 
#        when you run testPrimaryAnalysis.
#
# Requirements: The file "confirmationRegression.zip" must be in the first
#       level of your privateUploads folder. A copy of this zip may be
#       found under BasicIntegrationTests > IO_for_test_files > experiment
#
# Limitations: At this time, the tests do not search the "override" file to
#       see if it is formatted properly. You can access the file because
#       we know where it's saved and what its name will be, but it's only
#       worth it to look at the file's contents in specific situations
#       (eg, when we enter flags and want to see if they are preserved)
#
# Note: This testing schema is dependent upon the file structure of ACAS.
#       If you change the location of the tests, be sure the change the
#       path here. If you change the location of primaryAnalysis.R, be
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
                             "PrimaryScreen",
                             "spec",
                             "BasicIntegrationTests")

testPrimaryAnalysis <- function() {
  # Put the "standard" (flagless) override file in the directory, so tests can compare which
  # flags were newly added
  file.copy(from = "public/src/modules/PrimaryScreen/spec/BasicIntegrationTests/IO_for_test_files/flagUploads/uneditedFile.csv",
            to = racas::getUploadedFilePath("experiments/test/draft/test_OverrideDRAFT.csv"),
            overwrite = TRUE)
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


testNormalUseNoFlags <- function() {
  test_file(file.path(filePathToTests, "test_integration_normalUseNoFlags.R"))
}

testBasicFormat <- function() {
  test_file(file.path(filePathToTests, "test_integration_basicFormat.R"))
}

testModifiedFileStructure <- function() {
  test_file(file.path(filePathToTests, "test_integration_modifiedFileStructure.R"))
}

testAcceptedFlagCells <- function() {
  test_file(file.path(filePathToTests, "test_integration_acceptedFlagCells.R"))
}

testflagCapitalization <- function() {
  test_file(file.path(filePathToTests, "test_integration_flagCapitalization.R"))
}

testBadFlags <- function() {
  test_file(file.path(filePathToTests, "test_integration_badFlags.R"))
}

testManyWellsFlagged <- function() {
  test_file(file.path(filePathToTests, "test_integration_manyWellsFlagged.R"))
}

testMinimalFlagInformation <- function() {
  test_file(file.path(filePathToTests, "test_integration_minimalFlagInformation.R"))
}

testFlagValues <- function() {
  test_file(file.path(filePathToTests, "test_integration_flagValues.R"))
}

testFlagBoth <- function() {
  test_file(file.path(filePathToTests, "test_integration_flagBoth.R"))
}
