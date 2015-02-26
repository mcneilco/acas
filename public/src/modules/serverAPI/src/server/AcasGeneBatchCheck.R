#exampleInput <- "{\"requests\":[{\"requestName\":\"CRA-025995-1\"},{\"requestName\":\"CMPD-0000052-01\"}]}"

acasGeneCodeCheck <- function(input) {
  require('RCurl')
  require('rjson')
  require('racas')

  json <- toJSON(input)

  configList <- racas::applicationSettings
# "localhost:8080/acas/lsthings/getGeneCodeNameFromNameRequest",

  tryCatch({
	response <- fromJSON(getURL(
	  paste0(configList$client.service.persistence.fullpath, "api/v1/lsthings/getGeneCodeNameFromNameRequest"),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=json))
  }, error = function(e) {
    stop(paste0("The Gene codeName service did not respond correctly, contact your system administrator. ", json))
  })

    return(response)
}

