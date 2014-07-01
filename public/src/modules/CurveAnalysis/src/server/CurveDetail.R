library(racas)

handler <- function(e) {
  myMessenger$logger$error('got error')
  myMessenger$logger$error(e$message)
  setHeader("Access-Control-Allow-Origin" ,"*")
  setContentType("text/plain")
  setStatus(500L)
  cat(e$message)
  OK
}

myMessenger <- Messenger$new()
myMessenger$logger <- logger(logName = "com.acas.doseresponse.fit.curve.detail", logToConsole = FALSE)
myMessenger$logger$debug("curve detail initiated")

tryCatch({
  if(!is.null(GET)) {
    myMessenger$logger$debug(paste0('getting curve detail with get json: ', GET))
    commandOutput <- capture.output(detail <- racas::api_doseResponse_get_curve_detail(GET))
  } else {
    postData <- rawToChar(receiveBin())
    if(!is.null(postData)) {
      POST <- jsonlite::fromJSON(postData)
      myMessenger$logger$debug(paste0('updating fit with postData: ', postData))
      if(is.null(POST$approval)) {
        commandOutput <- capture.output(detail <- racas::api_doseResponse.curve(POST))
      } else {
        commandOutput <- capture.output(detail <- racas::api_doseResponse_update_curve_user_approval(POST))
      }
    } else {
        myMessenger$logger$error("no post or get data received")
    }
  }
    myMessenger$logger$debug(paste0("curve detail response: ", detail))


  setHeader("Access-Control-Allow-Origin" ,"*")
  setContentType("application/json")
  cat(detail)
  DONE
}, error = function(e) {
    handler(e)
})