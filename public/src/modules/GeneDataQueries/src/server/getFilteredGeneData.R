# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getFilteredGeneData
require('RCurl')
require('rjson')
require('data.table')
require('racas')


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

      termsSQL <- rbind(termsSQL, list(termName, sqlQuery))

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
#postData <- '{"queryParams":{"batchCodes":"1,2,15,17","experimentCodeList":["PROT-00000026","EXPT-00000397","EXPT-00000398","EXPT-00000396","genomic","Root Node"],"searchFilters":{"booleanFilter":"advanced","advancedFilter":"","filters":[{"termName":"Q1","experimentCode":"EXPT-00000397","lsKind":"Result 7","lsType":"numericValue","operator":">","filterValue":"7"}]}},"maxRowsToReturn":"10000","user":"nouser"}'
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

if (postData.list$queryParams$searchFilters$booleanFilter == 'advanced'){
	termsSQL <- getSQLFromJSONFilterList(postData.list$queryParams$searchFilters$filters)
	advancedSqlQuery <- getFullSQLQuery(termsSQL, postData.list$queryParams$searchFilters$advancedFilter)
	searchParams$advancedFilterSQL <- advancedSqlQuery
}


dataCsv <- getURL(
  #	'http://localhost:8080/acas/experiments/agdata/batchcodelist/experimentcodelist?format=csv',
  paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/agdata/batchcodelist/experimentcodelist?format=csv&onlyPublicData=", onlyPublicData),
  customrequest='POST',
  httpheader=c('Content-Type'='application/json'),
  postfields=toJSON(searchParams))


dataDF <- read.csv(text = dataCsv, colClasses=c("character"))
dataDT <- as.data.table(dataDF)

pivotResults <- function(geneId, lsKind, result){
  exptSubset <- data.table(geneId, lsKind, result)
  setkey(exptSubset, geneId, lsKind)
  out <- exptSubset[CJ(unique(geneId), unique(lsKind))][, as.list(result), by=geneId]
  setnames(out, c("geneId", as.character(unique(exptSubset$lsKind))))
  return(out)
}

if (nrow(dataDT) > 0){
  firstPass <- TRUE
  for (expt in unique(dataDT$experimentId)){
    #print(paste0("current experiment ", expt))
    if(firstPass){
      outputDT <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId) ]
      experimentName <- dataDT[ experimentId == expt , unique(experimentName)]
      codeName <- as.character(unique(outputDT$experimentCodeName))
      outputDT <- subset(outputDT, ,-c(experimentCodeName, experimentId))
      colNames <- setdiff(names(outputDT),c("geneId"))
      setnames(outputDT, c("geneId", paste0(experimentName, "::", colNames)))
      firstPass <- FALSE
      colNamesDF <- unique(subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind)))
      allColNamesDF <- merge(data.frame(lsKind=colNames), colNamesDF)
      
    } else {
      outputDT2 <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId) ]
      experimentName <- dataDT[ experimentId == expt , unique(experimentName)]
      codeName <- as.character(unique(outputDT2$experimentCodeName))
      outputDT2 <- subset(outputDT2, ,-c(experimentCodeName, experimentId))
      colNames2 <- setdiff(names(outputDT2),c("geneId"))
      colNames <- c(colNames, colNames2)
      setnames(outputDT2, c("geneId", paste0(experimentName, "::", colNames2)))
      outputDT <- merge(outputDT, outputDT2, by="geneId", all=TRUE)
      colNamesDF2 <- unique(subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind)))
      colNamesDF2 <- merge(data.frame(lsKind=colNames2), colNamesDF2)
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
  
  allColNamesDT <- as.data.table(allColNamesDF)
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

