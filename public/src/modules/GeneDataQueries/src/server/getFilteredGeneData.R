
require('RCurl')
require('rjson')
require('data.table')
require('racas')

if(is.null(GET$format)){
  exportCSV <- FALSE
} else {
  exportCSV <- ifelse(GET$format == "CSV", TRUE, FALSE)
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


dataCsv <- getURL(
  #	'http://localhost:8080/acas/experiments/agdata/batchcodelist/experimentcodelist?format=csv',
  paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/agdata/batchcodelist/experimentcodelist?format=csv"),
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
  allColNamesDT[ , titleText := paste0(experimentCodeName, ": ", experimentName), by=list(experimentId)]
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

