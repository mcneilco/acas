# Runs all of the R tests for generic data parser
# Author: Jennifer Rogers
# Note: This testing schema is dependent upon the file structure of ACAS.
#       If you change the locatio of the tests, or of generic_data_parser.R,
#       be sure to change the file paths in here

library(racas)
library(testthat)

# File path to R tests (all file names should start with 'test')
test_dir(file.path(racas::applicationSettings$appHome,
                   "public",
                   "src",
                   "modules",
                   "GenericDataParser",
                   "spec",
                   "RTestSet"))
