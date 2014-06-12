# Unit Tests for validateCalculatedResultDatatypes
#
# Author: Jennifer Rogers, using code written by
# Sam Meyer

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

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
  expect_identical(list("The loader found classes in the Datatype row that it does not understand: 'Datatype'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."),
                   errorList)
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
  expect_identical(c("Datatype", "Text", "Number", "Number"),
                                    validateCalculatedResultDatatypes(c("Datatype","text","Number","Number"),
                                                                      c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  expect_identical(c("Datatype", "Text", "Number", "Number"),
                                    validateCalculatedResultDatatypes(c("Datatype","TEXT","Number","Number"),
                                                                      c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(list(), errorList)
  
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Standard Deviation", "Number", "Number"),
                                    validateCalculatedResultDatatypes(c("Datatype","Std. Dev","Number","Number"),
                                    c("Corporate Batch ID","Rendering Hint","curve id","Max"))))
  expect_identical(list(), errorList)                              
})


test_that("The function gives the right warnings when interpreting datatypes", {
  expect_that(validateCalculatedResultDatatypes(c("Datatype","Std. Dev","Number","Number"),
                                                c("Corporate Batch ID","Rendering Hint","curve id","Max")),
              gives_warning("In column \"Rendering Hint\", the loader found 'Std. Dev' as a datatype and interpreted it as 'Standard Deviation'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."))
})


test_that("Empty datatypes are handled correctly", {
  errorList <<- list()
  suppressWarnings(expect_identical(c("Datatype", "Number", "Number", "Number"),
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
  suppressWarnings(expect_identical(c("Datatype", "Number", "Text"),
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


test_that("Empty datatypes throw a warning", {
  # These go with the tests above -- here we are just checking the warning message
  expect_that(validateCalculatedResultDatatypes(c("Datatype", "()", "Number", "Number"),
                                                     c("Corporate Batch ID", "Rendering Hint", "curve id", "Max")),
              gives_warning())

  expect_that(validateCalculatedResultDatatypes(c("Datatype", "([link])", "Text"),
                                                c("Herring", "Shrubbery", "Ni")),
              gives_warning())

  expect_that(validateCalculatedResultDatatypes(c("Datatype", NA, "Text"), 
                                                c("Data", "DataType", NA_character_)),
              gives_warning())
  
  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c()),
              gives_warning())
  
  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c("", "", "")),
              gives_warning())

  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c("Nothing", NA_character_, "")),
              gives_warning())

  expect_that(validateCalculatedResultDatatypes(c("Datatype", "", "Text"), 
                                                c("Nothing")),
              gives_warning())
})

test_that("The system gracefully handles the 'Datatype' field being blank", {
  errorList <<- list()
  suppressWarnings(validateCalculatedResultDatatypes(c(NA,"Text","Number","Date"),
                                    c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(errorList,
                   list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, 'Datatype' is missing."),)

  errorList <<- list()
  suppressWarnings(validateCalculatedResultDatatypes(c(NA,NA,NA,NA),
                                                      c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  expect_identical(errorList,
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
  expect_identical(list("The loader found classes in the Datatype row that it does not understand: 'Frog'. Please enter 'Number', 'Text', 'Date', 'Standard Deviation', or 'Comments'."),
                   errorList)
})


test_that("Leading and trailing whitespace is trimmed", {
  # Currently a known error
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


test_that("lockCorpBatchId works as expected", {
  # Currently a known error
  errorList <<- list()
  expect_identical(c("Boxes", "Comments", "Text"), validateCalculatedResultDatatypes(c("Boxes", "comments", "Text"), 
                                                                                     c("Corporate Batch ID", "Boxes", "Refrigerators"), FALSE))
  expect_identical(1, length(errorList))
})
