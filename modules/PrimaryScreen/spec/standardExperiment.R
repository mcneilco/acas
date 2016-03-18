# Code to set up basic experiment OLD
require(RCurl)
require(rjson)
require(racas)
lsServerURL <- racas::applicationSettings$serverPath


## example of creating a experiment with discrete parts 

lsTransaction <- createLsTransaction(comments="primary analysis experiment transactions")
experimentStates <- list()  ## experiment may have many states
experimentLabels <- list()  ## experiment may have many lables

############################# BEGIN block of experiment meta data #######################
experimentValues <- list()

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "notebook",
                          stringValue = "NB 1234-123")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "target",
                          stringValue = "target A")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "assay format",
                          stringValue = "biochemical")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "experiment status",
                          stringValue = "active")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                           valueType = "stringValue",
                           valueKind = "analysis status",
                           stringValue = "not started")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                           valueType = "clobValue",
                           valueKind = "analysis result html",
                           stringValue = "<p>not started</p>")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                           valueType = "dateValue",
                           valueKind = "completion date",
                           dateValue = as.numeric(format(Sys.time(), "%s"))*1000)

experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                          experimentValues=experimentValues, 
                          recordedBy="userName", 
                          stateType="metadata", 
                          stateKind="experiment metadata", 
                          comments="")
#################################################################################################
############################# BEGIN block of experiment experimental parameters - controls #######################
experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "control type",
                          stringValue = "positive control")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "codeValue",
                          valueKind = "batch code",
                          codeValue = "CRA-000399:1")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "tested concentration",
                          numericValue = 10,
                          valueUnit = "uM")

experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                          experimentValues=experimentValues, 
                          recordedBy="userName", 
                          stateType="metadata", 
                          stateKind="experiment controls", 
                          comments="")                   
#################################################################################################
############################# BEGIN block of experiment experimental parameters - controls #######################
experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "control type",
                          stringValue = "negative control")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "codeValue",
                          valueKind = "batch code",
                          codeValue = "CRA-000396:1")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "tested concentration",
                          numericValue = 1,
                          valueUnit = "uM")

experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                          experimentValues=experimentValues, 
                          recordedBy="userName", 
                          stateType="metadata", 
                          stateKind="experiment controls", 
                          comments="")                   
#################################################################################################
############################# BEGIN block of experiment experimental parameters - controls #######################
experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "control type",
                          stringValue = "vehicle control")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "codeValue",
                          valueKind = "batch code",
                          codeValue = "CMPD0000001-1")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "tested concentration",
                          numericValue = 0,
                          valueUnit = "uM")

experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                          experimentValues=experimentValues, 
                          recordedBy="userName", 
                          stateType="metadata", 
                          stateKind="experiment controls", 
                          comments="")                   
#################################################################################################

############################# BEGIN block of experiment analysis parameters #######################
experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "reader instrument",
                          stringValue = "Molecular Dynamics FLIPR")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "data source",
                          stringValue = "FLIPR Min Max")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "data transformation rule",
                          stringValue = "(maximum-minimum)/minimum")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "stringValue",
                          valueKind = "normalization rule",
                          stringValue = "plate order")

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "active efficacy threshold",
                          numericValue = 0.7,
                          sigFigs = 1)

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "active SD threshold",
                          numericValue = 3,
                          sigFigs = 1)
                                                    
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "curve min",
                          numericValue = 0,
                          sigFigs = 2)

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                          valueType = "numericValue",
                          valueKind = "curve max",
                          numericValue = 100,
                          sigFigs = 2)

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "stringValue",
                                                                   valueKind = "replicate aggregation",
                                                                   stringValue = "no")


experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                          experimentValues=experimentValues, 
                          recordedBy="userName", 
                          stateType="metadata", 
                          stateKind="experiment analysis parameters", 
                          comments="")
#################################################################################################

codeName <- getAutoLabels(thingTypeAndKind="document_experiment", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]

#################################################################################################
############################# BEGIN block of report locations #######################
experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "fileValue",
                                                                   valueKind = "summary location",
                                                                   fileValue = paste0("experiments/",codeName,"/analysis/",codeName,"_Summary.pdf"))

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "fileValue",
                                                                   valueKind = "data results location",
                                                                   fileValue = paste0("experiments/",codeName,"/analysis/",codeName,"_Results.csv"))

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "fileValue",
                                                                   valueKind = "raw r results location",
                                                                   fileValue = paste0("experiments/",codeName,"/analysis/rawResults.Rda"))

experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                                                                        experimentValues=experimentValues, 
                                                                        recordedBy="userName", 
                                                                        stateType="metadata", 
                                                                        stateKind="report locations", 
                                                                        comments="")

#################################################################################################
############################# BEGIN block of raw data locations #######################
experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "fileValue",
                                                                   valueKind = "max file",
                                                                   fileValue = paste0("experiments/",codeName,"/analysis/rawData/BAR-123.stat1"))

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "fileValue",
                                                                   valueKind = "min file",
                                                                   fileValue = paste0("experiments/",codeName,"/analysis/rawData/BAR-123.stat2"))

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "fileValue",
                                                                   valueKind = "seq file",
                                                                   fileValue = paste0("experiments/",codeName,"/analysis/rawData/BAR-123.seq1"))

experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
                                                                   valueType = "stringValue",
                                                                   valueKind = "barcode",
                                                                   stringValue = "BAR-123")

experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
                                                                        experimentValues=experimentValues, 
                                                                        recordedBy="userName", 
                                                                        stateType="metadata", 
                                                                        stateKind="raw results locations", 
                                                                        comments="")
#############################  experiment labels #######################

experimentLabels[[length(experimentLabels)+1]] <- createExperimentLabel(lsTransaction = lsTransaction, 
													recordedBy="userName", 
													labelType="name", 
													labelKind="experiment name",
													labelText=codeName,
													preferred=TRUE)

#################################################################################################

## get the protocols
fullProtocollist <- fromJSON(getURL(paste(lsServerURL, "protocols/",sep="")))
testProtocolCodeName <- "PROT-00000001"
protocolObjectArray <- fromJSON(getURL(paste(lsServerURL, "protocols/codename/", testProtocolCodeName,sep="")))
fullProtocolObject <- fromJSON(getURL(paste(lsServerURL, "protocols/", protocolObjectArray[[1]]$id,sep="")))

##### important step ########
exptProtocol <- list(id=protocolObjectArray[[1]]$id)  ## the mininum required is the protocol id

### Save the experiment object #########
experiment <- createExperiment(	lsTransaction = lsTransaction,
              protocol=exptProtocol,
							shortDescription="primary analysis",  
							recordedBy="smeyer", 
							experimentLabels=experimentLabels,
							experimentStates=experimentStates)

## to view experiment JSON before save 
#cat(toJSON(experiment))

experimentSaved <- saveExperiment(experiment)


## to view experiment JSON after save 
cat(toJSON(experimentSaved))

## to get full experiment object
## TODO: need to make server change to return all of the experiment info
experimentObjectArray <- fromJSON(getURL(paste(lsServerURL, "experiments/codename/", experimentSaved$codeName,sep="")))

fullExperimentObject <- fromJSON(getURL(paste(lsServerURL, "experiments/", experimentSaved$id,sep="")))


