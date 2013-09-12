# Registers sample transfers from one well to another

# bulkLoadSampleTransfers(request=list(fileToParse="public/src/modules/BulkLoadSampleTransfers/spec/specFiles/FLIPROutputLogSmall.csv", dryRun=TRUE, user = "smeyer"))

#containerTable <- fullContainerTable
#containerTable <- containerTable[!is.na(containerTable$WELL_ID) & !is.na(containerTable$VOLUME_UNIT), ]
#containerTable <- containerTable[containerTable$WELL_ID %in% c(logFile$Source.Id, logFile$Destination.Id), ]
#containerTable$VOLUME[containerTable$WELL_NAME == "A01"] <- Inf
runMain <- function(fileName, dryRun, testMode, recordedBy) {
  require(plyr)
  
  logFile <- read.csv(fileName, stringsAsFactors = FALSE)
  
  summaryInfo <- list(info = list(
      "Transfers" = nrow(logFile),
      "User name" = recordedBy))
  
  if (dryRun) return(summaryInfo)
  
  containerTable <- getCompoundPlateInfo(unique(c(logFile$Source.Barcode, logFile$Destination.Barcode)), testMode)
  
  # TODO: this makes it look pretty, remove later
  containerTable <- containerTable[!is.na(containerTable$WELL_ID) & !is.na(containerTable$VOLUME) & !is.na(containerTable$VOLUME_UNIT), ]
  
  containerTable$numericValue[containerTable$VOLUME_STRING == "infinite"] <- Inf
  
  newBarcodeList <- unique(logFile$Destination.Barcode[!(logFile$Destination.Barcode %in% containerTable$BARCODE)])
  
  logFile$Source.Well <- normalizeWellNames(logFile$Source.Well)
  logFile$Destination.Well <- normalizeWellNames(logFile$Destination.Well)
  logFile$FakeSourceId <- paste(logFile$Source.Barcode, logFile$Source.Well, sep="&")
  logFile$FakeDestinationId <- paste(logFile$Destination.Barcode, logFile$Destination.Well, sep="&")
  
  containerTable$FakeId <- paste(containerTable$BARCODE, containerTable$WELL_NAME, sep="&")
  
  logFile$Source.Id <- containerTable$WELL_ID[match(logFile$FakeSourceId, containerTable$FakeId)]
  logFile$Destination.Id <- containerTable$WELL_ID[match(logFile$FakeDestinationId,containerTable$FakeId)]
  
  logFile$Date.Time <- as.POSIXct(logFile$Date.Time, format = "%Y-%m-%d %H:%M")
  
  # New wells have a negative destination Id as a placeholder
  logFile$Destination.Id[is.na(logFile$Destination.Id)] <- -1:-sum(is.na(logFile$Destination.Id))
  logFile$Source.Id[is.na(logFile$Source.Id)] <- logFile$Destination.Id[match(logFile$FakeSourceId, logFile$FakeDestinationId)][is.na(logFile$Source.Id)]
  
  containerTable <- containerTable[containerTable$WELL_ID %in% c(logFile$Source.Id, logFile$Destination.Id), ]
  
  interactions <- data.frame()
  for (i in 1:nrow(logFile)) {
    row <- logFile[i, ]
    
    sourceTable <- containerTable[row$Source.Id == containerTable$WELL_ID, ]
    destinationTable <- containerTable[row$Destination.Id == containerTable$WELL_ID, ]
    ##################
    if (sourceTable$VOLUME_UNIT[1] != row$Amount.Units[1]) {
      stop("Units must match")
      #TODO: fix units for them
      convertUnits()
    }
    newSourceSet <- sourceTable
    newSourceSet$VOLUME <- sourceTable$VOLUME[1] - row$Amount.Transferred
    if (newSourceSet$VOLUME[1] < 0) {
      stop(paste0("More liquid was removed from well ", sourceTable$WELL_ID, " (", sourceTable$WELL_NAME, ") than was available."))
    } else if (newSourceSet$VOLUME[1] == 0) {
      newSourceSet <- data.frame()
    }
    ##################
    if (sourceTable$VOLUME_UNIT[1] != row$Amount.Units[1]) {
      stop("Units must match")
      #TODO: fix units for them
      convertUnits()
    }
    destinationVolume <- sum(destinationTable$VOLUME[1], row$Amount.Transferred, na.rm=TRUE)
    destinationWellId <- row$Destination.Id
    combinedSet <- rbind.fill(sourceTable, destinationTable)
    newDestinationSet <- ddply(combinedSet, ~BATCH_CODE, summarize, 
                               WELL_ID = destinationWellId, 
                               BATCH_CODE = BATCH_CODE[1], 
                               VOLUME = destinationVolume, 
                               VOLUME_UNIT = VOLUME_UNIT[1], 
                               CONCENTRATION = sum(CONCENTRATION*VOLUME, na.rm = TRUE)/destinationVolume,
                               CONCENTRATION_UNIT = CONCENTRATION_UNIT[1])
    newDestinationSet$dateChanged <- row$Date.Time
    newDestinationSet <- rbind.fill(newDestinationSet, destinationTable)
    
    # Remove old rows
    containerTable <- containerTable[!(containerTable$WELL_ID %in% c(row$Destination.Id, row$Source.Id)), ]
    # Add new ones
    containerTable <- rbind.fill(containerTable, newSourceSet, newDestinationSet)
    
    # TODO: add state that has date, amount, etc.
    newInteraction <- data.frame(
      interactionType = "transferred to",
      interactionKind = "content transfer",
      firstContainer = row$Source.Id,
      secondContainer = row$Destination.Id,
      dateTransferred = row$Date.Time,
      volumeTransferred = row$Amount.Transferred,
      protocol = row$Protocol
      )
    interactions <- rbind.fill(interactions, newInteraction)
  }

  ### Save new plates (but not contents)
  lsTransaction <- createLsTransaction(comments="Sample Transfer load")$id
  
  wellTranslation <- saveNewWells(newBarcodeList, logFile, lsTransaction, recordedBy)
  IdsToReplace <- containerTable$WELL_ID < 0
  containerTable$WELL_ID[IdsToReplace]  <- wellTranslation$newWellId[match(containerTable$WELL_ID, wellTranslation$oldWellId)][IdsToReplace]
  interactions$firstContainer  <- wellTranslation$newWellId[match(interactions$firstContainer, wellTranslation$oldWellId)]
  interactions$secondContainer <- wellTranslation$newWellId[match(interactions$secondContainer, wellTranslation$oldWellId)]
  
  
  MarkContainersStatusIgnored(containerTable$WELL_ID)
  
  containerTable$BARCODE <- NULL
  containerTable$WELL_NAME <- NULL
  containerTable$FakeId <- NULL
  batchCodeRows <- data.frame(valueType = "codeValue", valueKind = "batch code", codeValue = containerTable$BATCH_CODE, containerId = containerTable$WELL_ID, stringsAsFactors=FALSE)
  volumeRows <- data.frame(valueType = "numericValue", valueKind = "volume", numericValue = containerTable$VOLUME, valueUnit = containerTable$VOLUME_UNIT, containerId = containerTable$WELL_ID, stringsAsFactors=FALSE)
  volumeRows$stringValue <- NA
  infiniteRows <- volumeRows$numericValue == Inf
  volumeRows$stringValue[infiniteRows] <- "infinite"
  volumeRows$numericValue[infiniteRows] <- NA
  concentrationRows <- data.frame(valueType = "numericValue", valueKind = "concentration", numericValue = containerTable$CONCENTRATION, valueUnit = containerTable$CONCENTRATION_UNIT, containerId = containerTable$WELL_ID, stringsAsFactors=FALSE)
  containerdf <- rbind.fill(batchCodeRows,volumeRows,concentrationRows)
    
  containerdf$stateGroupIndex <- 1
  containerdf$publicData <- TRUE
  
  stateGroups <- list(list(entityKind="container",
                           stateType="status",
                           stateKind="test compound content",
                           valueKinds=c(),
                           includesOthers=TRUE))
  
  # idColumn may change to organize these correctly
  stateIdAndVersion <- saveStatesFromLongFormat(containerdf, "container", stateGroups, idColumn="containerID", recordedBy, lsTransaction)

  containerdf$stateID <- stateIdAndVersion$entityStateId
  containerdf$stateVersion <- stateIdAndVersion$entityStateVersion
  
  savedValues <- saveValuesFromLongFormat(containerdf, "container", stateGroupIndices = 1, lsTransaction=lsTransaction)
  
  #### interaction Saving
  
  interactions$codeName <- unlist(getAutoLabels(thingTypeAndKind="interaction_containerContainer",
                                                labelTypeAndKind="id_codeName", 
                                                numberOfLabels=nrow(interactions)), 
                                  use.names = FALSE)
  
  interactions$rowID <- 1:nrow(interactions)
  createLocalContainerContainerItx <- function(interactionType, firstContainer, secondContainer, codeName, ...) {
    createContainerContainerInteraction(interactionType = interactionType, 
                                        firstContainer=list(id=firstContainer, version=0), 
                                        secondContainer=list(id=secondContainer, version=0), 
                                        codeName=codeName, lsTransaction=lsTransaction, recordedBy=recordedBy)
  }
  interactionList <- mlply(interactions, .fun = createLocalContainerContainerItx)
  names(interactionList) <- NULL
  savedInteractions <- saveAcasEntities(interactionList, "itxcontainercontainers")
  interactions$interactionId <- sapply(savedInteractions, getElement, "id")
  interactions$stateID <- 1:nrow(interactions)
  
  dateRows <- data.frame(valueType = "dateValue", valueKind = "date transferred", dateValue = interactions$dateTransferred, interactionID = interactions$interactionId, stringsAsFactors=FALSE)
  amountRows <- data.frame(valueType = "numericValue", valueKind = "amount transferred", numericValue = interactions$amountTransferred, interactionID = interactions$interactionId, stringsAsFactors=FALSE)
  protocolRows <- data.frame(valueType = "stringValue", valueKind = "protocol", stringValue = interactions$protocol, interactionID = interactions$interactionId, stringsAsFactors=FALSE)
  interactiondf <- rbind.fill(dateRows, amountRows, protocolRows)
  interactiondf$stateGroupIndex <- 1
  
  stateGroups <- list(list(entityKind="interaction",
                           stateType="data",
                           stateKind="transfer data",
                           valueKinds=c("date transferred", "amount transferred", "protocol"),
                           includesOthers=TRUE))
  
  stateIdAndVersion <- saveStatesFromLongFormat(interactiondf, "interaction", stateGroups, idColumn="interactionID", recordedBy, lsTransaction)
  
  containerdf$stateID <- stateIdAndVersion$entityStateId
  containerdf$stateVersion <- stateIdAndVersion$entityStateVersion
  
  savedValues <- saveValuesFromLongFormat(interactiondf, "interaction", stateGroupIndices = 1, lsTransaction=lsTransaction)
  
  summaryInfo$info <- c(summaryInfo$info,
                        "New Plates" = length(newBarcodeList),
                        "Source Plates" = length(unique(logFile$Source.Barcode)),
                        "Destination Plates" = length(unique(logFile$Destination.Barcode)))
  return(summaryInfo)
  
}
createPlateWellInteraction <- function(wellId, plateId, interactionCodeName, lsTransaction, recordedBy) {
  return(createContainerContainerInteraction(
    interactionType= "has member",
    interactionKind= "plate well",
    codeName= interactionCodeName,
    recordedBy= recordedBy,
    lsTransaction= lsTransaction,
    firstContainer= list(id=plateId, version=0),
    secondContainer= list(id=wellId, version=0)
  ))
}
saveNewWells <- function(newBarcodeList, logFile, lsTransaction, recordedBy) {
  # Saves new wells and their interactions with plates
  
  savedNewPlates <- registerNewPlates(newBarcodeList, lsTransaction=lsTransaction, recordedBy=recordedBy)
  
  # Now these are included in the new query- might change that
  #newPlateIdTranslation <- data.frame(barcode=newBarcodeList, plateId=sapply(savedNewPlates,getId))
  oldPlates <- unique(c(logFile$Destination.Barcode, logFile$Source.Barcode))
  oldPlateIdTransation <- query(paste0(
    "SELECT label_text AS barcode,
    container_id    AS plateid
    FROM container_label
    WHERE label_text IN ('", paste(oldPlates, collapse = "','"), "')"))
  plateIdTranslation <- oldPlateIdTransation
  
  newWellInformation <- unique(logFile[logFile$Destination.Id < 0, c('Destination.Barcode', 'Destination.Well', 'Destination.Id')])
  newPlateIds <- plateIdTranslation$PLATEID[match(newWellInformation$Destination.Barcode, plateIdTranslation$BARCODE)]
  newWells <- data.frame(plateId = newPlateIds, 
                         labelText = newWellInformation$Destination.Well, 
                         containerId = newWellInformation$Destination.Id)
  
  if(nrow(newWells)>0) {
    newWells$wellCodeName <- unlist(getAutoLabels(thingTypeAndKind="material_container",
                                                  labelTypeAndKind="id_codeName", 
                                                  numberOfLabels=nrow(newWells)), 
                                    use.names = FALSE)
    
    # Combines the well information with the code names
    createLocalContainer <- function(plateId, labelText, containerId, wellCodeName, ..., lsTransaction, recordedBy) {
      createContainer(
        codeName=wellCodeName, lsTransaction=lsTransaction, recordedBy=recordedBy, 
        containerType= "well", containerKind= "plate well",
        containerLabels=list(createContainerLabel(
          labelType="name", labelKind="well name", labelText=labelText, recordedBy=recordedBy, lsTransaction=lsTransaction)))
    }
    wellList <- mlply(.data= newWells, .fun = createLocalContainer,
                      lsTransaction=lsTransaction, recordedBy=recordedBy)
    names(wellList) <- NULL
    
    savedWells <- saveContainers(wellList)
    
    newWells$wellId <- sapply(savedWells, function(x) x$id)
    
    # Save interactions
    newWells$interactionCodeName <- unlist(getAutoLabels(thingTypeAndKind="interaction_containerContainer",
                                                         labelTypeAndKind="id_codeName", 
                                                         numberOfLabels=nrow(newWells)),
                                           use.names = FALSE)
    
    interactionData <- newWells[,c("wellId", "plateId", "interactionCodeName")]
    
    interactions <- mlply(.data=interactionData, .fun = createPlateWellInteraction,
                          lsTransaction=lsTransaction, recordedBy=recordedBy)
    names(interactions) <- NULL
    
    savedContainerContainerInteractions <- saveContainerContainerInteractions(interactions)
    
  }
  
  unchangedIds <- c(logFile$Destination.Id[logFile$Destination.Id > 0], logFile$Source.Id[logFile$Source.Id > 0])
  wellTranslation <- data.frame(oldWellId = c(newWells$containerId, unchangedIds), newWellId = c(newWells$wellId, unchangedIds))
  
  return(wellTranslation)
}
registerNewPlates <- function(barcodes, lsTransaction, recordedBy) {
  if (length(barcodes) < 1) return(list())
  plateCodeNameList <- getAutoLabels(thingTypeAndKind="material_container",
                                     labelTypeAndKind="id_codeName", 
                                     numberOfLabels=length(barcodes))
  plates <- mapply(barcodes, plateCodeNameList, FUN = createPlateWithBarcode, MoreArgs = list(lsTransaction=lsTransaction, recordedBy=recordedBy), USE.NAMES=FALSE)
  plateList <- apply(plates,MARGIN=2,as.list)
  
  savedPlates <- saveContainers(plateList)
  
  return(savedPlates)
}
createPlateWithBarcode <- function(barcode, codeName, lsTransaction, recordedBy) {
  return(createContainer(
    codeName = codeName[[1]],
    containerType = "plate", 
    containerKind = "384 well compound plate", 
    recordedBy = recordedBy,
    lsTransaction = lsTransaction,
    containerLabels = list(createContainerLabel(
      labelText = barcode,
      recordedBy = recordedBy,
      labelType = "barcode",
      labelKind = "plate",
      lsTransaction = lsTransaction)),
    containerStates = list(createContainerState(
      stateType="constants",
      stateKind="plate format",
      recordedBy=recordedBy,
      lsTransaction=lsTransaction,
      containerValues= list(
        createStateValue(
          valueType="numericValue",
          valueKind="rows",
          numericValue=16,
          lsTransaction=lsTransaction),
        createStateValue(
          valueType="numericValue",
          valueKind="columns",
          numericValue=24,
          lsTransaction=lsTransaction),
        createStateValue(
          valueType="numericValue",
          valueKind="wells",
          numericValue=384,
          lsTransaction=lsTransaction)
      )
    ))
  ))
}
getCompoundPlateInfo <- function(barcodeList, testMode = FALSE) {
  barcodeQuery <- paste(barcodeList,collapse="','")
  
  # TODO: need to add current state
  if (testMode) {
    fakeAPI <- read.csv("public/src/modules/PrimaryScreen/spec/api_container_export.csv")
    wellTable <- fakeAPI
  } else {
    wellTable <- query(paste0("SELECT * FROM api_container_contents WHERE barcode IN ('", barcodeQuery, "')"))
  }
  wellTable <- wellTable[wellTable$BARCODE %in% barcodeList, ]
  
  return(wellTable)
}
normalizeWellNames <- function(wellName) {
  # Turns A1 into A01
  #
  # Args:
  #   wellName:     a charcter vector
  # Returns:
  #   a character vector
  
  return(gsub("(\\D)(\\d)$","\\10\\2",wellName))
}
MarkContainersStatusIgnored <- function(idVector) {
  query(paste0(
    "UPDATE container_state
        SET ignored = 1,
        version     = version+1
        WHERE container_id IN (", paste(idVector, collapse=","), ")"))
  query(paste0(
    "UPDATE container_value
        SET ignored = 1,
        version     = version+1
WHERE container_state_id in (
select id from container_state
        WHERE container_id IN (", paste(idVector, collapse=","), "))"))
}
bulkLoadSampleTransfers <- function(request) {
  # The top level function
  require(racas)
  # Collect the information from the request
  request <- as.list(request)
  fileName <- request$fileToParse
  dryRun <- request$dryRun
  recordedBy <- request$user
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  testMode <- TRUE
  # Run the main function with error handling
  loadResult <- tryCatch.W.E(runMain(fileName,dryRun, testMode, recordedBy))
  
  # If the output has class simpleError, save it as an error
  errorList <- list()
  if(class(loadResult$value)[1]=="simpleError") {
    errorList <- list(loadResult$value$message)
    loadResult$errorList <- errorList
    loadResult$value <- NULL
  }
  
  # Save warning messages (but not the function call, as it is only useful while programming)
  loadResult$warningList <- lapply(loadResult$warningList, function(x) x$message)
  if (length(loadResult$warningList)>0) {
    loadResult$warningList <- strsplit(unlist(loadResult$warningList),"\n")
  }
  
  # Organize the error outputs
  loadResult$errorList <- errorList
  hasError <- length(errorList) > 0
  hasWarning <- length(loadResult$warningList) > 0
  
  htmlSummary <- createHtmlSummary(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value,dryRun)
  
  errorMessages <- list()
  
  # This is code that could put the error and warning messages into a format that is displayed at the bottom of the screen
  for (singleError in errorList) {
    errorMessages <- c(errorMessages, list(list(errorLevel="error", message=singleError)))
  }
  
  for (singleWarning in loadResult$warningList) {
    errorMessages <- c(errorMessages, list(list(errorLevel="warning", message=singleWarning)))
  }
  
  response <- list(
    commit= !hasError,
    transactionId= loadResult$value$lsTransactionId,
    results= list(
      id= loadResult$value$lsTransactionId,
      path= getwd(),
      fileToParse= request$fileToParse,
      dryRun= request$dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning = hasWarning,
    errorMessages= errorMessages
  )
  return(response)
}
