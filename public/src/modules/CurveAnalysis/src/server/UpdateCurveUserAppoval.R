library(racas)

tryCatch({
    commandOutput <- capture.output(userFlag <- racas::api_doseResponse_update_curve_user_approval(GET))
    setHeader("Access-Control-Allow-Origin" ,"*");
    setContentType("application/json")
    cat(toJSON(userFlag))
    DONE
}, error = function(e) {
  setContentType("application/json")
  setStatus(500L)
  cat("call failed")
  DONE
})