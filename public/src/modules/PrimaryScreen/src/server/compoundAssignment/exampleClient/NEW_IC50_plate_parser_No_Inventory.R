# Reminder: Functions on top to be sourced first

getPlateContent <- function(pathToExcelFile) {
  # Description: A function that reads the excel spreadsheet which contains the plate template (96-, 384-, or 1536-well 
  # plate format) and returns a data.frame with colums representing the content of each tab in the excel file as well as
  # supplementary information (concentration units, plate ID, data read title and units)
  #
  # Arg: file path to target excel file containing a plate template without inventory (multiple tabs)
  #
  # Returns: A dataframe with at least 4 columns: PlateContent, PlateConc, FlagWells, Data_Read_1
  
  # Load the appropriate library to read and extract from Excel spreasheets
  library(XLConnect)
  
  # Define a vector that contains all the names of all the wells in the plate contained in the excel file, whether
  # it is a 96-, 384-, or 1536-well plate format
  # Case 1: 96 well plate format (8 rows x 12 columns) reading row after row
  # Generate index vector for well location (96 wells)
  wellLetters_96 <- rep(LETTERS[1:8], each=12)
  wellNumbers_96 <- rep(seq(1:12), times=8)
  leadingZerosWellNumbers_96 <- formatC(wellNumbers_96, width = 2, format = "d", flag = "0")
  standardWellNames_96 <- paste0(wellLetters_96, leadingZerosWellNumbers_96)
  
  #  Case 2: 384 well plate format (16 rows x 24 columns) reading row after row
  # Generate index vector for well location (384 wells)
  wellLetters_384 <- rep(LETTERS[1:16], each=24)
  wellNumbers_384 <- rep(seq(1:24), times=16)
  leadingZerosWellNumbers_384 <- formatC(wellNumbers_384, width = 2, format = "d", flag = "0")
  standardWellNames_384 <- paste0(wellLetters_384, leadingZerosWellNumbers_384)
  
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

  
  # Load the plate template
  plateTemplate <- loadWorkbook(pathToExcelFile)
  
  # Get available names for tabs in the plate template
  plateTemplateTabs <- getSheets(plateTemplate)
  
  # Get the approximate size of plate as presented in the first tab of the excel file
  rowRange <- getLastRow(plateTemplate,sheet=1)
  columnRange <- getLastColumn(plateTemplate,sheet=1)
  # Ignore rows and columns outside the plate layout (standard tab format)
  # 6 rows above plate layout not required
  rowRange <- rowRange - 6
  # 1 column left to layout not required
  columnRange <- columnRange - 1
  # calculate available wells
  wellPlateDeterminedFormat <- rowRange*columnRange
  
  # Confirm the presence of at least 4 required tabs: (PlateTemplate tab is ignored for now)
  # 1. PlateContent
  # 2. PlateConc
  # 3. FlagWells
  # 4. Data_Read_1
  # otherwise prompt the user
  
  # Display error if there is less than four (4) tabs in the excel file
  if (length(plateTemplateTabs) < 4) {
    stop("Insufficient number of tabs detected in plate template: minimum required number of tabs = 4 (PlateContent, PlateConc,FlagWells, Data_Read_1)")
  } 
  
  # Display errors if one of the four (4) required tabs is missing from the excel file
  if (!("PlateContent" %in% plateTemplateTabs)) {
    stop("No PlateContent tab was detected in plate template. Please make sure the right file has been provided.")
  }
    if (!("PlateConc" %in% plateTemplateTabs)) {
    stop("No PlateConc tab was detected in plate template. Please make sure the right file has been provided.")
  }
  if (!("FlagWells" %in% plateTemplateTabs)) {
    stop("No FlagWells tab was detected in plate template. Please make sure the right file has been provided.")
  }
  if (!("Data_Read_1" %in% plateTemplateTabs)) {
    stop("No Data_Read_1 tab was detected in plate template. Please make sure the right file has been provided.")
  }
  
  # If Inventory tab is detected then it is the wrong type of file
  if ("Inventory" %in% plateTemplateTabs) {
    stop("Inventory tab was detected in the plate template. Please make sure the file does not have an inventory-related tab.")
  }
  
  
  readTabFromTemplate <- function(sheetName, pathToExcelFile) {
    # Description: Reads the specified sheet and stores all data row-by-row in a vector
    #
    # Arg: sheet name captured from the excel file, and path to that excel file
    #
    # Returns: The vector containing all entries from the sheet row-after-row
    
    # Extract all data present in the spreadsheet (i.e. tab) as a table, not only limited to the plate contents
    allDataTable <- readWorksheetFromFile(pathToExcelFile, sheet=sheetName, header=FALSE)

    # Extract supplementary info in the first 5 lines above the plate layout within each tab of the plate template excel file
    headerInfo <- as.vector(t(allDataTable[1:5, 2]))
    
    # Extract the number of wells defined in the first tab, indicating whether a 96-, 384-, or 1536-well plate format is defined
    numberOfWells <- as.numeric(headerInfo[5])
   
    # Confirm that this is a 96-, 384-, or 1536-well plate format otherwise throw an error
    if (!(numberOfWells==96 | numberOfWells==384 | numberOfWells==1536)) {
      stop("A different plate format than the expected 96-, 384-, or 1536-well plate is registered in the file. Please check the plate template.")
    }
    
    ## Purge any NA values from headerInfo vector
    #headerInfo <- headerInfo[!is.na(headerInfo)]
    
    pickPlateSizeExtract <- function(dataTable, wellFormat) {
      # Description: Determines the range of cells that contain useful information regarding the plate layout, extracts all data row-by-row 
      # from the main table, and stores extracted content in a single vector
      #
      # Arg:  table(/matrix) containing all data copied from a tab in the excel file
      # Arg:  number representing the plate well format (96, 384, or 1536)
      #
      # Returns:  vector containing all entries from the sheet row-after-row, within the limits of the size of the plate
      
      if (wellFormat==96) {
        # 96 well plate format (8 rows x 12 columns)
        # Wanted: Rows #1 to #8
        rowRange <- 1:8
        # Wanted: Columns #1 to #12
        columnRange <- 1:12
      } else if (wellFormat==384) {
        # 384 well plate format (16 rows x 24 columns)
        # Wanted: Rows #1 to #16
        rowRange <- 1:16
        # Wanted: Columns #1 to #24
        columnRange <- 1:24
      } else if (wellFormat==1536) {
        # 1536 well plate format (32 rows x 48 columns)
        # Wanted: Rows #1 to #32
        rowRange <- 1:32
        # Wanted: Columns #1 to #48
        columnRange <- 1:48
      } else {
        stop("Well format provided does not match the anticipated options of 96-, 384-, or 1536-well plate format. Please check plate size.")
      }
    
      # Ignore rows and columns outside the plate layout
      # 6 rows above plate layout not required
      rowRange <- rowRange + 6
      # 1 column left to layout not required
      columnRange <- columnRange + 1
        
      # Save the well contents of the current spreadsheet as a vector, reading row after row and extending to the limits
      # defined by the plate format size
      outputVector <- as.vector(t(dataTable[rowRange, columnRange]))
        
      return(outputVector)
    }
    
    # Isolate the plate content (and trim the unnecessary rows/colums from allDataTable) based on the type of well format determined
    plateData <- pickPlateSizeExtract(allDataTable, numberOfWells)
    
    # Paste together the supplementary info in the first 5 lines above the plate layout with the vector containing the plate contents
    finalVector <- c(headerInfo, plateData)
    return(finalVector)
  }
  
 
  # Create the main matrix reading all the tabs in the excel file and trim leading and trailing blanks (taking into account the 5 lines above the
  # plate layout included in the final vector)
  mainMatrix <- trimws(vapply(plateTemplateTabs, readTabFromTemplate, as.character(1:(wellPlateDeterminedFormat+5)), pathToExcelFile))#as.character(1:389), pathToExcelFile))
 
  # Refine the headers and registered units
  headers <- paste(mainMatrix[1,], mainMatrix[2,])
  headers[1] <- "batchCode"
  headers[2] <- gsub("NA ", "", headers[2])
  headers[3] <- "FlaggedWells"
  
  # Extract the plate ID
  extractedPlateID <- mainMatrix[4,1]
  
  
  # Create the main dataframe
  plateDataFrame <- rbind(headers, mainMatrix[-c(1:5),])
  plateDataFrame <- as.data.frame(plateDataFrame, row.names=FALSE)
  
  # Pick well plate format and corresponding well names
  if (wellPlateDeterminedFormat==96) {
    standardWellNames <- standardWellNames_96
  } else if (wellPlateDeterminedFormat==384) {
    standardWellNames <- standardWellNames_384
  } else if (wellPlateDeterminedFormat==1536) {
    standardWellNames <- standardWellNames_1536
  } else {
    stop("Well format detected does not match the anticipated options of 96-, 384-, or 1536-well plate format. Please check plate size in the provided file.")
  }
  
  # Expand the well names with the plateID and add to the dataframe
  plateDataFrame$plateWells <- c(paste0('Plate Id: ', extractedPlateID), standardWellNames)
  
  # General format for batchCodes of the type EPI-XXXXXX-00X
  targetLength <- nchar('EPI-XXXXXX-00X')

  
  # Replace commented sections below with batch validation service  
#  # Throw an error if a batchCode is detected that does not have the appropriate character length (while excluding the NA ones i.e. originally registered as blanks)
#  if (any(nchar(as.vector(plateDataFrame$PlateContent))!=targetLength)) {
#    stop(paste0("The following batchcodes were found to be non-conforming: ", 
#                 paste(plateDataFrame$PlateContent[which(nchar(as.vector(plateDataFrame$PlateContent))!=targetLength & !is.na(as.vector(plateDataFrame$PlateContent)))], collapse=", "), 
#                 ".\n Please check the plate template."))
#  }
#  # Throw an error if a batchCode is detected that does not match the EPI-XXXXXX-00X batchcode format (while excluding the NA ones i.e. originally registered as blanks)
#  if (any(!grepl("^EPI-[0-9]{6}-[0-9]{3}", as.vector(plateDataFrame$PlateContent)) & !is.na(as.vector(plateDataFrame$PlateContent)))) {
#    stop(paste0("The following batchcodes do not follow the batchCode ID format: ", 
#                 paste(plateDataFrame$PlateContent[which(!grepl("^EPI-[0-9]{6}-[0-9]{3}", as.vector(plateDataFrame$PlateContent)) & !is.na(as.vector(plateDataFrame$PlateContent)))], collapse=", "), 
#                 ".\n Please check the plate template."))
#  }

  
  # Throw an error if a well with a defined batchCode is missing info in all the other columns (i.e. concentration, data reads)
  # Create a smaller dataframe without the flagged wells column, and keep only the rows from plateDataFrame that have defined batchCodes
  dfWithoutFlags <- plateDataFrame[, names(plateDataFrame)!="FlagWells"]
  dfWithoutFlags <- dfWithoutFlags[!is.na(dfWithoutFlags$PlateContent),]
  # Create a vector that stores any rows of the smaller dataframe that contain NA values
  vectorFindNA <- apply(dfWithoutFlags, 1, function(x) any(is.na(x)))

  # if at least one entry of the vector vectorFindNA is detected with a NA value then prompt the user showing which well(s) are missing information 
  if (length(vectorFindNA[vectorFindNA==T])>0) {
    stop(paste0("Wells ", paste(dfWithoutFlags$plateWells[vectorFindNA], collapse = ", "), " were found to be missing information from at least one tab in 
                 the plate template, despite having properly defined compound IDs. Please check data in the plate template."))
  }
    
  
  # Throw an error if even though a batchCode was not defined, there is unexpected data in other tabs of the excel file
  if (any(is.na(plateDataFrame$PlateContent))) {
    #print(plateTemplateTabs[2])
    
    # Create vector that contains the number of available tabs in the given excel file
    numbersRepresentingTabs <- 1:length(plateTemplateTabs)
    # remove from that vector the number representing the tab PlateContent, as it is the only tab that is not necessary for the action below
    numbersRepresentingTabs <- numbersRepresentingTabs[-(which(plateTemplateTabs=="PlateContent"))]
    
    for (columnDataFrame in numbersRepresentingTabs) {
      #columnDataFrame <- 2
      rowDataFrame <- which(is.na(plateDataFrame$PlateContent))
      
      vectorWithNA <- vapply(rowDataFrame, function(x) is.na(plateDataFrame[x, columnDataFrame]), TRUE)
      wellsWithUnexpectedValues <- plateDataFrame$plateWells[rowDataFrame[which(vectorWithNA==FALSE)]]
      
      if (length(wellsWithUnexpectedValues)>0) {
        stop(paste0("Wells ", paste(wellsWithUnexpectedValues, collapse = ", "), " were found to contain some unexpected value (instead of being blank)
                     in tab '", colnames(plateDataFrame[columnDataFrame]), "' despite the fact that no compound IDs were defined in those wells in tab 'PlateContent'.
                     Please check data in the plate template."))
      }
    }
    
  }
    
  return(plateDataFrame)
}


formatPlateContent <- function(plateDataFrame) {
  # Description: A function that provides the appropriate format for a dataframe containing the plate content for
  # each tab in the excel file (plate template without inventory tab), as well as expected supplementary info 
  # regarding column headers, data read units, concentration units and plate ID, before it can be used by function
  # getAssayCompoundData()
  #
  # Arg: A dataframe with supplementary unit/header info embedded in its first row
  #
  # Returns: A formatted dataframe to be used by function getAssayCompoundData()
  
  # First row of the dataframe contains header info from which the plate ID can be extracted
  columnWithPlateID <- grep("Plate Id", plateDataFrame[1, ])
  plateIDString <- plateDataFrame[1, columnWithPlateID]
  strippedPlateID <- trimws(gsub("Plate Id:", "", plateIDString))
  
  # Remove first line from dataframe (containing column headers, data read units, concentration units and plate ID) 
  # and reset row numbering
  formattedDataFrame <- plateDataFrame[-1,]
  rownames(formattedDataFrame) <- NULL
  
  # Rename headers to the ones expected by function getAssayCompoundData()
  setnames(formattedDataFrame, c("PlateContent","PlateConc", "plateWells"), c("cmpdBarcode","cmpdConc", "wellReference"))
  formattedDataFrame$assayBarcode <- strippedPlateID
  # Save the concentration as numbers so that they can be used in concentration djusting calculations later on
  formattedDataFrame$cmpdConc <- as.numeric(formattedDataFrame$cmpdConc)
  
  # Required column headers by function getAssayCompoundData()
  # "plateType","assayBarcode","cmpdBarcode","sourceType","wellReference",
  # "rowName","colName","corp_name","batch_number","cmpdConc","supplier","plateOrder"
  
  # Generate the missing ones: "plateType","sourceType","corp_name","batch_number","supplier"
  # Split the batchCode based on the general format for batchCodes of the type EPI-XXXXXX-00X
  compoundBatchSplitList <- strsplit(as.character(formattedDataFrame$cmpdBarcode), "-")
  corpInitials <- rapply(compoundBatchSplitList, function(x) {x[1]})
  corpInitials[is.na(corpInitials)] <- ""
  
  compoundNumber <- rapply(compoundBatchSplitList, function(x) {x[2]})
  compoundNumber[is.na(compoundNumber)] <- ""
  
  # Paste together the corporate initials with the compound ID
  formattedDataFrame$corp_name <- ifelse((compoundNumber!=""), yes=paste0(corpInitials, "-", compoundNumber), no=NA)
  
  # Isolate the batch number and turn it into  number
  formattedDataFrame$batch_number <- as.numeric(rapply(compoundBatchSplitList, function(x) {x[3]}))
  
  # Generate the remaining required columns
  formattedDataFrame$plateType <- "no inventory"
  formattedDataFrame$sourceType <- NA
  formattedDataFrame$supplier <- NA
  
  return(formattedDataFrame)
}

checkPlateConcentrationMicromolarUnits <- function(plateDataFrame) {
  # Description: A function that looks in the unformatted dataframe (containing the plate content for
  # each tab in the excel file, as well as expected supplementary info regarding column headers, data read units, 
  # concentration units and plate ID) for the concentration units used in the concentration tab
  #
  #
  # Arg: A dataframe with supplementary unit/header info embedded in its first row
  #
  # Returns: A logical flag that is TRUE if the units are uM
  
  # First row of the dataframe column with header "PlateConc" shows the concentration unit
  plateConcUnitString <- plateDataFrame$PlateConc[1]
  concentrationUnit <- trimws(plateConcUnitString)
  if (concentrationUnit=="uM" | concentrationUnit=="um" | concentrationUnit=="μM" | concentrationUnit=="μm") {
    microMolarFlag <- TRUE
  } else if (concentrationUnit=="" | is.na(concentrationUnit)) {
    microMolarFlag <- TRUE
  } else if (concentrationUnit=="nM" | concentrationUnit=="nm" | concentrationUnit=="nM" | concentrationUnit=="nm") {
    microMolarFlag <- FALSE
  } else {
    microMolarFlag <- FALSE
  }
  
  return(microMolarFlag)
}

####TO BE REMOVED
## main script for testing purposes ONLY
# Point to the proper plate template without inventory (and depending the plate format)
# 96 well plate
#testExcelFile <- "/Users/vasileios/Desktop/example_plateData_without_inventory.xlsx"
# 384 well plate
#testExcelFile <- "/Users/vasileios/Desktop/example_plateData_without_inventory_384.xlsx"

#aa <- getPlateContent(testExcelFile)
#aa <- formatPlateContent(aa)
#print(aa)
