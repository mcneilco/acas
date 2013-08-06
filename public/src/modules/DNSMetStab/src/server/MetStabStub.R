source("public/src/modules/DNSMetStab/src/server/MetStabPreprocessingStub.R")
source("public/src/modules/GenericDataParser/src/server/GenericDataParserStub.R")

parseMetStabData <- function(request){
  # Needs a list:
  # dryRun
  # testMode
  # inputParameters:
  #   format
  #		protocolName
  #		scientist
  #		notebook
  #		project
  #		fileLocation
  #
  request <- as.list(request)
  inputParameters <- request$inputParameters
  parserInput <- list(fileToParse = preprocessMetStab(request$fileToParse, inputParameters))
  parserInput$dryRunMode <- request$dryRunMode
  parserInput$reportFile <- ""
  parserInput$user <- request$user
  results <- parseGenericData(parserInput)
  results$results$csvDataPreview <- "Corporate Batch ID,solubility (ug/mL),Assay Comment (-)\nDNS123456789::12,11.4,good\nDNS123456790::01,6.9,ok\n"
  return(results)
}
