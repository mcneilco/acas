# Unit tests for validateMetaData
#
# Author: Jennifer Rogers

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("validateMetaData")

# Our own expectation: gives_no_warning()
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

errorList <<- list()
configList <- racas::applicationSettings  
# configList is an input to all of these functions. Note that it might change depending on your version
# of ACAS, but we still want these tests to behave properly.

# This is a data frame of the normal use case -- all data is present and correct. It's called "metaData"
load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateMetaData/normalMetaData.rda")

test_that("validateMetaData handles cases where all metadata is present", {
  validatedMetaData <- metaData
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  # We don't need formatSettings becuase our experiment doesn't need any extra data
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})


test_that("validateMetaData handles a missing format, replacing it with NA as a string", {
  validatedMetaData <- metaData
  
  metaData$"Format" <- NA_character_
  validatedMetaData$"Format" <- "NA"
  
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})


test_that("validateMetaData handles missing formats and protocols, replacing them with NA as a string", {
  # Note: This should work on its own in unit testing, even though it currently gives an
  # error in integration testing (see bug #211)
  validatedMetaData <- metaData
  
  metaData$"Format" <- NA_character_
  validatedMetaData$"Format" <- "NA"
  metaData$"Protocol Name" <- NA_character_
  validatedMetaData$"Protocol Name" <- "NA"
  
  validatedMetaData$"Assay Date" <- validateDate("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})


test_that("validateMetaData handles missing metadata, replacing them with NA as a string", {
  # Note: This should work on its own in unit testing, even though it currently gives an
  # error in integration testing (see bug #211)
  validatedMetaData <- metaData
  
  metaData$"Format" = NA_character_
  metaData$"Protocol Name" = NA_character_
  metaData$"Experiment Name" = NA_character_
  metaData$"Scientist" = NA_character_
  metaData$"Notebook" = NA_character_
  metaData$"Page" = NA_character_
  metaData$"Assay Date" = NA_character_
  
  # Here is the validated data
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateMetaData/outputAllFieldsNA.rda")
  
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   validatedMetaData)
})


test_that("validateMetaData returns the correct frame when given extra columns of metadata", {
  validatedMetaData <- metaData
  
  #This is called "extraData", and it has three rows, including some NA's
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateMetaData/inputExtraData.rda")
  
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  expect_identical(suppressWarnings(validateMetaData(extraData, configList, testMode = TRUE)),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})

test_that("validateMetaData throws an error when given extra columns of metadata", {
  validatedMetaData <- metaData
  
  #extraData has three rows, including some NA's
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateMetaData/inputExtraData.rda")
  
  validatedMetaData$"Assay Date" <- validateDate("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  errorList <<- list()
  suppressWarnings(validateMetaData(extraData, configList, testMode = TRUE))
  expect_equal(length(errorList), 1)
})


test_that("validateMetaData throws no warnings when given extra columns of metadata (known bug, ACAS#213)", {
  # Known bug #213
  validatedMetaData <- metaData
  
  #This is called "extraData", and it has three rows, including some NA's
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateMetaData/inputExtraData.rda")
  
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  #Take out "suppress warnings" from earlier
  expect_that(validateMetaData(extraData, configList, testMode = TRUE),
                   gives_no_warning())
})


test_that("validateMetaData throws an error when the Format header is missing", {
  missingFormat <- metaData
  missingFormat$"Format" <- NULL
  
  
  expect_that(validateMetaData(missingFormat, configList, testMode = TRUE),
              throws_error(regexp = "Format"))
})

test_that("validateMetaData handles an unknown scientist", {
  validatedMetaData <- metaData
  
  metaData$"Scientist" <- "unknownUser"
  validatedMetaData$"Scientist" <- ""
  
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  errorList <<- list()
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
  expect_equal(length(errorList), 1)
})


test_that("validateMetaData handles an incorrectly formatted date (will err when bug RACAS#6 is fixed)", {
  validatedMetaData <- metaData
  
  metaData$"Assay Date" <- "2012/11/07"
  
  #When bug RACAS#6 is fixed, the return type will be date, so uncomment this line and remove the one after it
  #validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  validatedMetaData$"Assay Date" <- "2012-11-07"
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  expect_equal(suppressWarnings(validateMetaData(metaData, configList, testMode = TRUE)),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})


test_that("validateMetaData can use an existing experiment", {
  metaData$"Protocol Name" <- NULL
  metaData$"Experiment Name" <- NULL
  metaData$"Scientist" <- NULL
  metaData$"Notebook" <- NULL
  metaData$"Page" <- NULL
  metaData$"Assay Date" <- NULL
  metaData$"Format" <- "Use Existing Experiment"
  metaData$"Experiment Code Name" <- "EXPT-00000002"
  
  expect_equal(validateMetaData(metaData, configList, testMode = TRUE),
               list(validatedMetaData = metaData, 
                    duplicateExperimentNamesAllowed = FALSE,
                    useExisting = TRUE))
  
  metaData$"Format" <- "Precise For Existing Experiment"
  expect_equal(validateMetaData(metaData, configList, testMode = TRUE),
               list(validatedMetaData = metaData, 
                    duplicateExperimentNamesAllowed = FALSE,
                    useExisting = TRUE))
})

test_that("validateMetaData will accept CREATETHISEXPERIMENT", {
  validatedMetaData <- metaData
  metaData$"Experiment Name" <- "CREATETHISEXPERIMENT"
  validatedMetaData$"Experiment Name" <- ""
  
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  
  
  expect_equal(suppressWarnings(validateMetaData(metaData, configList, testMode = TRUE)),
               list(validatedMetaData = validatedMetaData, 
                    duplicateExperimentNamesAllowed = TRUE,
                    useExisting = FALSE))
})


test_that("validateMetaData can use custom headers", {
  validatedMetaData <- metaData
  metaData$"Extra Header" <- "Required"
  
  validatedMetaData$"Extra Header" <- "Required"
  
  formatSettings = list("Dose Response" = list(annotationType = "",
                                               hideAllData = FALSE,
                                               extraHeaders = data.frame(headers = c("Extra Header"),
                                                                         class = c("Text"),
                                                                         isNullable = c(FALSE)),
                                               sigFigs = 3))
  
  validatedMetaData$"Assay Date" <- as.Date("2012-11-07")
  
  expect_equal(validateMetaData(metaData, configList, formatSettings = formatSettings, testMode = TRUE),
               list(validatedMetaData = validatedMetaData, 
                    duplicateExperimentNamesAllowed = FALSE,
                    useExisting = FALSE))
})

test_that("validateMetaData rejects extra headers", {
  metaData$"Extra Header" <- "Err"
  
  expect_that(validateMetaData(metaData, configList, testMode = TRUE),
               gives_warning(regexp = "extra Experiment Meta Data row"))
})
