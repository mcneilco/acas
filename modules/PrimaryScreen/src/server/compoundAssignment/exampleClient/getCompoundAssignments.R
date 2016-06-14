getCompoundAssignments <- function(folderToParse, instrumentData, testMode, parameters, tempFilePath) {
  # exampleClient
  assayCompoundData <- getAssayCompoundData(filePath=folderToParse,
                                            plateData=instrumentData$plateAssociationDT,
                                            testMode=testMode,
                                            tempFilePath=tempFilePath,
                                            assayData=instrumentData$assayData)
  
  resultTable <- assayCompoundData$allAssayCompoundData[ , c("plateType",
                                                             "assayBarcode",
                                                             "cmpdBarcode",
                                                             "sourceType",
                                                             "wellReference",
                                                             "rowName",
                                                             "colName",
                                                             "plateOrder",
                                                             "corp_name",
                                                             "batch_number",
                                                             "cmpdConc",
                                                             assayCompoundData$activityColNames), with=FALSE]
  # TODO: Check concUnit prior to making this adjustment
  resultTable[ , cmpdConc := cmpdConc * 1000]
  
  batchSep <- racas::applicationSettings$server.service.external.preferred.batchid.separator
  resultTable[, batchCode := paste0(corp_name, batchSep, batch_number)]
  resultTable[batchCode == paste0("NA", batchSep, "NA"), batchCode := batchSep]
  #   setnames(resultTable, c("wellReference", "assayBarcode", "cmpdConc", "corp_name"), c("well", "barcode", "concentration", "batchName"))
  setnames(resultTable, c("wellReference","rowName", "colName", "corp_name"), c("well","row", "column", "batchName"))
  
  # apply dilution
  if (!is.null(parameters$dilutionRatio) && parameters$dilutionRatio != "") {
    resultTable$cmpdConc <- resultTable$cmpdConc / parameters$dilutionRatio
  }
  
  return(resultTable)
}

getCompoundAssignmentsFromFiles <- function(folderToParse, instrumentData, parameters) {
  library(plyr)
  library(XLConnect)
  
  allAvailableExcelFiles <- list.files(folderToParse, pattern = "\\.xlsx?$")
  
  compoundData <- ldply(allAvailableExcelFiles, getCompoundAssignmentsFromFile, folderToParse=folderToParse)
  
  # ActivityColNames are the names in assayData
  activityColNames <- instrumentData$userInputReadTable$activityColName
  usedAssayData <- instrumentData$assayData[, c("assayBarcode", "wellReference", activityColNames)]
  resultTable <- merge(compoundData, usedAssayData, by = c("assayBarcode", "wellReference"))
  
  setnames(resultTable, c("wellReference","rowName", "colName", "corp_name"), c("well","row", "column", "batchName"))
  
  # apply dilution
  if (!is.null(parameters$dilutionRatio) && parameters$dilutionRatio != "") {
    resultTable$cmpdConc <- as.numeric(resultTable$cmpdConc) / parameters$dilutionRatio
  }
  
  return(as.data.table(resultTable))
}

getCompoundAssignmentsFromFile <- function(fileName, folderToParse) {
  # Inputs fileName with no path in folderToParse
  # Outputs data.frame defined at end
  pathToExcelFile <- file.path(folderToParse, fileName)
  wkbk <- loadWorkbook(pathToExcelFile)
  sheetNames <- getSheets(wkbk)
  if (!("PlateContent" %in% sheetNames)) {
    return(data.frame())
  } else if (!("PlateConc" %in% sheetNames)) {
    stopUser("All Excel files with PlateContent sheet must also have a PlateConc sheet")
  }
  
  contentDataFrame <- readWorksheetFromFile(pathToExcelFile, sheet="PlateContent", header=FALSE)
  headerInfo <- getSection(contentDataFrame, "Plate Information", transpose = TRUE, required = TRUE)
  numberOfWells <- as.numeric(headerInfo$"Plate Format")
  plateFormatInfo <- getPlateFormatInfo(numberOfWells)
  rowRange <- plateFormatInfo$rowRange + 1  # Offset by 1 to skip labels
  columnRange <- plateFormatInfo$columnRange + 1 # Offset by 1 to skip labels
  plateSection <- getSection(contentDataFrame, "^Plate$", required = TRUE)
  compoundVector <- as.vector(t(plateSection[rowRange, columnRange]))
  
  concDataFrame <- readWorksheetFromFile(pathToExcelFile, sheet="PlateConc", header=FALSE)
  concHeaderInfo <- getSection(concDataFrame, "Plate Information", transpose = TRUE, required = TRUE)
  plateSection <- getSection(concDataFrame, "^Plate$", required = TRUE)
  concVector <- as.vector(t(plateSection[rowRange, columnRange]))
  
  # Split batchCode into compound and batch
  batchSep <- racas::applicationSettings$server.service.external.preferred.batchid.separator
  splitBatch <- strsplit(compoundVector, batchSep)
  batchNumber <- vapply(splitBatch, tail, "", n=1)
  batchNumber[batchNumber==compoundVector] <- NA
  # Remove last section to get compound name
  compoundName <- vapply(lapply(splitBatch, function(x) {
    head(x, n=length(x)-1)
  }), paste, "", collapse=batchSep)
  compoundName[compoundName==""] <- compoundVector[compoundName==""]
  output <- data.frame(plateType=NA,
                       assayBarcode=headerInfo$"Assay Barcode",
                       cmpdBarcode=NA,
                       sourceType=NA,
                       wellReference=plateFormatInfo$wellName,
                       rowName=plateFormatInfo$rowName,
                       colName=plateFormatInfo$colName,
                       plateOrder=as.numeric(headerInfo$"Plate Order"),
                       corp_name=compoundName,
                       batch_number=batchNumber,
                       cmpdConc=concVector,
                       batchCode=compoundVector, 
                       stringsAsFactors = FALSE)
  return(output)
}


getCompoundAssignmentsInternal <- function(folderToParse, instrumentData, testMode, parameters) {
  library(data.table)  
  library(plyr)
  
  #save(folderToParse, instrumentData, testMode, parameters, file="public/cmpdAssignments.Rda")
  resultTable <- instrumentData$assayData
  
  barcodeList <- unique(resultTable$assayBarcode)
  
  wellTable <- createWellTable(barcodeList, testMode)
  
  # apply dilution
  if (!is.null(parameters$dilutionRatio)) {
    wellTable$CONCENTRATION <- wellTable$CONCENTRATION / parameters$dilutionRatio
  }
  
  
  # Define file path for template
  templatePath <- paste0(folderToParse, "/Template_v1.xlsx")
  
  # Warn user if the template was not found in the designated folder
  if (!file.exists(templatePath)) {
    stopUser("The template containing controls, agonist concentration, and vehicle was not found in the zip file.")
  }
  
  # Read the template containing information about controls, agonist conc., vehicle and insert in dataframe
  extraColumn <- getControlValues(templatePath)
  
  
  # Isolate wells that only contain controls from the dataframe
  controlsIsolate <- data.frame(extraColumn[c('WELL_NAME','controls')])
  
  # Exclude the rows that contain no controls
  controlsRows <- controlsIsolate[!is.na(controlsIsolate$controls), ]
  
  # Define dataframe that will be filled with all the necessary values related to the controls
  controlsFrame <- data.frame(ID=NA, BARCODE=NA, WELL_ID=NA, WELL_NAME=controlsRows$WELL_NAME, BATCH_CODE=NA, VOLUME=Inf, VOLUME_STRING=NA, 
                              VOLUME_UNIT='uL', CONCENTRATION=NA,
                              CONCENTRATION_STRING=NA, CONCENTRATION_UNIT='uM', WELL_TYPE=controlsRows$controls)
  
  
  # Fill in values for controls concentration
  negativeConc <- Inf
  if (!is.null(parameters$negativeControl$concentration)) {
    negativeConc <- parameters$negativeControl$concentration
  }
  controlsFrame$CONCENTRATION <- NA_real_
  controlsFrame$CONCENTRATION[controlsFrame$WELL_TYPE=='PC'] <- parameters$positiveControl$concentration
  controlsFrame$CONCENTRATION[controlsFrame$WELL_TYPE=='NC'] <- parameters$negativeControl$concentration
  controlsFrame$CONCENTRATION[controlsFrame$WELL_TYPE=='VC'] <- 0
  
  # Set infinity chracter in concentration strings if concentration is defined with infinity
  controlsFrame$CONCENTRATION_STRING[controlsFrame$CONCENTRATION==Inf] <- "infinite"
  
  # Set batch Code for controls
  controlsFrame$BATCH_CODE[controlsFrame$WELL_TYPE=='PC'] <- parameters$positiveControl$batchCode
  controlsFrame$BATCH_CODE[controlsFrame$WELL_TYPE=='NC'] <- parameters$negativeControl$batchCode
  controlsFrame$BATCH_CODE[controlsFrame$WELL_TYPE=='VC'] <- parameters$vehicleControl$batchCode
  
  
  # Remove the column that annotates positive vs negative controls from dataframe
  controlsFrame <- subset(controlsFrame, select=-WELL_TYPE)
  
  # Find the number of elements in the dataframe
  numberRowsFrame <- nrow(controlsFrame)
  
  # Duplicate all entries in the dataframe
  controlsFrameDupl <- controlsFrame[rep(row.names(controlsFrame), length(barcodeList)), ]
  
  # Update the barcodes in the dataframe with both available ones
  controlsFrameDupl$BARCODE <- rep(barcodeList, each=numberRowsFrame)
  
  controlsFrame <- controlsFrameDupl
  
  
  
  # Find any wells annotated in the template as (positive/negative) controls that are simultaneously annotated also as test compounds 
  commonWellsNames <- intersect(controlsFrame$WELL_NAME,wellTable$WELL_NAME)
  
  
  # If at least one well is common (i.e. well is registered as both a control and a test), then warn the user
  # with the following warning, displaying all the common wells
  if (length(commonWellsNames)>0) {
    mssg1 <- "The following wells were found assigned to both controls and test compounds: "
    mssg2 <- paste(commonWellsNames,collapse=', ')     #as.character(controlsFrame$WELL_NAME[commonWellsNames]))
    mssg3 <- ". In those wells, the test compounds will be replaced with the controls!"
    warnUser(paste(mssg1, mssg2, mssg3))
  }
  
  # Remove any wells with test compounds from wellTable dataframe that are annotated as controls in the template
  wellTablePurged <- subset(wellTable, !(wellTable$WELL_NAME %in% commonWellsNames))
  wellTable <- wellTablePurged
  
  # Merge the existing dataframe for test compounds with the controls-related dataframe
  ww <- rbind.fill(controlsFrame, wellTable)
  wellTable <- ww[order(ww$WELL_NAME), ]
  
  # Reset the row counter of the merged dataframe
  rownames(wellTable) <- NULL
  
  # Add the extra column that pertains to the agonist concentration extracted from the template above
  wellTable <- merge(wellTable, extraColumn[c('WELL_NAME','agonistConc')], all=TRUE)
  
  # De-activate the getAgonist and removeVehicle functions, added removeAgonist for backwards compatability
  #wellTable <- getAgonist(parameters$agonistControl, wellTable)
  #wellTable <- removeVehicle(parameters$vehicleControl, wellTable)
  wellTable <- removeAgonist(parameters$agonistControl, wellTable)
  
  if(anyDuplicated(paste(wellTable$BARCODE, wellTable$WELL_NAME, sep=":"))) {
    wellTable$plateAndWell <- paste(wellTable$BARCODE, wellTable$WELL_NAME, sep=":")
    stopUser(paste0("Multiple test compounds were found in these wells, so it is unclear which is the tested compound: '", 
                    paste(wellTable$plateAndWell[duplicated(wellTable$plateAndWell)], collapse = "', '"),
                    "'. Please contact your system administrator."))
  }
  
  
  batchNamesAndConcentrations <- getBatchNamesAndConcentrations(resultTable$assayBarcode, resultTable$wellReference, wellTable)
  # The indices in the following line were raising n error so I fed the function above with the full resultTable$assayBarcode and
  # resultTable$wellReference vectors
  #batchNamesAndConcentrations <- getBatchNamesAndConcentrations(resultTable[[1]]$assayBarcode, resultTable[[1]]$wellReference, wellTable)
  
  
  
  #print(resultTable)
  resultTable <- cbind(resultTable,batchNamesAndConcentrations)
  
  
  setnames(resultTable,c("batchName", "concentration"),c("batchCode", "cmpdConc"))  #previously batchName was barcode
  
  resultTable$batchName <- gsub("(.*)-", "\\1", resultTable$batchCode) # Get parent code (called batchName for historical reasons)
  
  resultTable[, agonistBatchCode := parameters$agonistControl$batchCode]
  # save(resultTable, file="public/cmpdAssignmentsOutput.Rda")  
  return(resultTable)
  
}

getAgonist <- function(agonist, wellTable) {
  # Adds columns agonistBatchCode and agonistConc to the wellTable
  
  # TODO: does not deal with multiple compounds in one well
  if((length(agonist) > 0) && !(agonist$batchCode %in% wellTable$BATCH_CODE)) {
    stopUser("The agonist was not found in the plates. Have all transfers been loaded?")
  }
  
  wellTable$plateAndWell <- paste(wellTable$BARCODE, wellTable$WELL_NAME, sep=":")
  
  # For Dose Response agonist, we will have a variety of concentrations. Then the agonist concentration should be null
  if (is.null(agonist$concentration) || agonist$concentration == "") {
    agonistRows <- wellTable$BATCH_CODE == agonist$batchCode & 
      wellTable$CONCENTRATION == agonist$concentration &
      wellTable$CONCENTRATION_UNIT == agonist$concentrationUnits
  } else {
    agonistRows <- wellTable$BATCH_CODE == agonist$batchCode
  }
  
  agonistMatch <- wellTable[agonistRows, c("plateAndWell", "CONCENTRATION")]
  names(agonistMatch) <- c("plateAndWell", "agonistConc")
  
  #agonistTable <- wellTable[agonistRows, c("BARCODE", "WELL_NAME")]
  #agonistLocations <- paste(agonistTable$BARCODE, agonistTable$WELL_NAME, sep=":")
  #wellTable$hasAgonist <- wellTable$plateAndWell %in% agonistLocations
  wellTable <- merge(wellTable, agonistMatch, all.x=TRUE)
  wellTable$agonistBatchCode <- agonist$batchCode
  
  wellTable <- wellTable[!agonistRows, ]
  
  return(wellTable)
}

removeVehicle <- function(vehicle, wellTable) {
  #Removes rows with a vehicle that are part of another well
  # If the vehicle is the only compound in a well, it is kept
  library(plyr)
  
  vehicleRows <- wellTable$BATCH_CODE == vehicle$batchCode
  #wellTable$CONCENTRATION <= agonist$concentration & wellTable$CONCENTRATION_UNIT == agonist$concentrationUnits
  compoundCount <- ddply(wellTable, "WELL_ID", summarise, count = length(BATCH_CODE))
  hasMoreThanOneCompound <- compoundCount$WELL_ID[compoundCount$count > 1]
  vehicleIds <- wellTable$ID[vehicleRows & wellTable$WELL_ID %in% hasMoreThanOneCompound]
  wellTable <- wellTable[!(wellTable$ID %in% vehicleIds), ]
  return(wellTable)
}

removeAgonist <- function(agonist, wellTable) {
  #Removes rows with a agonist that are part of another well
  # If the agonist is the only compound in a well, it is kept
  library(plyr)
  
  agonistRows <- wellTable$BATCH_CODE == agonist$batchCode
  #wellTable$CONCENTRATION <= agonist$concentration & wellTable$CONCENTRATION_UNIT == agonist$concentrationUnits
  compoundCount <- ddply(wellTable[!is.na(wellTable$WELL_ID), ], "WELL_ID", summarise, count = length(BATCH_CODE))
  hasMoreThanOneCompound <- compoundCount$WELL_ID[compoundCount$count > 1]
  agonistIds <- wellTable$ID[agonistRows & wellTable$WELL_ID %in% hasMoreThanOneCompound]
  wellTable <- wellTable[!(wellTable$ID %in% agonistIds), ]
  return(wellTable)
}

getBatchNamesAndConcentrations <- function(barcode, well, wellTable) {
  # Matches result rows up with batch names and concentrations
  #
  # Args:
  #   barcode:        A vector of the barcodes
  #   well:           A vector of the wells
  #   wellTabe:       A data.frame with columns of BARCODE, WELL_NAME, BATCH_CODE,CONCENTRATION,CONCENTRATION_UNIT
  # Returns:
  #   A data.frame with batchName,concentration, concUnit, agonistConc that matches the order of the input barcodes and wells
  
  wellUniqueId <- paste(barcode, well)
  wellTableUniqueId <- paste(wellTable$BARCODE, wellTable$WELL_NAME)
  # definition of outputFrame below was expanded to include the agonist values extracted from template (see getControlValues function)
  # and remove the row "agonistConc" which was not added any more by function getAgonist() defined above
  outputFrame <- wellTable[match(wellUniqueId,wellTableUniqueId),c("BATCH_CODE","CONCENTRATION","CONCENTRATION_UNIT","agonistConc")]
  names(outputFrame) <- c("batchName","concentration","concUnit","agonistConc")
  return(outputFrame)
}


createWellTable <- function(barcodeList, testMode) {
  # Creates a table of wells and corporate batch id's
  #
  # Args:
  #   barcodeList:    A list of plate barcodes used in the experiment
  #   testMode:       A boolean of the testMode
  # Returns:
  #   A data.frame of wells and corporate batch id's
  
  barcodeQuery <- paste(barcodeList,collapse="','")
  
  if (testMode) {
    # wellTable <- read.csv("public/src/modules/PrimaryScreen/spec/examplePlateContentsConfirmation.csv")
    wellTable <- read.csv("public/src/modules/PrimaryScreen/spec/examplePlateContentsControlsRemoved.csv", stringsAsFactors = FALSE)
    #     fakeAPI <- read.csv("public/src/modules/PrimaryScreen/spec/api_container_export.csv")
    #     fakeAPI$BARCODE <- gsub("BF00007450", "TL00098001", fakeAPI$BARCODE)
    #     fakeAPI$BARCODE <- gsub("BF00007460","TL00098002",fakeAPI$BARCODE)
    #     fakeAPI$BARCODE <- gsub("BF00007390","TL00098003",fakeAPI$BARCODE)
    #     fakeAPI$BARCODE <- gsub("BF00007395","TL00098004",fakeAPI$BARCODE)
    #     wellTable <- fakeAPI[fakeAPI$BARCODE %in% barcodeList, ]
    #     wellTable$BATCH_CODE <- gsub("CRA-024169-1", "CRA-000399-1", wellTable$BATCH_CODE)
    #     wellTable$BATCH_CODE <- gsub("CRA-024184-1", "CRA-000396-1", wellTable$BATCH_CODE)
    #     wellTable$BATCH_CODE <- gsub("CRA-024074-1", "CRA-000399-1", wellTable$BATCH_CODE)
    #     wellTable$BATCH_CODE <- gsub("CRA-024087-1", "CRA-000396-1", wellTable$BATCH_CODE)
    #     # different test, remove after nextval deploy
    #     load("public/src/modules/PrimaryScreen/spec/wellTable.Rda")
    #     wellTable <- wellTable[!(wellTable$BATCH_CODE=="FL0073897-1-1" & (wellTable$CONCENTRATION < 0.2 | wellTable$CONCENTRATION>49.6)), ]
  } else {
    wellTable <- query(paste0(
      "SELECT *
      FROM api_container_contents
      WHERE barcode IN ('", barcodeQuery, "')"))
  }
  
  names(wellTable) <- toupper(names(wellTable))
  wellTable$CONCENTRATION[wellTable$CONCENTRATION_STRING == "infinite"] <- 0
  
  return(wellTable)
  }






getControlValues <- function(pathToExcelFile) {
  # Description: A function getControlValues(pathToExcelFile) that returns 
  # a data.frame with colums "index","controls","agonist","vehicle", and uses no globals
  #
  # Creates the 4 vectors necessary to construct the wanted data.frame
  # i.e. 1 for the well index and 3 for the sheets in the excel file
  #
  # Arg: file path to target excel file
  #
  # Returns: The wanted data.frame
  
  #path <- "~/Desktop/Template_v1.xlsx"  #temporary file-path
  
  
  # Load the library to extract from Excel
  library(XLConnect)
  
  # Generate index vector for well location
  first.letter <- rep(LETTERS[1:16], time=24)
  numbers <- rep(seq(1:24), each=16)
  suffix <- formatC(numbers, width = 2, format = "d", flag = "0")
  WELL_NAME <- paste0(first.letter, suffix)
  
  
  # Define template file-path
  excel.file <- file.path(pathToExcelFile)
  
  # Load workbook
  wb <- loadWorkbook(excel.file)
  
  # Query available worksheets
  sheets <- getSheets(wb)
  
  # Display error if missing sheets
  if (!"Controls" %in% sheets) {
    stopUser("Missing 'Controls' sheet in Template_v1.xlsx")
  }
  if (!"Agonist" %in% sheets) {
    stopUser("Missing 'Agonist' sheet in Template_v1.xlsx")
  }
  
  
  readInputFiles <- function(sheet.name) {
    # Reads the specified sheet and stores all data row-by-row in a vector
    #
    # Arg: sheet name captured from the excel file
    #
    # Returns: The vector containing all entries from the sheet row-after-row
    
    tableX1 <- readWorksheetFromFile(excel.file, sheet=sheet.name)
    tableX1Trimmed <- tableX1[1:16,2:25]
    outputVector <- as.vector(as.matrix(tableX1Trimmed))
    
    return(outputVector)
  }
  
  
  # Apply (sub)function readInputFiles to create a different vector from each of the 3 sheets
  controls <- readInputFiles("Controls")
  agonist <- as.numeric(readInputFiles("Agonist"))
  
  
  
  # Fill the wanted data.frame using the 4 vectors
  final <- data.frame(WELL_NAME,controls,agonistConc=agonist, stringsAsFactors = FALSE)
  return(final)
}

