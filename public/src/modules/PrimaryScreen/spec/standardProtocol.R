# Code to set up basic protocol

#     setwd("~/Documents/clients/Wellspring/SeuratAddOns/")
#source("public/src/modules/serverAPI/src/server/labSynch_JSON_library.R")
require(racas)
require(RCurl)
lsServerURL <- racas::applicationSettings$client.service.persistence.fullpath

## example of creating a protocol with discrete parts 

lsTransaction <- createLsTransaction(comments="primary analysis protocol transactions")$id
protocolStates <- list()  ## protocol may have many states
protocolLabels <- list()  ## protocol may have many lables

############################# BEGIN block of protocol meta data #######################
protocolValues <- list()

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "notebook",
                          stringValue = "NB 1234-123")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "target",
                          stringValue = "target A")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "assay format",
                          stringValue = "biochemical")

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction,
                          protocolValues=protocolValues, 
                          recordedBy="userName", 
                          lsType="metadata", 
                          lsKind="protocol metadata",
                          comments="")
#################################################################################################

############################# BEGIN block of experiment meta data #######################
protocolValues <- list()


protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction,
                          lsType = "clobValue",
                          lsKind = "data analysis parameters",
                          clobValue = '{  "positiveControl": {    "batchCode": "FL0073900-1-1",    "concentration": 10,    "conentrationUnits": "uM"  },  "negativeControl": {    "batchCode": "FL0073895-1-1",    "concentration": 1,    "concentrationUnits": "uM"  },  "agonistControl": {    "batchCode": "FL0073897-1-1",    "concentration": 49.5,    "concentrationUnits": "uM"  },  "vehicleControl": {    "batchCode": "CMPD-00000001-01",    "concentration": null,    "concentrationUnits": null  },  "transformationRule": "(maximum-minimum)/minimum",  "normalizationRule": "plate order",  "hitEfficacyThreshold": 42,  "hitSDThreshold": 5.0,  "thresholdType": "sd"}'
                          )

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction,
                          protocolValues=protocolValues,
                          recordedBy="userName",
                          lsType="metadata",
                          lsKind="experiment metadata",
                          comments="")
#################################################################################################


#############################  protocol labels #######################

protocolLabels[[length(protocolLabels)+1]] <- createProtocolLabel(lsTransaction = lsTransaction, 
													recordedBy="userName", 
													lsType="name", 
													lsKind="protocol name",
													labelText="FLIPR test old data",
													preferred=TRUE)

#################################################################################################

### Save the protocol object #########
protocol <- createProtocol(	lsTransaction = lsTransaction, 
							shortDescription="primary analysis",  
							recordedBy="username", 
							protocolLabels=protocolLabels,
							protocolStates=protocolStates,
							lsKind="flipr screening assay")

## to view protocol JSON before save 
#cat(toJSON(protocol))

protocolSaved <- saveProtocol(protocol)


## to view protocol JSON after save 
cat(toJSON(protocolSaved))

## to get full protocol object
## TODO: need to make server change to return all of the protocol info
fullProtocolObject <- fromJSON(getURL(paste(lsServerURL, "protocols/codename/", protocolSaved$codeName,sep="")))


