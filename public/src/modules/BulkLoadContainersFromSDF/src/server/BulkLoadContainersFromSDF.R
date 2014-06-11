# BulkLoadContainersFromSDF.R
#
#
# Sam Meyer
# sam@mcneilco.com
# Copyright 2012 John McNeil & Co. Inc.
#########################################################################
# Parses a structure data file and uploads it to ACAS
#########################################################################


# TODO: Check if the information has already been uploaded
# TODO: Save status, as this will take a long time with 30 plates
# TODO: validate corporate batch ids

# How to run:
#   Before running: 
#   file.copy("public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/Shipment_9814_with_DMSO.csv", "privateUploads/", overwrite=T)
#   To run: 
#     bulkLoadContainersFromSDF(list(fileName,dryRun,user))
#   Example:
#     bulkLoadContainersFromSDF(request=list(fileToParse="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/Shipment_8242_Update_cutoff.sdf", dryRun= "true",user="smeyer"))
#     bulkLoadContainersFromSDF(request=list(fileToParse="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/control_cmpds.sdf", dryRun= "true",user="smeyer"))
#     runMain(fileName="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/IFF_Mock data_Confirmation_Update.sdf", dryRun= TRUE,recordedBy="smeyer")

# Random notes on container and interaction creation:
# yellowContainer <- createContainer(kind = "No, yellow!")
# saveContainer(yellowContainer)
# yellowContainer <- fromJSON(getURL("http://host3.labsynch.com:8080/acas/containers/219"))
# blueContainer <- fromJSON(getURL("http://host3.labsynch.com:8080/acas/containers/11"))
# createContainerContainerInteraction(kind="Monty Python",interactionType="refers to",interactionKind="favorite color",firstContainer=yellowContainer,secondContainer=blueContainer)
# itx2 <- createContainerContainerInteraction(kind="Monty Python",interactionType="refers to",interactionKind="favorite color",firstContainer=yellowContainer,secondContainer=blueContainer,interactionStates=createContainerContainerItxState())
# scitx <- createSubjectContainerInteraction(interactionType="refers to",interactionKind="unrelated",subject =subject, container = yellowContainer)

# Seurat loading notes
# 10:39 PM - loaded 70 records from file
# 10:52 PM -loaded 140 records from file
# 7:33 AM   - loaded 4500 records from file
# Stopped for transport

runMain <- function(fileName,dryRun=TRUE,recordedBy) {
  library('rcdk')
  library('plyr')
  library('iterators')
  
  fileName <- getUploadedFilePath(fileName)
  
  testMode <- FALSE
  
  # fileName <- "public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/IFF_Mock data_Confirmation_Update.sdf"
  
  if (!grepl("\\.sdf$|\\.csv$",fileName)) {
    stop("The input file must have extension .sdf or .csv")
  }
  
  tryCatch({
    if (grepl("\\.sdf$",fileName)) {
      moleculeList <- iload.molecules(fileName, type="sdf")
      firstMolecule <- nextElem(moleculeList)
    } else if (grepl("\\.csv$",fileName)) {
      moleculeList <- read.csv(fileName, blank.lines.skip=TRUE)
    }
  }, error = function(e) {
    stop(paste("Error in loading the file:",e))
  })
  
  if (grepl("\\.sdf$",fileName)) {
    fileLines <- readLines(fileName)
    compoundNumber <- sum(fileLines == "$$$$")
    availableProperties <- names(get.properties(firstMolecule))
  } else if (grepl("\\.csv$",fileName)) {
    fileLines <- read.csv(fileName, blank.lines.skip=TRUE, check.names=F, stringsAsFactors=F)
    compoundNumber <- nrow(fileLines)
    availableProperties <- colnames(fileLines)
  }
  
  requiredProperties <- c("ALIQUOT_PLATE_BARCODE","ALIQUOT_WELL_ID","SAMPLE_ID","ALIQUOT_SOLVENT","ALIQUOT_CONC","ALIQUOT_CONC_UNIT",
                          "ALIQUOT_VOLUME","ALIQUOT_VOLUME_UNIT","ALIQUOT_DATE")
  
  differences <- setdiff(requiredProperties,availableProperties)
  
  if(length(differences)>0) {
    stop(paste("Your file is missing:",paste(differences, sep = ", ")))
  }
  
  # TODO: if the compound already exists, give a warning before loading
  
  summaryInfo <- list(
    info = list(
      "User name" = recordedBy,
      "Number of wells to load" = compoundNumber
    ))
  
  if (!dryRun) {
    if (grepl("\\.sdf$",fileName)) {
      propertyTable <- as.data.frame(lapply(requiredProperties, function(property) get.property(firstMolecule, key=property)))
      names(propertyTable) <- requiredProperties
      while(hasNext(moleculeList)) {
        mol <- nextElem(moleculeList)
        newPropertyTable <- as.data.frame(lapply(requiredProperties, function(property) get.property(mol, key=property)))
        names(newPropertyTable) <- requiredProperties
        propertyTable <- rbind.fill(propertyTable, newPropertyTable)
      }
    } else if (grepl("\\.csv$",fileName)) {
      propertyTable <- as.data.frame(subset(fileLines, select= c(requiredProperties, "Corporate Batch ID")))
    }
    
    summaryInfo$info$"Number of wells loaded" <- nrow(propertyTable)
    
    if (racas::applicationSettings$client.service.external.preferred.batchid.type == "SeuratCmpdReg") {
      sampleIdTranslationList <- query("select ss.alias_id || '-' || scl.lot_id as \"COMPOUND_NAME\", data1 as \"PROPERTY_VALUE\" from seurat.syn_sample ss join seurat.syn_compound_lot scl on ss.sample_id=scl.sample_id")
      propertyTable$batchName <- sampleIdTranslationList$COMPOUND_NAME[match(propertyTable$"SAMPLE_ID", sampleIdTranslationList$PROPERTY_VALUE)]
    } else {
      propertyTable$batchName <- NA
    }
    
    propertyTable$batchName[!is.na(propertyTable$"Corporate Batch ID")] <- propertyTable$"Corporate Batch ID"[!is.na(propertyTable$"Corporate Batch ID")]
    
    if (any(is.na(propertyTable$batchName))) {
      missingCompounds <- propertyTable$"SAMPLE_ID"[!(propertyTable$"SAMPLE_ID" %in% sampleIdTranslationList$PROPERTY_VALUE)]
      if(testMode) {
        propertyTable <- propertyTable[!is.na(propertyTable$batchName), ]
      } else {
        stop(paste0("Could not find compounds: ", paste(missingCompounds, collapse = ', '), ". Make sure that all compounds have already been loaded into Seurat and you are not using a new lot."))
      }
    }
    
    propertyTable$ALIQUOT_CONC <- as.numeric(propertyTable$ALIQUOT_CONC)
    propertyTable$ALIQUOT_VOLUME <- as.numeric(propertyTable$ALIQUOT_VOLUME)
    
    if (any(is.na(c(propertyTable$ALIQUOT_CONC, propertyTable$ALIQUOT_VOLUME)))) {
      stop("Some of the concentrations or volumes are not numbers")
    }
    
    # Convert 'mM' to 'uM'
    propertyTable$ALIQUOT_CONC[propertyTable$ALIQUOT_CONC_UNIT == "mM"] <- propertyTable$ALIQUOT_CONC[propertyTable$ALIQUOT_CONC_UNIT == "mM"] * 1000
    propertyTable$ALIQUOT_CONC_UNIT[propertyTable$ALIQUOT_CONC_UNIT == "mM"] <- "uM"
    
    if (any(propertyTable$ALIQUOT_CONC_UNIT != "uM")) {
    	stop("All concentration units must be uM or mM")
    }
    
    # Save plate
    if(!file.exists(racas::getUploadedFilePath("uploadedPlates"))) {
      dir.create(racas::getUploadedFilePath("uploadedPlates"))
    }
    newFileName <- paste0("uploadedPlates/", basename(fileName))
    
    if(!file.exists(fileName)) {
      stop(paste("Missing file", fileName))
    }
    file.rename(fileName, paste0(racas::getUploadedFilePath(newFileName)))
    
    lsTransaction <- createLsTransaction(comments="Bulk load from .sdf file")$id
    
    barcodes <- unique(propertyTable$ALIQUOT_PLATE_BARCODE)
    plateCodeNameList <- getAutoLabels(thingTypeAndKind="material_container",
                                      labelTypeAndKind="id_codeName", 
                                      numberOfLabels=length(barcodes))
    plates <- mapply(barcodes, plateCodeNameList, FUN = createPlateWithBarcode, MoreArgs = list(lsTransaction=lsTransaction, recordedBy=recordedBy, sourceFile=newFileName), USE.NAMES=FALSE)
    plateList <- apply(plates,MARGIN=2,as.list)
    
    savedPlates <- saveContainers(plateList)
    
    plateIds <- data.frame(barcode=barcodes, plateId=sapply(savedPlates,getElement, "id"))
    
    propertyTable$plateId <- plateIds$plateId[match(propertyTable$ALIQUOT_PLATE_BARCODE,plateIds$barcode)]
    
    # Save wells
    propertyTable$wellCodeName <- unlist(getAutoLabels(thingTypeAndKind="material_container",
                                                       labelTypeAndKind="id_codeName", 
                                                       numberOfLabels=nrow(propertyTable)), 
                                         use.names = FALSE)
    

    
    # Combines the well information with the code names
    wellList <- dlply(.data= propertyTable, .variables=.(wellCodeName), .fun = createWellFromSDFtable,
                    lsTransaction=lsTransaction, recordedBy=recordedBy)
    names(wellList) <- NULL
    
    savedWells <- saveContainers(wellList)
    
    propertyTable$wellId <- sapply(savedWells, getElement, "id")
    
    # Save interactions
    propertyTable$interactionCodeName <- unlist(getAutoLabels(thingTypeAndKind="interaction_containerContainer",
                                                              labelTypeAndKind="id_codeName", 
                                                              numberOfLabels=nrow(propertyTable)),
                                                use.names = FALSE)
    
    interactionData <- propertyTable[,c("wellId", "plateId", "interactionCodeName")]
    
    interactions <- mlply(.data=interactionData, .fun = createPlateWellInteraction,
                           lsTransaction=lsTransaction, recordedBy=recordedBy)
    names(interactions) <- NULL
    
    savedContainerContainerInteractions <- saveContainerContainerInteractions(interactions)
    
    summaryInfo$lsTransactionId <- lsTransaction
  }
  return(summaryInfo)
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
          lsTransaction=lsTransaction,
          recordedBy= recordedBy),
        createStateValue(
          lsType="numericValue",
          lsKind="columns",
          numericValue=24,
          lsTransaction=lsTransaction,
          recordedBy= recordedBy),
        createStateValue(
          lsType="numericValue",
          lsKind="wells",
          numericValue=384,
          lsTransaction=lsTransaction,
          recordedBy= recordedBy)
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
createWellFromSDFtable <- function(propertyTable, lsTransaction, recordedBy) {
  return(createContainer(
    lsType= "well", 
    lsKind= "plate well",
    codeName= propertyTable$wellCodeName,
    recordedBy= recordedBy,
    lsTransaction= lsTransaction,
    containerLabels= list(createContainerLabel(
      labelText= propertyTable$"ALIQUOT_WELL_ID",
      recordedBy= recordedBy,
      lsType= "name",
      lsKind= "well name",
      lsTransaction= lsTransaction)),
    containerStates= list(
      createContainerState(
        lsType= "status",
        lsKind= "test compound content",
        recordedBy= recordedBy,
        lsTransaction= lsTransaction,
        containerValues= list(
          createStateValue(
            lsType= "codeValue",
            lsKind= "batch code",
            codeValue= propertyTable$batchName,
            lsTransaction= lsTransaction,
            recordedBy= recordedBy),
          createStateValue(
            lsType= "numericValue",
            lsKind= "concentration",
            stringValue= if (propertyTable$"ALIQUOT_CONC"==Inf) {"infinite"} else {NULL},
            numericValue= if (propertyTable$"ALIQUOT_CONC"==Inf) {NULL} else {propertyTable$"ALIQUOT_CONC"},
            valueUnit= propertyTable$"ALIQUOT_CONC_UNIT",
            lsTransaction= lsTransaction,
            recordedBy= recordedBy),
          createStateValue(
            lsType= "numericValue",
            lsKind= "volume",
            stringValue= if (propertyTable$"ALIQUOT_VOLUME"==Inf) {"infinite"} else {NULL},
            numericValue= if (propertyTable$"ALIQUOT_VOLUME"==Inf) {NULL} else {propertyTable$"ALIQUOT_VOLUME"},
            valueUnit= propertyTable$"ALIQUOT_VOLUME_UNIT",
            lsTransaction= lsTransaction,
            recordedBy= recordedBy),
          createStateValue(
            lsType= "dateValue",
            lsKind= "date prepared",
            dateValue= as.numeric(format(as.Date(propertyTable$ALIQUOT_DATE,format="%d-%b-%y"),"%s"))*1000,
            lsTransaction= lsTransaction,
            recordedBy= recordedBy)
        )
      ),
      createContainerState(
        lsType= "status",
        lsKind= "solvent content",
        recordedBy= recordedBy,
        lsTransaction= lsTransaction,
        containerValues= list(
          createStateValue(
            lsType= "stringValue",
            lsKind= "solvent",
            stringValue= propertyTable$"ALIQUOT_SOLVENT"[1],
            lsTransaction= lsTransaction,
            recordedBy= recordedBy)
        )
      )
    )
  ))
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

bulkLoadContainersFromSDF <- function(request) {
  library('racas')
  options(stringsAsFactors = FALSE)
  
  # Collect the information from the request
  request <- as.list(request)
  fileName <- request$fileToParse
  dryRun <- request$dryRun
  recordedBy <- request$user
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  
  # Run the main function with error handling
  loadResult <- tryCatch.W.E(runMain(fileName,dryRun,recordedBy))
  
  # If the output has class simpleError, save it as an error
  errorList <- list()
  if(class(loadResult$value)[1]=="simpleError") {
    errorList <- list(loadResult$value$message)
    loadResult$errorList <- errorList
    loadResult$value <- NULL
  }
  
  # Save warning messages (but not the function call, as it is only useful while programming)
  loadResult$warningList <- lapply(loadResult$warningList, getElement, "message")
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
  
  return( response) 
}

