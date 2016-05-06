library(racas)
library(plyr)
clobResults <- query("select ev.clob_value, es.experiment_id from experiment_value ev
  join experiment_state es on ev.experiment_state_id = es.id
        where ev.ls_kind = 'data analysis parameters'
        and es.ls_kind = 'experiment metadata'
        and ev.ignored = '0'
        and es.ignored = '0' ")
names(clobResults) <- tolower(clobResults)

d_ply(clobResults, "experiment_id", function(x) {
  # Example in experiment id experiment_id = 67449320
  parameters <- fromJSON(x$clobValue)
  if (is.null(parameters$standardCompoundList)) {
    parameters$standardCompoundList <- list(
      list(standardNumber=1, 
           batchCode=parameters$positiveControl$batchCode, 
           concentration=parameters$positiveControl$concentration,
           concentrationUnits=parameters$positiveControl$concentrationUnits,
           standardType="PC"),
      list(standardNumber=2, 
           batchCode=parameters$negativeControl$batchCode, 
           concentration=parameters$negativeControl$concentration,
           concentrationUnits=parameters$negativeControl$concentrationUnits,
           standardType="NC"))
    if (!is.null(parameters$vehicleControl$batchCode)) {
      parameters$standardCompoundList <- append(
        parameters$standardCompoundList,
        list(standardNumber=3, 
             batchCode=parameters$vehicleControl$batchCode, 
             concentration=parameters$vehicleControl$concentration,
             concentrationUnits=parameters$vehicleControl$concentrationUnits,
             standardType="PC"))
    }
    parameters$positiveControl <- NULL
    parameters$negativeControl <- NULL
    parameters$vehicleControl <- NULL
    parameters$agonistControl <- NULL # Agonist control is totally removed
    
    # normalization
    parameters$normalization <- list(
      normalizationRule=parameters$normalizationRule, 
      positiveControl=list(standardNumber="1", defaultValue=""),
      negativeControl=list(standardNumber="2", defaultValue=""))
    parameters$normalizationRule <- NULL
    
    for (i in 1:length(parameters$transformationRuleList)) {
      if (parameters$transformationRuleList[[i]]$transformationRule == "percent efficacy") {
        parameters$transformationRuleList[[i]]$positiveControl <- list(standardNumber="1", defaultValue="")
        parameters$transformationRuleList[[i]]$negativeControl <- list(standardNumber="2", defaultValue="")
      } else if (parameters$transformationRuleList[[i]]$transformationRule == "sd") {
        parameters$transformationRuleList[[i]]$negativeControl <- list(standardNumber="2", defaultValue="")
      }
    }
    updateValueByTypeAndKind(toJSON(parameters), "experiment", x$experiment_id, "metadata", 
                             "experiment metadata", "clobValue", "data analysis parameters")
  }
})

