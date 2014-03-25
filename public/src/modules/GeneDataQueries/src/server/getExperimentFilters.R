
require('RCurl')
require('rjson')
require('racas')

configList <- racas::applicationSettings
postData <- rawToChar(receiveBin(1024))
#postData <- '{"experimentCodes": ["EXPT-00000314", "EXPT-00000002-testingPut-101"]}'
#cat(postData)


postData.list <- fromJSON(postData)
postData.Json <- toJSON(postData.list$experimentCodes)

experimentFilters <- getURL(
	paste0(configList$client.service.persistence.fullpath, "experiments/filters/jsonArray"),
#	paste0("http://localhost:8080/acas/experiments/filters/jsonArray"),
	customrequest='POST',
	httpheader=c('Content-Type'='application/json'),
	postfields=postData.Json)
	
if (length(fromJSON(experimentFilters)) > 1){

	responseJson <- list()
	responseJson$results$experiments <- fromJSON(experimentFilters)
	responseJson$results$htmlSummary <- "OK"
	responseJson$hasError <- FALSE
	responseJson$hasWarning <- FALSE
	responseJson$errorMessages <- list()
	setStatus(status=200L)

} else {

	responseJson <- list()
	responseJson$results$experiments <- list()
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
