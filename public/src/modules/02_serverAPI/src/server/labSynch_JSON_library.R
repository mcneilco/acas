## R code follows here
## example R code to interact with LabSynch JSON services

options(scipen=99)
require(RCurl)
require(rjson)

#lsServerURL <- "http://localhost:8080/labseer/"
#lsServerURL <- "http://host3.labsynch.com:8080/acas/"


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
	cat(toJSON(labelSequenceDTO))
	response <- fromJSON(getURL(
	  paste(lsServerURL, "labelsequences/getNextLabelSequences", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(labelSequenceDTO)))
	return(response)
}


#to get system labels
getAutoLabels <- function(thingTypeAndKind="thingTypeAndKind", labelTypeAndKind="labelTypeAndKind", numberOfLabels=1){
	labelSequenceDTO = list(
		thingTypeAndKind=thingTypeAndKind,
		labelTypeAndKind=labelTypeAndKind,
		numberOfLabels=numberOfLabels
	)
	response <- getURL(
	  paste(lsServerURL, "labelsequences/getLabels", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(labelSequenceDTO))
	if (grepl("^<",response)) {
	  stop (paste("The loader was unable to get labels. Instead, it got this response:", response))
	}
  response <- fromJSON(response)
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
		  postfields=toJSON(newLsTransaction)))
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
		  postfields=toJSON(newThing)))
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
	  postfields=toJSON(thingLabels)))
	return(response)
}

createProtocolLabel <- function(protocol = NULL, labelText, recordedBy="authorName", labelType="name", labelKind="protocol name", lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	# The protocol must include at least an id and version
  protocolLabel = list(
    protocol=protocol,
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

createExperimentLabel <- function(experiment=NULL, labelText, recordedBy="authorName", labelType="name", labelKind="experiment name", lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	experimentLabel = list(
    experiment=experiment,
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

createAnalysisGroupLabel <- function(analysisGroup=NULL, labelText, recordedBy="authorName", labelType="name", labelKind="analysis group name", lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	analysisGroupLabel = list(
    analysisGroup=analysisGroup,
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

createTreatmentGroupLabel <- function(treatmentGroup=NULL, labelText, recordedBy="authorName", labelType="name", labelKind="treatment group name", lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
  treatmentGroupLabel = list(
    treatmentGroup=treatmentGroup,
    labelText=labelText,
    recordedBy=recordedBy,
    labelType=labelType,
    labelKind=labelKind,
    preferred=preferred,
    ignored=ignored,
    lsTransaction=lsTransaction,
    recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
  )
  return(treatmentGroupLabel)
}

createSubjectLabel <- function(subject=NULL, labelText, recordedBy="authorName", labelType="name", labelKind="subject name", lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
  subjectLabel = list(
    subject=subject,
    labelText=labelText,
    recordedBy=recordedBy,
    labelType=labelType,
    labelKind=labelKind,
    preferred=preferred,
    ignored=ignored,
    lsTransaction=lsTransaction,
    recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
  )
  return(subjectLabel)
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
	response <- getURL(
	  paste(lsServerURL, "interactions/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(lsInteractions))
	if (grepl("^<",response)) {
	  stop (paste("The loader was unable to save your interactions. Instead, it got this response:", response))
	}
  response <- fromJSON(response)
	return(response)
}

saveLsInteractions <- function(lsInteractions){
	response <- fromJSON(getURL(
	  paste(lsServerURL, "interactions/lsinteraction/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(lsInteractions)))
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
createProtocolState <- function(protocol=NULL, protocolValues=NULL, recordedBy="userName", stateType="stateType", 
									stateKind="stateKind", comments="", lsTransaction=NULL){
	protocolState = list(
    protocol=protocol,
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
createExperimentState <- function(experimentValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL, experiment=NULL){
	experimentState = list(
	  experiment=experiment, #This will fail if not given an id and version (but the version does not matter)
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

createAnalysisGroupState <- function(analysisGroup = NULL, analysisGroupValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
  analysisGroupState = list(
    analysisGroup=analysisGroup, #This will fail if not given an id and version (but the version does not matter)
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

createTreatmentGroupState <- function(treatmentGroup=NULL, treatmentGroupValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
	treatmentGroupState = list(
    treatmentGroup=treatmentGroup,
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
createTreatmentGroup <- function(analysisGroup=NULL,subjects=NULL,treatmentGroupStates=NULL, codeName=NULL, recordedBy="userName", comments="", lsTransaction=NULL){

	if (is.null(codeName) ) {
		codeName <- getAutoLabels(thingTypeAndKind="document_treatment group", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
	}

	treatmentGroup= list(
    analysisGroup=analysisGroup,
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
createSubject <- function(treatmentGroup=NULL, subjectStates=NULL, codeName=NULL, recordedBy="userName", comments="", lsTransaction=NULL){

	if (is.null(codeName) ) {
		codeName <- getAutoLabels(thingTypeAndKind="document_subject", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
	}
	
	subject= list(
    treatmentGroup=treatmentGroup,
		codeName=codeName,
    subjectStates=subjectStates,
    recordedBy=recordedBy,
    comments=comments,
    lsTransaction=lsTransaction,
    ignored=FALSE,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(subject)
}

createSubjectState <- function(subject=NULL, subjectValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", comments="", lsTransaction=NULL){
  sampleState = list(
    subject=subject,
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

createStateValue <- function(valueType="valueType", valueKind="valueKind", stringValue=NULL, fileValue=NULL,
                             urlValue=NULL, publicData=TRUE, ignored=FALSE,
                             dateValue=NULL, clobValue=NULL, blobValue=NULL, valueOperator=NULL, numericValue=NULL,
                             sigFigs=NULL, uncertainty=NULL, uncertaintyType=NULL,
                             numberOfReplicates=NULL, valueUnit=NULL, comments=NULL, 
                             lsTransaction=NULL, thingIdValue=NULL, codeValue=NULL,  
                             entityState=NULL,
                             protocolState=NULL,
                             experimentState=NULL,
                             analysisGroupState=NULL,
                             treatmentGroupState=NULL,
                             subjectState=NULL,
                             containerState=NULL,
                             containerContainerItxState=NULL,
                             subjectContainerItxState=NULL){
	stateValue = list(
    entityState=entityState,
    protocolState=protocolState,
    experimentState=experimentState,
    analysisGroupState=analysisGroupState,
    treatmentGroupState=treatmentGroupState,
    subjectState=subjectState,
    containerState=containerState,
    containerContainerItxState=containerContainerItxState,
    subjectContainerItxState=subjectContainerItxState,
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
    uncertaintyType=uncertaintyType,
    numberOfReplicates=numberOfReplicates,
		valueUnit=valueUnit,
		comments=comments,
		ignored=ignored,
		publicData=publicData,
		codeValue=codeValue,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000,
		lsTransaction=lsTransaction		
	)
	return(stateValue)
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
								lsTransaction=NULL, recordedBy="userName", experimentLabels=list(),
								experimentStates=list()){
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
	sysDateTime <- as.numeric(format(Sys.time(), "%s"))*1000
	analysisGroup <- list(
		codeName=codeName,
    kind=kind,
		experiment=experiment,
		recordedBy=recordedBy,
		lsTransaction=lsTransaction,
		treatmentGroups=treatmentGroups,
		analysisGroupStates=analysisGroupStates
		#recordedDate=sysDateTime,
		#modifiedBy=recordedBy,
		#modifiedDate=sysDateTime
	)

	return(analysisGroup)	
}			


createContainer <- function(codeName=NULL, ignored = FALSE, kind=NULL, lsTransaction=NULL, recordedBy="userName",
                               containerStates=NULL, containerLabels=NULL, containerType="material", containerKind = "well"){
  if (is.null(codeName) ) {
    codeName <- getAutoLabels(thingTypeAndKind="material_container", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]						
  }
  sysDateTime <- as.numeric(format(Sys.time(), "%s"))*1000
  container <- list(
    codeName=codeName,
    ignored=ignored,
    kind=kind,
    recordedBy=recordedBy,
    lsTransaction=lsTransaction,
    containerStates=containerStates,
    containerLabels=containerLabels,
    recordedDate=sysDateTime,
    modifiedBy=recordedBy,
    modifiedDate=sysDateTime,
    containerType=containerType,
    containerKind=containerKind
  )
  
  return(container)	
}		

createLabelSequence <- function(labelPrefix = "PREF", labelSeparator="-", groupDigits = FALSE, digits=8, latestNumber = 1,
                                ignored=FALSE, modifiedDate = as.numeric(format(Sys.time(), "%s"))*1000, thingTypeAndKind,
                                labelTypeAndKind = "id_codeName") {
  labelSequence <- list(
    labelPrefix=labelPrefix,
    labelSeparator=labelSeparator,
    groupDigits=groupDigits,
    digits=digits,
    latestNumber=latestNumber,
    ignored=ignored,
    modifiedDate=modifiedDate,
    thingTypeAndKind=thingTypeAndKind,
    labelTypeAndKind=labelTypeAndKind)
}

createContainerState <- function(container=NULL,containerValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", 
                                 comments="", lsTransaction=NULL){
  containerState = list(
    container=container,
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

createContainerLabel <- function(container=NULL,labelText, recordedBy="userName", labelType="labelType", labelKind="labelKind", 
                                 lsTransaction=NULL, preferred=TRUE, imageFile=NULL, labelTypeAndKind=NULL, physicallyLabeled=FALSE,
                                 modifiedDate=NULL,version=NULL){
  containerLabel = list(
    container=container,
    recordedBy=recordedBy,
    labelText=labelText,
    labelType=labelType,
    labelKind=labelKind,
    lsTransaction=lsTransaction,
    preferred=preferred,
    imageFile=imageFile,
    labelTypeAndKind=labelTypeAndKind,
    physicallyLabeled=physicallyLabeled,
    ignored=FALSE,
    recordedDate=as.numeric(format(Sys.time(), "%s"))*1000,
    modifiedDate=modifiedDate,
    version=version
  )
  return(containerLabel)
}
 

createContainerContainerInteraction <- function(codeName=NULL, ignored = FALSE, kind=NULL, lsTransaction=NULL, recordedBy="userName",
                                                interactionStates=NULL, interactionType, interactionKind="interaction", 
                                                firstContainer, secondContainer){
  #interactionType = c("added to","removed from","operated on", "created by", "destroyed by", "refers to", "member of")
  if (is.null(codeName) ) {
    codeName <- getAutoLabels(thingTypeAndKind="interaction_containerContainer", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]  					
  }
  sysDateTime <- as.numeric(format(Sys.time(), "%s"))*1000
  containerContainerInteraction <- list(
    codeName=codeName,
    ignored=ignored,
    kind=kind,
    recordedBy=recordedBy,
    lsTransaction=lsTransaction,
    interactionStates=interactionStates,
    recordedDate=sysDateTime,
    modifiedBy=recordedBy,
    modifiedDate=sysDateTime,
    interactionType=interactionType,
    interactionKind=interactionKind,
    firstContainer=firstContainer,
    secondContainer=secondContainer
  )
  
  return(containerContainerInteraction)	
}			

createContainerContainerItxState <- function(container=NULL, interactionValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", 
                                 comments="", lsTransaction=NULL){
  interactionState = list(
    container=container,
    interactionValues=interactionValues,
    recordedBy=recordedBy,
    stateType=stateType,
    stateKind=stateKind,
    comments=comments,
    lsTransaction=lsTransaction,
    ignored=FALSE,
    recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
  )
  return(interactionState)
}

createSubjectContainerInteraction <- function(codeName=NULL, ignored = FALSE, kind=NULL, lsTransaction=NULL, recordedBy="userName",
                                                interactionStates=NULL, interactionType, interactionKind="interaction", 
                                                subject, container){
  #interactionType = c("added to","removed from","operated on", "created by", "destroyed by", "refers to", "member of")
  if (is.null(codeName) ) {
    codeName <- getAutoLabels(thingTypeAndKind="interaction_subjectContainer", labelTypeAndKind="id_codeName", numberOfLabels=1)[[1]][[1]]    				
  }
  sysDateTime <- as.numeric(format(Sys.time(), "%s"))*1000
  subjectContainerInteraction <- list(
    codeName=codeName,
    ignored=ignored,
    kind=kind,
    recordedBy=recordedBy,
    lsTransaction=lsTransaction,
    interactionStates=interactionStates,
    recordedDate=sysDateTime,
    modifiedBy=recordedBy,
    modifiedDate=sysDateTime,
    interactionType=interactionType,
    interactionKind=interactionKind,
    subject=subject,
    container=container
  )
  
  return(subjectContainerInteraction)	
}			

createSubjectContainerItxState <- function(subjectContainerInteraction=NULL, interactionValues=NULL, recordedBy="userName", stateType="stateType", stateKind="stateKind", 
                                             comments="", lsTransaction=NULL){
  interactionState = list(
    subjectContainerInteraction=subjectContainerInteraction,
    interactionValues=interactionValues,
    recordedBy=recordedBy,
    stateType=stateType,
    stateKind=stateKind,
    comments=comments,
    lsTransaction=lsTransaction,
    ignored=FALSE,
    recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
  )
  return(interactionState)
}

saveProtocols <- function(protocols){
 	  response <- getURL(
	  paste(lsServerURL, "protocols/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(protocols))
 	  if (grepl("^<",response)) {
 	    stop (paste("The loader was unable to save your protocols. Instead, it got this response:", response))
 	  }
 	  response <- fromJSON(response)
	return(response)
}


saveProtocol <- function(protocol){
	response <- getURL(
	  paste(lsServerURL, "protocols/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(protocol))
	if (grepl("^<",response)) {
	  stop (paste("The loader was unable to save your protocol. Instead, it got this response:", response))
	}
	response <- fromJSON(response)
	return(response)
}



saveExperiment <- function(experiment){
	response <- getURL(
	  paste(lsServerURL, "experiments/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(experiment))
	if (grepl("^<",response)) {
	  stop (paste("The loader was unable to save your experiment. Instead, it got this response:", response))
	}
	response <- fromJSON(response)
	return(response)
}


saveExperiments <- function(experiments){
	response <- getURL(
	  paste(lsServerURL, "experiments/jsonArray", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(experiments))
	if (grepl("^<",response)) {
	  stop (paste("The loader was unable to save your experiments. Instead, it got this response:", response))
	}
	response <- fromJSON(response)
	return(response)
}

saveAnalysisGroups <- function(analysisGroups){
  message <- toJSON(analysisGroups)
  # toJSON fails with NA, NaN, and Inf, but so far it seems that these have been successfully stripped out
  #message <- gsub("\"NA\"|\"NaN\"", "null", message)
  response <- getURL(
    paste(lsServerURL, "analysisgroups/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your data. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveAnalysisGroup <- function(analysisGroup){
	response <- getURL(
	  paste(lsServerURL, "analysisgroups/", sep=""),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(analysisGroup))
	if (grepl("^<",response)) {
	  stop (paste("The loader was unable to save your data. Instead, it got this response:", response))
	}
	response <- fromJSON(response)
	return(response)
}

# Currently, this cannot accept labels and states
saveContainer <- function(container){
  response <- getURL(
    paste(lsServerURL, "containers/", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(container))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your container. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveContainers <- function(containers){
  response <- getURL(
    paste(lsServerURL, "containers/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containers))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your containers. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveContainerLabel <- function(containerLabel) {
  response <- getURL(
    paste(lsServerURL, "containerlabels/", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerLabel))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your container label. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveContainerLabels <- function(containerLabels) {
  response <- getURL(
    paste(lsServerURL, "containerlabels/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerLabels))
    if (grepl("^<",response)) {
      stop (paste("The loader was unable to save your container labels. Instead, it got this response:", response))
    }
    response <- fromJSON(response)
    return(response)
}

saveContainerState <- function(containerState) {
  response <- getURL(
    paste(lsServerURL, "containerstates/", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerLabel))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your container state. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveContainerStates <- function(containerStates) {
  response <- getURL(
    paste(lsServerURL, "containerstates/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerLabels))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your container states. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveContainerContainerInteraction <- function(containerContainerInteraction){
  response <- getURL(
    paste(lsServerURL, "itxcontainercontainers/", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerContainerInteraction))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your interaction. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveContainerContainerInteractions <- function(containerContainerInteractions){
  response <- getURL(
    paste(lsServerURL, "itxcontainercontainers/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerContainerInteractions))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your interactions. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveSubjectContainerInteraction <- function(subjectContainerInteraction){
  response <- getURL(
    paste(lsServerURL, "itxsubjectcontainers/", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(subjectContainerInteraction))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your interaction. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveProtocolLabel <- function(containerLabel) {
  response <- getURL(
    paste(lsServerURL, "protocollabels/", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(containerLabel))
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your container label. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveAcasEntity <- function(entity, acasCategory) {
  # If you have trouble, make sure the acasCategory is all lowercase, has no spaces, and is plural
  message <- toJSON(entity)
  response <- getURL(
    paste(lsServerURL, acasCategory, sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste0("The loader was unable to save your ", acasCategory ,". Instead, it got this response: ", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveAcasEntities <- function(entities, acasCategory) {
  # If you have trouble, make sure the acasCategory is all lowercase, has no spaces, and is plural
  message <- toJSON(entities)
  response <- getURL(
    paste(lsServerURL, acasCategory, "/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste0("The loader was unable to save your ", acasCategory ,". Instead, it got this response: ", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveAnalysisGroupState <- function(analysisGroupState){
  message <- toJSON(analysisGroupState)
  response <- getURL(
    paste(lsServerURL, "analysisgroupstates", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your analysis group state. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveAnalysisGroupStates <- function(analysisGroupStates){
  message <- toJSON(analysisGroupStates)
  response <- getURL(
    paste(lsServerURL, "analysisgroupstates/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your analysis group states. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveExperimentState <- function(experimentState){
  message <- toJSON(experimentState)
  response <- getURL(
    paste(lsServerURL, "experimentstates", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your experiment state. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveExperimentStates <- function(experimentStates){
  message <- toJSON(experimentStates)
  response <- getURL(
    paste(lsServerURL, "experimentstates/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your experiment states. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveExperimentValue <- function(experimentValue){
  message <- toJSON(experimentValue)
  response <- getURL(
    paste(lsServerURL, "experimentvalues", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your experiment value. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveExperimentValues <- function(experimentValues){
  message <- toJSON(experimentValues)
  response <- getURL(
    paste(lsServerURL, "experimentvalues/jsonArray", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=message)
  if (grepl("^<",response)) {
    stop (paste("The loader was unable to save your experiment values. Instead, it got this response:", response))
  }
  response <- fromJSON(response)
  return(response)
}

saveLabelSequence <- function(labelSequence) {
  response <- getURL(
    paste(lsServerURL, "labelsequences", sep=""),
    customrequest='POST',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(labelSequence))
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
    postfields=toJSON(experiment))
  if(response!="") {
    stop (paste("The loader was unable to delete the old experiment. Instead, it got this response:", response))
  }
  return(response)
}

deleteExperimentValue <- function(experimentValue){
  response <- getURL(
    paste(lsServerURL, "experimentvalues/",experimentValue$id, sep=""),
    customrequest='DELETE',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(experimentValue))
  if(response!="") {
    stop (paste("The loader was unable to delete the experiment values. Instead, it got this response:", response))
  }
  return(response)
  
}

deleteAnalysisGroupState <- function(analysisGroupState) {
  response <- getURL(
    paste(lsServerURL, "analysisgroupstates/",analysisGroupState$id, sep=""),
    customrequest='DELETE',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(analysisGroupState))
  if(response!="") {
    stop (paste("The loader was unable to delete the old analysis group state. Instead, it got this response:", response))
  }
  return(response)
}

deleteEntity <- function(entity, acasCategory) {
  response <- getURL(
    paste(lsServerURL, acasCategory, "/", entity$id, sep=""),
    customrequest='DELETE',
    httpheader=c('Content-Type'='application/json'),
    postfields=toJSON(entity))
  if(response!="") {
    stop (paste0("The loader was unable to delete the ", acasCategory, ". Instead, it got this response: ", response))
  }
  return(response)
}