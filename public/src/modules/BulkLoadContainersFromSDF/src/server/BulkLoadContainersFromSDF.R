# BulkLoadcontainersFromSDF.R
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
# Question: Will there be multiple plates in one SDF file? Will all the plates be new?

# How to run:
#   Before running: 
#     Set your working directory to the checkout of SeuratAddOns
#     setwd("~/Documents/clients/Wellspring/SeuratAddOns/")
#   To run: 
#     bulkLoadContainersFromSDF(list(fileName,dryRun,user))
#   Example:
#     bulkLoadContainersFromSDF(request=list(fileToParse="public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/IFF_Mock data_Confirmation_Update.sdf", dryRun= "true",user="smeyer"))
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

source("public/src/modules/serverAPI/src/server/labSynch_JSON_library.R")
source("public/src/modules/sharedFunctions.R")

runMain <- function(fileName,dryRun=TRUE,recordedBy,configList) {
  require('rcdk')
  require('plyr')
  
  # fileName <- "public/src/modules/BulkLoadContainersFromSDF/spec/specFiles/IFF_Mock data_Confirmation_Update.sdf"
  
  if (!grepl("\\.sdf$",fileName)) {
    stop("The input file must have extension .sdf")
  }
  
  tryCatch({
    moleculeList <- load.molecules(molfiles=fileName)
  }, error = function(e) {
    stop(paste("Error in loading the file:",e))
  })
  
  requiredProperties <- c("ALIQUOT_PLATE_BARCODE","ALIQUOT_WELL_ID","SAMPLE_ID","ALIQUOT_SOLVENT","ALIQUOT_CONC","ALIQUOT_CONC_UNIT",
                          "ALIQUOT_VOLUME","ALIQUOT_VOLUME_UNIT","ALIQUOT_DATE")
  
  availableProperties <- names(get.properties(moleculeList[[1]]))
  
  differences <- setdiff(requiredProperties,availableProperties)
  
  if(length(differences)>0) {
    stop(paste("Your file is missing:",paste(differences, sep = ", ")))
  }
  
  # TODO: if the compound already exists, give a warning before loading
  
  summaryInfo <- list(
    info = list(
      "Number of wells to load" = length(moleculeList),
      "User name" = recordedBy
    ))
  
  if (!dryRun) {
    propertyTable <- as.data.frame(lapply(requiredProperties,function(property) sapply(moleculeList,get.property,key=property)))
    names(propertyTable) <- requiredProperties
    
    sampleIdTranslationList <- query("select compound_name, property_value from compound_properties where property_name = 'SAMPLE_ID'",
                                     configList)
    
    # Only lot 1 is loaded using this loader
    sampleIdTranslationList$COMPOUND_NAME <- paste0(sampleIdTranslationList$COMPOUND_NAME,"-1")
    
    propertyTable$batchName <- sampleIdTranslationList$COMPOUND_NAME[match(propertyTable$"SAMPLE_ID", sampleIdTranslationList$PROPERTY_VALUE)]
    
    if (any(is.na(propertyTable$batchName))) {
      missingCompounds <- propertyTable$"SAMPLE_ID"[!(propertyTable$"SAMPLE_ID" %in% sampleIdTranslationList$PROPERTY_VALUE)]
      stop(paste0("Could not find compounds: ", paste(missingCompounds, collapse = ', '), ". Make sure that all compounds have already been loaded into Seurat and you are not using a new lot."))
    }
    
    # Save plate
    lsTransaction <- createLsTransaction(comments="Bulk load from .sdf file")
    
    barcodes <- levels(propertyTable$ALIQUOT_PLATE_BARCODE)
    plateCodeNameList <- getAutoLabels(thingTypeAndKind="material_container",
                                      labelTypeAndKind="id_codeName", 
                                      numberOfLabels=length(barcodes))
    plates <- mapply(barcodes, plateCodeNameList, FUN = createPlateWithBarcode, MoreArgs = list(lsTransaction=lsTransaction, recordedBy=recordedBy), USE.NAMES=FALSE)
    plateList <- apply(plates,MARGIN=2,as.list)
    
    savedPlates <- saveContainers(plateList)
    
    plateIds <- data.frame(barcode=barcodes, plateId=sapply(savedPlates,getId))
    
    propertyTable$plateId <- plateIds$plateId[match(propertyTable$ALIQUOT_PLATE_BARCODE,plateIds$barcode)]
    
    # Save wells
    propertyTable$wellCodeName <- unlist(getAutoLabels(thingTypeAndKind="material_container",
                                                       labelTypeAndKind="id_codeName", 
                                                       numberOfLabels=length(moleculeList)), 
                                         use.names = FALSE)
    

    
    # Combines the well information with the code names
    wellList <- dlply(.data= propertyTable, .variables=.(wellCodeName), .fun = createWellFromSDFtable,
                    lsTransaction=lsTransaction, recordedBy=recordedBy)
    names(wellList) <- NULL
    
    savedWells <- saveContainers(wellList)
    
    propertyTable$wellId <- sapply(savedWells, getId)
    
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
    
    summaryInfo$lsTransactionId <- lsTransaction$id
  }
  return(summaryInfo)
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
createWellFromSDFtable <- function(propertyTable, lsTransaction, recordedBy) {
  return(createContainer(
    containerType= "well", 
    containerKind= "plate well",
    codeName= propertyTable$wellCodeName,
    recordedBy= recordedBy,
    lsTransaction= lsTransaction,
    containerLabels= list(createContainerLabel(
      labelText= propertyTable$"ALIQUOT_WELL_ID",
      recordedBy= recordedBy,
      labelType= "name",
      labelKind= "well name",
      lsTransaction= lsTransaction)),
    containerStates= list(
      createContainerState(
        stateType= "status",
        stateKind= "test compound content",
        recordedBy= recordedBy,
        lsTransaction= lsTransaction,
        containerValues= list(
          createStateValue(
            valueType= "codeValue",
            valueKind= "batch code",
            codeValue= propertyTable$batchName,
            lsTransaction= lsTransaction),
          createStateValue(
            valueType= "numericValue",
            valueKind= "concentration",
            numericValue= propertyTable$"ALIQUOT_CONC",
            valueUnit= propertyTable$"ALIQUOT_CONC_UNIT",
            lsTransaction= lsTransaction),
          createStateValue(
            valueType= "numericValue",
            valueKind= "volume",
            numericValue= propertyTable$"ALIQUOT_VOLUME",
            valueUnit= propertyTable$"ALIQUOT_VOLUME_UNIT",
            lsTransaction= lsTransaction),
          createStateValue(
            valueType= "dateValue",
            valueKind= "date prepared",
            dateValue= as.numeric(format(as.Date(propertyTable$ALIQUOT_DATE,format="%d-%b-%y"),"%s"))*1000,
            lsTransaction= lsTransaction)
        )
      ),
      createContainerState(
        stateType= "status",
        stateKind= "solvent content",
        recordedBy= recordedBy,
        lsTransaction= lsTransaction,
        containerValues= list(
          createStateValue(
            valueType= "stringValue",
            valueKind= "solvent",
            stringValue= propertyTable$"ALIQUOT_SOLVENT"[1],
            lsTransaction= lsTransaction)
        )
      )
    )
  ))
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

bulkLoadContainersFromSDF <- function(request) {
  
  # Collect the information from the request
  request <- as.list(request)
  fileName <- request$fileToParse
  dryRun <- request$dryRun
  recordedBy <- request$user
  
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  
  configList <- readConfigFile("public/src/conf/configuration.js")
  
  # Set the global for the JSON library
  lsServerURL <<- configList$serverPath
  
  # Run the main function with error handling
  loadResult <- tryCatch.W.E(runMain(fileName,dryRun,recordedBy,configList))
  
  # If the output has class simpleError, save it as an error
  errorList <- list()
  if(class(loadResult$value)[1]=="simpleError") {
    errorList <- list(loadResult$value$message)
    loadResult$errorList <- errorList
    loadResult$value <- NULL
  }
  
  # Save warning messages (but not the function call, as it is only useful while programming)
  loadResult$warningList <- lapply(loadResult$warningList,getWarningMessage)
  if (length(loadResult$warningList)>0) {
    loadResult$warningList <- strsplit(unlist(loadResult$warningList),"\n")
  }
    
  # Organize the error outputs
  loadResult$errorList <- errorList
  hasError <- length(errorList) > 0
  hasWarning <- length(loadResult$warningList) > 0
  
  htmlSummary <- createHTML(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value,dryRun)
  
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

