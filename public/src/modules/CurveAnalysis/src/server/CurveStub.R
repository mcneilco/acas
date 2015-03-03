# ROUTE: /curve/stub

library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.doseresponse.fit.curve.stub", logToConsole = FALSE)
myMessenger$logger$debug("curve stub initiated")

handle_response <- function(http_response_code, response) {
      setHeader("Access-Control-Allow-Origin" ,"*")
      setContentType("text/plain")
      setStatus(http_response_code)
      cat(response)
      return_code <- switch(http_response_code,
            HTTP_INTERNAL_SERVER_ERROR = DONE,
            OK)
      return(return_code)
}

update_curve_stub <- function() {
  postData <- rawToChar(receiveBin())
  POST <- jsonlite::fromJSON(postData)
  myMessenger$logger$debug(paste0('updating curve stub with postData: ', postData))
  myMessenger$capture_output(detail <- racas::api_doseResponse_update_flag(POST))

  if(myMessenger$hasErrors()) {
      return(handle_response(HTTP_INTERNAL_SERVER_ERROR, myMessenger$toJSON()))
  }

  setHeader("Access-Control-Allow-Origin" ,"*")
  setContentType("application/json")
  cat(detail)
  DONE
}

update_curve_stub()