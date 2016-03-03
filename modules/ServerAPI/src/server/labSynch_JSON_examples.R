## R code follows here
## example R code to interact with LabSynch JSON services

options(scipen=99)
require(RCurl)
require(RJSONIO)

#lsServerURL <- "http://localhost:8080/labseer/"
lsServerURL <- "http://host3.labsynch.com:8080/labseer/"


############  FUNCTIONS ########################

# http://localhost:8080/labseer/labelsequences?getNextLabelSequences&thingType=document&thingKind=protocol&labelType=id&labelKind=codeName&numberOfLabels=10
# http://host3.labsynch.com:8080/labseer/labelsequences?getNextLabelSequences&thingType=document&thingKind=protocol&labelType=id&labelKind=codeName&numberOfLabels=10

# curl http://host3.labsynch.com:8080/labseer/protocols/codename/PROT-000101
# curl http://host3.labsynch.com:8080/labseer/experiments/codename/EXP-000-101


#to get system label IDs
getAutoLabelId <- function(thingTypeAndKind="thingTypeAndKind", labelTypeAndKind="labelTypeAndKind", numberOfLabels=1){
	labelSequenceDTO = list(
		thingTypeAndKind=thingTypeAndKind,
		labelTypeAndKind=labelTypeAndKind,
		numberOfLabels=numberOfLabels
	)
	cat(toJSON(labelSequenceDTO, digit=15))
	response <- fromJSON(getURL(
	  paste(lsServerURL, "labelsequences/getNextLabelSequences", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(labelSequenceDTO, digit=15)))
	return(response)
}


#to get system labels
getAutoLabels <- function(thingTypeAndKind="thingTypeAndKind", labelTypeAndKind="labelTypeAndKind", numberOfLabels=1){
	labelSequenceDTO = list(
		thingTypeAndKind=thingTypeAndKind,
		labelTypeAndKind=labelTypeAndKind,
		numberOfLabels=numberOfLabels
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "labelsequences/getLabels", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(labelSequenceDTO, digit=15)))
	return(response)
}

# getAutoLabels(thingType="document", thingKind="protocol", labelType="id", labelKind="codeName", numberOfLabels=3)
# getAutoLabelId(thingType="document", thingKind="protocol", labelType="id", labelKind="codeName", numberOfLabels=1)

#to create a new thing kind
createThingKind <- function(thingType="thingType List Object", kindName="kindName"){
	thingKind = list(
		thingType=thingType,
		kindName=kindName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "thingkinds", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(thingKind)))
	return(response)
}


#to create a new labelkind
createLabelKind <- function(labelType="labelType List Object", kindName="kindName"){
	labelKind = list( 
		labelType=labelType,
		kindName=kindName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "labelkinds", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(labelKind)))
	return(response)
}

# to create a new thingstatetype
createStateType <- function(typeName="typeName"){
	stateType = list(
		typeName=typeName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "statetypes", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(stateType)))
	return(response)
}

# to create a new thingstatekind
createStateKind <- function(stateType="stateType List Object", kindName="kindName"){
	stateKind = list(
		stateType=stateType,
		kindName=kindName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "statekinds", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(stateKind)))
	return(response)
}

# to create a new state value type
createValueType <- function(typeName="typeName"){
	valueType = list(
		typeName=typeName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "valuetypes", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(valueType)))
	return(response)
}

# to create a new state value kind
createValueKind <- function(valueType="valueType List Object", kindName="kindName"){
	valueKind = list(
		valueType=valueType,
		kindName=kindName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "valuekinds", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(valueKind)))
	return(response)
}

# to create a new interaction kind
createInteractionKind <- function(interactionType="interactionType List Object", kindName="kindName"){
	interactionKind = list(
		interactionType=interactionType,
		kindName=kindName
	)
	response <- fromJSON(getURL(
	  paste(lsServerURL, "interactionkinds/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(interactionKind)))
	return(response)
}
##to create a new LsTransaction
createLsTransaction <- function(comments=""){
	newLsTransaction = list(
	  	comments=comments,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	response <- fromJSON(getURL(
		  paste(lsServerURL, "lstransactions", sep=""),
		  customrequest='POST',
		  httpheader=c('Content-Type'='application/json'),
		  postfields=toJSON(newLsTransaction, digits = 15)))
	return(response)
}


##to create a new basic thing
createThing <- function(thingType="thingType List Object", thingKind="thingKind List Object", recordedBy="author List Object", lsTransaction=NULL){
	newThing = list(
	  	recordedBy=recordedBy,
		thingType=thingType,
		thingKind=thingKind,
		lsTransaction=lsTransaction,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	response <- fromJSON(getURL(
		  paste(lsServerURL, "lsthings", sep=""),
		  customrequest='POST',
		  httpheader=c('Content-Type'='application/json'),
		  postfields=toJSON(newThing, digits = 15)))
	return(response)
}

createThingLabel <- function(thing, labelText, author, labelType, labelKind, lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	thingLabel = list(
		thing=thing,
		labelText=labelText,
	  	recordedBy=author,
	    labelType=labelType,
		labelKind=labelKind,
		preferred=preferred,
		ignored=ignored,
		lsTransaction=lsTransaction,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(thingLabel)
}

saveThingLabels <- function(thingLabels){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "thinglabels/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(thingLabels, digits = 15)))
	return(response)
}

createProtocolLabel <- function(labelText, recordedBy="authorName", labelType, labelKind, lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	protocolLabel = list(
		labelText=labelText,
	  	recordedBy=recordedBy,
	    labelType=labelType,
		labelKind=labelKind,
		preferred=preferred,
		ignored=ignored,
		lsTransaction=lsTransaction,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(protocolLabel)
}

createExperimentLabel <- function(labelText, recordedBy="authorName", labelType, labelKind, lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	experimentLabel = list(
		labelText=labelText,
	  	recordedBy=recordedBy,
	    labelType=labelType,
		labelKind=labelKind,
		preferred=preferred,
		ignored=ignored,
		lsTransaction=lsTransaction,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(experimentLabel)
}

createAnalysisGroupLabel <- function(labelText, recordedBy="authorName", labelType, labelKind, lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	analysisGroupLabel = list(
		labelText=labelText,
	  	recordedBy=recordedBy,
	    labelType=labelType,
		labelKind=labelKind,
		preferred=preferred,
		ignored=ignored,
		lsTransaction=lsTransaction,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(analysisGroupLabel)
}


createInteraction <- function(firstThing, secondThing, recordedBy, interactionType, interactionKind,
									ignored=FALSE, lsTransaction=NULL){
	interaction = list(
		firstThing=firstThing,
		secondThing=secondThing,
	  	recordedBy=recordedBy,
	    interactionType=interactionType,
		interactionKind=interactionKind,
		ignored=ignored,
		lsTransaction=lsTransaction,
		thingType="interaction",
		thingKind="interaction",
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(interaction)
}

saveInteractions <- function(lsInteractions){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "interactions/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(lsInteractions, digits = 15)))
	return(response)
}

saveLsInteractions <- function(lsInteractions){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "interactions/lsinteraction/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(lsInteractions, digits = 15)))
	return(response)
}


createLsState <- function(lsValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	LsState = list(
		lsValues=lsValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(LsState)
}
createProtocolState <- function(protocolValues=NULL, recordedBy="userName", stateType="stateType", 
									stateKind="stateKind", comments="", lsTransaction=NULL){
	protocolState = list(
		protocolValues=protocolValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(protocolState)
}
createExperimentState <- function(experimentValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	experimentState = list(
		experimentValues=experimentValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(experimentState)
}

createAnalysisGroupState <- function(analysisGroupValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	analysisGroupState = list(
		analysisGroupValues=analysisGroupValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(analysisGroupState)
}

createTreatmentGroupState <- function(treatmentGroupValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	treatmentGroupState = list(
		treatmentGroupValues=treatmentGroupValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(treatmentGroupState)
}
createTreatmentGroup <- function(subjects=NULL,treatmentGroupStates=NULL, codeName=NULL, recordedBy="userName", comments="", lsTransaction=NULL){

	if (is.null(codeName) ) {
		codeName <- getAutoLabels(thingTypeAndKind="document_treatment group", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
	}

	treatmentGroup= list(
		codeName=codeName,		
		subjects=subjects,
		treatmentGroupStates=treatmentGroupStates,
	  	recordedBy=recordedBy,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(treatmentGroup)
}
createSubject <- function(subjectStates=NULL, codeName=NULL, recordedBy="userName", comments="", lsTransaction=NULL){

	if (is.null(codeName) ) {
		codeName <- getAutoLabels(thingTypeAndKind="document_subject", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
	}
	
	sample= list(
		codeName=codeName,
		subjectStates=subjectStates,
	  	recordedBy=recordedBy,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(sample)
}

createSubjectState <- function(subjectValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	sampleState = list(
		subjectValues=subjectValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(sampleState)
}

createContainerState <- function(containerValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	containerState = list(
		containerValues=containerValues,
	  	recordedBy=recordedBy,
	    stateType=stateType,
		stateKind=stateKind,
		comments=comments,
		lsTransaction=lsTransaction,
		ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(containerState)
}

createStateValue <- function(valueType="valueType", valueKind="valueKind", stringValue=NULL, fileValue=NULL,
                             urlValue=NULL, batchCode=NULL, publicData=TRUE, ignored=FALSE,
                             dateValue=NULL, clobValue=NULL, blobValue=NULL, valueOperator=NULL, numericValue=NULL,
                             sigFigs=NULL, uncertainty=NULL, valueUnit=NULL, comments=NULL, 
                             lsTransaction=NULL, thingIdValue=NULL){
  StateValue = list(
    valueType=valueType,
    valueKind=valueKind,
    stringValue=stringValue,
    fileValue=fileValue,
    urlValue=urlValue,
    dateValue=dateValue,
    clobValue=clobValue,
    blobValue=blobValue,
    valueOperator=valueOperator,
    numericValue=numericValue,
    sigFigs=sigFigs,
    uncertainty=uncertainty,
    valueUnit=valueUnit,
    comments=comments,
    ignored=ignored,
    publicData=publicData,
    batchCode=batchCode,
    recordedDate=as.numeric(format(Sys.time(), "%s"))*1000,
    lsTransaction=lsTransaction		
  )
  return(StateValue)
}


createProtocol <- function(codeName=NULL, kind=NULL, shortDescription="protocol short description", lsTransaction=NULL, 
							recordedBy="userName", protocolLabels=NULL, protocolStates=NULL ){
		if (is.null(codeName) ) {
			codeName <- getAutoLabels(thingTypeAndKind="document_protocol", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
		}
	protocol <- list(
		codeName=codeName,
		kind=kind,
		shortDescription=shortDescription,
		lsTransaction=lsTransaction,
		recordedBy=recordedBy,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000,
		protocolLabels=protocolLabels,
		protocolStates=protocolStates
		)
	return(protocol)	
}			


createExperiment <- function(protocol=null, codeName=NULL, kind=NULL, shortDescription="Experiment Short Description text limit 255", 
								lsTransaction=NULL, recordedBy="userName", experimentLabels=NULL,
								experimentStates=NULL){
	if (is.null(codeName) ) {
		codeName <- getAutoLabels(thingTypeAndKind="document_experiment", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
	}
	experiment <- list(
		protocol=protocol,
		codeName=codeName,
		kind=kind,
		shortDescription=shortDescription,
		recordedBy=recordedBy,
		lsTransaction=lsTransaction,
		experimentLabels=experimentLabels,
		experimentStates=experimentStates
		)

	return(experiment)	
}			


createAnalysisGroup <- function(experiment=NULL, codeName=NULL, kind=NULL, lsTransaction=NULL, recordedBy="userName",
                                treatmentGroups=NULL, analysisGroupStates=NULL){
  if (is.null(codeName) ) {
    codeName <- getAutoLabels(thingTypeAndKind="document_analysis group", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
  }
  analysisGroup <- list(
    codeName=codeName,
    kind=kind,
    experiment=experiment,
    recordedBy=recordedBy,
    lsTransaction=lsTransaction,
    treatmentGroups=treatmentGroups,
    analysisGroupStates=analysisGroupStates
  )
  
  return(analysisGroup)	
}			



saveProtocols <- function(protocols){
 	  response <- fromJSON(getURL(
	  paste(lsServerURL, "protocols/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(protocols, digits = 15)))
	return(response)
}


saveProtocol <- function(protocol){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "protocols/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(protocol, digits = 15)))
	return(response)
}



saveExperiment <- function(experiment){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "experiments/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(experiment, digits = 15)))
	return(response)
}


saveExperiments <- function(experiments){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "experiments/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(experiments, digits = 15)))
	return(response)
}

saveAnalysisGroups <- function(analysisGroups){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "analysisgroups/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(analysisGroups, digits = 15)))
	return(response)
}

saveAnalysisGroup <- function(analysisGroup){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "analysisgroups/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(analysisGroup, digits = 15)))
	return(response)
}





compactList <- function(inputList) Filter(Negate(is.null), inputList) ## remove null elements from a list
 
returnListItem <- function(outputList){
	## input: list object
	## output: single list object if there is a single list element
	## 			return error if 0 or > 1 elements found in the list
	## note: null list elements are removed
	parsedList <- compactList(outputList)
	if (length(parsedList) == 0){
		return("Error: No results found")
	} else if (length(parsedList) > 1){
		return("Error: Multiple results found")		
	} else {
		return(compactList(parsedList)[[1]])
	}
}

getThingKind <- function( thingType="typeName", thingKind="kindName" ){
	getThingKindFromList <- function(inputList, thingType=thingType, thingKind=thingKind){
		if(inputList$thingType$typeName == thingType && inputList$kindName == thingKind){
			return(inputList)
		}	
	}			
	outputList <- lapply(thingKinds.list, getThingKindFromList, thingType=thingType, thingKind=thingKind)
	return (returnListItem(outputList))	
}

getThingKindByKindName <- function( thingKind="kindName" ){
	getThingKindFromList <- function(inputList, thingType=typeName, thingKind=thingKind){
		if( inputList$kindName == thingKind){
			return(inputList)
		}	
	}			
	outputList <- lapply(thingKinds.list, getThingKindFromList, thingKind=thingKind)
	return (returnListItem(outputList))	
}

getThingType <- function( typeName="typeName" ){
	getThingTypeFromList <- function(inputList, typeName=""){
		if(inputList$typeName == typeName){
			return(inputList)
		}	
	}	
	outputList <- lapply(thingTypes.list, getThingTypeFromList, typeName=typeName)
	return (returnListItem(outputList))
}

getLabelType <- function( typeName="typeName" ){
	getTypeFromList <- function(inputList, typeName=""){
		if(inputList$typeName == typeName){
			return(inputList)
		}	
	}	
	outputList <- lapply(labelTypes.list, getTypeFromList, typeName=typeName)
	return (returnListItem(outputList))
}

getLabelKind <- function( labelType="typeName", labelKind="kindName" ){
	getLabelKindFromList <- function(inputList, labelType="", labelKind=""){
		if(inputList$labelType$typeName == labelType && inputList$kindName == labelKind){
			return(inputList)
		}	
	}			
	outputList <- lapply(labelKinds.list, getLabelKindFromList, labelType=labelType, labelKind=labelKind)
	return (returnListItem(outputList))	
}

getLabelKindByKindName <- function( labelKind="kindName" ){
	getLabelKindFromList <- function(inputList, labelType="", labelKind=""){
		if(inputList$kindName == labelKind){
			return(inputList)
		}	
	}			
	outputList <- lapply(labelKinds.list, getLabelKindFromList, labelKind=labelKind)
	return (returnListItem(outputList))	
}

getInteractionType <- function( typeName="typeName" ){
	getTypeFromList <- function(inputList, typeName=""){
		if(inputList$typeName == typeName){
			return(inputList)
		}	
	}	
	outputList <- lapply(interactionTypes.list, getTypeFromList, typeName=typeName)
	return (returnListItem(outputList))
}

getInteractionTypeByVerb <- function( typeVerb="typeVerb" ){
	getTypeFromList <- function(inputList, typeVerb=""){
		if(inputList$typeVerb == typeVerb){
			return(inputList)
		}	
	}	
	outputList <- lapply(interactionTypes.list, getTypeFromList, typeVerb=typeVerb)
	return (returnListItem(outputList))
}

getInteractionKind <- function( typeName="typeName", kindName="kindName" ){
	getInteractionKindFromList <- function(inputList, typeName="", kindName=""){
		if(inputList$interactionType$typeName == typeName && inputList$kindName == kindName){
			return(inputList)
		}	
	}			
	outputList <- lapply(interactionKinds.list, getInteractionKindFromList, typeName=typeName, kindName=kindName)
	return (returnListItem(outputList))	
}

getInteractionKindByVerb <- function( typeVerb="typeVerb", kindName="kindName" ){
	getInteractionKindFromList <- function(inputList, typeVerb="", kindName=""){
		if(inputList$interactionType$typeVerb == typeVerb && inputList$kindName == kindName){
			return(inputList)
		}	
	}			
	outputList <- lapply(interactionKinds.list, getInteractionKindFromList, typeVerb=typeVerb, kindName=kindName)
	return (returnListItem(outputList))	
}

getStateType <- function( stateType="typeName" ){
	getTypeFromList <- function(inputList, stateType=""){
		if(inputList$typeName == stateType){
			return(inputList)
		}	
	}	
	outputList <- lapply(stateTypes.list, getTypeFromList, stateType=stateType)
	return (returnListItem(outputList))
}

getStateKind <- function( stateType="typeName", stateKind="kindName" ){
	getStateKindFromList <- function(inputList, stateType="", stateKind=""){
		if(inputList$stateType$typeName == stateType && inputList$kindName == stateKind){
			return(inputList)
		}	
	}			
	outputList <- lapply(stateKinds.list, getStateKindFromList, stateType=stateType, stateKind=stateKind)
	return (returnListItem(outputList))	
}

getStateValueType <- function( typeName="typeName" ){
	getTypeFromList <- function(inputList, typeName=""){
		if(inputList$typeName == typeName){
			return(inputList)
		}	
	}	
	outputList <- lapply(stateValueTypes.list, getTypeFromList, typeName=typeName)
	return (returnListItem(outputList))
}

getValueKind <- function( valueType="typeName", valueKind="kindName" ){
	getValueKindFromList <- function(inputList, valueType="", valueKind=""){
		if(inputList$valueType$typeName == valueType && inputList$kindName == valueKind){
			return(inputList)
		}	
	}			
	outputList <- lapply(valueKinds.list, getValueKindFromList, valueType=valueType, valueKind=valueKind)
	return (returnListItem(outputList))	
}

getAuthorByUserName <- function( userName="userName" ){
	getUserNameFromList <- function(inputList, userName=""){
		if(inputList$userName == userName){
			return(inputList)
		}	
	}	
	outputList <- lapply(authors.list, getUserNameFromList, userName=userName)
	return (returnListItem(outputList))
}

getAuthorById <- function( userId="userId" ){
	getTypeFromList <- function(inputList, userId=""){
		if(inputList$id == userId){
			return(inputList)
		}	
	}	
	outputList <- lapply(authors.list, getTypeFromList, userId=userId)
	return (returnListItem(outputList))
}

deleteExperiment <- function(experiment){
  response <- getURL(
    paste(lsServerURL, "experiments/",experiment$id, sep=""),
    customrequest='DELETE',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(experiment, digits = 15))
  return(response)
}

##########################################################
##### Example Functions ###########

## example protocol with basic parameters
## nested example for readibility

createExampleProtocol <- function(codeName="protocolName", shortDescription="protocol short description", lsTransaction=NULL, recordedBy="userName",
                           readerInstrument="Molecular Dynamics FLIPR", curveMin=0, curveMax=100){
	protocol <- list(
		codeName=codeName,
		shortDescription=shortDescription,
		lsTransaction=lsTransaction,
		recordedBy=recordedBy,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000,
		protocolStates=list(
			createProtocolState(
				lsTransaction=lsTransaction, 
				recordedBy=recordedBy,
				stateType="metadata", 
				stateKind="protocol analysis parameters",
				protocolValues=list(
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "stringValue",
				      valueKind = "reader instrument",
					  stringValue = readerInstrument),
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "numericValue",
				      valueKind = "curve min",
					  numericValue = curveMin,
				      sigFigs = 2),
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "numericValue",
				      valueKind = "curve max",
					  numericValue = curveMax,
				      sigFigs = 2)
					)
				)
			)		
		)
	return(protocol)	
}			

## example experiment with basic parameters
## nested example for readibility

### TODO: note -- this example is broken. Need to fix.

createExampleExperiment <- function(protocol=null, name="Experiment Name EXP-101", shortDescription="Experiment Short Description text limit 255", 
								lsTransaction=NULL, recordedBy="userName",
								readerInstrument="Molecular Dynamics FLIPR", curveMin=0, curveMax=100){
	experiment <- list(
		protocol=protocol,
		name=name,
		shortDescription=shortDescription,
		recordedBy=recordedBy,
		lsTransaction=lsTransaction,
		experimentStates=list(
			createExperimentState(
				lsTransaction=lsTransaction, 
				recordedBy=recordedBy,
				stateType="metadata", 
				stateKind="experiment parameters",
				experimentValues=list(
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "stringValue",
				      valueKind = "reader instrument",
					  stringValue = readerInstrument),
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "numericValue",
				      valueKind = "curve min",
					  numericValue = curveMin,
				      sigFigs = 2),
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "numericValue",
				      valueKind = "curve max",
					  numericValue = curveMax,
				      sigFigs = 2)
					)
				)
			)		
		)
	return(experiment)	
}			

## example analysisGroup with basic parameters
## nested example for readibility

createExampleAnalysisGroup <- function(experiment=NULL, lsTransaction=NULL, recordedBy="userName"){
	analysisGroup <- list(
		experiment=experiment,
		recordedBy=recordedBy,
		lsTransaction=lsTransaction,
		treatmentGroups=list(
			createTreatmentGroup(
				recordedBy=recordedBy,
				lsTransaction=lsTransaction,
				comments="no comments",
				treatmentGroupStates=list(
					createTreatmentGroupState(
						lsTransaction=lsTransaction, 
						recordedBy=recordedBy,
						stateType="data", 
						stateKind="aggrated sample data",
						treatmentGroupValues=list(
							createStateValue(
							  lsTransaction = lsTransaction, 
							  valueType = "numericValue",
						      valueKind = "average RLU",
							  numericValue = 0.245,
							  uncertainty = 0.011,
						      sigFigs = 3)
						)						
					)
				),
				subjects=list(
					createSubject(
						lsTransaction=lsTransaction, 
						recordedBy=recordedBy,
						subjectStates=list(
							createSubjectState(
								lsTransaction=lsTransaction, 
								recordedBy=recordedBy,
								stateType="data", 
								stateKind="read data 1",
								subjectValues=list(
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "numericValue",
								      valueKind = "raw1",
									  valueUnit="RLU",
									  numericValue = 0.334,
								      sigFigs = 3,
									  concValue=3,
									  concUnit="uM",
									  comments="some comment 1"
									)
								)
							),
							createSubjectState(
								lsTransaction=lsTransaction, 
								recordedBy=recordedBy,
								stateType="metadata", 
								stateKind="assay plate info",
								subjectValues=list(
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "stringValue",
								      valueKind = "well ref",
									  stringValue = "A001"
									),
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "stringValue",
								      valueKind = "barcode",
									  stringValue = "A-123456"
									)
								)
							)
						)
					),
					createSubject(
						lsTransaction=lsTransaction, 
						recordedBy=recordedBy,
						subjectStates=list(
							createSubjectState(
								lsTransaction=lsTransaction, 
								recordedBy=recordedBy,
								stateType="data", 
								stateKind="read data 1",
								subjectValues=list(
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "numericValue",
								      valueKind = "raw1",
									  valueUnit="RLU",
									  numericValue = 0.334,
								      sigFigs = 3,
									  concValue=3,
									  concUnit="uM",
									  comments="some comment 1"
									)
								)	
							),
							createSubjectState(
								lsTransaction=lsTransaction, 
								recordedBy=recordedBy,
								stateType="metadata", 
								stateKind="assay plate info",
								subjectValues=list(
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "stringValue",
								      valueKind = "well ref",
									  stringValue = "A002"
									),
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "stringValue",
								      valueKind = "barcode",
									  stringValue = "A-123456"
									)
								)						
							)						
						)
					),
					createSubject(
						lsTransaction=lsTransaction, 
						recordedBy=recordedBy,
						subjectStates=list(
							createSubjectState(
								lsTransaction=lsTransaction, 
								recordedBy=recordedBy,
								stateType="data", 
								stateKind="read data 1",
								subjectValues=list(
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "numericValue",
								      valueKind = "raw1",
									  valueUnit="RLU",
									  numericValue = 0.235,
								      sigFigs = 3,
									  concValue=3,
									  concUnit="uM",
									  comments="some comment 1"
									)
								)	
							),
							createSubjectState(
								lsTransaction=lsTransaction, 
								recordedBy=recordedBy,
								stateType="metadata", 
								stateKind="assay plate info",
								subjectValues=list(
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "stringValue",
								      valueKind = "well ref",
									  stringValue = "A003"
									),
									createStateValue(
									  lsTransaction = lsTransaction, 
									  valueType = "stringValue",
								      valueKind = "barcode",
									  stringValue = "A-123456"
									)
								)						
							)						
						)
					)
				)
			)
		),
		analysisGroupStates=list(
			createAnalysisGroupState(
				lsTransaction=lsTransaction, 
				recordedBy=recordedBy,
				stateType="data", 
				stateKind="experiment parameters",
				analysisGroupValues=list(
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "stringValue",
				      valueKind = "descriptive result",
					  stringValue = "result text blah"),
					createStateValue(
					  lsTransaction = lsTransaction, 
					  valueType = "numericValue",
				      valueKind = "ec50",
					  numericValue = 0.234,
 					  valueOperator = "=",
					  uncertainty = 0.015,
				      sigFigs = 3)
				),
			)
		)
	)
	return(analysisGroup)	
}			


############  END OF FUNCTIONS ########################

############ LabSynch JSON Contstants #################

### refresh upon workspace startup
### may also refresh as necessary

############ GLOBAL VARIABLES ##########################
refreshGlobalList <- function(){
	thingTypes.list 		<<- fromJSON(getURL(paste(lsServerURL, "thingtypes/", sep="")), digits=15)
	thingKinds.list 		<<- fromJSON(getURL(paste(lsServerURL, "thingkinds/", sep="")), digits=15)
	labelTypes.list 		<<- fromJSON(getURL(paste(lsServerURL, "labeltypes/", sep="")), digits=15)
	labelKinds.list 		<<- fromJSON(getURL(paste(lsServerURL, "labelkinds/", sep="")), digits=15)
	interactionTypes.list 	<<- fromJSON(getURL(paste(lsServerURL, "interactiontypes/", sep="")), digits=15)
	interactionKinds.list 	<<- fromJSON(getURL(paste(lsServerURL, "interactionkinds/", sep="")), digits=15)
	stateTypes.list 	<<- fromJSON(getURL(paste(lsServerURL, "statetypes/", sep="")), digits=15)
	stateKinds.list 	<<- fromJSON(getURL(paste(lsServerURL, "statekinds/", sep="")), digits=15)
	valueTypes.list 	<<- fromJSON(getURL(paste(lsServerURL, "valuetypes/", sep="")), digits=15)
	valueKinds.list 	<<- fromJSON(getURL(paste(lsServerURL, "valuekinds/", sep="")), digits=15)
	authors.list 			<<- fromJSON(getURL(paste(lsServerURL, "authors/", sep="")), digits=15)	
}

refreshGlobalList()

############ END OF GLOBAL VARIABLES ##########################



### example to create thing kind, label kind, and thing state kinds
### note --- currently not guarding against duplicate entries --- should be unique constraints

createThingKind(thingType=getThingType(typeName="document"), kindName="protocol")
createThingKind(thingType=getThingType(typeName="document"), kindName="protocol parameters")
createLabelKind(labelType=getLabelType( typeName="name" ), kindName="Protocol Name")
createLabelKind(labelType=getLabelType( typeName="name" ), kindName="Protocol Parameters Name")								
createLabelKind(labelType=getLabelType( typeName="name" ), kindName="Experiment Name")
createStateKind(stateType=getStateValueType( stateType="metadata" ), kindName="protocol info")										
createStateKind(stateType=getStateValueType( stateType="metadata" ), kindName="protocol parameters")
createStateKind(stateType=getStateValueType( stateType="metadata" ), kindName="curve min")
createStateKind(stateType=getStateValueType( stateType="metadata" ), kindName="curve max")												
createInteractionKind(interactionType = getInteractionType("member of"), kindName = "protocol parameters")
createValueKind(valueType=getStateValueType( typeName="numeric" ), kindName="curve min")
createValueKind(valueType=getStateValueType( typeName="numeric" ), kindName="curve max")
createValueKind(ValueType=getStateValueType( typeName="string" ), kindName="short description")

refreshGlobalList()

##########################################################
## this exercises the json services on the server
## creates the protocol, experiment, and analysisGroups with the data
## example of creating a protocol with discrete parts 

lsTransaction <- createLsTransaction(comments="protocol 201 transactions")

protocolValues <- list()
protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
													valueType = "stringValue",
													valueKind = "reader instrument",
													stringValue = "Molecular Dynamics FLIPR")


protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
													valueType = "numericValue",
													valueKind = "curve min",
													numericValue = 0,
													sigFigs = 2)

protocolValues[[length(protocolValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
													valueType = "numericValue",
													valueKind = "curve max",
													numericValue = 100,
													sigFigs = 2)


protocolStates <- list()
protocolStates[[length(protocolStates)+1]] <- createProtocolState(lsTransaction = lsTransaction, 
													protocolValues=protocolValues, 
													recordedBy="userName", 
													stateType="metadata", 
													stateKind="protocol analysis parameters", 
													comments="")

protocolLabels <- list()
protocolLabels[[length(protocolLabels)+1]] <- createProtocolLabel(lsTransaction = lsTransaction, 
													recordedBy="userName", 
													labelType="name", 
													labelKind="protocol name",
													labelText="Test Inhibition Values",
													preferred=TRUE)

protocol <- createProtocol(	lsTransaction = lsTransaction, 
							codeName=NULL, 
							shortDescription="protocol short description goes here",  
							recordedBy="userName", 
							protocolLabels=protocolLabels,
							protocolStates=protocolStates)

protocolSaved_101 <- saveProtocol(protocol)
							

########################################################################
## example of creating an experiment with discrete parts 


lsTransaction <- createLsTransaction(comments="experiment 201 transactions")

experimentValues <- list()
experimentValues[[length(experimentValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
													valueType = "stringValue",
													valueKind = "reader instrument",
													stringValue = "Molecular Dynamics FLIPR")

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

experimentStates <- list()
experimentStates[[length(experimentStates)+1]] <- createExperimentState(lsTransaction = lsTransaction, 
													experimentValues=experimentValues, 
													recordedBy="userName", 
													stateType="metadata", 
													stateKind="experiment analysis parameters", 
													comments="")

experimentLabels <- list()
experimentLabels[[length(experimentLabels)+1]] <- createExperimentLabel(lsTransaction = lsTransaction, 
													recordedBy="userName", 
													labelType="name", 
													labelKind="experiment name",
													labelText="Test Inhibition Values 201",
													preferred=TRUE)

experiment <- createExperiment(	codeName=NULL,
	 							kind="dose response",
								shortDescription="experiment short description", 
								lsTransaction=lsTransaction, 
								recordedBy="userName",
								protocol=protocolSaved_101,
								experimentLabels=experimentLabels,
                        		experimentStates=experimentStates)

experimentSaved_101 <- saveExperiment(experiment)

########################################################################
## example of creating an analysis group with discrete parts 

lsTransaction <- createLsTransaction(comments="experiment 101 AnalysisGroup transactions")
recordedBy <- "userName"
subjects <- list()
subjectStates <- list()																										

subjectValues <- list()
subjectValues[[length(subjectValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
															valueType = "stringValue",
															valueKind = "well ref",
															stringValue = "A003")

subjectValues[[length(subjectValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
															valueType = "stringValue",
															valueKind = "barcode",
															stringValue = "A-123456")

subjectStates[[length(subjectStates)+1]] <- createSubjectState(lsTransaction=lsTransaction, 
															recordedBy=recordedBy,
															stateType="metadata", 
															stateKind="assay plate info",
															subjectValues=subjectValues)

subjectValues <- list()
subjectValues[[length(subjectValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
															valueType = "numericValue",
															valueKind = "raw1",
															valueUnit="RLU",
															numericValue = 0.235,
															sigFigs = 3,
															comments="some comment 1")

subjectValues[[length(subjectValues)+1]] <- createStateValue(lsTransaction = lsTransaction, 
															valueType = "numericValue",
															valueKind = "tested concentration",
															valueUnit= "uM",
															numericValue = 3,
															sigFigs = 1,
															comments="some comment 1")

subjectValues[[length(subjectValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
															valueType = "batchCode",
															valueKind = "test compound",
															batchCode = "CMPD-10001:1")

subjectStates[[length(subjectStates)+1]] <- createSubjectState(lsTransaction=lsTransaction, 
															recordedBy=recordedBy,
															stateType="data", 
															stateKind="read data 1",
															subjectValues=subjectValues)

subjects[[length(subjects)+1]] <- createSubject(lsTransaction=lsTransaction, 
												recordedBy=recordedBy,
												subjectStates=subjectStates)


treatmentGroupValues <- list()
treatmentGroupValues[[length(treatmentGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																			valueType = "numericValue",
																			valueKind = "average RLU",
																			numericValue = 0.245,
																			uncertainty = 0.011,
																			sigFigs = 3)

treatmentGroupStates <- list()
treatmentGroupStates[[length(treatmentGroupStates)+1]] <- createTreatmentGroupState( lsTransaction=lsTransaction, 
																			recordedBy=recordedBy,
																			stateType="data", 
																			stateKind="aggregated subject data",
																			treatmentGroupValues=treatmentGroupValues)

treatmentGroups <- list()
treatmentGroups[[length(treatmentGroups)+1]] <- createTreatmentGroup( lsTransaction=lsTransaction, 
																	recordedBy="userName",
																	comments="no comments",
																	subjects=subjects,
																	treatmentGroupStates=treatmentGroupStates)


analysisGroupValues <- list()
																	
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "ec50",
																	numericValue = 0.234,
																	valueOperator = "=",
																	uncertainty = 0.015,
																	sigFigs = 3)

analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "hill slope",
																	numericValue = 0.098,
																	valueOperator = "=",
																	uncertainty = 0.01,
																	sigFigs = 2)

analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "stringValue",
																	valueKind = "curve shape",
																	stringValue = "sigmoid")																																		

analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "batchCode",
																	valueKind = "test compound",
																	batchCode = "CMPD-10001:1")

analysisGroupStates <- list()
analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
																		recordedBy=recordedBy,
																		stateType="data", 
																		stateKind="aggregated analysis group data",
																		analysisGroupValues=analysisGroupValues)

analysisGroups<- list()
analysisGroups[[length(analysisGroups)+1]] <- createAnalysisGroup( lsTransaction=lsTransaction,
																codeName=NULL,
                                kind="Dose Response",
																experiment=experimentSaved_101,
																recordedBy="userName",
																analysisGroupStates=analysisGroupStates,
																treatmentGroups=treatmentGroups)


analysisGroupsSaved_101 <- saveAnalysisGroups(analysisGroups)

#### Multiple Concentration Units

analysisGroupStates <- list()
analysisGroupValues <- list()
																	
### set 1
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "tested concentration",
																	valueUnit= "uM",
																	numericValue = 10,
																	sigFigs = 1,
																	comments="some comment 1")
																																																	sigFigs = 2)
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "inhibition",
																	numericValue = 50,
																	valueUnit= "%",
																	valueOperator = "=",
																	uncertainty = 0.01,
																	sigFigs = 2)																																	

analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "batchCode",
																	valueKind = "test compound",
																	batchCode = "CMPD-0000012-01")


analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
																		recordedBy=recordedBy,
																		stateType="data", 
																		stateKind="inhibition",
																		analysisGroupValues=analysisGroupValues)
### set 2
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "tested concentration",
																	valueUnit= "uM",
																	numericValue = 20,
																	sigFigs = 1,
																	comments="some comment 1")
																																																	sigFigs = 2)
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "inhibition",
																	numericValue = 75,
																	valueUnit= "%",
																	valueOperator = "=",
																	uncertainty = 0.01,
																	sigFigs = 2)																																	

analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "batchCode",
																	valueKind = "test compound",
																	batchCode = "CMPD-0000012-01")


analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
																		recordedBy=recordedBy,
																		stateType="data", 
																		stateKind="inhibition",
																		analysisGroupValues=analysisGroupValues)

### set 3
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "tested concentration",
																	valueUnit= "uM",
																	numericValue = 30,
																	sigFigs = 1,
																	comments="some comment 1")
																																																	sigFigs = 2)
analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "numericValue",
																	valueKind = "inhibition",
																	numericValue = 95,
																	valueUnit= "%",
																	valueOperator = "=",
																	uncertainty = 0.01,
																	sigFigs = 2)																																	

analysisGroupValues[[length(analysisGroupValues)+1]] <- createStateValue( lsTransaction = lsTransaction, 
																	valueType = "batchCode",
																	valueKind = "test compound",
																	batchCode = "CMPD-0000012-01")


analysisGroupStates[[length(analysisGroupStates)+1]] <- createAnalysisGroupState( lsTransaction=lsTransaction, 
																		recordedBy=recordedBy,
																		stateType="data", 
																		stateKind="inhibition",
																		analysisGroupValues=analysisGroupValues)


analysisGroups<- list()
analysisGroups[[length(analysisGroups)+1]] <- createAnalysisGroup( lsTransaction=lsTransaction,
																codeName=NULL,
                                kind="Dose Response",
																experiment=experimentSaved_101,
																recordedBy="userName",
																analysisGroupStates=analysisGroupStates,
																treatmentGroups=treatmentGroups)


analysisGroupsSaved_201 <- saveAnalysisGroups(analysisGroups)



########################################################################
## example of creating a protocol with a hard wired construct
########################################################################
lsTransaction <- createLsTransaction(comments="protocol 102 transactions")
protocol <- createExampleProtocol(codeName="protocolName", shortDescription="protocol short description", 
						lsTransaction=lsTransaction, recordedBy="userName",
                        readerInstrument="Molecular Dynamics FLIPR", curveMin=0, curveMax=100)
protocolSaved_102 <- saveProtocol(protocol)

## example of creating an experiment with a hard wired construct
experiment <- createExampleExperiment(protocol=protocolSaved_102, name="Experiment Name EXP-102", shortDescription="Experiment Short Description text limit 255", 
								lsTransaction=lsTransaction, recordedBy="userName",
								readerInstrument="Molecular Dynamics FLIPR", curveMin=0, curveMax=100)
savedExperiment <- saveExperiment(experiment)

## example of creating an analysisGroup with a hard wired construct

analysisGroup <- createExampleAnalysisGroup(experiment=savedExperiment, lsTransaction=lsTransaction, recordedBy="userName")
savedAnalysisGroup <- saveAnalysisGroup(analysisGroup)

