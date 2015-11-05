
# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getGeneExperiments
require('RCurl')
require('rjson')
require('data.table')
require('racas')

configList <- racas::applicationSettings


postData <- rawToChar(receiveBin())

#postData <- '{"geneIDs":"1, 2; 15, blah"}'
geneData <- fromJSON(postData)$geneIDs
#split on whitespace (except "-", don't split on that)
geneDataList <- strsplit(geneData, split="[^A-Za-z0-9_-]")[[1]]
geneDataList <- geneDataList[geneDataList!=""]
batchCodeList <- geneDataList

# if (length(geneDataList) > 0) {
# 	requestList <- list()
# 	for (i in 1:length(geneDataList)){
# 	   requestList[[length(requestList)+1]] <- list(requestName=geneDataList[[i]])
# 	}
#
# 	requestObject <- list()
# 	requestObject$requests <- requestList
#
# 	geneNameList <- getURL(
# 		paste0(configList$client.service.persistence.fullpath, "lsthings/getGeneCodeNameFromNameRequest"),
# 		customrequest='POST',
# 		httpheader=c('Content-Type'='application/json'),
# 		postfields=toJSON(requestObject))
#
# 	genes <- fromJSON(geneNameList)$results
#
#   save(genes,requestList,file="geneQuery.Rda")
#
# 	batchCodeList <- list()
# 	for (i in 1:length(genes)){
# 	   if (genes[[i]]$referenceName != ""){
# 	      batchCodeList[[length(batchCodeList)+1]] <- list(batchCode=genes[[i]]$referenceName)
# 	   }
# #Hack to include compound ids
#      else{
#        batchCodeList[[length(batchCodeList)+1]] <- list(batchCode=genes[[i]]$requestName)
#      }
# 	}



if (length(batchCodeList) > 0){
    batchCodes <- list()
    for (i in 1:length(batchCodeList)){
        batchCodes[[length(batchCodes)+1]] <- list(batchCode=batchCodeList[[i]])
    }
    batchCodes.Json <- toJSON(batchCodes)
} else {
    batchCodes.Json <- '[]'
}



experimentNodes <- getURL(
	paste0(configList$client.service.persistence.fullpath, "experiments/jstreenodes/jsonArray"),
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
