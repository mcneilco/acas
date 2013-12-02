require(RCurl)
require(rjson)

x <- readline("What is the experiment code? ")

if (x == "" | x == "n") {
  x <- readline("What is the experiment name? ")
  experiment <- fromJSON(getURL(paste0("http://acas.dart.corp:8080/acas/experiments?FindByExperimentName&experimentName=", URLencode(x, reserved=TRUE))))[[1]]
} else{
  experiment <- fromJSON(getURL(paste0("http://acas.dart.corp:8080/acas/experiments/codename/", x)))[[1]]
}

locationState <- experiment$lsStates[lapply(experiment$lsStates, function(x) x$"lsKind")=="raw results locations"]

locationState <- locationState[[1]]

lsKinds <- lapply(locationState$lsValues, function(x) x$"lsKind")

valuesToFind <- locationState$lsValues[lsKinds %in% c("source file")]

fileToFind <- valuesToFind[[1]]$fileValue

cat(paste0("http://dsanpimapp01:8080/DNS/core/v1/DNSFile/", fileToFind))
