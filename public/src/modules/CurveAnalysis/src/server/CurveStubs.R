library(racas)

commandOutput <- capture.output(stubs <- racas::api_doseResponse_stubs(GET))

setHeader("Access-Control-Allow-Origin" ,"*");
setContentType("application/json")
cat(toJSON(stubs))
DONE