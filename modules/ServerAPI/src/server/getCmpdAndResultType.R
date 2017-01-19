# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /ServerAPI/getCmpdAndResultType

library(racas)

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.ServerAPI.getCmpdAndResultType", logToConsole = FALSE)
myMessenger$logger$debug("getting compounds and result types")

library(plyr)

tryCatch({
  qu <- paste0("SELECT DISTINCT parent.corp_name AS parent_corp_name FROM 
            api_analysis_group_results aagr
               JOIN api_experiment e ON e.id = aagr.experiment_id
               JOIN compound.lot ON aagr.tested_lot = lot.corp_name
               JOIN compound.salt_form ON lot.salt_form = salt_form.id
               JOIN compound.parent ON parent.id = salt_form.parent
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
  qu <- paste0("SELECT e.project FROM
  				api_experiment e
            	WHERE e.code_name = '", GET$experiment, "'")
  projectDF <- query(qu)
  names(projectDF) <- tolower(names(projectDF))
  headerList <- dlply(lsKindDF, .variables = c("label_text", "ls_kind"), .fun = function(x) {list(protocolName=x$label_text, resultType=x$ls_kind)})
  names(headerList) <- NULL
  output <- list(compounds = testedLotDF$parent_corp_name, 
                 assays = headerList,
                 project = projectDF$project[1])
  cat(toJSON(output))
  }, error = function(ex) {
    cat(toJSON(list(error=TRUE, message=ex$message)))
  })
