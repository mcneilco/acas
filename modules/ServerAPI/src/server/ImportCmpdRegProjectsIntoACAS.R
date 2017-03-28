## Tranfer projects from CReg to ACAS
## query projects from CReg and populate projects in ACAS
## run this R script directly on the ACAS server as the acas user
##

## TODO: transfer CReg scientists to ACAS authors
## TODO: Assign roles to ACAS authors


library(racas)
library(RCurl)
library(jsonlite)
library(rjson)
library(data.table)

#configList <- racas::applicationSettings
#client.service.cmpdReg.persistence.basepath
#racas::applicationSettings$client.service.persistence.fullpath

checkIfProjectExists <- function(projectName=""){
	projectCurlURL <- paste0(racas::applicationSettings$client.service.persistence.fullpath,"lsthings/project/project?with=stub&labelType=name&labelKind=project name&labelText=")
	fullProjectURL <- URLencode(paste0(projectCurlURL, projectName))
	responseJSON <- getURL(fullProjectURL)
	projects <- fromJSON(responseJSON)
	foundProject <- FALSE
	if (length(projects) > 0) {
	  foundProject <- TRUE
	}
	return(foundProject)
}

createThingLabel <- function(labelText, author, lsType, lsKind, lsTransaction=NULL, preferred=TRUE, ignored=FALSE){
	thingLabel = list(
		labelText=labelText,
	  	recordedBy=author,
	    lsType=lsType,
		lsKind=lsKind,
		preferred=preferred,
		ignored=ignored,
		lsTransaction=lsTransaction,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)
	return(thingLabel)
}

createStateValue <- function(lsType="lsType", lsKind="lsKind", stringValue=NULL, fileValue=NULL,
                             urlValue=NULL, publicData=TRUE, ignored=FALSE,
                             dateValue=NULL, clobValue=NULL, blobValue=NULL, concentration=NULL,
                             concUnit=NULL, valueOperator=NULL, operatorType=NULL, numericValue=NULL,
                             sigFigs=NULL, uncertainty=NULL, uncertaintyType=NULL,
                             numberOfReplicates=NULL, valueUnit=NULL, unitType=NULL, comments=NULL,
                             lsTransaction=NULL, codeValue=NULL, recordedBy="username",
                             lsState=NULL, testMode=FALSE, recordedDate=as.numeric(format(Sys.time(), "%s"))*1000,
                             codeType = NULL, codeKind = NULL, codeOrigin = NULL){
  #TODO: use unitType and operatorType
  stateValue = list(
    lsState=lsState,
    lsType=lsType,
    lsKind=lsKind,
    lsTypeAndKind=paste0(lsType,'_',lsKind),
    stringValue=stringValue,
    fileValue=fileValue,
    urlValue=urlValue,
    dateValue=dateValue,
    clobValue=clobValue,
    blobValue=blobValue,
    concentration=concentration,
    concUnit=concUnit,
    operatorKind=valueOperator,
    operatorType=if(is.null(valueOperator)) NULL else "comparison",
    numericValue=numericValue,
    sigFigs=sigFigs,
    uncertainty=uncertainty,
    uncertaintyType=uncertaintyType,
    numberOfReplicates=numberOfReplicates,
    unitKind=valueUnit,
    comments=comments,
    ignored=ignored,
    publicData=publicData,
    codeValue=codeValue,
    codeOrigin=codeOrigin,
    codeType=codeType,
    codeKind=codeKind,
    recordedBy=recordedBy,
    recordedDate=if(testMode) 1376954591000 else recordedDate,
    lsTransaction=lsTransaction
  )
  return(stateValue)
}

createProject <- function(projectName, authorName, lsTransaction){
	projectName <- projectName
	authorName <- authorName
	setProjectNameEqualProjectName <- TRUE
	newProject = list(
	  	recordedBy=authorName,
		lsType='project',
		lsKind='project',
		lsTransaction=lsTransaction$id,
		recordedDate=as.numeric(format(Sys.time(), "%s"))*1000
	)

	if (setProjectNameEqualProjectName) newProject$codeName <- projectName
	newThingLabels <- list()
	newThingLabel <- createThingLabel(labelText=projectName, author=authorName, lsType="name", lsKind="project name", lsTransaction= lsTransaction$id)
	newThingLabels[[length(newThingLabels)+1]] <- newThingLabel
	newThingLabel <- createThingLabel(labelText=projectName, author=authorName, lsType="name", lsKind="project alias", lsTransaction= lsTransaction$id)
	newThingLabels[[length(newThingLabels)+1]] <- newThingLabel

	lsValues <- list()
	lsValues[[1]] <- createStateValue(lsState=NULL, lsType='codeValue', lsKind='is restricted', codeValue='false',
	                                  codeType='project', codeKind = 'restricted', codeOrigin = 'ACAS DDICT', recordedBy=authorName)
	thingStates <- list()
	thingStates[[1]] <- createLsState(lsValues=lsValues, recordedBy=authorName, lsType="metadata", lsKind="project metadata", comments="", lsTransaction=lsTransaction$id)

	newProject$lsStates <- thingStates
	newProject$lsLabels <- newThingLabels
	response <- getURL(
		  paste(lsServerURL, "lsthings/project/project", sep=""),
		  customrequest='POST',
		  httpheader=c("Content-Type"="application/json", "Accept"="application/json"),
		  postfields=rjson::toJSON(newProject))
	return(response)
}

checkOrCreateProject <- function(projectName="Project 1", authorName, lsTransaction){
	if (!checkIfProjectExists(projectName)){
		createProject(projectName, authorName, lsTransaction)
	}

}


createProjectRoleType <- function(typeName='Project'){
	roleTypes <- list()
	newRoleType = list(
		typeName = typeName
		)
	roleTypes[[1]] <- newRoleType
	response <- getURL(
		  paste(lsServerURL, "setup/roletypes", sep=""),
		  customrequest='POST',
		  httpheader=c("Content-Type"="application/json", "Accept"="application/json"),
		  postfields=rjson::toJSON(roleTypes))
	return(response)
}


createProjectRoleKind <- function(projectName){
	roleKinds <- list()
	newRoleKind = list(
		typeName = 'Project',
		kindName = projectName
		)
	roleKinds[[1]] <- newRoleKind
	response <- getURL(
		  paste(lsServerURL, "setup/rolekinds", sep=""),
		  customrequest='POST',
		  httpheader=c("Content-Type"="application/json", "Accept"="application/json"),
		  postfields=rjson::toJSON(roleKinds))
	return(response)
}

createProjectRoles <- function(projectName){
	projectRoles <- list()
	userRole = list(
		lsType = 'Project',
		lsKind = projectName,
		roleName = "User"
		)
	projectRoles[[length(projectRoles)+1]] <- userRole

	adminRole = list(
		lsType = 'Project',
		lsKind = projectName,
		roleName = "Administrator"
		)
	projectRoles[[length(projectRoles)+1]] <- adminRole

	response <- getURL(
		  paste(lsServerURL, "setup/lsroles", sep=""),
		  customrequest='POST',
		  httpheader=c("Content-Type"="application/json", "Accept"="application/json"),
		  postfields=rjson::toJSON(projectRoles))
	return(response)
}


	## get CReg projects
cRegBaseURL <- racas::applicationSettings$client.service.cmpdReg.persistence.basepath
cRegProjectURL <- paste0(cRegBaseURL,'/projects')
responseJSON <- getURL(cRegProjectURL)
cRegProjects <- jsonlite::fromJSON(responseJSON,simplifyDataFrame=TRUE)
cRegProjectsDT <- as.data.table(cRegProjects, stringsAsFactors=FALSE)

authorName <- "jmcneil"
lsServerURL <- racas::applicationSettings$client.service.persistence.fullpath
lsTransaction <- createLsTransaction("creating projects")

cRegProjectsDT[ , checkOrCreateProject(name, authorName, lsTransaction), by=code]

createProjectRoleType('Project')
cRegProjectsDT[ , createProjectRoleKind(name), by=code]
cRegProjectsDT[ , createProjectRoles(name), by=code]

