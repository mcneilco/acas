# To run overnight:
# nohup R CMD BATCH coreETLfileUpload.R &

Sys.setenv("ACAS_HOME"="/opt/node_apps/acas/")
home <- Sys.getenv("ACAS_HOME")
foldersLocation <- "~/coreetl/coreSELFilesToLoad6"
outputFile <- "~/coreETLoutput.txt"
dryRunMode <- "true"
user <- "smeyer"
require(racas)

source(paste0(home,"public/src/modules/GenericDataParser/src/server/generic_data_parser.R"))

fileList <- list.files(foldersLocation, recursive=TRUE, full.names=TRUE)
print("changing working directory")
setwd(home)
print("changed working directory")

parseGenericDataWrapper <- function(fileName) {
  print(fileName)
  parseGenericData(c(fileToParse=fileName, dryRunMode = dryRunMode, user=user))
}

system.time(responseList <- lapply(fileList, parseGenericDataWrapper))

getErrorMessages <- function(errorList) {
  unlist(lapply(errorList, getElement, "message"))
}
messageList <- unique(unlist(lapply(responseList, function(x) getErrorMessages(x$errorMessages))))

sink(outputFile)

cat("Unique error messages\n\n")
print(messageList)
cat("\n============================================================================")
Sys.time()

cat("\nError messages for each file\n")


for (response in responseList) {
  cat("\n", response$results$fileToParse, "\n", sep="")
  for (errorMessage in response$errorMessage) {
    cat("\t*", errorMessage$errorLevel, "*\n", sep="")
    cat("\t", errorMessage$message, "\n", sep="")
  }
}
sink()