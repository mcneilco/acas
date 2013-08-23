# Code to set up basic protocol

#     setwd("~/Documents/clients/Wellspring/SeuratAddOns/")
#source("public/src/modules/serverAPI/src/server/labSynch_JSON_library.R")
require(racas)
require(RCurl)
lsServerURL <- racas::applicationSettings$serverPath

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

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "experiment status",
                          stringValue = "active")

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction, 
                          protocolValues=protocolValues, 
                          recordedBy="userName", 
                          lsType="metadata", 
                          lsKind="experiment metadata", 
                          comments="")
#################################################################################################
############################# BEGIN block of protocol experimental parameters - controls #######################
protocolValues <- list()
protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "control type",
                          stringValue = "positive control")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "codeValue",
                          lsKind = "batch code",
                          codeValue = "CRA-000399-1")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "tested concentration",
                          numericValue = 10,
                          valueUnit = "uM")

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction, 
                          protocolValues=protocolValues, 
                          recordedBy="userName", 
                          lsType="metadata", 
                          lsKind="experiment controls", 
                          comments="")                   
#################################################################################################
############################# BEGIN block of protocol experimental parameters - controls #######################
protocolValues <- list()
protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "control type",
                          stringValue = "negative control")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "codeValue",
                          lsKind = "batch code",
                          codeValue = "CRA-000396-1")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "tested concentration",
                          numericValue = 1,
                          valueUnit = "uM")

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction, 
                          protocolValues=protocolValues, 
                          recordedBy="userName", 
                          lsType="metadata", 
                          lsKind="experiment controls", 
                          comments="")                   
#################################################################################################
############################# BEGIN block of protocol experimental parameters - controls #######################
protocolValues <- list()
protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "control type",
                          stringValue = "vehicle control")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "codeValue",
                          lsKind = "batch code",
                          codeValue = "CMPD0000001-1")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "tested concentration",
                          numericValue = 0,
                          valueUnit = "uM")

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction, 
                          protocolValues=protocolValues, 
                          recordedBy="userName", 
                          lsType="metadata", 
                          lsKind="experiment controls", 
                          comments="")                   
#################################################################################################

############################# BEGIN block of protocol analysis parameters #######################
protocolValues <- list()
protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "reader instrument",
                          stringValue = "Molecular Dynamics FLIPR")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "data source",
                          stringValue = "FLIPR Min Max")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "data transformation rule",
                          stringValue = "(maximum-minimum)/minimum")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "stringValue",
                          lsKind = "normalization rule",
                          stringValue = "none")

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "active efficacy threshold",
                          numericValue = 0.7,
                          sigFigs = 1)

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "active SD threshold",
                          numericValue = -5,
                          sigFigs = 1)
                                                    
protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "curve min",
                          numericValue = 0,
                          sigFigs = 2)

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          lsType = "numericValue",
                          lsKind = "curve max",
                          numericValue = 100,
                          sigFigs = 2)

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                               lsType = "stringValue",
                                                               lsKind = "replicate aggregation",
                                                               stringValue = "no")

protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction, 
                          protocolValues=protocolValues, 
                          recordedBy="userName", 
                          lsType="metadata", 
                          lsKind="experiment analysis parameters", 
                          comments="")
#################################################################################################


#############################  protocol labels #######################

protocolLabels[[length(protocolLabels)+1]] <- createProtocolLabel(lsTransaction = lsTransaction, 
													recordedBy="userName", 
													lsType="name", 
													lsKind="protocol name",
													labelText="FLIPR target A biochemical",
													preferred=TRUE)

#################################################################################################

### Save the protocol object #########
protocol <- createProtocol(	lsTransaction = lsTransaction, 
							shortDescription="primary analysis",  
							recordedBy="username", 
							protocolLabels=protocolLabels,
							protocolStates=protocolStates)

## to view protocol JSON before save 
#cat(toJSON(protocol))

protocolSaved <- saveProtocol(protocol)


## to view protocol JSON after save 
cat(toJSON(protocolSaved))

## to get full protocol object
## TODO: need to make server change to return all of the protocol info
fullProtocolObject <- fromJSON(getURL(paste(lsServerURL, "protocols/codename/", protocolSaved$codeName,sep="")))


