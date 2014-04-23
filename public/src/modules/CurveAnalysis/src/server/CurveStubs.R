library(racas)

commandOutput <- capture.output(stubs <- racas::api_doseResponse_get_curve_stubs(GET))

setHeader("Access-Control-Allow-Origin" ,"*");
setContentType("application/json")
cat(toJSON(stubs))
DONE