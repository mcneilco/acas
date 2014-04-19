library(racas)

commandOutput <- capture.output(detail <- racas::api_doseResponse_detail(GET))

setHeader("Access-Control-Allow-Origin" ,"*");
setContentType("application/json")
cat(detail)
DONE