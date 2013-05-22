# To Run:
# setwd("~/Documents/clients/Wellspring/SeuratAddOns/") or whatever install directory is
# source("public/src/modules/GenericDataParser/spec/RTestSet/run_tests.R")

# Happily stolen from http://www.johnmyleswhite.com/notebook/2010/08/17/unit-testing-in-r-the-bare-minimum/
# Also http://www.bioconductor.org/developers/unitTesting-guidelines/

library('RUnit')

source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

# Create errorList
suppressWarnings(rm(errorList))
errorHandlingBox <- list(errorList = list())
attach(errorHandlingBox)

# Get info from the config file
configList <- readConfigFile("public/src/conf/configuration.js")

# Picks up all tests with a name test_(any character).R
test.suite <- defineTestSuite("example",
                              dirs = file.path("public/src/modules/GenericDataParser/spec/RTestSet"),
                              testFileRegexp = '^test_.+\\.R')

test.result <- runTestSuite(test.suite)

detach(errorHandlingBox)

printTextProtocol(test.result)