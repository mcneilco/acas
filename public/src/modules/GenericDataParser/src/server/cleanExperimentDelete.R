require(racas)
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")
require(RCurl)
experimentName <- "testExperiment"

configList <- racas::applicationSettings

experimentList <- fromJSON(getURL(URLencode(paste0(configList$serverPath, "experiments/experimentname/", experimentName, "/"))))
experiment <- experimentList[[1]]
deleteSourceFile(experiment, configList)
deleteAnnotation(experiment, configList)
deleteExperiment(experiment)