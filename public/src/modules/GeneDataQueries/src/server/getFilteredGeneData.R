# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getFilteredGeneData

#.libPaths('/opt/acas_home/app_1.4/acas/r_libs')

require('RCurl')
require('rjson')
require('data.table')
require('racas')
require('reshape2')

#setwd('/opt/acas_home/app_1.4/acas/public/src/modules/GeneDataQueries/src/server')
#setwd('/opt/acas_homes/acas/acas/public/src/modules/GeneDataQueries/src/server')
source('getSELColOrder.R')
source('getExperimentColOrder.R')

#.libPaths('/opt/acas_homes/acas/acas/r_libs')


myLogger <- createLogger(logName = "1",
                         logFileName = 'geneData.log',
                         logLevel = "DEBUG", logToConsole = FALSE)

#myLogger$debug("get getFilteredGeneData data initiated")

### FUNCTIONS #####

#' Returns a data.table with term names in one column and corresponding SQL statements in the other.
#'
#' @param searchFilters This is a list of filters from a JSON string.
#' @return Outputs a data.table
#' @keywords JSON SQL, Advanced Query
#' @export
getSQLFromJSONFilterList <- function(searchFilters) {
  
  termsSQL <- data.table()
  filterList <- 1
    for (filterList in 1:length(searchFilters)) {
      sqlQuery <- "(SELECT tested_lot FROM api_experiment_results WHERE "
      if (!is.null(searchFilters[[filterList]]$termName)) {
        termName <- searchFilters[[filterList]]$termName
      } else {
        stop("Filter termName not specified.")
      }
      if (!is.null(searchFilters[[filterList]]$experimentCode)) {
        sqlQuery <- paste0(sqlQuery, "expt_code_name='", searchFilters[[filterList]]$experimentCode, "' AND")
      }
      if (!is.null(searchFilters[[filterList]]$lsKind)) {
        sqlQuery <- paste0(sqlQuery, " ls_kind='", searchFilters[[filterList]]$lsKind, "' AND")
      }

      if (!is.null(searchFilters[[filterList]]$lsType)) {
        sqlQuery <- paste0(sqlQuery, " ls_type='", searchFilters[[filterList]]$lsType, "' AND")
      }

      if (!is.null(searchFilters[[filterList]]$lsType) &&
           !is.null(searchFilters[[filterList]]$operator) &&
           !is.null(searchFilters[[filterList]]$filterValue)) {
        if(searchFilters[[filterList]]$lsType == "numericValue") {
          sqlQuery <- paste0(sqlQuery, " numeric_value", searchFilters[[filterList]]$operator, searchFilters[[filterList]]$filterValue, " AND")
        } else {
          stop(paste0("ls Type ", searchFilters[[filterList]]$lsType, " not defined yet"))
        }
      } else if (!is.null(searchFilters[[filterList]]$lsType) |
                   !is.null(searchFilters[[filterList]]$operator) |
                   !is.null(searchFilters[[filterList]]$filterValue)) {
        stop("lsType/operator/filterValue not completely defined")
      }

      # checks to see if the query string ends with " AND"
      if (substr(sqlQuery, start=nchar(sqlQuery)-3, stop=nchar(sqlQuery))==" AND") {
        sqlQuery <- paste0(substr(sqlQuery, start=1, stop=nchar(sqlQuery)-4), ")")
      } else {
        sqlQuery <- paste0(sqlQuery, ")")
      }
      # print(sqlQuery)
      # print(filterList)
      # print(searchFilters[[filterList]])

      #termsSQL <- rbind(termsSQL, list(termName, sqlQuery))

	  if (filterList == 1){
	      termsSQL <- as.data.table(list(termName, sqlQuery))
	  } else {
	      termsSQL <- rbind(termsSQL, list(termName, sqlQuery))
	  }

    }

    setnames(termsSQL, colnames(termsSQL), c("tableTermName", "tableSQLQuery"))
  return(termsSQL)
}

#' Returns a sqlString that can be used to query against a server.
#'
#' @param termsSQL This is a data.table with term names in one column and sql strings in the other.
#' @param inputString This is an advanced query string. Example: '(Q1 and Q2) or (Q3 and Q4)'
#' @return Outputs a sqlString
#' @keywords JSON SQL, Advanced Query
#' @export
getFullSQLQuery <- function(termsSQL, sqlString) {
  sqlString <- toupper(sqlString)

  sqlString <- gsub(" AND ", " INTERSECT ", sqlString)
  sqlString <- gsub(" OR ", " UNION ", sqlString)
  sqlString <- gsub(" NOT ", " EXCEPT ", sqlString) # alternate SQL servers: s/except/minus
  sqlString <- gsub(" MINUS ", " EXCEPT ", sqlString) # alternate SQL servers: s/except/minus
  sqlString <- gsub(" EXCEPT ", " EXCEPT ", sqlString) # alternate SQL servers: s/except/minus

  for (rowSubstitute in 1:nrow(termsSQL)) {
    sqlString <- gsub(termsSQL[rowSubstitute, tableTermName], termsSQL[rowSubstitute, tableSQLQuery], sqlString)
  }


  return(sqlString)
}


### END FUNCTIONS #####

    
if(is.null(GET$format)){
  exportCSV <- FALSE
  onlyPublicData <- "true"
} else {
  exportCSV <- ifelse(GET$format == "CSV", TRUE, FALSE)
  onlyPublicData <- "false"
}


postData <- rawToChar(receiveBin())

myLogger$debug(postData)

#postData <- '{"queryParams":{"batchCodes":"29 60","experimentCodeList":["EXPT-00017","tags_EXPT-00017","PROT-00014","_External data_Published Influenza Datasets"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#postData <- '{"queryParams":{"batchCodes":"","experimentCodeList":["EXPT-00000039"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#exportCSV <- TRUE
#onlyPublicData <- "false"


postData.list <- fromJSON(postData)


batchCodeList <- list()
if (!is.null(postData.list$queryParams$batchCodes)) {
  geneData <- postData.list$queryParams$batchCodes
  geneDataList <- strsplit(geneData, split="\\W")[[1]]
  geneDataList <- geneDataList[geneDataList!=""]
  
  if (length(geneDataList) > 0) {
    requestList <- list()
    for (i in 1:length(geneDataList)){
      requestList[[length(requestList)+1]] <- list(requestName=geneDataList[[i]])
    }
    requestObject <- list()
    requestObject$requests <- requestList
    geneNameList <- getURL(
      #			paste0("http://localhost:8080/acas/lsthings/getGeneCodeNameFromNameRequest"),
      paste0(racas::applicationSettings$client.service.persistence.fullpath, "lsthings/getGeneCodeNameFromNameRequest"),
      customrequest='POST',
      httpheader=c('Content-Type'='application/json'),
      postfields=toJSON(requestObject))
    
    genes <- fromJSON(geneNameList)$results
    batchCodeList <- list()
    for (i in 1:length(genes)){
      if (genes[[i]]$referenceName != ""){
        batchCodeList[[length(batchCodeList)+1]] <- genes[[i]]$referenceName
      }
    }
  }
}

searchParams <- list()
if (length(postData.list$queryParams$experimentCodeList) > 1){
  searchParams$experimentCodeList <- postData.list$queryParams$experimentCodeList
  
} else {
  searchParams$experimentCodeList <- list()
  searchParams$experimentCodeList[1] <- postData.list$queryParams$experimentCodeList
}
searchParams$batchCodeList <- batchCodeList
searchParams$searchFilters <- postData.list$queryParams$searchFilters$filters
searchParams$booleanFilter <- postData.list$queryParams$searchFilters$booleanFilter
searchParams$advancedFilter <- postData.list$queryParams$searchFilters$advancedFilter


save(searchParams,file="searchParams.rda")

if (postData.list$queryParams$searchFilters$booleanFilter == 'advanced'){
	termsSQL <- getSQLFromJSONFilterList(postData.list$queryParams$searchFilters$filters)
#myLogger$debug("here is the termsSQL")
#myLogger$debug(termsSQL)


	advancedSqlQuery <- getFullSQLQuery(termsSQL, postData.list$queryParams$searchFilters$advancedFilter)
#myLogger$debug("here is the advancedSqlQuery")
#myLogger$debug(advancedSqlQuery)
	searchParams$advancedFilterSQL <- advancedSqlQuery
}

myLogger$debug("here is the final searchParams")
myLogger$debug(toJSON(searchParams))
myLogger$debug(searchParams)


serverURL <- racas::applicationSettings$client.service.persistence.fullpath
dataCsv <- getURL(
  paste0(serverURL, "experiments/agdata/batchcodelist/experimentcodelist?format=csv&onlyPublicData=", onlyPublicData),
  customrequest='POST',
  httpheader=c('Content-Type'='application/json'),
  postfields=toJSON(searchParams))
  
myLogger$debug("dataCsv is:")
myLogger$debug(dataCsv)

errorFlag <- FALSE
tryCatch({
  dataDF <- read.csv(text = dataCsv, colClasses=c("character"))},
  error = function(ex) {
  errorFlag <<- TRUE
})

if (errorFlag){
        dataDT <- data.table()
} else {
        dataDT <- as.data.table(dataDF)
}


pivotResults <- function(geneId, lsKind, result){
  exptSubset <- data.table(geneId, lsKind, result)
  answers <- dcast.data.table(exptSubset, geneId ~ lsKind, value.var=c("result"),fun.aggregate = paste, sep="<br>",collapse= "<br>")
  return(answers)
}


# A function to take in a string and round using signif() if possible before converting back to a string.
# if the string cannot be coersed into a numeric type, the original string is returned as is.
# e.g roundString("retest", 3) = "retest"
#     roundString("128479823", 3) = "1.28e+08"
roundString <- function(string,sigfigs){
  num <- as.numeric(string)
  if (!is.na(num)){
    return(as.character(signif(num,sigfigs)))
  }else{
    return(string)
  }
}


if (nrow(dataDT) > 0){
  firstPass <- TRUE
  experimentIdDT <- unique(subset(dataDT, ,sel=c(experimentId, experimentCodeName)))
  setkey(experimentIdDT, experimentCodeName)
  experimentIdList <- experimentIdDT$experimentId
  for (expt in experimentIdList){
    myLogger$debug(paste0("current experiment ", expt))
    if(firstPass){
      
      save(dataDT,file="dataDT.Rda")
      
      # Modify lsKind to include units and concentration info as well (if it exists)
      for (i in 1:nrow(dataDT)){
        if (dataDT[["resultUnit"]][i] != ""){
          dataDT[["lsKind"]][i]<-paste(dataDT[["lsKind"]][i]," (",dataDT[["resultUnit"]][i],") ",sep='')
        }
        if (dataDT[["testedConcentration"]][i] != "") {
          dataDT[["lsKind"]][i]<-paste(dataDT[["lsKind"]][i],"at",dataDT[["testedConcentration"]][i],dataDT[["testedConcentrationUnit"]][i],sep=" ")
        }
      }
      
      # Keep only 4 sig-figs if displying in browser
      if (!exportCSV){
        options( scipen = -2 ) #This is to force scientific notation more often
        dataDT[["result"]] <- sapply(dataDT[["result"]],function(x) roundString(x,4))
      }
      
      # Add operators to the front of result if they exist
      dataDT[["result"]] <- paste(dataDT[["operator"]],dataDT[["result"]],sep = '')
      
      outputDT <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId, experimentName) ]  
  		save(outputDT,file="outputDT.Rda")
      experimentName <- as.character(unique(outputDT$experimentName))
  		
      codeName <- as.character(unique(outputDT$experimentCodeName))
  		outputDT <- subset(outputDT, ,-c(experimentCodeName, experimentId, experimentName)) 
  
      # Add a column with the compound structure
      # TODO replace hard-coded url with a reference to the config.properties
      
      # For HTML display include <tags>. For csv just give the url.
      if (!exportCSV){
  		  outputDT <- cbind(outputDT, StructureImage=sapply(outputDT[["geneId"]],function(x) paste0('<img src="http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/',x,'">')))
      }else{
        outputDT <- cbind(outputDT, StructureImage=sapply(outputDT[["geneId"]],function(x) paste0("http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/",x)))
      }
      
  		exptDataColumns <- getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV) 
      save(exptDataColumns,file="exptData1.Rda")
#       exptDataColumns <- intersect(exptDataColumns, names(outputDT))

      # Can't take intersect anymore because lsKind might be modified with concentration info.
      # Instead use sapply and grep to keep values of exptDataColums which have a value of outputDT as part of their name (in the same order as exptDataColums)
      # unique(paste(unlist(...))) just ensures the the output is a single-demensional list with no duplicates (like the result of intersect)
      exptDataColumns <- unique(paste(unlist(sapply(exptDataColumns,function(x) grep(x,names(outputDT),value=TRUE)))))
      
      # Get names of inlineFileValue thigs if they exist (e.g. Western Blots) and add them to exptDataColums
      fileValues <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & experimentId == expt,lsKind))))
      exptDataColumns <- c(exptDataColumns,fileValues)

      # Replace inlineFileValue with a link to the file
      for (i in fileValues){
        outputDT[[i]] <- sapply(outputDT[[i]],function(x) paste0('<img src="http://192.168.99.100:3000/dataFiles/',x,'">'))
      }

  		myLogger$debug("exptDataColumns is:")
  		myLogger$debug(exptDataColumns)
      save(exptDataColumns, file="exptData2.Rda")
  		
  		#setcolorder(outputDT, c("geneId",exptDataColumns))
   		outputDT <- subset(outputDT, ,sel=c("geneId","StructureImage", exptDataColumns))   

      # Try to convert curve id values into images from the server. If there is no "curve id" column, try fails and nothing happens
      # For csv, only output url, without html tags
      # TODO replace hard-coded url with a reference to config.properties
      if (!exportCSV){
        try(outputDT[["curve id"]] <- sapply(outputDT[["curve id"]],function(x) paste0('<a href="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=',x,'&showAxes=true&labelAxes=true" target="_blank"><img src="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=180&width=375&curveIds=',x,'&showAxes=true&labelAxes=true"></a>')),TRUE)
      }else{
        try(outputDT[["curve id"]] <- sapply(outputDT[["curve id"]],function(x) paste0("http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=",x,"&showAxes=true&labelAxes=true")),TRUE)
      }

  		for (colName in exptDataColumns){
  			setnames(outputDT, colName, paste0(experimentName, "::", colName))
  		}
  		firstPass <- FALSE
  
  		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))		
  		orderCols$order <- as.integer(as.character(orderCols$order))
  		
  		colNamesDF <- subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind))
      colNamesDF <- unique(colNamesDF)
      # Get rid of any columns that have the same lsKind (e.g. two "Slope" will appear if some values are strings and some are numbers)
      colNamesDF <- subset(colNamesDF,!duplicated(colNamesDF[["lsKind"]]))
  
  		allColNamesDF <- merge(colNamesDF, orderCols, by="lsKind")
  		allColNamesDF <- allColNamesDF[order(allColNamesDF$order),]

    } else {
  		myLogger$debug(paste0("current firstPass ", firstPass))
  		outputDT2 <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId, experimentName) ]
  		myLogger$debug(paste0("current outputDT2 ", nrow(outputDT2)))
  		myLogger$debug(paste0("current outputDT2 ", names(outputDT2)))
  
  		experimentName <- as.character(unique(outputDT2$experimentName))
  		codeName <- as.character(unique(outputDT2$experimentCodeName))
  		outputDT2 <- subset(outputDT2, ,-c(experimentCodeName, experimentId, experimentName))
  
  		if (!exportCSV){
  		  outputDT2 <- cbind(outputDT2, StructureImage=sapply(outputDT2[["geneId"]],function(x) paste0('<img src="http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/',x,'">')))
  		}else{
  		  outputDT2 <- cbind(outputDT2, StructureImage=sapply(outputDT2[["geneId"]],function(x) paste0("http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/",x)))
  		}
      
  		exptDataColumns <- getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV)
#   		exptDataColumns <- intersect(exptDataColumns, names(outputDT2))
      # See note at line 268
      exptDataColumns <- unique(paste(unlist(sapply(exptDataColumns,function(x) grep(x,names(outputDT2),value=TRUE)))))

      # Get names of inlineFileValue thigs if they exist (e.g. Western Blots) and add them to exptDataColums
      fileValues <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & experimentId == expt,lsKind))))
      exptDataColumns <- c(exptDataColumns,fileValues)

      for (i in fileValues){
        outputDT2[[i]] <- sapply(outputDT2[[i]],function(x) paste0('<img src="http://192.168.99.100:3000/dataFiles/',x,'">'))
      }


  		#setcolorder(outputDT2, c("geneId",exptDataColumns))
  		outputDT2 <- subset(outputDT2, ,sel=c("geneId","StructureImage",exptDataColumns))
  
  		# Try to convert curve id values into images from the server. If there is no "curve id" column, try fails and nothing happens
  		# TODO replace hard-coded url with a reference to config.properties
      if (!exportCSV){
        try(outputDT2[["curve id"]] <- sapply(outputDT2[["curve id"]],function(x) paste0('<a href="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=',x,'&showAxes=true&labelAxes=true" target="_blank"><img src="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=180&width=375&curveIds=',x,'&showAxes=true&labelAxes=true"></a>')),TRUE)
      }else{
        try(outputDT2[["curve id"]] <- sapply(outputDT2[["curve id"]],function(x) paste0("http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=",x,"&showAxes=true&labelAxes=true")),TRUE)
      }  		
      for (colName in exptDataColumns){
  			setnames(outputDT2, colName, paste0(experimentName, "::", colName))
  		}
  		outputDT <- merge(outputDT, outputDT2, by=c("geneId","StructureImage"), all=TRUE)
  		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))
  		orderCols$order <- as.integer(as.character(orderCols$order))
  		colNamesDF2 <- unique(subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind)))
  		#   Get rid of any columns that have the same lsKind (e.g. two Slopes will appear if some values are strings and some are numbers, this gets rid of that)
  		colNamesDF2 <- subset(colNamesDF2,!duplicated(colNamesDF2[["lsKind"]]))
      save(orderCols,file="orderCols2.Rda")
  		colNamesDF2 <- merge(colNamesDF2, orderCols, by="lsKind")
  		colNamesDF2 <- colNamesDF2[order(colNamesDF2$order),]
  		allColNamesDF <- rbind(allColNamesDF, colNamesDF2)
      }
  }


  
  outputDF <- as.data.frame(outputDT)
  names(outputDF) <- NULL
  outputDT.list <- as.list(as.data.frame(t(outputDF)))
  names(outputDT.list) <- NULL
  
  
  setType <- function(lsType){
    if (lsType == "stringValue"){
      sType <- "string"
    } else {
      sType <- "numeric"
    }
    return(sType)
  }
  
  allColNamesDF$originalOrder <- seq(1:nrow(allColNamesDF))
  allColNamesDT <- as.data.table(allColNamesDF)
  allColNamesDT[ , exptColName := paste0(experimentName, '::', lsKind)]
  allColNamesDT[ , sType := setType(lsType), by=list(lsKind, experimentId)]
  allColNamesDT[ , numberOfColumns := length(lsKind), by=list(experimentId)]
  allColNamesDT[ , titleText := experimentName, by=list(experimentId)]
  allColNamesDT$sClass <- "center"
  setnames(allColNamesDT, "lsKind", "sTitle")
  
  aoColumnsDF <- as.data.frame(subset(allColNamesDT, ,select=c(sTitle, sClass)))
  aoColumnsDF <- rbind(data.frame(sTitle="Compound Structure", sClass="center"), aoColumnsDF)
  aoColumnsDF <- rbind(data.frame(sTitle="ID", sClass="center"), aoColumnsDF)
  
  
  groupHeadersDF <- unique(as.data.frame(subset(allColNamesDT, ,select=c(numberOfColumns, titleText))))
  groupHeadersDF <- rbind(data.frame(numberOfColumns=2, titleText='Compound Information'), groupHeadersDF)
  
  aoColumnsDF.list <- as.list(as.data.frame(t(aoColumnsDF)))
  names(aoColumnsDF.list) <- NULL
  
  groupHeadersDF.list <- as.list(as.data.frame(t(groupHeadersDF)))
  names(groupHeadersDF.list) <- NULL
  
  responseJson <- list()
  responseJson$results$data$aaData <- outputDT.list
  responseJson$results$data$iTotalRecords <- nrow(outputDT)
  responseJson$results$data$iTotalDisplayRecords <- nrow(outputDT)
  responseJson$results$data$aoColumns <- aoColumnsDF.list
  responseJson$results$data$groupHeaders <- groupHeadersDF.list
  responseJson$results$htmlSummary <- "OK"
  responseJson$hasError <- FALSE
  responseJson$hasWarning <- FALSE
  responseJson$errorMessages <- list()
  setStatus(status=200L)
  
} else {
  
  responseJson <- list()
  responseJson$results$data$aaData <- list()
  responseJson$results$data$iTotalRecords <- 0
  responseJson$results$data$iTotalDisplayRecords <- 0
  responseJson$results$data$aoColumns <- list()
  responseJson$results$data$groupHeaders <- list()
  responseJson$results$htmlSummary <- "NO Resulsts"
  responseJson$hasError <- TRUE	
  responseJson$hasWarning <- FALSE
  error1 <- list(errorLevel="error", message="No results found.")
  error2 <- list(errorLevel="error", message="Please load more data.")
  responseJson$errorMessages <- list(error1, error2)
  setStatus(status=506L)
  
}

if (exportCSV){
  setHeader("Access-Control-Allow-Origin" ,"*");
  setContentType("application/text")
  write.csv(outputDT, file="", row.names=FALSE, quote=TRUE)
  
} else {
  setHeader("Access-Control-Allow-Origin" ,"*");
  setContentType("application/json")
  cat(toJSON(responseJson))
}
    


