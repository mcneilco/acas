# Registers sample transfers from one well to another

# file.copy(from="public/src/modules/BulkLoadSampleTransfers/spec/specFiles/shortTransferNew.csv", to="serverOnlyModules/blueimp-file-upload-node/public/files", overwrite = TRUE)
# bulkLoadSampleTransfers(request=list(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/shortTransferNew.csv", dryRun=FALSE, user = "smeyer"))
# bulkLoadSampleTransfers(request=list(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/redactedCustomer Primary Screen Transfer Log 2013_4_18_edited_barcodes.csv", dryRun=TRUE, user = "smeyer"))
# bulkLoadSampleTransfers(request=list(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/shortTransfer.csv", dryRun=TRUE, user = "smeyer"))
#
# test case
# library(testthat)
# load("public/src/modules/BulkLoadSampleTransfers/spec/specFiles/transferCompoundsInput_short.Rda")
# load("public/src/modules/BulkLoadSampleTransfers/spec/specFiles/transferCompoundsOutput_short.Rda")
# expect_identical(transferCompounds(containerTable, logFile), output)

# For barcodes that should be removed:
# container <- appendToContainerName("AP0001", "_fail")
# container$ignored <- TRUE
# updateAcasEntity(container, "containers")

#containerTable <- fullContainerTable
#containerTable <- containerTable[!is.na(containerTable$WELL_ID) & !is.na(containerTable$VOLUME_UNIT), ]
#containerTable <- containerTable[containerTable$WELL_ID %in% c(logFile$Source.Id, logFile$Destination.Id), ]
#containerTable$VOLUME[containerTable$WELL_NAME == "A01"] <- Inf
runMain <- function(fileName, dryRun, testMode, developmentMode, recordedBy) {
  require(plyr)
  require(RCurl)
  
  fileName <- getUploadedFilePath(fileName)
  
  logFile <- read.csv(fileName, stringsAsFactors = FALSE)
  
  summaryInfo <- list(info = list(
      "Transfers" = nrow(logFile),
      "Possible Transfer Errors" = sum(logFile$Possible.Transfer.Error),
      "User name" = recordedBy))
  
  containerTable <- getCompoundPlateInfo(unique(c(logFile$Source.Barcode, logFile$Destination.Barcode)), testMode)
  
  # Throw errors if the Is.New.Plate is not true
  newBarcodeList <- unique(logFile$Destination.Barcode[!(logFile$Destination.Barcode %in% containerTable$BARCODE)])
  oldBarcodeList <- unique(containerTable$BARCODE)
  logFileNewBarcodes <- unique(logFile$Destination.Barcode[logFile$Is.New.Plate])
  logFileOldBarcodes <- unique(logFile$Destination.Barcode[!logFile$Is.New.Plate])
  
  repeatNewBarcodes <- setdiff(logFileNewBarcodes, newBarcodeList)
  if(length(repeatNewBarcodes) > 0) {
    stop(paste0("Some barcodes were marked as new in the log file but have already been registered: '",
                paste(repeatNewBarcodes, collapse="', '"), "'. It is likely that this file has already been loaded."))
  }
  missingOldBarcodes <- setdiff(logFileOldBarcodes, oldBarcodeList)
  if(length(missingOldBarcodes) > 0) {
    stop(paste0("Some barcodes were marked as old in the log file but have never been registered: '",
                paste(missingOldBarcodes, collapse="', '"), 
                "'. It is likely that this file depends on a file that has not yet been loaded. ",
                "Check for other files that should be loaded first."))
  }
  
  # Set infinite volume and concentration to numbers instead of text
  containerTable$VOLUME[containerTable$VOLUME_STRING == "infinite"] <- Inf
  containerTable$CONCENTRATION[containerTable$CONCENTRATION_STRING == "infinite"] <- Inf
  
  logFile$Source.Well <- normalizeWellNames(logFile$Source.Well)
  logFile$Destination.Well <- normalizeWellNames(logFile$Destination.Well)
  logFile$FakeSourceId <- paste(logFile$Source.Barcode, logFile$Source.Well, sep="&")
  logFile$FakeDestinationId <- paste(logFile$Destination.Barcode, logFile$Destination.Well, sep="&")
  
  containerTable$FakeId <- paste(containerTable$BARCODE, containerTable$WELL_NAME, sep="&")
  
  logFile$Source.Id <- containerTable$WELL_ID[match(logFile$FakeSourceId, containerTable$FakeId)]
  logFile$Destination.Id <- containerTable$WELL_ID[match(logFile$FakeDestinationId,containerTable$FakeId)]
  
  logFile$Date.Time <- as.POSIXct(logFile$Date.Time, format = "%Y-%m-%d %H:%M")
  
  # New wells have a negative destination Id as a placeholder
  logFile$Destination.Id[is.na(logFile$Destination.Id)] <- -as.numeric(as.factor(logFile$FakeDestinationId[is.na(logFile$Destination.Id)]))
  logFile$Source.Id[is.na(logFile$Source.Id)] <- logFile$Destination.Id[match(logFile$FakeSourceId, logFile$FakeDestinationId)][is.na(logFile$Source.Id)]
  
  containerTable <- containerTable[containerTable$WELL_ID %in% c(logFile$Source.Id, logFile$Destination.Id), ]
  
  # This is a special addition for Nextval for their broken log files, it removes transfers from A01, B01, etc. that have no source.
  # Also removes wells with id "@00"
  skipFirstRow <- TRUE
  if (skipFirstRow) {
    logFile <- logFile[!(is.na(logFile$Source.Id) & grepl("\\D01", logFile$Source.Well)), ]
    logFile <- logFile[logFile$Source.Id != "@00", ]
    if(nrow(logFile) == 0) {
      stop(paste("Not all source plates have been registered. ",
                 "It is likely that this file depends on a file that has not yet been loaded. ",
                 "Check for other files that should be loaded first."))
    }
  }
  
  if (testMode || developmentMode) {
    logFile <- logFile[!is.na(logFile$Source.Id), ]
  } else {
    if(any(is.na(logFile$Source.Id))) {
      stop(paste("Not all source plates have been registered. ",
           "It is likely that this file depends on a file that has not yet been loaded. ",
           "Check for other files that should be loaded first."))
    }
  }
  
  if (dryRun) {
    return(summaryInfo)
  }
  
  output <- transferCompounds(containerTable, logFile)
  containerTable <- output$containerTable
  interactions <- output$interactions
  
  # Save things
  lsTransaction <- createLsTransaction(comments="Sample Transfer load")$id
  
  if(!file.exists(racas::getUploadedFilePath("uploadedLogFiles"))) {
    dir.create(racas::getUploadedFilePath("uploadedLogFiles"))
  }
  newFileName <- paste0("uploadedLogFiles/", basename(fileName))
  # TODO: safe rename that will not overwrite
  file.rename(fileName, paste0(racas::getUploadedFilePath(""), newFileName))
  
  ### Save new plates (but not contents yet)
  wellTranslation <- saveNewWells(newBarcodeList, logFile, lsTransaction, recordedBy, newFileName)
  IdsToReplace <- containerTable$WELL_ID < 0
  containerTable$WELL_ID[IdsToReplace]  <- wellTranslation$newWellId[match(containerTable$WELL_ID, wellTranslation$oldWellId)][IdsToReplace]
  interactions$firstContainer  <- wellTranslation$newWellId[match(interactions$firstContainer, wellTranslation$oldWellId)]
  interactions$secondContainer <- wellTranslation$newWellId[match(interactions$secondContainer, wellTranslation$oldWellId)]
  
  MarkContainersStatusIgnored(containerTable$WELL_ID)
  
  containerTable$stateID <- 1:nrow(containerTable)
  containerTable$BARCODE <- NULL
  containerTable$WELL_NAME <- NULL
  containerTable$FakeId <- NULL
  batchCodeRows <- data.frame(stateID = containerTable$stateID, valueType = "codeValue", valueKind = "batch code", codeValue = containerTable$BATCH_CODE, containerID = containerTable$WELL_ID, stringsAsFactors=FALSE)
  volumeRows <- data.frame(stateID = containerTable$stateID, valueType = "numericValue", valueKind = "volume", numericValue = containerTable$VOLUME, valueUnit = containerTable$VOLUME_UNIT, containerID = containerTable$WELL_ID, stringsAsFactors=FALSE)
  volumeRows$stringValue <- NA
  concentrationRows <- data.frame(stateID = containerTable$stateID, valueType = "numericValue", valueKind = "concentration", numericValue = containerTable$CONCENTRATION, valueUnit = containerTable$CONCENTRATION_UNIT, containerID = containerTable$WELL_ID, stringsAsFactors=FALSE)
  containerdf <- rbind.fill(batchCodeRows,volumeRows,concentrationRows)
  
  # Set the rows with Inf numbers to a stringValue
  infiniteRows <- containerdf$numericValue == Inf
  containerdf$stringValue[infiniteRows] <- "infinite"
  containerdf$numericValue[infiniteRows] <- NA
    
  containerdf$stateGroupIndex <- 1
  containerdf$publicData <- TRUE
  
  stateGroups <- list(list(entityKind="container",
                           stateType="status",
                           stateKind="test compound content",
                           valueKinds=c(),
                           includesOthers=TRUE))
  
  #9.7 sec (736 transfers) (1056 states)
  stateIdAndVersion <- saveStatesFromLongFormat(containerdf, "container", stateGroups, idColumn="stateID", recordedBy, lsTransaction)
  
  containerdf$stateID <- stateIdAndVersion$entityStateId
  containerdf$stateVersion <- stateIdAndVersion$entityStateVersion
  
  #29.8 sec (736 transfers) (3168 values)
  savedValues <- saveValuesFromLongFormat(containerdf, "container", stateGroups, lsTransaction, recordedBy, stateGroupIndices = 1)
  
  #### interaction Saving
  
  interactions$codeName <- unlist(getAutoLabels(thingTypeAndKind="interaction_containerContainer",
                                                labelTypeAndKind="id_codeName", 
                                                numberOfLabels=nrow(interactions)), 
                                  use.names = FALSE)
  
  interactions$rowID <- 1:nrow(interactions)
  createLocalContainerContainerItx <- function(interactionType, interactionKind, firstContainer, secondContainer, dateTransferred, volumeTransferred, protocol, codeName, ...) {
    createContainerContainerInteraction(lsType = interactionType,
                                        lsKind = interactionKind,
                                        firstContainer=list(id=firstContainer, version=0), 
                                        secondContainer=list(id=secondContainer, version=0), 
                                        codeName=codeName, lsTransaction=lsTransaction, recordedBy=recordedBy)
  }
  interactionList <- mlply(interactions, .fun = createLocalContainerContainerItx)
  names(interactionList) <- NULL
  # 26.15 sec (704 interactions)
  savedInteractions <- saveAcasEntities(interactionList, "itxcontainercontainers")
  interactions$itxContainerContainerID <- sapply(savedInteractions, getElement, "id")
  interactions$stateID <- 1:nrow(interactions)
  
  dateRows <- data.frame(valueType = "dateValue", valueKind = "date transferred", dateValue = interactions$dateTransferred, itxContainerContainerID = interactions$itxContainerContainerID, stringsAsFactors=FALSE)
  amountRows <- data.frame(valueType = "numericValue", valueKind = "amount transferred", numericValue = interactions$volumeTransferred, itxContainerContainerID = interactions$itxContainerContainerID, stringsAsFactors=FALSE)
  protocolRows <- data.frame(valueType = "stringValue", valueKind = "protocol", stringValue = interactions$protocol, itxContainerContainerID = interactions$itxContainerContainerID, stringsAsFactors=FALSE)
  sourceFileRow <- data.frame(valueType = "fileValue", valueKind = "source file", fileValue = newFileName, itxContainerContainerID = interactions$itxContainerContainerID, stringsAsFactors=FALSE)
  interactiondf <- rbind.fill(dateRows, amountRows, protocolRows, sourceFileRow)
  interactiondf$stateGroupIndex <- 1
  stateGroups <- list(list(entityKind="itxcontainercontainer",
                           stateType="data",
                           stateKind="transfer data",
                           valueKinds=c("date transferred", "amount transferred", "protocol", "source file"),
                           includesOthers=TRUE))
  
  # 8 seconds (704 interactions)
  stateIdAndVersion <- saveStatesFromLongFormat(interactiondf, "itxcontainercontainer", stateGroups, idColumn="itxContainerContainerID", recordedBy, lsTransaction)
  
  interactiondf$stateID <- stateIdAndVersion$entityStateId
  interactiondf$stateVersion <- stateIdAndVersion$entityStateVersion
  
  interactiondf$operatorType <- NA
  # TODO: get the correct unit
  interactiondf$unitType <- "volume"
  interactiondf$publicData <- TRUE
  
  # 22.5 seconds (2816 values)
  savedValues <- saveValuesFromLongFormat(interactiondf, "itxcontainercontainer", stateGroupIndices = 1, lsTransaction=lsTransaction, recordedBy = recordedBy)
  
  summaryInfo$info <- c(summaryInfo$info,
                        "New Plates" = length(newBarcodeList),
                        "Source Plates" = length(unique(logFile$Source.Barcode)),
                        "Destination Plates" = length(unique(logFile$Destination.Barcode)))
  return(summaryInfo)
  
}
transferCompounds <- function(containerTable, logFile) {
  library('data.table')
  library('plyr')
  
  # Preallocate the interactions table
  repeats <- nrow(logFile)
  interactions <- data.table(
    interactionType = rep("", repeats),
    interactionKind = rep("", repeats),
    firstContainer = rep(0, repeats),
    secondContainer = rep(0, repeats),
    dateTransferred = rep(as.POSIXct(Sys.time()), repeats),
    volumeTransferred = rep(0, repeats),
    transferUnit = rep("", repeats),
    protocol = rep("", repeats)
  )
  # This is a bit slow... 9.5 seconds for 700 rows
  for (i in 1:repeats) {
    logRow <- logFile[i, ]
    
    sourceTable <- containerTable[logRow$Source.Id == containerTable$WELL_ID, ]
    destinationTable <- containerTable[logRow$Destination.Id == containerTable$WELL_ID, ]
    ##################
    # Remove from source
    if (sourceTable$VOLUME_UNIT[1] != logRow$Amount.Units[1]) {
      logRow$Amount.Transferred <- convertVolumes(logRow$Amount.Transferred, logRow$Amount.Units[1], sourceTable$VOLUME_UNIT[1])
      logRow$Amount.Units <- sourceTable$VOLUME_UNIT[1]
    }
    newSourceSet <- sourceTable
    newSourceSet$VOLUME <- sourceTable$VOLUME[1] - logRow$Amount.Transferred
    if (newSourceSet$VOLUME[1] < 0) {
      stop(paste0("More liquid was removed from well ", sourceTable$WELL_ID, " (", sourceTable$WELL_NAME, ") than was available."))
    } else if (newSourceSet$VOLUME[1] == 0) {
      newSourceSet <- data.frame()
    }
    ##################
    # Add to destination
    destinationVolume <- sum(destinationTable$VOLUME[1], logRow$Amount.Transferred, na.rm=TRUE)
    destinationWellId <- logRow$Destination.Id
    sourceTable$VOLUME <- logRow$Amount.Transferred
    combinedSet <- rbind.fill(sourceTable, destinationTable)
    buildResultRows <- function(setFrame, destinationWellId, destinationVolume) {
      return(data.frame(
        WELL_ID = destinationWellId, 
        BATCH_CODE = setFrame$BATCH_CODE[1], 
        VOLUME = destinationVolume, 
        VOLUME_UNIT = setFrame$VOLUME_UNIT[1], 
        CONCENTRATION = sum(setFrame$CONCENTRATION*setFrame$VOLUME, na.rm = TRUE)/destinationVolume,
        CONCENTRATION_UNIT = setFrame$CONCENTRATION_UNIT[1],
        stringsAsFactors=FALSE))
    }
    newDestinationSet <- ddply(combinedSet, ~BATCH_CODE, buildResultRows, destinationWellId, destinationVolume)
    newDestinationSet$dateChanged <- logRow$Date.Time
    
    # Remove old rows
    containerTable <- containerTable[!(containerTable$WELL_ID %in% c(logRow$Destination.Id, logRow$Source.Id)), ]
    # Add new ones
    containerTable <- rbind.fill(containerTable, newSourceSet, newDestinationSet)
    
    newInteraction <- data.table(
      interactionType = "transferred to",
      interactionKind = "content transfer",
      firstContainer = logRow$Source.Id,
      secondContainer = logRow$Destination.Id,
      dateTransferred = logRow$Date.Time,
      volumeTransferred = logRow$Amount.Transferred,
      transferUnit = logRow$Amount.Units,
      protocol = logRow$Protocol
    )
    interactions[i, names(interactions):=newInteraction]
  }
  interactions <- as.data.frame(interactions)
  return(list(containerTable = containerTable, interactions=interactions))
}
createPlateWellInteraction <- function(wellId, plateId, interactionCodeName, lsTransaction, recordedBy) {
  return(createContainerContainerInteraction(
    lsType= "has member",
    lsKind= "plate well",
    codeName= interactionCodeName,
    recordedBy= recordedBy,
    lsTransaction= lsTransaction,
    firstContainer= list(id=plateId, version=0),
    secondContainer= list(id=wellId, version=0)
  ))
}
saveNewWells <- function(newBarcodeList, logFile, lsTransaction, recordedBy, logFilePath) {
  # Saves new wells and their interactions with plates
  require(plyr)
  
  
  
  savedNewPlates <- registerNewPlates(newBarcodeList, lsTransaction=lsTransaction, recordedBy=recordedBy, sourceFile=logFilePath)
  
  # Now these are included in the new query- might change that
  #newPlateIdTranslation <- data.frame(barcode=newBarcodeList, plateId=sapply(savedNewPlates,getId))
  oldPlates <- unique(c(logFile$Destination.Barcode, logFile$Source.Barcode))
  
  oldPlates <- lapply(oldPlates, function(x) {list(labelText=x)})
  
  response <- getURL(
    paste(racas::applicationSettings$client.service.persistence.fullpath, "containers/findByLabels/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(oldPlates))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to find the containers by barcodes. Instead, it got this response:", response))
  }  
  
  plateIdTranslation <- ldply(fromJSON(response), function(x) {data.frame(barcode=x$lsLabels[[1]]$labelText, plateId=x$id)})
  
  newWellInformation <- unique(logFile[logFile$Destination.Id < 0, c('Destination.Barcode', 'Destination.Well', 'Destination.Id')])
  newPlateIds <- plateIdTranslation$plateId[match(newWellInformation$Destination.Barcode, plateIdTranslation$barcode)]
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
        lsType= "well", lsKind= "plate well",
        containerLabels=list(createContainerLabel(
          lsType="name", lsKind="well name", labelText=labelText, recordedBy=recordedBy, lsTransaction=lsTransaction)))
    }
    wellList <- mlply(.data= newWells, .fun = createLocalContainer,
                      lsTransaction=lsTransaction, recordedBy=recordedBy)
    names(wellList) <- NULL
    
    # 5.66 seconds maybe a problem later?
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
    
    # 25.68 seconds
    savedContainerContainerInteractions <- saveContainerContainerInteractions(interactions)
    
  }
  
  unchangedIds <- c(logFile$Destination.Id[logFile$Destination.Id > 0], logFile$Source.Id[logFile$Source.Id > 0])
  wellTranslation <- data.frame(oldWellId = c(newWells$containerId, unchangedIds), newWellId = c(newWells$wellId, unchangedIds))
  
  return(wellTranslation)
}
registerNewPlates <- function(barcodes, lsTransaction, recordedBy, sourceFile) {
  if (length(barcodes) < 1) return(list())
  plateCodeNameList <- getAutoLabels(thingTypeAndKind="material_container",
                                     labelTypeAndKind="id_codeName", 
                                     numberOfLabels=length(barcodes))
  plates <- mapply(barcodes, plateCodeNameList, FUN = createPlateWithBarcode, MoreArgs = list(lsTransaction=lsTransaction, recordedBy=recordedBy, sourceFile=sourceFile), USE.NAMES=FALSE)
  plateList <- apply(plates,MARGIN=2,as.list)
  
  savedPlates <- saveContainers(plateList)
  
  return(savedPlates)
}
createPlateWithBarcode <- function(barcode, codeName, lsTransaction, recordedBy, sourceFile) {
  return(createContainer(
    codeName = codeName[[1]],
    lsType = "plate", 
    lsKind = "384 well compound plate", 
    recordedBy = recordedBy,
    lsTransaction = lsTransaction,
    containerLabels = list(createContainerLabel(
      labelText = barcode,
      recordedBy = recordedBy,
      lsType = "barcode",
      lsKind = "plate barcode",
      lsTransaction = lsTransaction)),
    containerStates = list(createContainerState(
      lsType="constants",
      lsKind="plate format",
      recordedBy=recordedBy,
      lsTransaction=lsTransaction,
      containerValues= list(
        createStateValue(
          lsType="numericValue",
          lsKind="rows",
          numericValue=16,
          lsTransaction=lsTransaction),
        createStateValue(
          lsType="numericValue",
          lsKind="columns",
          numericValue=24,
          lsTransaction=lsTransaction),
        createStateValue(
          lsType="numericValue",
          lsKind="wells",
          numericValue=384,
          lsTransaction=lsTransaction)
      )
    ), createContainerState(
      lsType="metadata",
      lsKind="plate information",
      recordedBy=recordedBy,
      lsTransaction=lsTransaction,
      containerValues= list(
        createStateValue(
          lsType="fileValue",
          lsKind="source file",
          fileValue=sourceFile,
          lsTransaction=lsTransaction,
          recordedBy= recordedBy))
    ))
  ))
}
getCompoundPlateInfo <- function(barcodeList, testMode = FALSE) {
  barcodeQuery <- paste(barcodeList,collapse="','")
  
  if (testMode) {
    fakeAPI <- read.csv("public/src/modules/PrimaryScreen/spec/api_container_export2.csv", stringsAsFactors=F)
    wellTable <- fakeAPI
  } else {
    wellTable <- query(paste0("SELECT * FROM api_container_contents WHERE barcode IN ('", barcodeQuery, "')"))
  }
  names(wellTable) <- toupper(names(wellTable))
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
  # Get the containers
  idVector <- unique(idVector)
  idList <- lapply(idVector, function(x) list(id=x))
  
  response <- getURL(
    paste0(racas::applicationSettings$client.service.persistence.fullpath, "containerstates/findValidContainerStates/jsonArray"),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(idList))
  if (grepl("^<",response)) {
    stop("Server failed to respond to requests for valid container states")
  }
  containerStates <- fromJSON(response)
  
  # Ignore containerStates
  # Remove values and states that are already ignored
  alreadyIgnoredStates <- vapply(containerStates, function(x) {x$ignored}, c(TRUE))
  testCompoundStates <- vapply(containerStates, function(x) {x$lsKind=="test compound content"}, c(TRUE))
  containerStatesSimplified <- lapply(containerStates, function(x) {x$lsValues <- NULL; x$ignored <- TRUE; return(x)})
  containerStatesSimplified <- containerStatesSimplified[testCompoundStates & !alreadyIgnoredStates]
  
  # Ignore containerStates
  #52.6 sec (700 rows)
  ignoreContainerStates <- function(entities, acasCategory= "containerstates", lsServerURL = racas::applicationSettings$client.service.persistence.fullpath) {
    response <- getURL(
      paste(lsServerURL, acasCategory, "/ignore/jsonArray", sep=""),
      customrequest='PUT',
      httpheader=c('Content-Type'='application/json'),
      postfields=toJSON(entities))
    if (grepl("^<",response)) {
      stop(paste0("The loader was unable to ignore your ", acasCategory, ". Instead, it got this response: ", response))
    }
  }
  
  ignoreContainerStates(containerStatesSimplified)
}
convertVolumes <- function (x, from, to) {
  if (from=="nL" && to=="uL") {
    return(x/1000)
  } else if (from=="uL" && to=="nL") {
    return(x*1000)
  } else if (from==to) {
    return(x)
  } else {
    stop(paste("Units not understood: Cannot convert from", from, "to", to))
  }
}
bulkLoadSampleTransfers <- function(request) {
  # The top level function
  require(racas)
  options("scipen"=15)
  # Collect the information from the request
  request <- as.list(request)
  fileName <- request$fileToParse
  dryRun <- request$dryRun
  recordedBy <- request$user
  testMode <- request$testMode
  
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  testMode <- interpretJSONBoolean(testMode)
  if(is.null(testMode)) {
    testMode <- FALSE
  }
  
  developmentMode <- FALSE
  # Run the main function with error handling
  loadResult <- tryCatch.W.E(runMain(fileName,dryRun, testMode, developmentMode, recordedBy))
  
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
