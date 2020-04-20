# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getExperimentalMetadata

library(racas)
library(data.table)
# Sample usage:
# curl "http://localhost:1080/r-services-api/getExperimentalMetadata?startTime=2019-09-05%2020:00:00&endTime=2019-09-05%2021:00:00"
# curl "http://localhost:1080/r-services-api/getExperimentalMetadata?hoursBack=24"

findExperiments <- function(GET) {
  
  startTime = NA
  endTime = NA
  hoursBack = NA
  
  if (("hoursBack" %in% names(GET)) && (!is.na(GET$hoursBack))) {
    hoursBack = as.integer(URLdecode(GET$hoursBack))
  } else {
    if (("startTime" %in% names(GET)) && (!is.na(GET$startTime))) {
      startTime = URLdecode(GET$startTime)
    }
    if (("endTime" %in% names(GET)) && (!is.na(GET$endTime))) {
      endTime = URLdecode(GET$endTime)
    }
  }
  
  queryString = paste0("select e.id, e.code_name as current_experiment, el.label_text as experiment_name, e.recorded_date,e.recorded_by, ev_prev.code_value as previous_experiment, ev_proj.code_value project, ev_scientist.code_value scientist, ev_jira.string_value as jira_id, cro.label_text as cro, ev_status.code_value experiment_status, p.recorded_date as protocol_recorded_date, pl.label_text as protocol_name ",
                       " from protocol p ",
                       " join protocol_label pl on p.deleted = '0' and p.ignored = '0' and p.id = pl.protocol_id and pl.ls_type = 'name' and pl.ls_kind = 'protocol name' and pl.ignored = '0' and pl.deleted = '0' ",
                       " join experiment e on p.id = e.protocol_id and e.deleted = '0' and e.ignored = '0' ",
                       " join experiment_label el on e.id = el.experiment_id and el.ls_type = 'name' and el.ls_kind = 'experiment name' and el.ignored = '0' and el.deleted = '0' ",
                       " left join experiment_state es on es.experiment_id = e.id and es.ls_type = 'metadata' and es.ls_kind = 'experiment metadata' and es.ignored = '0' and es.deleted = '0' ",
                       " left join experiment_value ev_prev on ev_prev.experiment_state_id = es.id and ev_prev.ls_type = 'codeValue' and ev_prev.ls_kind = 'previous experiment code' and ev_prev.ignored = '0' and ev_prev.deleted = '0' ",
                       " left join experiment_value ev_scientist on ev_scientist.experiment_state_id = es.id and ev_scientist.ls_type = 'codeValue' and ev_scientist.ls_kind = 'scientist' and ev_scientist.ignored = '0' and ev_scientist.deleted = '0' ",
                       " left join experiment_value ev_proj on ev_proj.experiment_state_id = es.id and ev_proj.ls_type = 'codeValue' and ev_proj.ls_kind = 'project' and ev_proj.ignored = '0' and ev_proj.deleted = '0' ",
                       " left join experiment_value ev_status on ev_status.experiment_state_id = es.id and ev_status.ls_type = 'codeValue' and ev_status.ls_kind = 'experiment status' and ev_status.ignored = '0' and ev_status.deleted = '0' ",
                       " left join experiment_state cs on cs.experiment_id = e.id and cs.ls_type = 'metadata' and cs.ls_kind = 'custom experiment metadata' and cs.ignored = '0' and cs.deleted = '0' ",
                       " left join experiment_value ev_jira on ev_jira.experiment_state_id = cs.id and ev_jira.ls_type = 'stringValue' and ev_jira.ls_kind = 'JIRA ID' and ev_jira.ignored = '0' and ev_jira.deleted = '0' ",
                       " left join experiment_value ev_cro on ev_cro.experiment_state_id = cs.id and ev_cro.ls_type = 'codeValue' and ev_cro.ls_kind = 'CRO' and ev_cro.ignored = '0' and ev_cro.deleted = '0' ",
                       " left join ddict_value cro on cro.short_name = ev_cro.code_value and cro.ls_type = 'custom experiment metadata' and cro.ls_kind = 'CRO' and cro.ignored = '0' "
  )
  
  if(!is.na(hoursBack)) {
    currentTime <- Sys.time()
    hoursBackTime <- currentTime - (hoursBack * 60 * 60)
    attributes(hoursBackTime)$tzone <- "UTC"
    queryString = paste0(queryString, " where e.recorded_date > '",hoursBackTime,"' ");
  } else {
    if (!is.na(startTime) && !is.na(endTime)) {
      queryString = paste0(queryString, " where e.recorded_date between '",startTime,"' and '",endTime,"'");
    } else if (!is.na(startTime)) {
      queryString = paste0(queryString, " where e.recorded_date > '",startTime,"' ");
    } else if (!is.na(endTime)) {
      queryString = paste0(queryString, " where e.recorded_date < '",endTime,"' ");
    }
  }
  
  results <- as.data.table(query(queryString))
  if(nrow(results) > 0) {
    setnames(results, tolower(names(results)))
    results[ , reload_count := length(previous_experiment[(!is.na(previous_experiment))]), by = id]
    results[ , is_reload := any(!is.na(previous_experiment)), by = id]
    results[ , previous_experiment := NULL]
    results <- unique(results)
    setorder(results, -recorded_date)
  }
  return (jsonlite::toJSON(results, auto_unbox = TRUE))
}

resultList <- findExperiments(GET);

cat(resultList);

DONE 