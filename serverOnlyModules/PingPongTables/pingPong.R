library(racas)

#PINGPONG api_protocol to pp_api_protocol
apiProtocolSuccess <- tryCatch({
  apiProtocolUpdated <- pingPong(originView = list(schema = "acas", name = "api_protocol"), 
                                 destinationViewName = list(schema = "acas", name = "pp_api_protocol"),
                                 primaryKey = "protocol_id")
}, error = function(e){
  FALSE
  stop(e)
})
if(apiProtocolSuccess) {
  cat("api_protocol ping pong successful\n")
}

#PINGPONG api_experiment to pp_api_experiment
apiExperimentSuccess <- tryCatch({
  apiExperimentUpdated <- pingPong(originView = list(schema = "acas", name = "api_experiment"), 
                                   destinationViewName = list(schema = "acas", name = "pp_api_experiment"),
                                   primaryKey = "id",
                                   indexes = lapply(list("protocol_id"), function(x) list(name = x, tableSpace = NA, options = c()))
  )
}, error = function(e){
  FALSE
  stop(e)
})
if(apiExperimentSuccess) {
  cat("api_experiment ping pong successful\n")
}


#PINGPONG api_analysis_group_results to pp_api_analysis_group_results
apiAnalysisResultsSuccess <- tryCatch({
  apiAnalysisResultsUpdated <- pingPong(originView = list(schema = "acas", name = "api_analysis_group_results"), 
                                        destinationViewName = list(schema = "acas", name = "pp_api_analysis_group_results"),
                                        primaryKey = "agv_id",
                                        indexes = lapply(list("tested_lot", "experiment_id"), function(x) list(name = x, tableSpace = NA, options = c()))
  )
}, error = function(e){
  FALSE
  stop(e)
})
if(apiAnalysisResultsSuccess) {
  cat("api_analysis_group_results ping pong successful\n")
}


