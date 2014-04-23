context("BulkLoadContainersFromSDF.R")

test_that("SDFLoadContainers works", {
  load(file="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/SDFDryRunOutput.Rda")
  source("public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDF.R")
  expect_that(runMain(fileName="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/control_cmpds.sdf", 
                      dryRun=TRUE, 
                      recordedBy="testTest"),
              equals(output))
})

test_that("CSVLoadContainers works", {
  load(file="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/CSVDryRunOutput.Rda")
  source("public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDF.R")
  expect_that(runMain(fileName="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/Shipment_9813_with_QC.csv", 
                      dryRun=TRUE, 
                      recordedBy="testTest"),
              equals(output))
})

test_that("Bad CSVLoadContainers break", {
  source("public/src/modules/BulkLoadContainersFromSDF/src/server/BulkLoadContainersFromSDF.R")
  expect_that(runMain(fileName="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/broken-Shipment_9813_with_QC.csv", 
                      dryRun=TRUE,
                      recordedBy="testTest"),
              throws_error("Error in loading the file"))
  
})