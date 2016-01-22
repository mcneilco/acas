# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /ServerAPI/getCmpdAndResultType

library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.ServerAPI.getCmpdAndResultType", logToConsole = FALSE)
myMessenger$logger$debug("getting compounds and result types")

library(plyr)

tryCatch({
  qu <- paste0("SELECT DISTINCT aagr.tested_lot FROM 
            api_analysis_group_results_ld aagr
               JOIN api_experiment_ld e ON e.id = aagr.experiment_id
               WHERE e.code_name = '", GET$experiment, "'")
  testedLotDF <- query(qu)
  names(testedLotDF) <- tolower(names(testedLotDF))
  qu <- paste0("SELECT DISTINCT p.label_text, aagr.ls_kind FROM 
            api_analysis_group_results_ld aagr
            JOIN api_experiment_ld e ON e.id = aagr.experiment_id
            JOIN api_protocol_ld p ON e.protocol_id = p.protocol_id
            WHERE e.code_name = '", GET$experiment, "'")
  lsKindDF <- query(qu)
  names(lsKindDF) <- tolower(names(lsKindDF))
  headerList <- dlply(lsKindDF, .variables = c("label_text", "ls_kind"), .fun = function(x) {list(protocolName=x$label_text, resultType=x$ls_kind)})
  names(headerList) <- NULL
  output <- list(compounds = gsub("([^-]+-[^-]+).*", "\\1", x = testedLotDF$tested_lot), 
                 assays = headerList)
  cat(toJSON(output))
  }, error = function(ex) {
    cat(toJSON(list(error=TRUE, message=ex$message)))
  })
