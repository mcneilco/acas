require(racas)
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")
require(RCurl)
experimentName <- "PK588_DNS001376769_NOP_R_IVPO_31Jul2013"

configList <- racas::applicationSettings

experimentList <- fromJSON(getURL(URLencode(paste0(configList$serverPath, "experiments/experimentname/", experimentName, "/"))))
experiment <- experimentList[[1]]
deleteSourceFile(experiment, configList)
deleteAnnotation(experiment, configList)
deleteExperiment(experiment)