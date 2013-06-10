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
  inputParameters <- c(experimentMetaData = "", scientist= request$user, inputParameters)
  fileLocationIndex <- which(names(inputParameters)=="fileLocation")
  inputParameters <- c(inputParameters[1:fileLocationIndex], list("", "rawData"=""), inputParameters[(fileLocationIndex+1):length(inputParameters)])
  parserInput <- list(fileToParse = preprocessPK(inputParameters))
  parserInput$dryRun <- request$dryRun
  parserInput$testMode <- request$testMode
  return(parseGenericData(parserInput))
}

# Testing code
#   request<- list(user="smeyer", dryRun = "true", testMode = "false")
#   request$inputParameters <- list("format"="In Vivo Full PK","protocolName"="PK Protocol 1","experimentName"="PK experiment 2","notebook"="SAM-000123", "inLifeNotebook"="LIFE-123","assayDate"="2013-05-22","project"="UNASSIGNED","fileLocation"="public/src/modules/FullPK/spec/specFiles/Worksheet.xls","bioavailability"="42.3","AUCType"="AUC-0")
# # 