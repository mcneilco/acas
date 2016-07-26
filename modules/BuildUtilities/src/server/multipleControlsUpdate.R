# This file exists for migrating clob values from 1.8 to 1.9

library(racas)
library(plyr)

updateClobValue <- function(clobValue) {
  parameters <- fromJSON(clobValue)
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
      parameters$standardCompoundList[[length(parameters$standardCompoundList) + 1]] <- list(
        standardNumber=3, 
        batchCode=parameters$vehicleControl$batchCode, 
        concentration=parameters$vehicleControl$concentration,
        concentrationUnits=parameters$vehicleControl$concentrationUnits,
        standardType="VC")
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
    
    ruleList <- parameters$transformationRuleList
    if (length(ruleList) > 0) {
      if (length(ruleList) == 1 && !(is.null(names(ruleList))) && !(is.na(names(ruleList))) && names(ruleList) == "transformationRule") {
        # Some migrated experiments had a malformed list, so we fix that here
        if (parameters$transformationRuleList$transformationRule == "percent efficacy") {
          parameters$transformationRuleList <- list(list(
            transformationRule = "percent efficacy",
            transformationParameters = list(
              positiveControl = list(standardNumber="1", defaultValue=""),
              negativeControl = list(standardNumber="2", defaultValue="")
            )
          ))
        } else if (parameters$transformationRuleList$transformationRule == "sd") {
          parameters$transformationRuleList <- list(list(
            transformationRule = "sd",
            transformationParameters = list(
              negativeControl = list(standardNumber="2", defaultValue="")
            )
          ))
        }
      }
      for (i in 1:length(parameters$transformationRuleList)) {
        if (parameters$transformationRuleList[[i]]$transformationRule == "percent efficacy") {
          parameters$transformationRuleList[[i]] <- list(
            transformationRule = "percent efficacy",
            transformationParameters = list(
              positiveControl = list(standardNumber="1", defaultValue=""),
              negativeControl = list(standardNumber="2", defaultValue="")
            )
          )
        } else if (parameters$transformationRuleList[[i]]$transformationRule == "sd") {
          parameters$transformationRuleList[[i]] <- list(
            transformationRule = "sd",
            transformationParameters = list(
              negativeControl = list(standardNumber="2", defaultValue="")
            )
          )
        }
      }
    }
  }
  return(toJSON(parameters))
}

clobResults <- query("select ev.clob_value, es.experiment_id from experiment_value ev
  join experiment_state es on ev.experiment_state_id = es.id
        where ev.ls_kind = 'data analysis parameters'
        and es.ls_kind = 'experiment metadata'
        and ev.ignored = '0'
        and es.ignored = '0' ")
names(clobResults) <- tolower(names(clobResults))
save(clobResults, file=tempfile("backupExperimentClob", "~", ".Rda"))
d_ply(clobResults, "experiment_id", function(x) {
  # Example in experiment id experiment_id = 67449320
  clobValue <- updateClobValue(x$clob_value)
  updateValueByTypeAndKind(clobValue, "experiment", x$experiment_id, "metadata", 
                           "experiment metadata", "clobValue", "data analysis parameters")
})

# Protocols
clobResults <- query("select pv.clob_value, ps.protocol_id from protocol_value pv
                     join protocol_state ps on pv.protocol_state_id = ps.id
                     where pv.ls_kind = 'data analysis parameters'
                     and ps.ls_kind = 'experiment metadata'
                     and pv.ignored = '0'
                     and ps.ignored = '0' ")
names(clobResults) <- tolower(names(clobResults))
save(clobResults, file=tempfile("backupProtocolClob", "~", ".Rda"))
d_ply(clobResults, "protocol_id", function(x) {
  clobValue <- updateClobValue(x$clob_value)
  updateValueByTypeAndKind(clobValue, "protocol", x$protocol_id, "metadata", 
                           "experiment metadata", "clobValue", "data analysis parameters")
})

