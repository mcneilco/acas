# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getExperimentFilters
require('RCurl')
require('rjson')
require('racas')

configList <- racas::applicationSettings
postData <- rawToChar(receiveBin())
#postData <- '{"experimentCodes": ["EXPT-00000314", "EXPT-00000002-testingPut-101"]}'
#cat(postData)


postData.list <- fromJSON(postData)
if (length(postData.list$experimentCodes) > 1){
	postData.Json <- toJSON(postData.list$experimentCodes)

} else {
	postData.single <- list()
	postData.single[1] <- postData.list$experimentCodes
	postData.Json <- toJSON(postData.single)
}

experimentFilters <- getURL(
	paste0(configList$client.service.persistence.fullpath, "api/v1/experiments/filters/jsonArray"),
#	paste0("http://localhost:8080/acas/experiments/filters/jsonArray"),
	customrequest='POST',
	httpheader=c('Content-Type'='application/json'),
	postfields=postData.Json)
	
if (length(fromJSON(experimentFilters)) > 0){

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
