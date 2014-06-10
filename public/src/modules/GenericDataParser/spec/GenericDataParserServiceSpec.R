# Provides tests for the generic_data_parser
# Author: Jennifer Rogers, with extensive
#         reliance on previous work by Sam Meyer

library(testthat)
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")


test_that ("validateMetaData passes best case scenarios", {
  # Best case: We don't need to change anything in the metadata
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/normalValidatedMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/normalMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  expect_identical(validatedMetaData, validateMetaData(metaData,expectedDataFormat)$validatedMetaData)

})


test_that ("validateMetaData correctly handles missing rows", {
  # Some rows are missing, we will get an error
  # Line 1457 through 1478 -- how did we get the error AND the string "username"?
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/missingRowsValidatedMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/missingRowsMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/missingRowsErrorsForValidateMetaData.Rda")
  expect_identical(validatedMetaData, validateMetaData(metaData, expectedDataFormat)$validatedMetaData)
  expect_identical(errorListExpected, errorList)
})


test_that("validateMetaData correctly handles extra rows", {  
  # Extra rows are added, which we have to remove (generates warnings, but not errors)
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedRowsValidateMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedRowsMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  expect_identical(addedRowsValidateMetaData, tryCatch.W.E(validateMetaData(metaData,expectedDataFormat)$validatedMetaData))
  expect_identical(list(), errorList)
})


test_that("validateMetaData correctly handles added columns next to the metadata", {
  # This is also suffering from a scientist called "username"
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedColumnsValidatedMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedColumnsMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  expect_identical(validatedMetaData, validateMetaData(metaData,expectedDataFormat)$validatedMetaData)
  expect_identical(list("Extra data were found next to the Experiment Meta Data and should be removed: 'One more row', 'Another row'"), errorList)
})


#This takes a protocol and gets a list of the information
# associated with it, as well as the experiments it has

# protocolList <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, 
#                                        "protocols?FindByProtocolName&protocolName=", 
#                                        URLencode("PAMPA Buffer A", reserved = TRUE))))

