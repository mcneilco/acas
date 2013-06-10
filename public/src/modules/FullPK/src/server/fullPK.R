source("public/src/modules/FullPK/src/server/fullPKPreprocessing.R")
source("public/src/modules/GenericDataParser/src/server/generic_data_parser.R")

# TODO: file annotation

parseFullPKData <- function(request){
  # Needs a list:
  # fileToParse
  # reportFile
  # dryRunMode
  # user
  # inputParameters:
  #   format
  #		protocolName
  #		experimentName
  #		scientist
  #		notebook
  #		inLifeNotebook
  #		assayDate
  #		project
  #		bioavailability
  #		aucType
  #
  # format is set as "In Vivo Full PK"
  request <- as.list(request)
  inputParameters <- request$inputParameters
  inputParameters$assayDate <- as.Date(inputParameters$assayDate, format="%s")
  inputParameters <- c(experimentMetaData = "", inputParameters)
  bioavailabilityIndex <- which(names(inputParameters)=="bioavailability")
  inputParameters <- c(inputParameters[1:bioavailabilityIndex - 1], list("", "rawData"=""), inputParameters[bioavailabilityIndex:length(inputParameters)])
  parserInput <- list(fileToParse = preprocessPK(request$fileToParse, inputParameters))
  parserInput$dryRun <- request$dryRunMode
  parserInput$reportFile <- request$reportFile
  return(parseGenericData(parserInput))
}

# Testing code
#   request<- list(user="smeyer", dryRunMode = "true", "fileLocation"="public/src/modules/FullPK/spec/specFiles/Worksheet.xls", reportFile="serverOnlyModules/blueimp-file-upload-node/public/files/PK_formatted (5).xls")
#   request$inputParameters <- list("format"="In Vivo Full PK","protocolName"="PK Protocol 1",scientist="Sam","experimentName"="PK experiment 2","notebook"="SAM-000123", "inLifeNotebook"="LIFE-123","assayDate"="1370822400000","project"="UNASSIGNED","bioavailability"="42.3","aucType"="AUC-0")
# # 