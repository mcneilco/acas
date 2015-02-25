library(racas)

pingPong <- function(tables = c("api_protocol", "api_experiment", "api_analysis_group_results", "api_curve_params", "api_dose_response"), tableSpace = NA, intermediateTableSpaceOptions = c(), indexOptions = c()) {
  args <- match.arg(tables, several.ok = TRUE)
  formal.args <- formals(sys.function(sys.parent()))
  choices <- eval(formal.args$tables)
  if(length(args) == 0) {
    shouldCreate <- as.list(rep(TRUE, length(choices)))
    names(shouldCreate) <- choices
  } else {
    shouldCreate <- as.list(choices %in% args)
    names(shouldCreate) <- choices
  }

  if(shouldCreate$api_protocol) {
    #PINGPONG api_protocol to pp_api_protocol
    apiProtocolSuccess <- tryCatch({
      apiProtocolUpdated <- racas::pingPong(originView = list(schema = "acas", name = "api_protocol"),
                                     destinationViewName = list(schema = "acas", name = "pp_api_protocol"),
                                     intermediateTablePrefix = list(schema = racas::applicationSettings$server.database.username, 
                                                                    name = "api_protocol",
                                                                    tableSpace = tableSpace, options = intermediateTableSpaceOptions),
                                     primaryKey = "protocol_id")
      
    }, error = function(e){
      FALSE
      stop(e)
    })
    if(apiProtocolSuccess) {
      cat("api_protocol ping pong successful\n")
    }
  }
  
  if(shouldCreate$api_experiment) {
    #PINGPONG api_experiment to pp_api_experiment
    apiExperimentSuccess <- tryCatch({
      apiExperimentUpdated <- racas::pingPong(originView = list(schema = "acas", name = "api_experiment"), 
                                       destinationViewName = list(schema = "acas", name = "pp_api_experiment"),
                                       intermediateTablePrefix = list(schema = racas::applicationSettings$server.database.username, 
                                                                      name = "api_experiment",
                                                                      tableSpace = tableSpace, options = intermediateTableSpaceOptions),
                                       primaryKey = "id",
                                       indexes = lapply(list("protocol_id"), function(x) list(name = x, tableSpace = tableSpace, options = indexOptions))
      )
    }, error = function(e){
      FALSE
      stop(e)
    })
    if(apiExperimentSuccess) {
      cat("api_experiment ping pong successful\n")
    }
  }
  
  if(shouldCreate$api_analysis_group_results) {
    #PINGPONG api_analysis_group_results to pp_api_analysis_group_results
    apiAnalysisResultsSuccess <- tryCatch({
      apiAnalysisResultsUpdated <- racas::pingPong(originView = list(schema = "acas", name = "api_analysis_group_results"), 
                                            destinationViewName = list(schema = "acas", name = "pp_api_analysis_group_results"),
                                            intermediateTablePrefix = list(schema = racas::applicationSettings$server.database.username, 
                                                                           name = "api_analysis_group_results",
                                                                           tableSpace = tableSpace, options = intermediateTableSpaceOptions),
                                            primaryKey = "agv_id",
                                            indexes = lapply(list("tested_lot", "experiment_id"), function(x) list(name = x, tableSpace = tableSpace, options = indexOptions))
      )
    }, error = function(e){
      FALSE
      stop(e)
    })
    if(apiAnalysisResultsSuccess) {
      cat("api_analysis_group_results ping pong successful\n")
    }
  }

  if(shouldCreate$api_curve_params) {
    #PINGPONG api_curve_params to pp_api_curve_params
    apiAnalysisResultsSuccess <- tryCatch({
      apiAnalysisResultsUpdated <- racas::pingPong(originView = list(schema = "acas", name = "api_curve_params"),
                                            destinationViewName = list(schema = "acas", name = "pp_api_curve_params"),
                                            intermediateTablePrefix = list(schema = racas::applicationSettings$server.database.username, 
                                                                           name = "api_curve_params",
                                                                           tableSpace = tableSpace, options = intermediateTableSpaceOptions),
                                            primaryKey = "valueId",
                                            indexes = lapply(list("curveId"), function(x) list(name = x, tableSpace = tableSpace, options = indexOptions))
      )
    }, error = function(e){
      FALSE
      stop(e)
    })
    if(apiAnalysisResultsSuccess) {
      cat("api_curve_params ping pong successful\n")
    }
  }
  
  if(shouldCreate$api_dose_response) {
    #PINGPONG api_dose_response to pp_api_dose_response
    apiAnalysisResultsSuccess <- tryCatch({
      apiAnalysisResultsUpdated <- racas::pingPong(originView = list(schema = "acas", name = "api_dose_response"),
                                            destinationViewName = list(schema = "acas", name = "pp_api_dose_response"),
                                            intermediateTablePrefix = list(schema = racas::applicationSettings$server.database.username, 
                                                                           name = "api_dose_response",
                                                                           tableSpace = tableSpace, options = intermediateTableSpaceOptions),
                                            primaryKey = "responseSubjectValueId",
                                            indexes = lapply(list("curveId"), function(x) list(name = x, tableSpace = tableSpace, options = indexOptions))
      )
    }, error = function(e){
      FALSE
      stop(e)
    })
    if(apiAnalysisResultsSuccess) {
      cat("api_dose_response ping pong successful\n")
    }
  }
}
commandArgs <- commandArgs(trailingOnly = TRUE)
args <- racas::parse_command_line_args(commandArgs)
do.call(pingPong,c(args))
