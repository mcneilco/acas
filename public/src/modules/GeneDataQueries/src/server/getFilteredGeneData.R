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


myLogger <- createLogger(logName = "com.acas.get.getFilteredGeneData",
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
exportCSV <- FALSE
onlyPublicData <- "true"


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

#myLogger$debug("here is the final searchParams")
#myLogger$debug(toJSON(searchParams))
#myLogger$debug(searchParams)


serverURL <- racas::applicationSettings$client.service.persistence.fullpath
#serverURL <- "http://host5.labsynch.com:8080/acas-1.4/"
dataCsv <- getURL(
  paste0(serverURL, "experiments/agdata/batchcodelist/experimentcodelist?format=csv&onlyPublicData=", onlyPublicData),
  customrequest='POST',
  httpheader=c('Content-Type'='application/json'),
  postfields=toJSON(searchParams))


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
  answers <- dcast.data.table(exptSubset, geneId ~ lsKind, value.var=c("result") )
  return(answers)
}


if (nrow(dataDT) > 0){
  firstPass <- TRUE
  experimentIdDT <- unique(subset(dataDT, ,sel=c(experimentId, experimentCodeName)))
  setkey(experimentIdDT, experimentCodeName)
  experimentIdList <- experimentIdDT$experimentId
  for (expt in experimentIdList){
    myLogger$debug(paste0("current experiment ", expt))
    if(firstPass){
		outputDT <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId, experimentName) ]
		experimentName <- as.character(unique(outputDT$experimentName))
		codeName <- as.character(unique(outputDT$experimentCodeName))
		outputDT <- subset(outputDT, ,-c(experimentCodeName, experimentId, experimentName))
		exptDataColumns <- getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV)
		#setcolorder(outputDT, c("geneId",exptDataColumns))
		outputDT <- subset(outputDT, ,sel=c("geneId",exptDataColumns))

		for (colName in exptDataColumns){
			setnames(outputDT, colName, paste0(experimentName, "::", colName))
		}
		firstPass <- FALSE

		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))
		orderCols$order <- as.integer(as.character(orderCols$order))
		colNamesDF <- unique(subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind)))
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
		exptDataColumns <- getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV)
		myLogger$debug(paste0("current experimentCodeName ", codeName))
		myLogger$debug(paste0("current exptDataColumns ", exptDataColumns))

		#setcolorder(outputDT2, c("geneId",exptDataColumns))
		outputDT2 <- subset(outputDT2, ,sel=c("geneId",exptDataColumns))
		for (colName in exptDataColumns){
			setnames(outputDT2, colName, paste0(experimentName, "::", colName))
		}
		outputDT <- merge(outputDT, outputDT2, by="geneId", all=TRUE)
		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))
		orderCols$order <- as.integer(as.character(orderCols$order))
		colNamesDF2 <- unique(subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind)))
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
  aoColumnsDF <- rbind(data.frame(sTitle="Gene ID", sClass="center"), aoColumnsDF)
  
  
  groupHeadersDF <- unique(as.data.frame(subset(allColNamesDT, ,select=c(numberOfColumns, titleText))))
  groupHeadersDF <- rbind(data.frame(numberOfColumns=1, titleText=' '), groupHeadersDF)
  
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

