# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /cleanExperimentDelete

require(racas)
source(file.path(applicationSettings$appHome,"/src/r/GenericDataParser/generic_data_parser.R"))
require(RCurl)
experimentName <- GET$experimentName

configList <- racas::applicationSettings

experimentList <- fromJSON(getURL(URLencode(paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/experimentname/", experimentName, "/"))))
experiment <- experimentList[[1]]
deleteOldData(experiment, FALSE)
cat(toJSON(experiment))