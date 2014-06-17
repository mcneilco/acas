# Unit tests for validateMetaData
#
# Author: Jennifer Rogers

library(racas)
library(testthat)

setwd(racas::applicationSettings$appHome)
source(file.path("public","src","modules","GenericDataParser","src","server","generic_data_parser.R"))

context("validateMetaData")

errorList <<- list()
configList <- racas::applicationSettings  
# configList is an input to all of these functions. Note that it might change depending on your version
# of ACAS, but we still want these tests to behave properly.


test_that("validateMetaData handles cases where all metadata is present", {
  # The first option allows spaces in column headers, the second prevents the data from being turned into factors
  metaData <- data.frame("Format" = "Dose Response", 
                         "Protocol Name" = "Target Y binding", 
                         "Experiment Name" = "2019120 Dose Response", 
                         "Scientist" = "jmcneil", 
                         "Notebook" = "911", 
                         "Page" = "12", 
                         "Assay Date" = "2012-11-07", 
                         check.names = FALSE, 
                         stringsAsFactors = FALSE)
  
  validatedMetaData <- metaData
  validatedMetaData$"Assay Date" <- validateDate("2012-11-07")
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  # We don't need formatSettings becuase our experiment doesn't need any extra data
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})


test_that("validateMetaData handles a missing protocol, replacing it with NA as a string", {
  metaData <- data.frame("Format" = NA_character_, 
                         "Protocol Name" = "Target Y binding", 
                         "Experiment Name" = "2019120 Dose Response", 
                         "Scientist" = "jmcneil", 
                         "Notebook" = "911", 
                         "Page" = "12", 
                         "Assay Date" = "2012-11-07", 
                         check.names = FALSE, 
                         stringsAsFactors = FALSE)
  
  validatedMetaData <- metaData
  validatedMetaData$"Assay Date" <- validateDate("2012-11-07")
  validatedMetaData$"Format" <- "NA"
  duplicateExperimentNamesAllowed <- FALSE
  useExisting <- FALSE
  
  expect_identical(validateMetaData(metaData, configList, testMode = TRUE),
                   list(validatedMetaData = validatedMetaData, 
                        duplicateExperimentNamesAllowed = duplicateExperimentNamesAllowed,
                        useExisting = useExisting))
})
