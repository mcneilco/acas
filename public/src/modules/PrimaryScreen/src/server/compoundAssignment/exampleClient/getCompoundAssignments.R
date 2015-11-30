
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
  
  resultTable[, batchCode := paste0(corp_name,"::",batch_number)]
  resultTable[batchCode == "NA::NA", batchCode := "::"]
  #   setnames(resultTable, c("wellReference", "assayBarcode", "cmpdConc", "corp_name"), c("well", "barcode", "concentration", "batchName"))
  setnames(resultTable, c("wellReference","rowName", "colName", "corp_name"), c("well","row", "column", "batchName"))
  
  # apply dilution
  if (!is.null(parameters$dilutionRatio) && parameters$dilutionRatio != "") {
    resultTable$cmpdConc <- resultTable$cmpdConc / parameters$dilutionRatio
  }
  
  return(resultTable)
}


getCompoundAssignmentsInternal <- function(folderToParse, instrumentData, testMode, parameters) {
  
  save(folderToParse, instrumentData, testMode, parameters, file="cmpdAssignments.Rda")
  resultTable <- instrumentData
  
  barcodeList <- levels(resultTable$barcode)
  
  wellTable <- createWellTable(barcodeList, testMode)
  
  
  # apply dilution
  if (!is.null(parameters$dilutionRatio)) {
    wellTable$CONCENTRATION <- wellTable$CONCENTRATION / parameters$dilutionRatio
  }

  
  wellTable <- getAgonist(parameters$agonistControl, wellTable) 
  wellTable <- removeVehicle(parameters$vehicleControl, wellTable)
  

  if(anyDuplicated(paste(wellTable$BARCODE, wellTable$WELL_NAME, sep=":"))) {
    stopUser(paste0("Multiple test compounds were found in these wells, so it is unclear which is the tested compound: '", 
                    paste(wellTable$plateAndWell[duplicated(wellTable$plateAndWell)], collapse = "', '"),
                    "'. Please contact your system administrator."))
  }
  
  batchNamesAndConcentrations <- getBatchNamesAndConcentrations(resultTable[[1]]$assayBarcode, resultTable[[1]]$wellReference, wellTable)
  
  resultTable <- cbind(resultTable[[1]],batchNamesAndConcentrations)  #added in [[1]] in resultTable in lines 89 and 94

  
  
  
  setnames(resultTable,c("batchName", "concentration"),c("batchCode", "cmpdConc"))  #previously batchName was barcode
  
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

getBatchNamesAndConcentrations <- function(barcode, well, wellTable) {
  # Matches result rows up with batch names and concentrations
  #
  # Args:
  #   barcode:        A vector of the barcodes
  #   well:           A vector of the wells
  #   wellTabe:       A data.frame with columns of BARCODE, WELL_NAME, BATCH_CODE,CONCENTRATION,CONCENTRATION_UNIT
  # Returns:
  #   A data.frame with batchName,concentration, and concUnit that matches the order of the input barcodes and wells
  
  wellUniqueId <- paste(barcode, well)
  wellTableUniqueId <- paste(wellTable$BARCODE, wellTable$WELL_NAME)
  outputFrame <- wellTable[match(wellUniqueId,wellTableUniqueId),c("BATCH_CODE","CONCENTRATION","CONCENTRATION_UNIT", "agonistConc")]
  names(outputFrame) <- c("batchName","concentration","concUnit", "agonistConc")
  return(outputFrame)
}


createWellTable <- function(barcodeList, testMode) {
  # Creates a table of wells and corporate batch id's
  #
  # Args:
  #   barcodeList:    A list of plate barcodes used in the experiment
  #   testMode:       A boolean of the testMode
  # Returns:
  #   A table of wells and corporate batch id's
  
  barcodeQuery <- paste(barcodeList,collapse="','")
  
  testMode <- TRUE
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
  
  wellTable$CONCENTRATION[wellTable$CONCENTRATION_STRING == "infinite"] <- Inf
  
  return(wellTable)
  }


