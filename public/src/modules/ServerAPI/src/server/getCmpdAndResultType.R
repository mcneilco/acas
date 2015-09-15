# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /ServerAPI/getCmpdAndResultType

library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.ServerAPI.getCmpdAndResultType", logToConsole = FALSE)
myMessenger$logger$debug("getting compounds and result types")

tryCatch({
  qu <- paste0("SELECT DISTINCT aagr.tested_lot FROM 
            api_analysis_group_results aagr
               JOIN api_experiment e ON e.id = aagr.experiment_id
               WHERE e.code_name = '", GET$experiment, "'")
  testedLotDF <- query(qu)
  names(testedLotDF) <- tolower(names(testedLotDF))
  qu <- paste0("SELECT DISTINCT p.label_text, aagr.ls_kind FROM 
            api_analysis_group_results aagr
            JOIN api_experiment e ON e.id = aagr.experiment_id
            JOIN api_protocol p ON e.protocol_id = p.protocol_id
            WHERE e.code_name = '", GET$experiment, "'")
  lsKindDF <- query(qu)
  names(lsKindDF) <- tolower(names(lsKindDF))
  output <- list(compounds = testedLotDF$tested_lot, 
                 assays = list(list(protocolName=unique(lsKindDF$label_text), 
                                    resultType=unique(lsKindDF$ls_kind))))
  cat(toJSON(output))
  }, error = function(ex) {cat(toJSON(list(error=TRUE, message=ex$message)))})
