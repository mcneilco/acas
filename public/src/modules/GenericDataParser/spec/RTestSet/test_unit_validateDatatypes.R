# Unit Tests for validateCalculatedResultDatatypes
#
# Author: Jennifer Rogers, using code written by
# Sam Meyer

library(testthat)
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

context("validateCalculatedResultDatatypes")


test_that("Typical use cases work as expected", {
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("Datatype","Text","Number","Date"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Date"),
                   validateCalculatedResultDatatypes(
                     c("Datatype (hidden)", "Text (HIDDEN)", "Number (Shown)", "Date(shown)"),
                     c("Corporate Batch ID", "Octopus (hidden)", "curve id", "max")))
  expect_identical(list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, it is 'Datatype (hidden)'."), errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Number", "Number", "Number"),
                   validateCalculatedResultDatatypes(
                     c("Datatype", "Number", "Number", "Number"),
                     c("Corporate Batch ID", "Rendering Hint", "curve id", "Max")))
  expect_identical(list(), errorList)
})


test_that("The entries in the second list make no difference if the first list is correct", {
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("Datatype","Text","Number","Date"),
                                                     c("Octopus","Sculpin","")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("Datatype","Text","Number","Date"),
                                                     c()))
  expect_identical(list(), errorList)
})

test_that("Error cases give an error", {
  errorList <<- list()
  expect_identical(c("Datatype", "frog", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("Datatype","frog","Number","Date"),
                                                     c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_equal(1, length(errorList))
  
  errorList <<- list()
  expect_identical(c("killer rabbit", "Text", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("killer rabbit","Text","Number","Date"),
                                                     c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_equal(1, length(errorList))
  
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Datatype", "Number"),
                   validateCalculatedResultDatatypes(c("Datatype","Text","Datatype","Number"),
                                                     c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_equal(1, length(errorList))
})


test_that("Error cases give the correct error", {
  errorList <<- list()
  expect_identical(c("Datatype", "frog", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("Datatype","frog","Number","Date"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list("The loader found classes in the Datatype row that it does not understand: 'frog'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."),
                 errorList)
  
  errorList <<- list()
  expect_identical(c("killer rabbit", "Text", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("killer rabbit","Text","Number","Date"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, it is 'killer rabbit'."),
                 errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Datatype", "Number"),
                   validateCalculatedResultDatatypes(c("Datatype","Text","Datatype","Number"),
                                                     c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list("The loader found classes in the Datatype row that it does not understand: 'datatype'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."),
                   errorList)
})


test_that("Leading and trailing whitespace is trimmed", {
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Date"), 
                   validateCalculatedResultDatatypes(c("Datatype", "  Text", "Number", "Date  "),
                                                     c("Corporate Batch ID", "Rendering Hint", "curve id", "Max")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Date"), 
                   validateCalculatedResultDatatypes(c(" Datatype ", "Text", "Number", "Date"),
                                                     c("Corporate Batch ID", "Rendering Hint", "curve id", "Max")))
  expect_identical(list(), errorList)
})


test_that("Missing Datatypes are handled appropriately", {
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Number", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("Datatype","  ","Number","Date"),
                                                     c("Fish"))))
  expect_that(validateCalculatedResultDatatypes(c("Datatype","  ","Number","Date"),
                                                c("Fish")),
              gives_warning())
  expect_identical(list(), errorList)
})


test_that("the function can interpret datatypes", {
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Text", "Number", "Number"),
                                    validateCalculatedResultDatatypes(c("Datatype","text","Number","Number"),
                                                                      c("Corporate Batch ID","Rendering Hint","curve id","Max"))))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Text", "Number", "Number"),
                                    validateCalculatedResultDatatypes(c("Datatype","TEXT","Number","Number"),
                                                                      c("Corporate Batch ID","Rendering Hint","curve id","Max"))))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "standard deviation", "Number", "Number"),
                                    validateCalculatedResultDatatypes(c("Datatype","Std. Dev","Number","Number"),
                                    c("Corporate Batch ID","Rendering Hint","curve id","Max"))))
  expect_identical(list(), errorList)                              
})


test_that("The function gives the right warnings when interpreting datatypes", {
  # These go with the tests above -- we've already asked if they give errors
  expect_that(validateCalculatedResultDatatypes(c("Datatype","text","Number","Number"),
                                                c("Corporate Batch ID","Rendering Hint","curve id","Max")),
              gives_warning("In column \"Rendering Hint\", the loader found 'text' as a datatype and interpreted it as 'Text'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
  # This will fail until we return same-case error messages
  expect_that(validateCalculatedResultDatatypes(c("Datatype","text","Number","Number"),
                                                c("Corporate Batch ID","Rendering Hint","curve id","Max")),
              gives_warning("In column \"Rendering Hint\", the loader found 'TEXT' as a datatype and interpreted it as 'Text'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
  expect_that(validateCalculatedResultDatatypes(c("Datatype","Std. Dev","Number","Number"),
                                                c("Corporate Batch ID","Rendering Hint","curve id","Max")),
              gives_warning("In column \"Rendering Hint\", the loader found 'Std. Dev' as a datatype and interpreted it as 'Standard Deviation'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
})


test_that("lockCorpBatchId works as expected", {
  # This should give an error because "Boxes" isn't an okay field name
  errorList <<- list()
  expect_identica(c("Boxes", "comments", "Text"), validateCalculatedResultDatatypes(c("Boxes", "comments", "Text"), 
                                    c("Corporate Batch ID", "Boxes", "Refrigerators"), FALSE))
  expect_identical(1, length(errorList))
})


test_that("Empty datatypes are handled correctly", {
  errorList <<- list()
  suppressWarninges(expect_identical(c("Datatype", "Number", "Number", "Number"),
                   validateCalculatedResultDatatypes(c("Datatype", "()", "Number", "Number"),
                                                     c("Corporate Batch ID", "Rendering Hint", "curve id", "Max"))))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
                   validateCalculatedResultDatatypes(c("Datatype", "([link])", "Text"),
                                                     c("Herring", "Shrubbery", "Ni"))))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
                                    validateCalculatedResultDatatypes(c("Datatype", "", "Text"), c())))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identica(c("Datatype", "Number", "Text"),
                                   validateCalculatedResultDatatypes(c("Datatype", NA, "Text"), 
                                                                     c("Data", "DataType", NA_character_))))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
                                    validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                     c())))
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
                                    validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                                      c("", "", ""))))
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
                                    validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                                      c("Nothing", NA_character_, ""))))
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
                                    validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                                      c("Nothing"))))
  expect_identical(list(), errorList)
  
})


test_that("Empty datatypes throw the correct warning", {
  # These go with the tests above -- here we are just checking the warning message
  expect_that(validateCalculatedResultDatatypes(c("Datatype", "()", "Number", "Number"),
                                                     c("Corporate Batch ID", "Rendering Hint", "curve id", "Max")),
              gives_warning("Column B (Rendering Hint) does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))

  expect_that(validateCalculatedResultDatatypes(c("Datatype", "([link])", "Text"),
                                                c("Herring", "Shrubbery", "Ni")),
              gives_warning("Column B (Shrubbery) does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))

  expect_that(validateCalculatedResultDatatypes(c("Datatype", NA, "Text"), 
                                                c("Data", "DataType", NA_character_)),
              gives_warning("Column B (DataType) does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
  
  # The following aren't necessarily THE BEST behavior, but they are the current behavior, so if they
  # change, it should be noted
  
  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c()),
              gives_warning("Column B () does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
  
  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c("", "", "")),
              gives_warning("Column B () does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))

  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c("Nothing", NA_character_, "")),
              gives_warning("Column B (NA) does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))

  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c("Nothing")),
              gives_warning("Column B (NA) does not have a Datatype entered. The loader will attempt to interpret entries in column B as numbers, but it may not work very well. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
})

test_that("The system gracefully handles the 'Datatype' field being blank", {
  errorList <<- list()
  supporessWarnings(validateCalculatedResultDatatypes(c(NA,"Text","Number","Date"),
                                    c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list(),
                   list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, 'Datatype' is missing."),)

  errorList <<- list()
  supporessWarnings(validateCalculatedResultDatatypes(c(NA,NA,NA,NA),
                                                      c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list(),
                   list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, 'Datatype' is missing."),)
  
})


test_that("Error messages for unrecognized columns respect capitalization", {
  errorList <<- list()
  expect_identical(c("Monty Python", "Text", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("Monty Python","Text","Number","Date"),
                                                     c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, it is 'Monty Python'."),
                   errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Frog", "Number", "Date"),
                   validateCalculatedResultDatatypes(c("Datatype","Frog","Number","Date"),
                                                     c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list("The loader found classes in the Datatype row that it does not understand: 'Frog'. Please enter 'Number','Text', or 'Date'."),
                   errorList)
})