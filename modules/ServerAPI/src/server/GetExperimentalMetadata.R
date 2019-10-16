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
    if (!is.na(GET$startTime)) {
      startTime = URLdecode(GET$startTime)
    }
    if (("endTime" %in% names(GET)) && (!is.na(GET$endTime))) {
      endTime = URLdecode(GET$endTime)
    }
  }
  
  queryString = paste0("select e.id, e.code_name as current_experiment, el.label_text as experiment_name, e.recorded_date, ev_prev.code_value as previous_experiment, ev_proj.code_value project, pl.label_text as protocol_name ",
                       " from protocol p ",
                       " join protocol_label pl on p.deleted = '0' and p.ignored = '0' and p.id = pl.protocol_id and pl.ls_type = 'name' and pl.ls_kind = 'protocol name' and pl.ignored = '0' and pl.deleted = '0' ",
                       " join experiment e on p.id = e.protocol_id and e.deleted = '0' and e.ignored = '0' ",
                       " join experiment_label el on e.id = el.experiment_id and el.ls_type = 'name' and el.ls_kind = 'experiment name' and el.ignored = '0' and el.deleted = '0' ",
                       " left join experiment_state es on es.experiment_id = e.id and es.ls_type = 'metadata' and es.ls_kind = 'experiment metadata' and es.ignored = '0' and es.deleted = '0' ",
                       " left join experiment_value ev_prev on ev_prev.experiment_state_id = es.id and ev_prev.ls_type = 'codeValue' and ev_prev.ls_kind = 'previous experiment code' and ev_prev.ignored = '0' and ev_prev.deleted = '0' ",
                       " left join experiment_value ev_proj on ev_proj.experiment_state_id = es.id and ev_proj.ls_type = 'codeValue' and ev_proj.ls_kind = 'project' and ev_proj.ignored = '0' and ev_proj.deleted = '0' "
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