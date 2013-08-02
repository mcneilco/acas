source("public/src/modules/FullPK/src/server/fullPKPreprocessingStub.R")
source("public/src/modules/GenericDataParser/src/server/GenericDataParserStub.R")

parseFullPKData <- function(request){
  # Needs a list:
  # dryRun
  # testMode
  # inputParameters:
  #   format
  #		protocolName
  #		experimentName
  #		scientist
  #		notebook
  #		inLifeNotebook
  #		assayDate
  #		project
  #		fileLocation
  #		reportFileLocation
  #		bioavailability
  #		aucType
  #
  # format will be "In Vivo Full PK"
  request <- as.list(request)
  inputParameters <- request$inputParameters
  parserInput <- list(fileToParse = preprocessPK(request$fileToParse, inputParameters))
  parserInput$dryRunMode <- request$dryRunMode
  parserInput$reportFile <- request$reportFile
  parserInput$user <- request$user
  return(parseGenericData(parserInput))
}
