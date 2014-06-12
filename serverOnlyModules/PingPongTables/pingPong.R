library(racas)

#PINGPONG api_protocol to pp_api_protocol
pingPong(originView = list(schema = "acas", name = "api_protocol"), 
         destinationViewName = list(schema = "acas", name = "pp_api_protocol"),
         primaryKey = "protocol_id"
        )

#PINGPONG api_experiment to pp_api_experiment
pingPong(originView = list(schema = "acas", name = "api_experiment"), 
         destinationViewName = list(schema = "acas", name = "pp_api_experiment"),
         primaryKey = "id",
         indexes = lapply(list("protocol_id"), function(x) list(name = x, tableSpace = NA, options = c()))
         )

#PINGPONG api_analysis_group_results to pp_api_analysis_group_results
pingPong(originView = list(schema = "acas", name = "api_analysis_group_results"), 
         destinationViewName = list(schema = "acas", name = "pp_api_analysis_group_results"),
         primaryKey = "agv_id",
         indexes = lapply(list("tested_lot", "experiment_id"), function(x) list(name = x, tableSpace = NA, options = c()))
         )

