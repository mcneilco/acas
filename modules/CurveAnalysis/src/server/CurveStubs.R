# ROUTE: /experimentcode/curveids

library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.doseresponse.fit.curve.stubs", logToConsole = FALSE)
myMessenger$logger$debug("curve stubs initiated")

handle_response <- function(http_response_code, response) {
      setHeader("Access-Control-Allow-Origin" ,"*")
      setContentType("text/plain")
      setStatus(http_response_code)
      cat(response)
      return_code <- switch(http_response_code,
            HTTP_INTERNAL_SERVER_ERROR = DONE,
            HTTP_BAD_REQUEST = HTTP_BAD_REQUEST,
            HTTP_NOT_FOUND = OK,
            OK)
      return(return_code)
}

get_curve_stubs <- function(myMessenger, GET) {
  myMessenger$logger$info(paste0("curve stubs initiated with: ", GET))
  myMessenger$capture_output("stubs <- racas::api_doseResponse_get_curve_stubs(GET)", userError = paste0("There was an error retrieving curves for '", GET, "'"))
  if(myMessenger$hasErrors()) {
    if(myMessenger$errors[[1]]$message == "no experiment results found") {
      return(handle_response(HTTP_NOT_FOUND , "no experiment results found"))
    } else if (myMessenger$errors[[1]]$message == "experiment not fit") {
      return(handle_response(HTTP_BAD_REQUEST, "Experiment has not been fit"))
    } else if (myMessenger$errors[[1]]$message == "experiment has been deleted") {
      return(handle_response(HTTP_BAD_REQUEST, "Experiment has been deleted"))
    } else {
      myMessenger$logger$error(paste0("unknown r error: ", myMessenger$toJSON()))
      return(handle_response(HTTP_INTERNAL_SERVER_ERROR, myMessenger$toJSON()))
    }
  } else {
    myMessenger$logger$debug(paste0("api_doseResponse_get_curve_stubs response: ", toJSON(stubs)))
    setHeader("Access-Control-Allow-Origin" ,"*");
    setContentType("application/json")
    cat(toJSON(stubs))
    return(DONE)
  }
}

get_curve_stubs(myMessenger, GET)
