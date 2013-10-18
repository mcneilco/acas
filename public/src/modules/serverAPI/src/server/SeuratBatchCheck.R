#exampleInput <- "{\"requests\":[{\"requestName\":\"CRA-025995-1\"},{\"requestName\":\"CMPD-0000052-01\"}]}"

seuratBatchCodeCheck <- function(input) {
	require(racas)
#	batchCodeList <- fromJSON(input)
	batchCodeList <- input

	batchCodes <- vapply(batchCodeList$requests, getElement, c(""), "requestName")

	goodBatchCodes <- query(paste0("select c.corporate_id || '-' || l.lot_id from syn_compound c
	join syn_compound_lot l on c.compound_id=l.compound_id
	where c.corporate_id || '-' || l.lot_id in (", sqliz(batchCodes),")"))[[1]]

	results <- lapply(batchCodes, function(x) list(requestName=x, preferredName=ifelse(x %in% goodBatchCodes, x, "")))

	return(list(
		error = FALSE,
		errorMessages = list(),
		results = results
	))
}

#exampleOutput <- "{\n  \"error\": false,\n  \"errorMessages\": [],\n  \"results\": [\n    {\n      \"requestName\": \"CMPD-0000051-01\",\n      \"preferredName\": \"CMPD-0000051-01\"\n    },\n    {\n      \"requestName\": \"CMPD-0000052-01\",\n      \"preferredName\": \"CMPD-0000052-01\"\n    }\n  ]\n}"