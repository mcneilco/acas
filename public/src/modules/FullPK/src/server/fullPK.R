source("public/src/modules/FullPK/src/server/fullPKPreprocessing.R")
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

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
  #		bioavailability
  #		AUCType
  #
  # format will be "In Vivo Full PK"
  request <- as.list(request)
  inputParameters <- request$inputParameters
  parserInput <- list(fileToParse = preprocessPK(inputParameters))
  parserInput$dryRun <- request$dryRun
  parserInput$testMode <- request$testMode
  return(parseGenericData(parserInput))
}
