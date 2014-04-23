library(racas)

if(!is.null(GET)) {
    commandOutput <- capture.output(detail <- racas::api_doseResponse_get_curve_detail(GET))
} else {
    postData <- rawToChar(receiveBin())
    if(!is.null(postData)) {
        commandOutput <- capture.output(detail <- racas::api_doseResponse_fit_curve(postData))
    }
}

setHeader("Access-Control-Allow-Origin" ,"*");
setContentType("application/json")
cat(detail)
DONE