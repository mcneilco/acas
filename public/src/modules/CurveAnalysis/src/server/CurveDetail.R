# ROUTE: /curve/detail

library(racas)

handler <- function(e) {
  myMessenger$logger$error(e)
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
    commandOutput <- capture.output(response <- racas::api_doseResponse_get_curve_detail(GET))
  } else {
    postData <- rawToChar(receiveBin())
    POST <- jsonlite::fromJSON(postData)
    myMessenger$logger$debug(paste0('updating fit with postData: ', postData))
    commandOutput <- capture.output(response <- switch(POST$action,
        'save' = racas::api_doseResponse_save_session(POST$sessionID, POST$user),
        'pointsChanged' = racas::api_doseResponse_refit(POST),
        'parametersChanged' = racas::api_doseResponse_refit(POST),
        'flagUser' = racas::api_doseResponse_update_user_flag(POST$sessionID,POST$flagUser, POST$user))
    )

  }
  setHeader("Access-Control-Allow-Origin" ,"*")
  setContentType("application/json")
  cat(response)
  DONE
}, error = function(e) {
    handler(e)
})