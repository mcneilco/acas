
require('RCurl')
require('rjson')

postData <- rawToChar(receiveBin(1024))

#postData <- '[{"code":"EXPT-00000314"}, {"code":"EXPT-00000002-testingPut-101"}]'
#postData <- '["EXPT-00000314", "EXPT-00000002-testingPut-101"]'

experimentFilters <- getURL(
	paste0("http://localhost:8080/acas/experiments/filters/jsonArray"),
	customrequest='POST',
	httpheader=c('Content-Type'='application/json'),
	postfields=postData)

if (length(fromJSON(experimentFilters)) > 1){

	responseJson <- list()
	responseJson$results$experimentFilters <- fromJSON(experimentFilters)
	responseJson$results$htmlSummary <- "OK"
	responseJson$hasError <- FALSE
	responseJson$hasWarning <- FALSE
	responseJson$errorMessages <- list()
	setStatus(status=200L)

} else {

	responseJson <- list()
	responseJson$results$experimentFilters <- list()
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




