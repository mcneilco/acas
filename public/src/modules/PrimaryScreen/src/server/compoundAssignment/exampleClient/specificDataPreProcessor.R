

specificDataPreProcessor <- function (parameters, folderToParse, errorEnv, 
                                      dryRun, instrumentClass, testMode, tempFilePath) {
  ##### exampleClient #####
  # 
  # This function sources the functions that parse the instrument files
  #
  # Input:  parameters (list of GUI parameters)
  #         folderToParse (folder where the raw data files are)
  #         errorEnv
  #         dryRun (boolean)
  #         instrumentClass
  #         testMode (boolean)
  #         tempFilePath (where log files and ini files are saved)
  # Output: instrumentData (list of two data tables: plateAssociationDT, assayData)
  
  instrumentSpecificFolder <- "public/src/modules/PrimaryScreen/src/server/instrumentSpecific/"
  
  fileList <- c(list.files(file.path(instrumentSpecificFolder, "/specificDataPreProcessorFiles/"), full.names=TRUE),
                list.files(file.path(instrumentSpecificFolder, instrumentClass), full.names=TRUE))
  #lapply(fileList, source)
  # Cannot use lapply because then "local" is inside lapply
  for (sourceFile in fileList) { 
    source(sourceFile, local=TRUE)
  }
  
  readsTable <- getReadOrderTable(readList=parameters$primaryAnalysisReadList)
  
  ## TODO: dryRun should return "summaryInfo" here?
  
  matchNames <- parameters$matchReadName
  
  instrumentData <- getInstrumentSpecificData(filePath=folderToParse, 
                                              instrument=parameters$instrumentReader, 
                                              readsTable=readsTable, 
                                              testMode=testMode,
                                              errorEnv=errorEnv,
                                              tempFilePath=tempFilePath, # this should be the analysis folder?
                                              dryRun=dryRun,
                                              matchNames=matchNames)
  
  return(instrumentData)
}

genericPlateDataPreProcessor <- function(parameters, folderToParse, tempFilePath) {
  # Returns: list of: 
  # assayData
  #   assayFileName: vector of file names (without path)
  #   assayBarcode: vector of plate barcodes
  #   plateOrder: vector of integers of plate order number for plate barcode
  #   rowName: vector of row
  #   colName: vector of column
  #   wellReference: vector of well name
  #   num: unique id for each well
  #   Well: NA (unused)
  #   Then columns that hold the data reads, in order. Names of columns are Read Names from the file
  # plateAssociationDT (will have (numberOfReads * numberOfPlates) rows): (left NULL to see if needed)
  #   plateOrder: same as in assayData
  #   readPosition: position list from readNames
  #   assayBarcode: assay plate barcode
  #   compoundBarcode_1: compound plate barcode (source for assay barcode), here NA
  #   sideCarBarcode: sidecar barcode (control source), here NA
  #   assayFileName: same as in assayData
  #   instrumentType: parameters$instrumentReader
  #   dataTitle: names for readNames, should match read positions
  # userInputReadTable:
  #   output of formatUserInputActivityColumns: Columns: readPosition, readName, ativityColName, newActivityColName, activity
  library(plyr)
  library(XLConnect)
  
  # All parsed files in /experiments/EXPT-000000XX/rawData/ passed through the current function's argument 'filepath'
  allAvailableExcelFiles <- list.files(folderToParse, pattern = "\\.xlsx?$")
  
  if (length(allAvailableExcelFiles)==0) {
    stopUser("No .xlsx files were found in the uploaded zipped folder. Please check again zipped folder.")
  }
  
  assayData <- ldply(allAvailableExcelFiles, getAssayDataFromFile, folderToParse=folderToParse)
  # Read names are all names after the first 8 columns
  readNameList <- names(assayData)[9:length(assayData)]
  
  readsTable <- getReadOrderTable(readList=parameters$primaryAnalysisReadList)
  userInputReadTable <- formatUserInputActivityColumns(readsTable=readsTable, 
                                                       activityColNames=readNameList, 
                                                       tempFilePath=tempFilePath, matchNames=FALSE)
  
  return(list(assayData=assayData, userInputReadTable=userInputReadTable))
}

getAssayDataFromFile <- function(fileName, folderToParse) {
  # Required headers in "Plate Information" in files that are kept: "Plate Format", "Assay Barcode", "Plate Order", "Read Name"
  pathToExcelFile <- file.path(folderToParse, fileName)
  wkbk <- loadWorkbook(pathToExcelFile)
  sheetNames <- getSheets(wkbk)
  # Skip plates without PlateContent tab
  if (!("Data_Read_1" %in% sheetNames)) {
    return(data.frame())
  }
  
  allDataFrame <- readWorksheetFromFile(pathToExcelFile, sheet="Data_Read_1", header=FALSE)
  headerInfo <- getSection(allDataFrame, "Plate Information", transpose = TRUE, required = TRUE)
  numberOfWells <- as.numeric(headerInfo$"Plate Format")
  plateFormatInfo <- getPlateFormatInfo(numberOfWells)
  output <- data.frame(assayFileName=fileName,
                       assayBarcode=headerInfo$"Assay Barcode",
                       plateOrder=as.numeric(headerInfo$"Plate Order"),
                       rowName=plateFormatInfo$rowName,
                       colName=plateFormatInfo$colName,
                       wellReference=plateFormatInfo$wellName,
                       num=NA,
                       Well=NA)
  rowRange <- plateFormatInfo$rowRange + 1  # Offset by 1 to skip labels
  columnRange <- plateFormatInfo$columnRange + 1 # Offset by 1 to skip labels
  
  # This assumes no read numbers are skipped
  dataReadSheets <- sort(grep("^Data_Read_[0-9]+$", sheetNames, value = TRUE))
  
  for (sheetName in dataReadSheets) {
    allDataFrame <- readWorksheetFromFile(pathToExcelFile, sheet=sheetName, header=FALSE)
    headerInfo <- getSection(allDataFrame, "Plate Information", transpose = TRUE, required = TRUE)
    readName <- headerInfo$"Read Name"
    plateSection <- getSection(allDataFrame, "^Plate$", required = TRUE)
    outputVector <- as.vector(t(plateSection[rowRange, columnRange]))
    output[[readName]] <- as.numeric(outputVector)
  }
  
  return(output)
}

getPlateFormatInfo <- function(numberOfWells) {
  # Define a vector that contains all the names of all the wells in the plate contained in the excel file, whether
  # it is a 96-, 384-, or 1536-well plate format - make sure that number of digits in every well is the same with the number used
  # in table assayData (e.g. A001)
  # Returns a list with rowName, colName, wellName, rowRange, columnRange
  
  if (numberOfWells==96) {
    # Case 1: 96 well plate format (8 rows x 12 columns) reading row after row
    # Generate index vector for well location (96 wells)
    wellLetters_96 <- rep(LETTERS[1:8], each=12)
    wellNumbers_96 <- rep(seq(1:12), times=8)
    leadingZerosWellNumbers_96 <- formatC(wellNumbers_96, width = 3, format = "d", flag = "0")
    standardWellNames_96 <- paste0(wellLetters_96, leadingZerosWellNumbers_96)
    return(list(rowName=wellLetters_96, colName=wellNumbers_96, wellName=standardWellNames_96,
                rowRange=1:8, columnRange=1:12))
  } else if (numberOfWells==384) {
    #  Case 2: 384 well plate format (16 rows x 24 columns) reading row after row
    # Generate index vector for well location (384 wells)
    wellLetters_384 <- rep(LETTERS[1:16], each=24)
    wellNumbers_384 <- rep(seq(1:24), times=16)
    leadingZerosWellNumbers_384 <- formatC(wellNumbers_384, width = 3, format = "d", flag = "0")
    standardWellNames_384 <- paste0(wellLetters_384, leadingZerosWellNumbers_384)
    return(list(rowName=wellLetters_384, colName=wellNumbers_384, wellName=standardWellNames_384,
                rowRange=1:16, columnRange=1:24))
  } else if (numberOfWells==1536) {
    #  Case 3: 1536 well plate format (32 rows x 48 columns) reading row after row
    # Generate index vector for well location (1536 wells)
    # Note: After letters A-Z (n=26) are used the naming pattern continues with AA, AB, .., AF (n=32-26)
    wellLetters_1536 <- rep(c(LETTERS[1:26], paste0('A', LETTERS[1:(32-26)])), each=48)
    wellNumbers_1536 <- rep(seq(1:48), times=32)
    # Due to the well naming pattern incorporating double letters (e.g. AA, AF) the number of leading zeros changes based on the presence of 
    # single/double letters, with the goal of having the same number of characters for every well's name
    # index of last well with a single letter (Z-48)
    lastWellSingleLetter <- 26*48
    # index of last well with a double letter (AF-48)
    lastWellDoubleLetter <- 32*48
    leadingZerosWellNumbers_1536 <- c(
      ifelse(wellNumbers_1536[1:lastWellSingleLetter], yes=formatC(wellNumbers_1536, width = 3, format = "d", flag = "0")),
      ifelse(wellNumbers_1536[(lastWellSingleLetter+1):(lastWellDoubleLetter)], yes=formatC(wellNumbers_1536, width = 2, format = "d", flag = "0"))
    )
    standardWellNames_1536 <- paste0(wellLetters_1536, leadingZerosWellNumbers_1536)
    return(list(rowName=wellLetters_1536, colName=leadingZerosWellNumbers_1536, wellName=standardWellNames_1536,
                rowRange=1:32, columnRange=1:48))
  } else {
    stopUser("Invalid Plate Format: only 96, 384, and 1536 are supported")
  }
}


checkPlateContentInFiles <- function(folderToParse) {
  # Check if a PlateContent sheet is in any Excel file in folderToParse
  library(XLConnect)
  
  # All parsed files in /experiments/EXPT-000000XX/rawData/ passed through the current function's argument 'filepath'
  allAvailableExcelFiles <- list.files(folderToParse, pattern = "\\.xlsx?$")
  
  for (fileName in allAvailableExcelFiles) {
    pathToExcelFile <- file.path(folderToParse, fileName)
    wkbk <- loadWorkbook(pathToExcelFile)
    sheetNames <- getSheets(wkbk)
    # Breaks on the first sheet found
    if ("PlateContent" %in% sheetNames) {
      return(TRUE)
    }
  }
  
  # If none found, return FALSE
  return(FALSE)
}
