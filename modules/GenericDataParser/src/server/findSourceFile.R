# This is a utility function for finding source files, only used from command line at the moment

require(RCurl)
require(rjson)
library(racas)

x <- readline("What is the experiment code? ")

experiment <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/codename/", x)))[[1]]


locationState <- experiment$lsStates[lapply(experiment$lsStates, function(x) x$"lsKind")=="raw results locations"]

locationState <- locationState[[1]]

lsKinds <- lapply(locationState$lsValues, function(x) x$"lsKind")

valuesToFind <- locationState$lsValues[lsKinds %in% c("source file")]

fileToFind <- valuesToFind[[1]]$fileValue

cat(paste0(server.service.external.file.service.url, fileToFind))
