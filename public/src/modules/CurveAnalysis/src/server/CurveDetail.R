library(racas)

if(!is.null(GET)) {
    commandOutput <- capture.output(detail <- racas::api_doseResponse_get_curve_detail(GET))
} else {
    postData <- rawToChar(receiveBin())
    if(!is.null(postData)) {
        POST <- jsonlite::fromJSON(postData)
        if(is.null(POST$approval)) {
            commandOutput <- capture.output(detail <- racas::api_doseResponse_fit_curve(POST))
        } else {
             commandOutput <- capture.output(detail <- racas::api_doseResponse_update_curve_user_approval(POST))
        }
    }
}

setHeader("Access-Control-Allow-Origin" ,"*");
setContentType("application/json")
cat(detail)
DONE