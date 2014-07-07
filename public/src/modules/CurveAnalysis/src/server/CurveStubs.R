# ROUTE: /experimentcode/curveids

library(racas)

handler <- function(e) {
  myMessenger$logger$error('got error')
  setHeader("Access-Control-Allow-Origin" ,"*")
  setContentType("text/plain")
  setStatus(500L)
  cat(e$message)
  OK
}
tryCatch({
  myMessenger <- Messenger$new()
  myMessenger$logger <- logger(logName = "com.acas.doseresponse.fit.curve.detail", logToConsole = FALSE)
  myMessenger$logger$info(paste0("curve stubs initiated with: ", GET))
  myMessenger$captureOutput("commandOutput <- capture.output(stubs <- racas::api_doseResponse_get_curve_stubs(GET))", userError = paste0("There was an error retrieving curves for '", GET, "'"))
  if(myMessenger$hasErrors()) {
    myMessenger$logger$error(paste0("got errors in response: ", myMessenger$toJSON()))
    stubs <- myMessenger$userErrors
  } else {
    myMessenger$logger$debug(paste0("api_doseResponse_get_curve_stubs response: ", toJSON(stubs)))
  }
  setHeader("Access-Control-Allow-Origin" ,"*");
  setContentType("application/json")
  cat(toJSON(stubs))
  DONE
}, error = function(e) {
  handler(e)
})