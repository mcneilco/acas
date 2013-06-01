# How to run:
#   Before running: 
#     Set your working directory to the checkout of SeuratAddOns
#     setwd("~/Documents/clients/Wellspring/SeuratAddOns/")
#
# Some example input, put into JSON (enters this code already as a list)
# {"docForBatches":{"id":1235,"docUpload":{"id":1234,"url":"","currentFileName":"/Users/smeyer/Documents/ACAS/serverOnlyModules/blueimp-file-upload-node/public/files/ExampleInputFormat_with_Curve.xls","description":"importantDocument","docType":"file","documentKind":"experiment"},"batchNameList":{"id":11,"requestName":"CMPD-0000123-01","preferredName":"CMPD-0000123-01","comment":"okay"},"user":"smeyer"},"user":"smeyer"}

runMain <- function(request) {
  require('rjson')
  require('RCurl')
  
  request <- translateRequestFromMessyJSON(request)
  
  # Set the global (within this environment) for the JSON library
  lsServerURL <<- racas::applicationSettings$serverPath
  
  validateRequest(request)
  
  lsTransaction <- createLsTransaction(comments = "docForBatches upload")
  
  # Get the protocol if it exists
  protocol <- fromJSON(getURL(paste0(lsServerURL, "/protocols/codename/ACASdocForBatches")))
  
  # Make the protocol if it does not exist
  if (length(protocol)==0) {
    protocol <- createDocForBatchesProtocol(request, lsTransaction)

  } else {
    protocol <- protocol[[1]]
  }
  
  experiment <- createDocForBatchesExperiment(request, lsTransaction, protocol)
  
  createDocForBatchesAnalysisGroups(request, lsTransaction, experiment)

  return(lsTransaction)
}

translateRequestFromMessyJSON <- function (request) {
  # Because the JSON that comes in translates to a weird combination of lists and vectors, this translates it to lists
  #
  # Args:
  #   request:    A string that contains JSON
  # Returns:
  #   A list that holds the same information as the JSON in a format easily read in R
  
  require('rjson')
  
  request <- as.list(request)
  if(class(request$docForBatches)=="character") {
    request$docForBatches <- fromJSON(request$docForBatches)
  }
  
  # Turn a vector into a list so selection can be done by name
  request$docForBatches$docUpload <- as.list(request$docForBatches$docUpload)
  
#   # Exists for use if we are not capturing the logged in user
#   if(is.null(request$user)) {
#     request$user <- "nosecurity"
#   }
  
  return(request)
}

validateRequest <- function(request) {
  # Checks that the request has the needed fields and that the batches have preferred names
  #
  # Args:
  #   request:    A list object containing the request
  # Returns:
  #   NULL
  docType <- request$docForBatches$docUpload$docType
  if (docType!="file"&&docType!="url") {
    stop("No valid annotation type given")
  }
  for (batchName in request$docForBatches$batchNameList) {
    if(as.list(batchName)$preferredName=="") {
      stop(paste("No preferred name was found for requested name:",as.list(batchName)$requestName))
    }
  }
}

createDocForBatchesProtocol <- function(request, lsTransaction) {
  # Creates the protocol used for all DocForBatches uploads
  #
  # Args:
  #   request:    A list containing the requested upload information
  # Returns:
  #   A list that is a protocol returned from the server
  
  # Add a label for the name
  protocolLabels <- list()
  protocolLabels[[length(protocolLabels)+1]] <- createProtocolLabel(lsTransaction = lsTransaction, 
                                                                    recordedBy=request$user, 
                                                                    labelType="name", 
                                                                    labelKind="protocol name",
                                                                    labelText="ACAS Doc For Batches",
                                                                    preferred=TRUE)
  
  # Create the protocol
  protocol <- createProtocol(lsTransaction = lsTransaction, 
                             codeName="ACASdocForBatches", 
                             shortDescription="ACAS Doc For Batches",  
                             recordedBy=request$user, 
                             protocolLabels=protocolLabels)
  protocol <- saveProtocol(protocol)
  return(protocol)
}
createDocForBatchesExperiment <- function(request, lsTransaction, protocol) {
  # Creates the experiment for a single upload
  #
  # Args:
  #   request:    A list containing the requested upload information
  #   protocol:   A list containing the protocol
  # Returns:
  #   A list that is an experiment returned from the server
  
  experimentCodeName <- getAutoLabels(thingTypeAndKind="document_experiment",
                                      labelTypeAndKind="id_codeName")
  
  # Create a label for the experiment name
  experimentLabels <- list()
  experimentLabels[[length(experimentLabels)+1]] <- createExperimentLabel(lsTransaction = lsTransaction, 
                                                                          recordedBy=request$user, 
                                                                          labelType="name", 
                                                                          labelKind="experiment name",
                                                                          labelText=experimentCodeName[[1]][[1]],
                                                                          preferred=TRUE)
  experiment <- createExperiment(lsTransaction = lsTransaction, 
                                 protocol = protocol,
                                 kind = "ACAS doc for batches",
                                 codeName=NULL, 
                                 shortDescription=request$docForBatches$docUpload$description,  
                                 recordedBy=if(is.null(request$user)) {"nosecurity"} else {request$user}, 
                                 experimentLabels=experimentLabels,
                                 experimentStates=list())
  
  experiment <- saveExperiment(experiment)
  return(experiment)
}
createDocForBatchesAnalysisGroups <- function(request, lsTransaction, experiment) {
  # Creates the set of analysis groups, one for each batchName
  #
  # Args:
  #   request:      A list containing the requested upload information
  #   experiment:   A list containing the experiment
  # Returns:
  #   NULL
  
  analysisGroupStates <- list()
  for (uploadSet in request$docForBatches$batchNameList) {
    
    uploadSet <- as.list(uploadSet)
    
    analysisGroupValues <- list()
    # File or url value
    analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
      valueType = if (request$docForBatches$docUpload$docType == "file") {
        "fileValue"
      } else if (request$docForBatches$docUpload$docType == "url") {
        "urlValue"
      } else {
        stop("No valid annotation type given (Should not have reached this point)")
      },
      valueKind = "annotation",
      fileValue = if (request$docForBatches$docUpload$docType == "file") {
        request$docForBatches$docUpload$currentFileName
      } else {NULL},
      urlValue = if (request$docForBatches$docUpload$docType == "url") {
        request$docForBatches$docUpload$url
      } else {NULL},
      comment = uploadSet$comment,
      lsTransaction=lsTransaction
    )
    analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
      valueType = "codeValue",
      valueKind = "batch code",
      codeValue = uploadSet$preferredName,
      lsTransaction = lsTransaction
    )
    analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue(
      valueType = "stringValue",
      valueKind = "document kind",
      stringValue = request$docForBatches$docUpload$documentKind,
      lsTransaction = lsTransaction
    )        
    
    analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
                                                                                      recordedBy=request$user,
                                                                                      stateType="results",
                                                                                      stateKind="Document for Batch",
                                                                                      analysisGroupValues=analysisGroupValues)
  }
  
  analysisGroups <- list(createAnalysisGroup(lsTransaction=lsTransaction,
                                             kind="ACAS doc for batches",
                                             recordedBy=request$user,
                                             analysisGroupStates=analysisGroupStates,
                                             experiment=experiment))
  
  response <- saveAnalysisGroups(analysisGroups)
  return(NULL)
}

getWarningMessage <- function (warn) {
  # This function takes in a warning and outputs only the message part
  return (warn$message)
}

saveDocForBatches <- function(request) {
  require(racas)
  
  # Run the main function with error handling
  loadResult <- tryCatch.W.E(runMain(request))
  
	# If the output has class simpleError, save it as an error
  lsTransaction <- NULL
  errorList <- list()
	if(class(loadResult$value)[1]=="simpleError") {
	  errorList <- list(loadResult$value$message)
	  loadResult$errorList <- errorList
	  loadResult$value <- NULL
	} else {
    lsTransaction <- loadResult$value
	}
	
	# Save warning messages but not the function call, which is only useful while programming
	loadResult$warningList <- lapply(loadResult$warningList,getWarningMessage)
	if (length(loadResult$warningList)>0) {
	  loadResult$warningList <- strsplit(unlist(loadResult$warningList),"\n")
	}
	
	# Organize the error outputs
	loadResult$errorList <- errorList
	hasError <- length(errorList) > 0
	hasWarning <- length(loadResult$warningList) > 0
	
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
	  transactionId= lsTransaction$id,
	  results= list(
	    id= lsTransaction$id
	  ),
	  error= hasError,
    #hasWarning = FALSE,
	  errorMessages= errorMessages
	)
  
	return( response)
  
  
}
