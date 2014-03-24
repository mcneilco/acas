
require('RCurl')
require('rjson')

postData <- rawToChar(receiveBin(1024))

#postData <- '{"batchCodes":"GENE-000017, GENE-000002"}'
postData <- '{"batchCodes":"1, 2; 15, blah"}'
#postData <- '{"batchCodes":""}'

geneData <- fromJSON(postData)$batchCodes
geneData <- gsub(";|\t|\n", ",", geneData)
geneData <- gsub(" ", "", geneData)

geneDataList <- strsplit(geneData, split=",")[[1]]

if (length(geneDataList) > 0) {
	requestList <- list()
	for (i in 1:length(geneDataList)){
	   requestList[[length(requestList)+1]] <- list(requestName=geneDataList[[i]])
	}

	requestObject <- list()
	requestObject$requests <- requestList

	inputString <- '{"requests":[{"requestName":"1"}, {"requestName":"2"}, {"requestName":"15"}, {"requestName":"blah"}]}'
	geneNameList <- getURL(
		paste0("http://host3.labsynch.com:8080/acas/lsthings/getGeneCodeNameFromNameRequest"),
		customrequest='POST',
		httpheader=c('Content-Type'='application/json'),
		postfields=toJSON(requestObject))

	genes <- fromJSON(geneNameList)$results
	batchCodeList <- list()
	for (i in 1:length(genes)){
	   if (genes[[i]]$referenceName != ""){
	      batchCodeList[[length(batchCodeList)+1]] <- list(batchCode=genes[[i]]$referenceName)
	   }
	}

	if (length(batchCodeList) > 0){
	    batchCodes <- list()
	    for (i in 1:length(batchCodeList)){
	        batchCodes[[length(batchCodes)+1]] <- batchCodeList[[i]]
	    }
	    batchCodes.Json <- toJSON(batchCodes)
	} else {
	    batchCodes.Json <- '[]'
	}

} else {

	    batchCodes.Json <- '[]'
}



experimentNodes <- getURL(
	paste0("http://host3.labsynch.com:8080/acas/experiments/jstreenodes/jsonArray"),
	customrequest='POST',
	httpheader=c('Content-Type'='application/json'),
	postfields=batchCodes.Json)


if (length(fromJSON(experimentNodes)) > 1){

	responseJson <- list()
	responseJson$results$experimentData <- fromJSON(experimentNodes)
	responseJson$results$htmlSummary <- "OK"
	responseJson$hasError <- FALSE
	responseJson$hasWarning <- FALSE
	responseJson$errorMessages <- list()
	setStatus(status=200L)

} else {

	responseJson <- list()
	responseJson$results$experimentData <- list()
	responseJson$results$htmlSummary <- "NO Results"
	responseJson$hasError <- TRUE	
	responseJson$hasWarning <- FALSE
	error1 <- list(errorLevel="error", message="No results found.")
	error2 <- list(errorLevel="error", message="Please load more data.")
	responseJson$errorMessages <- list(error1, error2)
	setStatus(status=506L)

}

setHeader("Access-Control-Allow-Origin" ,"*");
setContentType("application/json")
cat(toJSON(responseJson))




