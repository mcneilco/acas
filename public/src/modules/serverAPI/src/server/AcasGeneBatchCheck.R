#exampleInput <- "{\"requests\":[{\"requestName\":\"CRA-025995-1\"},{\"requestName\":\"CMPD-0000052-01\"}]}"

acasGeneCodeCheck <- function(input) {
  require('RCurl')
  require('rjson')
  json <- toJSON(input)

  tryCatch({
	response <- fromJSON(getURL(
	  "localhost:8080/acas/lsthings/getGeneCodeNameFromNameRequest",
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=json))
  }, error = function(e) {
    stop(paste0("The project service did not respond correctly, contact your system administrator. ", json))
  })

    return(response)
}

#exampleOutput <- "{\n  \"error\": false,\n  \"errorMessages\": [],\n  \"results\": [\n    {\n      \"requestName\": \"CMPD-0000051-01\",\n      \"preferredName\": \"CMPD-0000051-01\"\n    },\n    {\n      \"requestName\": \"CMPD-0000052-01\",\n      \"preferredName\": \"CMPD-0000052-01\"\n    }\n  ]\n}"