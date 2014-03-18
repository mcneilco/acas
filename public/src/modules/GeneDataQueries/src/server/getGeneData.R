
require('RCurl')
require('rjson')
require('data.table')
require('racas')

configList <- racas::applicationSettings

str(GET) ## to see the values that are passed into the GET params

exportCSV <- as.boolean(GET$exportCSV)

postData <- rawToChar(receiveBin(1024))
postData.list <- fromJSON(postData)
genes <- postData.list$geneIDs

convertToChar <- function(input){
	lapply(input, as.character)
}
genes.char <- lapply(genes, convertToChar)
genes.Json <- toJSON(genes.char)

dataCsv <- getURL(
	paste0(configList$client.service.persistence.fullpath, "analysisgroupvalues/geneCodeData?format=csv"),
	customrequest='POST',
	httpheader=c('Content-Type'='application/json'),
	postfields=genes.Json)

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
			codeName <- as.character(unique(outputDT$experimentCodeName))
			outputDT <- subset(outputDT, ,-c(experimentCodeName, experimentId))
			colNames <- setdiff(names(outputDT),c("geneId"))
			setnames(outputDT, c("geneId", paste0(codeName, "_", colNames)))
			firstPass <- FALSE
			colNamesDF <- unique(subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind)))
			allColNamesDF <- merge(data.frame(lsKind=colNames), colNamesDF)
	
		} else {
			outputDT2 <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId) ]
			codeName <- as.character(unique(outputDT2$experimentCodeName))
			outputDT2 <- subset(outputDT2, ,-c(experimentCodeName, experimentId))
			colNames2 <- setdiff(names(outputDT2),c("geneId"))
			colNames <- c(colNames, colNames2)
			setnames(outputDT2, c("geneId", paste0(codeName, "_", colNames2)))
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
	responseJson$errorMessages <- "[]"
	setStatus(status=200L)

} else {

	responseJson <- list()
	responseJson$results$data$aaData <- '[]'
	responseJson$results$data$iTotalRecords <- 0
	responseJson$results$data$iTotalDisplayRecords <- 0
	responseJson$results$data$aoColumns <- '[]'
	responseJson$results$data$groupHeaders <- '[]'
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
    setContentType("application/json")
    print(outputDF)
} else {
    setHeader("Access-Control-Allow-Origin" ,"*");
    setContentType("application/json")
    cat(toJSON(responseJson))
}




